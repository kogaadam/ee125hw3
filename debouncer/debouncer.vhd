library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity debouncer is
	generic (
		T_DEB_MS: natural := 25;		 --minimum debounce time in ms
		F_CLK_KHZ: natural := 50_000); --clock frequency in kHz
	port (
		x, clk: in std_logic;
		y: out std_logic);
end entity;

architecture single_switch of debouncer is
	constant COUNTER_BITS: natural := 3; --given that N=2
begin

	process(clk)
		variable count: unsigned(COUNTER_BITS-1 downto 0);
	begin
		
		-- Timer
		if rising_edge(clk) then
			-- increment timer if the output doesnt match the input
			if y=x then
				count := (others => '0');
			else
				count := count + 1;
			end if;
		end if;
		
		--Output register:
		if falling_edge(clk) then
			if count(COUNTER_BITS-1) then
				-- invert the output if the counter is done
				y <= not y;
			end if;
		end if;
		
	end process;

end architecture;