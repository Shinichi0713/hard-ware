library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity selector is
port(
    dataa   : in unsigned(3 downto 0);
    datab   : in unsigned(3 downto 0);
    sel     : in std_logic;
    result  : out unsigned(3 downto 0)
);
end entity;

architecture rtl of selector is
begin
    process(dataa, datab, sel)
    begin
    case(sel) is
        when '1' => result <= dataa;
        when '0' => result <= datab;
        when others => result <= (others=>'0');
    end case;
end process;
end rtl;

