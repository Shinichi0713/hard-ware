library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity countdown7seg is
    Port (
        clk      : in  STD_LOGIC;          -- 50MHzクロック
        reset    : in  STD_LOGIC;          -- 非同期リセット
        seg      : out STD_LOGIC_VECTOR(6 downto 0)  -- 7セグメントLED出力
    );
end countdown7seg;

architecture Behavioral of countdown7seg is
    signal count     : integer range 0 to 9 := 9;
    signal clk_div   : unsigned(25 downto 0) := (others => '0'); -- 1秒分周用
begin

    -- 1秒ごとにカウントダウン
    process(clk, reset)
    begin
        if reset = '1' then
            clk_div <= (others => '0');
            count   <= 9;
        elsif rising_edge(clk) then
            if clk_div = 49999999 then       -- 50MHz × 1秒 - 1
                clk_div <= (others => '0');
                if count = 0 then
                    count <= 9;
                else
                    count <= count - 1;
                end if;
            else
                clk_div <= clk_div + 1;
            end if;
        end if;
    end process;

    -- 7セグメントデコーダ（abcdefg, アノードコモン, 1=点灯）
    process(count)
    begin
        case count is
            when 0 => seg <= "1111110";
            when 1 => seg <= "0110000";
            when 2 => seg <= "1101101";
            when 3 => seg <= "1111001";
            when 4 => seg <= "0110011";
            when 5 => seg <= "1011011";
            when 6 => seg <= "1011111";
            when 7 => seg <= "1110000";
            when 8 => seg <= "1111111";
            when 9 => seg <= "1111011";
            when others => seg <= "0000000";
        end case;
    end process;

end Behavioral;
