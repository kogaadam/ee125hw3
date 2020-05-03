library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity largestClusterOnes is
	generic (
		BITS_IN: positive := 8;
		BITS_OUT: positive := 4); --calculated by user as ceil(log2(BITS_IN+1))
	port(
		inp_vector: in std_logic_vector(BITS_IN-1 downto 0);
		largestCluster: out std_logic_vector(BITS_OUT-1 downto 0));
end entity;


architecture sequential of largestClusterOnes is

begin

	process(all)
		variable count: natural range 0 to BITS_IN;
		variable runningCount: natural range 0 to BITS_IN;
	begin
	
		count := 0;
		runningCount := 0;
	
		loop1: for i in 0 to BITS_IN-1 loop
			if inp_vector(i) then
				runningCount := runningCount + 1;
			else
				if runningCount > count then
					count := runningCount;
				end if;
				runningCount := 0;
			end if;
				
			if i = BITS_IN-1 then
				if runningCount > count then
					count := runningCount;
				end if;			
			end if;
			
		end loop loop1;
	
		largestCluster <= std_logic_vector(to_unsigned(count, BITS_OUT));
	end process;
	
end architecture;
