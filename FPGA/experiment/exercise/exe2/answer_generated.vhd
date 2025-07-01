library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity compare is
    Port (
        da : in STD_LOGIC_VECTOR(7 downto 0);
        db : in STD_LOGIC_VECTOR(7 downto 0);
        equ : out STD_LOGIC;
        agb : out STD_LOGIC;
        alb : out STD_LOGIC
    );
end compare;

architecture Behavioral of compare is
begin
    process(da, db)
    begin
        if da = db then
            equ <= '1';
            agb <= '0';
            alb <= '0';
        elsif da > db then
            equ <= '0';
            agb <= '1';
            alb <= '0';
        else -- da < db
            equ <= '0';
            agb <= '0';
            alb <= '1';
        end if;
    end process;
end Behavioral;
