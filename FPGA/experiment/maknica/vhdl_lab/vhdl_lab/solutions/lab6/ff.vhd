library ieee;
use ieee.std_logic_1164.all;

entity ff is
port	( clk, aclr, clken	:	in	std_logic;
			d				:	in	std_logic;
			q				:	out	std_logic);
end ff;

architecture logic of ff is
begin
	process (clk, aclr)
	begin
		if (aclr = '0') then
			q <= '0';
		elsif (clk 'event and clk = '1') then
			if (clken = '1') then
				q <= d;
			end if;
		end if;
	end process;
end logic;				
