了解しました。  
「FPGA(10M50DAF484C6GES, Intel MAX10)で、複数のランプ（LED）が適当なタイミングで点灯するVHDLコード」と「Quartusによる設定手順」をご案内します。

---

## 1. VHDLコード例

ここでは「8個のLEDが一定周期で順番に点灯」するサンプルを示します。  
（タイミングや点灯パターンはご要望に応じて変更可能です）

### 例：8つのLEDが1秒ごとに1つずつ順番に点灯

```vhdl
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity led_chaser is
    Port (
        clk    : in  std_logic;           -- クロック入力（例：50MHz）
        reset  : in  std_logic;           -- リセット
        leds   : out std_logic_vector(7 downto 0)  -- LED出力
    );
end led_chaser;

architecture Behavioral of led_chaser is
    signal cnt      : unsigned(25 downto 0) := (others => '0'); -- 26bitカウンタ(約1秒@50MHz)
    signal led_idx  : unsigned(2 downto 0) := (others => '0');  -- LEDインデックス(0～7)
begin
    process(clk, reset)
    begin
        if reset = '1' then
            cnt     <= (others => '0');
            led_idx <= (others => '0');
        elsif rising_edge(clk) then
            if cnt = 49999999 then  -- 50,000,000クロック=1秒
                cnt <= (others => '0');
                if led_idx = 7 then
                    led_idx <= (others => '0');
                else
                    led_idx <= led_idx + 1;
                end if;
            else
                cnt <= cnt + 1;
            end if;
        end if;
    end process;

    leds <= std_logic_vector(to_unsigned(1,8) sll to_integer(led_idx));
    -- 1を左シフト：1つだけ点灯
end Behavioral;
```

### ポイント
- `clk`はFPGAボードのクロック（例：50MHz）を想定
- `reset`はリセット信号（スイッチ等で接続）
- `leds`は8ビット出力（LEDに接続）
- 1秒ごとに1つずつLEDが順番に点灯

---

## 2. Quartusでの設定・手順

### (1) 新規プロジェクト作成
1. Quartus Primeを起動し「File → New Project Wizard」
2. プロジェクト名・フォルダを設定
3. デバイス選択で「10M50DAF484C6GES」を選択

### (2) VHDLソースの追加
1. 「File → New → VHDL File」で上記コードを貼り付けて保存（例：led_chaser.vhd）
2. 「Project Navigator」から「Add/Remove Files in Project」で追加

### (3) ピン割り当て（Pin Assignment）
1. 「Assignments → Pin Planner」を開く
2. `clk`, `reset`, `leds` の各信号を物理ピンに割り当て
   - 例：`clk` → クロック入力ピン（ボード仕様書参照）
   - `reset` → 任意のスイッチ
   - `leds` → LEDにつながるピン（例：PIN_A1, PIN_B2 ... など、ボードの回路図を参照）

### (4) 合成・配置配線・書き込み
1. 「Processing → Start Compilation」で合成・配置配線
2. 完了後、「Programmer」でFPGAに書き込み

---

## 3. 注意点

- **ピン番号は必ず使用するFPGAボード（評価ボードなど）の回路図やマニュアルで確認してください。**
- クロック周波数はボードによって異なる場合があります（例：50MHz, 25MHzなど）。
- LEDの極性（アノード/カソード）や点灯ロジック（Hで点灯 or Lで点灯）も確認してください。

---

## 4. 参考リンク

- [Intel MAX 10 FPGA データシート](https://www.intel.com/content/www/jp/ja/products/details/fpga/max-10.html)
- [Quartus Prime ユーザーガイド](https://www.intel.com/content/www/jp/ja/software/programmable/quartus-prime/overview.html)

---

ご不明点があれば、ピン配置や点灯パターンのカスタマイズ例もお伝えできます。  
以上です。