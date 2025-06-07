library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity compare_if is
    Port ( da : in STD_LOGIC_VECTOR (7 downto 0);
           db : in STD_LOGIC_VECTOR (7 downto 0);
           equ : out STD_LOGIC;
           agb : out STD_LOGIC;
           alb : out STD_LOGIC);
end compare_if;

architecture Behavioral of compare_if is
begin
    process(da, db)
    begin
        if da = db then
            equ <= '1';
        else
            equ <= '0';
        end if;

        if da > db then
            agb <= '1';
        else
            agb <= '0';
        end if;

        if da < db then
            alb <= '1';
        else
            alb <= '0';
        end if;
    end process;
end Behavioral;
