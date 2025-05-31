library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity mult4x4 is
 port (
  a, b : in std_logic_vector (3 downto 0);
  product : out std_logic_vector (7 downto 0) );
end entity;

architecture logic of mult4x4 is
 begin
  process (a, b)
   begin
    product <= a*b;
  end process;
end logic;
