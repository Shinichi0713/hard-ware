library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity adder is
    Port ( a : in STD_LOGIC_VECTOR(15 downto 0);
           b : in STD_LOGIC_VECTOR(15 downto 0);
           sum : out STD_LOGIC_VECTOR(15 downto 0));
end adder;

architecture Behavioral of adder is
begin
    sum <= a + b;
end Behavioral;
