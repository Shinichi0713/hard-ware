library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity counter is
	port(
		clock: in std_logic;
		reset: in std_logic;
		counter_out: out unsigned(31 downto 0));
end counter;

architecture rtl of counter is
	signal cnt: unsigned(31 downto 0) := (others=>'0');
	
	begin
		process(clock, reset)
		begin
			if (reset='0') then
			
			elsif (rising_edge(clock)) then
				cnt <= cnt+1;
			end if;
			counter_out <= cnt;
		end process;
end rtl;


