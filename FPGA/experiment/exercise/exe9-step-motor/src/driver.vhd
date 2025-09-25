library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stepper_driver is
    port(
        clk         : in  std_logic;        -- FPGA基準クロック (例:50MHz)
        reset_n     : in  std_logic;        -- 非同期リセット (Low有効)
        speed_divider : in unsigned(31 downto 0); -- パルス周期設定
        dir_ctrl    : in  std_logic;        -- 回転方向の設定入力
        step_out    : out std_logic;        -- ステップパルス出力
        dir_out     : out std_logic         -- 回転方向出力
    );
end entity;

architecture rtl of stepper_driver is
    signal counter : unsigned(31 downto 0) := (others => '0');
    signal step_sig : std_logic := '0';
begin
    -- DIRはそのまま出力
    dir_out <= dir_ctrl;

    process(clk, reset_n)
    begin
        if reset_n = '0' then
            counter  <= (others => '0');
            step_sig <= '0';
        elsif rising_edge(clk) then
            if counter >= speed_divider then
                counter  <= (others => '0');
                step_sig <= not step_sig;  -- トグル動作でパルス生成
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

    step_out <= step_sig;
end rtl;
