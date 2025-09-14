library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity adder is
port(
a:in std_logic_vector(15 downto 0);
b:in std_logic_vector(15 downto 0);
sum:out std_logic_vector(15 downto 0));
end adder;

architecture Behavioral of adder is
begin
sum <= a + b;
end Behavioral;

