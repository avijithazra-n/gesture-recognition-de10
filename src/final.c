#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <stdint.h>
#include <sys/ioctl.h>
#include <math.h>
#include <linux/i2c-dev.h>

#define FPGA_AXI_BASE   0xC0000000
#define BRIDGE_SPAN     0x00001000
#define _USE_MATH_DEFINES

#define ADXL345_I2C_ADDR    0x53
#define I2C_BUS             "/dev/i2c-0"

#define ACCEL_X_OFFSET 0x10
#define ACCEL_Y_OFFSET 0x20
#define ACCEL_Z_OFFSET 0x30
#define ACCEL_pitch_OFFSET 0x40

int main() {
    int mem_fd, i2c_fd;
    void *virtual_base;

    volatile int32_t *h2p_x_addr;
    volatile int32_t *h2p_y_addr;
    volatile int32_t *h2p_z_addr;
    volatile int32_t *h2p_pitch_addr;
    
    // 1. OPEN FPGA BRIDGE
    mem_fd = open("/dev/mem", (O_RDWR | O_SYNC));
    if (mem_fd == -1) {
        perror("ERROR: could not open /dev/mem");
        return 1;
    }

    // Map the bridge
    virtual_base = mmap(NULL, BRIDGE_SPAN, (PROT_READ | PROT_WRITE), MAP_SHARED, mem_fd, FPGA_AXI_BASE);
    if (virtual_base == MAP_FAILED) {
        perror("ERROR: mmap failed");
        close(mem_fd);
        return 1;
    }

    // Assign pointers to the virtual addresses of your PIOs
    h2p_x_addr = (int32_t *)(virtual_base + ACCEL_X_OFFSET);
    h2p_y_addr = (int32_t *)(virtual_base + ACCEL_Y_OFFSET);
    h2p_z_addr = (int32_t *)(virtual_base + ACCEL_Z_OFFSET);
    h2p_pitch_addr = (int32_t *)(virtual_base + ACCEL_pitch_OFFSET);

    // 2. OPEN I2C BUS
    i2c_fd = open(I2C_BUS, O_RDWR);
    if (i2c_fd < 0) {
        perror("ERROR: could not open I2C bus");
        return 1;
    }

    if (ioctl(i2c_fd, I2C_SLAVE, ADXL345_I2C_ADDR) < 0) {
        perror("ERROR: could not set I2C slave address");
        return 1;
    }

    // Wake up ADXL345: Write 0x08 to Power Control Register (0x2D)
    uint8_t config[] = {0x2D, 0x08};
    if (write(i2c_fd, config, 2) != 2) {
        perror("Failed to wake up sensor");
        return 1;
    }

    while (1) {
        uint8_t reg = 0x32; // Start of data registers (X0, X1, Y0, Y1, Z0, Z1)
        uint8_t data[6];

        if (write(i2c_fd, &reg, 1) != 1) {
            printf("\rError: Failed to write register address!    ");
            fflush(stdout);
        }else {
            // Read 6 bytes of data
            ssize_t num_read = read(i2c_fd, data, 6);
            if (num_read == 6) {
                // Combine MSB and LSB

                int16_t x = (int16_t)((data[1] << 8) | data[0]);
                int16_t y = (int16_t)((data[3] << 8) | data[2]);
                int16_t z = (int16_t)((data[5] << 8) | data[4]);

                //Pitch angle
                //float pitch_float = atan2(x, sqrt(y * y + z * z)) * 180.0 / M_PI;
                float pitch_float = atan2(x, z) * 180.0 / M_PI;

                // 3. SEND DATA TO FPGA PIO REGISTERS

                *h2p_x_addr     = (int32_t)x;
                *h2p_y_addr     = (int32_t)y;
                *h2p_z_addr     = (int32_t)z;
                *h2p_pitch_addr = (int16_t)pitch_float;

                // Optional: Print to UART for debugging
                printf("\rX: %5d | Y: %5d | Z: %5d | pitch: %5d", x, y, z, (int16_t)pitch_float);
                fflush(stdout);
            }else {
                printf("\rI2C Read Failed! Result: %ld    ", num_read);
                fflush(stdout);
            }
        }
        usleep(50000); // 20Hz update rate
    }

    // Clean up
    munmap(virtual_base, BRIDGE_SPAN);
    close(mem_fd);
    close(i2c_fd);
    return 0;
}