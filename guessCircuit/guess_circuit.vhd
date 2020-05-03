library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity guess_circuit is
    generic (
	     BITS: natural := 8);
    port (
	     clk, rst: in std_logic;
		  outp: out std_logic_vector(BITS-1 downto 0));
end entity;

architecture arch1 of guess_circuit is
    signal a, b, c: unsigned(BITS-1 downto 0);
begin
    process (all)
	 begin
	     if rst then
		      b <= (0 => '1', others => '0');
				c <= (others => '0');
		   elsif rising_edge(clk) then
			   b <= a;
				c <= b;
		   end if;
		   a <= b + c;	
			outp <= std_logic_vector(c);
    end process;
end architecture arch1;