library IEEE;

use IEEE.std_logic_1164.all;

use IEEE.std_logic_unsigned.all;

entity COUNT4 is

generic (SEC1_MAX : integer := 50000000); -- 50 MHz

port (

CLK, RESET : in std_logic;

COUNT : out std_logic_vector(3 downto 0)

);

end entity;

architecture RTL of COUNT4 is

signal tmp_count : std_logic_vector(25 downto 0); -- 1秒のカウンタ

signal ENABLE : std_logic;

signal COUNT_TMP : std_logic_vector(3 downto 0);

begin

COUNT <= COUNT_TMP;

process(CLK, RESET)

begin

if (RESET = '0') then

tmp_count <= (others => '0');

elsif (CLK'event and CLK = '1') then

if (ENABLE = '1') then

tmp_count <= (others => '0');

else

tmp_count <= tmp_count + '1';

end if;

end if;

end process;

ENABLE <= '1' when (tmp_count = (SEC1_MAX - 1)) else '0';

process(CLK, RESET)

begin

if (RESET = '0') then

COUNT_TMP <= X"0";

elsif (CLK'event and CLK = '1') then

if (ENABLE = '1') then

COUNT_TMP <= COUNT_TMP + '1';

end if;

end if;

end process;

end RTL;