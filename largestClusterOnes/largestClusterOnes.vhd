library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity largestClusterOnes is
	generic (
		BITS_IN: positive := 8;
		BITS_OUT: positive := 4); --calculated by user as ceil(log2(BITS_IN+1))
	port(
		inp_vector: in std_logic_vector(BITS_IN-1 downto 0);
		largestCluster: out std_logic_vector(BITS_OUT-1 downto 0);
		ssd: out std_logic_vector(6 downto 0));
end entity;


architecture combinational of largestClusterOnes is

begin

	process(all)
		-- count represents the size of the largest cluster of ones we have found so far
		variable count: natural range 0 to BITS_IN;
		-- runningCount represents the size of the cluster of ones we are in as we
		--     loop through the input bits
		variable runningCount: natural range 0 to BITS_IN;
	begin
	
		-- initialize the variables
		count := 0;
		runningCount := 0;
	
		-- loop through each bit of the input
		loop1: for i in 0 to BITS_IN-1 loop
			-- if we reached a '1' then increment our running count since we have not
			--     gotten to the end of the cluster
			if inp_vector(i) then
				runningCount := runningCount + 1;
			-- otherwise we found a '0' so save the running count if it is the max
			--     cluster size have seen so far
			else
				if runningCount > count then
					count := runningCount;
				end if;
				-- reset the running count since we are not in a cluster of ones
				runningCount := 0;
			end if;
				
			-- if we got to the last bit then automatically save the running count if
			--     it is the max size we have seen
			if i = BITS_IN-1 then
				if runningCount > count then
					count := runningCount;
				end if;			
			end if;
			
		end loop loop1;
	
		-- save the count for the largest cluster size to our output
		largestCluster <= std_logic_vector(to_unsigned(count, BITS_OUT));
	end process;
	
	-- convert to SSD value
	with largestCluster select
		ssd <= "0000001" when "0000",
				 "1001111" when "0001",
				 "0010010" when "0010",
				 "0000110" when "0011",
				 "1001100" when "0100",
				 "0100100" when "0101",
				 "0100000" when "0110",
				 "0001111" when "0111",
				 "0000000" when "1000",
				 "1111110" when others;
	
end architecture;
