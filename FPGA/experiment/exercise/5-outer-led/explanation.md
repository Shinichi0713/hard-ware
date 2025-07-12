FPGAで**外部のLEDを点滅**させるには、FPGAのI/OピンをLEDのアノードまたはカソードに接続し、VHDLやVerilogでそのピンを制御するだけです。  
LEDの片側は抵抗を介してGNDまたはVCCに接続してください（多くはカソードをGND、アノードをFPGAピンに接続する「ソース出力」方式が一般的です）。
 
---
 
## 基本回路例
 
```
FPGAピン ──[抵抗]──→|─── GND
                    LED
```
- [抵抗]はLEDの定格に合わせて330Ω～1kΩ程度が一般的です。
- LEDのアノード（長い足）をFPGAピン、カソード（短い足）を抵抗経由でGNDへ。
 
---
 
## VHDLサンプルコード
 
### エンティティ部
 
```vhdl
entity blink_led is
    port (
        clk  : in  std_logic;    -- クロック入力
        rst  : in  std_logic;    -- リセット
        led  : out std_logic     -- LED出力（外部LEDに接続）
    );
end entity;
```
 
### アーキテクチャ部
 
```vhdl
architecture rtl of blink_led is
    signal counter : unsigned(25 downto 0) := (others => '0'); -- 26bitカウンタ
    signal led_reg : std_logic := '0';
begin
 
    process(clk, rst)
    begin
        if rst = '1' then
            counter <= (others => '0');
            led_reg <= '0';
        elsif rising_edge(clk) then
            if counter = 49999999 then -- 50MHzクロックで1秒周期
                counter <= (others => '0');
                led_reg <= not led_reg;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;
 
    led <= led_reg; -- LEDピンに出力
 
end architecture;
```
 
---
 
## ピンアサイン例（Quartus .qsf）
 
```tcl
set_location_assignment PIN_AB12 -to led    # 実際のLED接続ピン名に置き換えてください
set_location_assignment PIN_Y10  -to clk    # クロック入力ピン名
```
 
---
 
## 注意点
 
- **FPGAピンの電流制限**に注意してください（1ピンあたり最大8mA程度が一般的。複数LEDを同時点灯する場合は合計電流にも注意）。
- LEDの極性（向き）を間違えないようにしてください。
- 必ず抵抗を直列に入れてください（過電流防止のため）。
 
# ピンアサインメント

69と70を使いました

差動の正極と負極を選択してループさせることでLED点灯しました。


