library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mult4x4 is
    Port ( a : in STD_LOGIC_VECTOR (3 downto 0);
           b : in STD_LOGIC_VECTOR (3 downto 0);
           product : out STD_LOGIC_VECTOR (7 downto 0));
end mult4x4;

architecture Behavioral of mult4x4 is
begin
    process(a, b)
    begin
        product <= std_logic_vector(unsigned(a) * unsigned(b));
    end process;
end Behavioral;
