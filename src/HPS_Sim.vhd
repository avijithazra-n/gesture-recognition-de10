LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity HPS_Sim is 
	port(
		CLOCK_50 			: in		std_logic;
		reset					: in 		std_logic;
		status				: out		string(1 to 2);
		accel_x				: in 		std_logic_vector(15 downto 0);
		accel_y				: in 		std_logic_vector(15 downto 0);
		accel_z				: in 		std_logic_vector(15 downto 0)
	);
end HPS_Sim;

architecture HPS_Sim_arch of HPS_Sim is		
	begin
		process(CLOCK_50, reset)
			begin
				if (reset='0') then
					status<="ID";
				elsif (rising_edge(CLOCK_50)) then
				
					if (signed(accel_z) > 200) then
						status<="UP";
					elsif (signed(accel_z) < -200) then
						status<="DO"; --Down
					elsif (signed(accel_y) > 200) then
						status<="FR"; --Front
					elsif (signed(accel_y) < -200) then
						status<="BA"; --Back
					elsif (signed(accel_x) > 200) then
						status<="RI"; --Right
					elsif (signed(accel_x) < -200) then
						status<="LE"; --Left
					else 
						status<="ID"; --IDLE
					end if;
				end if;
		end process;

	end HPS_Sim_arch;