TARGET=Gesture_Final

CROSS_COMPILE=arm-linux-gnueabihf-
CFLAGS=-static -g -Wall -l $(SOCEDS_DEST_ROOT)/ip/altera/hps/altera_hps/hwlib/include
LDFLAGS=-g -Wall
CC=$(CROSS_COMPILE)gcc-4.9
ARCH=arm

build:$(TARGET)

$(TARGET): final.o
		$(CC) $(LDFLAGS) $^ -o $@ -lm

%.o: %.c
		$(CC) $(CFLAGS) -c $< -o $@

.PHONY: clean
clean:
		rm -f $(TARGET) *.a *.o *~