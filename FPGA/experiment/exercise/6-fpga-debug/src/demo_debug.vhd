library ieee;
use ieee.std_logic_1164.all;

entity debug_test is
    port (
        my_source : out std_logic_vector(0 downto 0);
        my_probe  : in  std_logic_vector(0 downto 0)
    );
end debug_test;

architecture rtl of debug_test is

    component in_system_source_inst is
        port (
            source : out std_logic_vector(0 downto 0);
            probe  : in  std_logic_vector(0 downto 0)
        );
    end component;

begin

    u0 : in_system_source_inst
        port map (
            source => my_source,
            probe  => my_probe
        );

end rtl;