library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity demo_top is
    port (
        clk : in std_logic;
        rst : in std_logic
    );
end entity;

architecture rtl of demo_top is

    -- 8ビットカウンタ
    signal counter : std_logic_vector(7 downto 0);

    -- In System Sources and Probes IPコアのコンポーネント宣言
    component in_system_source_inst is
        port (
            probe : in std_logic_vector(7 downto 0)
        );
    end component;

begin

    -- カウンタの動作
    process(clk, rst)
    begin
        if rst = '1' then
            counter <= (others => '0');
        elsif rising_edge(clk) then
            counter <= std_logic_vector(unsigned(counter) + 1);
        end if;
    end process;

    -- IPコアのインスタンス化
    u_in_system_source : in_system_source_inst
        port map (
            probe => counter
        );

end rtl;