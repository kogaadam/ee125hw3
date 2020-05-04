library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity debouncer is
	generic (
		T_DEB_MS: natural := 25;		 --minimum debounce time in ms
		F_CLK_KHZ: natural := 50_000); --clock frequency in kHz
	port (
		x, clk, rst: in std_logic;
		y: out std_logic;
		ssd_x, ssd_y: out std_logic_vector(6 downto 0));
end entity;

architecture single_switch of debouncer is
	constant COUNTER_BITS: natural := 1 + integer(ceil(log2(real(T_DEB_MS*F_CLK_KHZ))));
	constant SSD_INT_BITS: natural := 4;
	signal y_prev: std_logic;
begin	

	-- Test Circuit
	process(x, y, rst)
		function slv_to_ssd (input: std_logic_vector) return std_logic_vector is
		begin
			case input is
				when "0000" => return "0000001";		--"0" on SSD
				when "0001" => return "1001111";		--"1" on SSD
				when "0010" => return "0010010";		--"2" on SSD
				when "0011" => return "0000110";		--"3" on SSD
				when "0100" => return "1001100";		--"4" on SSD
				when "0101" => return "0100100";		--"5" on SSD
				when "0110" => return "0100000";		--"6" on SSD
				when "0111" => return "0001111";		--"7" on SSD
				when "1000" => return "0000000";		--"8" on SSD
				when "1001" => return "0000100";		--"9" on SSD
				when "1010" => return "0001000";		--"A" on SSD
				when "1011" => return "1100000";		--"b" on SSD
				when "1100" => return "0110001";		--"C" on SSD
				when "1101" => return "1000010";		--"d" on SSD
				when "1110" => return "0110000";		--"E" on SSD
				when "1111" => return "0111000";		--"F" on SSD
				when others => return "1111110";		--"-" on SSD
			end case;
		end function slv_to_ssd;
		
		variable count_x_rise, count_x_fall, count_y: natural range 0 to 8;
		
	begin
		-- Build x counter
		if rst = '1' then
			count_x_rise := 0;
			count_x_fall := 0;
		else
			--if x = '1' and x_prev = '0' then
			if rising_edge(x) then
				count_x_rise := count_x_rise + 1;
			end if;
			 if falling_edge(x) then
				count_x_fall := count_x_fall + 1;
			end if;		
		end if;
	
		ssd_x <= slv_to_ssd(std_logic_vector(to_unsigned(count_x_rise + count_x_fall, SSD_INT_BITS)));
			
		-- Build y counter
		if rst = '1' then
			count_y := 0;
		else
			if rising_edge(clk) then
				if y /= y_prev then
					count_y := count_y + 1;
				end if;
			end if;
		end if;
			
		ssd_y <= slv_to_ssd(std_logic_vector(to_unsigned(count_y, SSD_INT_BITS)));
			
	end process;		

	process(clk)
		variable count: unsigned(COUNTER_BITS-1 downto 0);
		variable y_back, counter_done: std_logic;
	begin
		
		-- Timer
		if rising_edge(clk) then
			if x then
				count := (others => '0');
			elsif not counter_done then
				count := count + 1;
			end if;
		end if;
		
		--Output register:
		if falling_edge(clk) then
			
			if x then
				counter_done := '0';
			end if;
			
			if y_back = '1' then
				y_prev <= y;
				y_back := '0';
			end if;
		
			if count(COUNTER_BITS-1) then
				y_prev <= y;
				y_back := '1';
				counter_done := '1';
				y <= not y;
			end if;
		end if;
		
		if counter_done then
			count := (others => '0');
		end if;
		
	end process;

end architecture;