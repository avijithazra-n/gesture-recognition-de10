LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity seg_7_ang is 
	port(
		clk			: in	std_logic;
		accel_data 	: in	std_logic_vector(15 downto 0);
		hex			: out	std_logic_vector(20 downto 0)
	);
end seg_7_ang;

architecture seg_7_ang_arch of seg_7_ang is
	signal slow_clk	: integer RANGE 0 TO 2500000	:=0;
	signal angle		: integer range 0 to 32767		:=0;
	
	begin
		process(clk)
			begin
			if (rising_edge(clk)) then
				if (slow_clk<2500000) then 
					slow_clk<=slow_clk+1;
				else
					slow_clk	<=	0;
					angle		<=	abs(to_integer(signed(accel_data)));
					
					case (angle/100) is
						when 0 => hex(20 downto 14) 	<= "1111111";
						when 1 => hex(20 downto 14) 	<= "1111001";
						when 2 => hex(20 downto 14) 	<= "0100100";
						when 3 => hex(20 downto 14) 	<= "0110000";
						when 4 => hex(20 downto 14) 	<= "0011001";
						when 5 => hex(20 downto 14) 	<= "0010010";
						when 6 => hex(20 downto 14) 	<= "0000010";
						when 7 => hex(20 downto 14) 	<= "1111000";
						when 8 => hex(20 downto 14) 	<= "0000000";
						when 9 => hex(20 downto 14) 	<= "0010000";
						when others => hex(20 downto 14) <= "1111111";
				  end case;
				  case (angle rem 100/10) is
						when 0 => hex(13 downto 7) 	<= "1000000";
						when 1 => hex(13 downto 7) 	<= "1111001";
						when 2 => hex(13 downto 7) 	<= "0100100";
						when 3 => hex(13 downto 7) 	<= "0110000";
						when 4 => hex(13 downto 7) 	<= "0011001";
						when 5 => hex(13 downto 7) 	<= "0010010";
						when 6 => hex(13 downto 7) 	<= "0000010";
						when 7 => hex(13 downto 7) 	<= "1111000";
						when 8 => hex(13 downto 7) 	<= "0000000";
						when 9 => hex(13 downto 7) 	<= "0010000";
						when others => hex(13 downto 7) <= "1111111";
				  end case;
				  case (angle rem 10) is
						when 0 => hex(6 downto 0) 	<= "1000000";
						when 1 => hex(6 downto 0) 	<= "1111001";
						when 2 => hex(6 downto 0) 	<= "0100100";
						when 3 => hex(6 downto 0) 	<= "0110000";
						when 4 => hex(6 downto 0) 	<= "0011001";
						when 5 => hex(6 downto 0) 	<= "0010010";
						when 6 => hex(6 downto 0) 	<= "0000010";
						when 7 => hex(6 downto 0) 	<= "1111000";
						when 8 => hex(6 downto 0) 	<= "0000000";
						when 9 => hex(6 downto 0) 	<= "0010000";
						when others => hex(6 downto 0) <= "1111111";
				  end case;
				end if;
			end if;
		end process;
	end seg_7_ang_arch;