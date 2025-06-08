-- library
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- entity
entity ff is
    Port(
	clk : in std_logic;
	aclr : in std_logic;
	clken : in std_logic;
	d: in std_logic;
	q: out std_logic
    );
end ff;

-- architecture
architecture Behavioral of ff is
    begin
	process(aclr, clk)
	begin
	    if aclr = '0' then
		q <= '0';
	    elsif rising_edge(aclr) then
		if clken = '1' then
		    q <= d;
		end if;
	    end if;
	end process;
end Behavioral;
