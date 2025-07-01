library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- Please start to write a entity block ! --
entity adder is
port ( a, b : in std_logic_vector (15 downto 0);
	      sum : out std_logic_vector (15 downto 0) );
end adder;
-- End of  a entity block.  --

architecture logic of adder is
begin
	sum <= a + b;
end;
