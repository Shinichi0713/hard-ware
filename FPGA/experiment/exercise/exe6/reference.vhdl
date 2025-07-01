library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ff is
    Port ( 
        aclr  : in  STD_LOGIC;
        clk   : in  STD_LOGIC;
        clken : in  STD_LOGIC;
        d     : in  STD_LOGIC;
        q     : out STD_LOGIC
    );
end ff;

architecture Behavioral of ff is
begin
    process (aclr, clk)
    begin
        if aclr = '0' then
            q <= '0';
        elsif rising_edge(clk) then
            if clken = '1' then
                q <= d;
            end if;
        end if;
    end process;
end Behavioral;
