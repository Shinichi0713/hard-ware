library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux4 is
    Port ( a : in  STD_LOGIC_VECTOR (3 downto 0);
           b : in  STD_LOGIC_VECTOR (3 downto 0);
           sel : in  STD_LOGIC;
           y : out  STD_LOGIC_VECTOR (3 downto 0));
end mux4;

architecture Behavioral of mux4 is
begin
    process(a, b, sel)
    begin
        case sel is
            when '0' =>
                y <= a;
            when '1' =>
                y <= b;
            when others =>
                y <= (others => '0');
        end case;
    end process;
end Behavioral;


