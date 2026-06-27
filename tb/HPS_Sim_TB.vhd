LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity HPS_Sim_TB is 
end HPS_Sim_TB;

architecture HPS_Sim_TB_arch of HPS_Sim_TB is
	signal clk_t 		: 	std_logic := '0';
	signal reset_t		:	std_logic := '0';
	signal accel_x_t	:	std_logic_vector(15 downto 0);
	signal accel_y_t	:	std_logic_vector(15 downto 0);
	signal accel_z_t	:	std_logic_vector(15 downto 0);
	signal status_t	: 	string(1 to 2);
	
	component HPS_Sim is 
		port(
			CLOCK_50 			: in		std_logic;
			reset				: in 		std_logic;
			status				: out		string(1 to 2);
			accel_x				: in 		std_logic_vector(15 downto 0);
			accel_y				: in 		std_logic_vector(15 downto 0);
			accel_z				: in 		std_logic_vector(15 downto 0)
		);
	end component;
	
	begin 
	tb1:component HPS_Sim
		port map(clk_t,reset_t,status_t,accel_x_t,accel_y_t,accel_z_t);
		
	clk_t	 		<= not clk_t after 5ns;

	proc: process
		begin
			accel_x_t <= std_logic_vector(to_signed(0, 16));
			accel_y_t <= std_logic_vector(to_signed(0, 16));
			accel_z_t <= std_logic_vector(to_signed(0, 16));
			wait for 20 ns;
			
			reset_t <= '1';
			wait for 20 ns;
			
			accel_x_t <= std_logic_vector(to_signed(0, 16));
			accel_y_t <= std_logic_vector(to_signed(0, 16));
			accel_z_t <= std_logic_vector(to_signed(256, 16));
			wait for 60 ns;
			
			accel_x_t <= std_logic_vector(to_signed(0, 16));
			accel_y_t <= std_logic_vector(to_signed(0, 16));
			accel_z_t <= std_logic_vector(to_signed(-256, 16));
			wait for 60 ns;
			
			accel_x_t <= std_logic_vector(to_signed(0, 16));
			accel_y_t <= std_logic_vector(to_signed(100, 16));
			accel_z_t <= std_logic_vector(to_signed(100, 16));
			wait for 60 ns;
			
			accel_x_t <= std_logic_vector(to_signed(0, 16));
			accel_y_t <= std_logic_vector(to_signed(256, 16));
			accel_z_t <= std_logic_vector(to_signed(50, 16));
			wait for 60 ns;
			
			accel_x_t <= std_logic_vector(to_signed(0, 16));
			accel_y_t <= std_logic_vector(to_signed(-256, 16));
			accel_z_t <= std_logic_vector(to_signed(50, 16));
			wait for 60 ns;
			
			accel_x_t <= std_logic_vector(to_signed(256, 16));
			accel_y_t <= std_logic_vector(to_signed(10, 16));
			accel_z_t <= std_logic_vector(to_signed(1, 16));
			wait for 60 ns;
			
			accel_x_t <= std_logic_vector(to_signed(-256, 16));
			accel_y_t <= std_logic_vector(to_signed(10, 16));
			accel_z_t <= std_logic_vector(to_signed(1, 16));
			wait for 60 ns;
			
			reset_t <= '0';
			accel_x_t <= std_logic_vector(to_signed(-256, 16));
			accel_y_t <= std_logic_vector(to_signed(10, 16));
			accel_z_t <= std_logic_vector(to_signed(1, 16));
			wait for 60 ns;

		end process;
	
end HPS_Sim_TB_arch;