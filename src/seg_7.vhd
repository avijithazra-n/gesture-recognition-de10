LIBRARY ieee;
USE ieee.std_logic_1164.all;

entity seg_7 is 
	port(
		clk			: in	std_logic;
		status	 	: in	string(1 to 2);
		hex			: out	std_logic_vector(6 downto 0)
	);
end seg_7;

architecture seg_7_arch of seg_7 is
	signal slow_clk	: integer RANGE 0 TO 2500000	:=0;
	begin
		process(clk)
			begin
			if (rising_edge(clk)) then
				if (slow_clk<2500000) then 
					slow_clk<=slow_clk+1;
				else
					slow_clk<=0;
					case status is
							when "UP" => hex 	<= "1000001"; -- UP
							when "DO" => hex 	<= "0100001"; -- Down
							when "FR" => hex 	<= "0001110"; -- Front
							when "BA" => hex 	<= "0000011"; -- Back
							when "RI" => hex 	<= "0101011"; -- Right
							when "LE" => hex 	<= "1000111"; -- Left
							when "ID" => hex 	<= "1111001"; -- Idle
							when others => hex 	<= "0000000";
					end case;
				end if;
			end if;
		end process;
	end seg_7_arch;