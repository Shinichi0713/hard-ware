entity top_module is
    Port (
        clk    : in  std_logic;    -- クロック入力
        reset  : in  std_logic;    -- リセット
        my_sig : out std_logic     -- 外部出力ピン
    );
end top_module;

architecture rtl of top_module is
    signal internal_sig : std_logic := '0';
begin
    process(clk, reset)
    begin
        if reset = '1' then
            internal_sig <= '0';
        elsif rising_edge(clk) then
            internal_sig <= not internal_sig; -- 内部でトグル
        end if;
    end process;

    my_sig <= internal_sig;  -- 出力ポートに結線
end rtl;
