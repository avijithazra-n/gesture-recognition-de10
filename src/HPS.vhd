LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity HPS is 
	port(
		CLOCK_50 			: in		std_logic;
		KEY					: in 		std_logic_vector(3 downto 0);
		LEDR					: out 	std_logic_vector(9 downto 0);
		HEX0					: out		std_logic_vector(6 downto 0);
		HEX1					: out		std_logic_vector(6 downto 0);
		HEX2					: out		std_logic_vector(6 downto 0);
		HEX3					: out		std_logic_vector(6 downto 0);
		HEX4					: out		std_logic_vector(6 downto 0);
		HEX5					: out		std_logic_vector(6 downto 0);
		
		HPS_DDR3_ADDR   	: out   	std_logic_vector(14 downto 0);
		HPS_DDR3_BA     	: out   	std_logic_vector(2 downto 0);
		HPS_DDR3_CAS_N  	: out   	std_logic;
		HPS_DDR3_CKE    	: out   	std_logic;
		HPS_DDR3_CK_N   	: out   	std_logic;
		HPS_DDR3_CK_P   	: out   	std_logic;
		HPS_DDR3_CS_N   	: out   	std_logic;
		HPS_DDR3_DM     	: out   	std_logic_vector(3 downto 0);
		HPS_DDR3_DQ     	: inout 	std_logic_vector(31 downto 0);
		HPS_DDR3_DQS_N  	: inout 	std_logic_vector(3 downto 0);
		HPS_DDR3_DQS_P  	: inout 	std_logic_vector(3 downto 0);
		HPS_DDR3_ODT    	: out   	std_logic;
		HPS_DDR3_RAS_N  	: out   	std_logic;
		HPS_DDR3_RESET_N	: out   	std_logic;
		HPS_DDR3_WE_N   	: out   	std_logic;
		HPS_DDR3_RZQ    	: in    	std_logic
	);
end HPS;

architecture HPS_arch of HPS is	
	signal reset		: 	std_logic;
	signal pitch		: 	std_logic_vector(15 downto 0);
	signal accel_x		:	std_logic_vector(15 downto 0);
	signal accel_y		:	std_logic_vector(15 downto 0);
	signal accel_z		:	std_logic_vector(15 downto 0);
	signal hex_dir		: 	std_logic_vector(6 downto 0);
	signal hex_pit		: 	std_logic_vector(20 downto 0);
	signal hex_rol		: 	std_logic_vector(20 downto 0);

	type arr is array (0 to 7) of signed(15 downto 0);
   signal x_all 		: 	arr := (others => (others => '0'));
	signal y_all 		: 	arr := (others => (others => '0'));
	signal z_all 		: 	arr := (others => (others => '0'));
	
	signal sum_x 		: 	signed(18 downto 0) := (others => '0');
	signal sum_y 		: 	signed(18 downto 0) := (others => '0');
	signal sum_z 		: 	signed(18 downto 0) := (others => '0');
	signal avg_x 		: 	signed(15 downto 0) := (others => '0');
	signal avg_y 		: 	signed(15 downto 0) := (others => '0');
	signal avg_z 		: 	signed(15 downto 0) := (others => '0');
	signal cnt_clk		: 	integer RANGE 0 to 2500000 :=0;
	
	signal status		:	string(1 to 2);

	component seg_7 is 
		port(
		clk			: in	std_logic;
		status	 	: in	string(1 to 2);
		hex			: out	std_logic_vector(6 downto 0)
	);
	end component;
	
	component seg_7_ang is 
		port(
			clk			: in	std_logic;
			accel_data 	: in	std_logic_vector(15 downto 0);
			hex			: out	std_logic_vector(20 downto 0)
		);
	end component;
	
	component axis is
		port (
			clk_clk                           	: in    std_logic := '0';
			memory_mem_a                      	: out   std_logic_vector(14 downto 0);
			memory_mem_ba                     	: out   std_logic_vector(2 downto 0);
			memory_mem_ck                     	: out   std_logic;
			memory_mem_ck_n                   	: out   std_logic; 
			memory_mem_cke                    	: out   std_logic; 
			memory_mem_cs_n                   	: out   std_logic; 
			memory_mem_ras_n                  	: out   std_logic; 
			memory_mem_cas_n                  	: out   std_logic;
			memory_mem_we_n                   	: out   std_logic;
			memory_mem_reset_n                	: out   std_logic;
			memory_mem_dq                     	: inout std_logic_vector(31 downto 0) := (others => '0');
			memory_mem_dqs                    	: inout std_logic_vector(3 downto 0) := (others => '0');
			memory_mem_dqs_n                  	: inout std_logic_vector(3 downto 0) := (others => '0');
			memory_mem_odt                    	: out   std_logic;
			memory_mem_dm                     	: out   std_logic_vector(3 downto 0);
			memory_oct_rzqin                  	: in    std_logic := '0';
			pio_pitch_external_connection_export: out   std_logic_vector(15 downto 0);
			pio_x_external_connection_export  	: out   std_logic_vector(15 downto 0);
			pio_y_external_connection_export  	: out   std_logic_vector(15 downto 0);
			pio_z_external_connection_export  	: out   std_logic_vector(15 downto 0)
		);
		end component;
		
	begin
		axis_data : axis port map(
			CLOCK_50,		
			HPS_DDR3_ADDR,
			HPS_DDR3_BA,
			HPS_DDR3_CK_P,
			HPS_DDR3_CK_N,
			HPS_DDR3_CKE,
			HPS_DDR3_CS_N,
			HPS_DDR3_RAS_N,
			HPS_DDR3_CAS_N,
			HPS_DDR3_WE_N,
			HPS_DDR3_RESET_N,
			HPS_DDR3_DQ,
			HPS_DDR3_DQS_P,
			HPS_DDR3_DQS_N,
			HPS_DDR3_ODT,
			HPS_DDR3_DM,
			HPS_DDR3_RZQ,
			pitch,
			accel_x,
			accel_y,
			accel_z
		);

		reset<=KEY(0);
		LEDR(0)<=reset;

		process(CLOCK_50, reset)
			begin
				if (reset='0') then
					x_all<=(others => (others => '0'));
					y_all<=(others => (others => '0'));
					z_all<=(others => (others => '0'));
					sum_x<= (others => '0');
					sum_y<= (others => '0');
					sum_z<= (others => '0');
					cnt_clk<=0;
				elsif (rising_edge(CLOCK_50)) then
					if (cnt_clk<2499999) then
						cnt_clk<=cnt_clk+1;
					else 
						x_all(1 to 7) 	<= x_all(0 to 6);
						x_all(0)      	<= signed(accel_x);
						y_all(1 to 7) 	<= y_all(0 to 6);
						y_all(0)      	<= signed(accel_y);
						z_all(1 to 7) 	<= z_all(0 to 6);
						z_all(0)      	<= signed(accel_z);
						
						sum_x <=resize(x_all(0), 19) + resize(x_all(1), 19) + 
								resize(x_all(2), 19) + resize(x_all(3), 19) +
								resize(x_all(4), 19) + resize(x_all(5), 19) + 
								resize(x_all(6), 19) + resize(x_all(7), 19);
						sum_y <=resize(y_all(0), 19) + resize(y_all(1), 19) + 
								resize(y_all(2), 19) + resize(y_all(3), 19) +
								resize(y_all(4), 19) + resize(y_all(5), 19) + 
								resize(y_all(6), 19) + resize(y_all(7), 19);
						sum_z <=resize(z_all(0), 19) + resize(z_all(1), 19) + 
								resize(z_all(2), 19) + resize(z_all(3), 19) +
								resize(z_all(4), 19) + resize(z_all(5), 19) + 
								resize(z_all(6), 19) + resize(z_all(7), 19);

						avg_x <= sum_x(18 downto 3);
						avg_y <= sum_y(18 downto 3);
						avg_z <= sum_z(18 downto 3);
						cnt_clk<=0;

						if (signed(avg_z) > 200) then
							status<="UP";
						elsif (signed(avg_z) < -200) then
							status<="DO"; --Down
						elsif (signed(avg_y) > 200) then
							status<="FR"; --Front
						elsif (signed(avg_y) < -200) then
							status<="BA"; --Back
						elsif (signed(avg_x) > 200) then
							status<="RI"; --Right
						elsif (signed(avg_x) < -200) then
							status<="LE"; --Left
						else 
							status<="ID"; --IDLE
						end if;
						
						if (signed(pitch)<0) then
							HEX4<="0111111";
						else
							HEX4<="1111111";	
						end if;
						
					end if;
				end if;
		end process;

		seg_7_direction	:	seg_7 port map(CLOCK_50,status,hex_dir);
		seg_7_pitch			:	seg_7_ang port map(CLOCK_50,pitch,hex_pit);
		
		HEX0	<=	hex_dir(6 downto 0);
		HEX1	<=	hex_pit(6 downto 0);
		HEX2	<=	hex_pit(13 downto 7);
		HEX3	<=	hex_pit(20 downto 14);

	end HPS_arch;