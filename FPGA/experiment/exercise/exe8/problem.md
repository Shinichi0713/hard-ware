# 問題

不通にLED点灯で良い。

なぜなら、あんまりピン発光すら理解していないため。



## 手順

FPGA で「ピンに出力する」というのは、FPGA 内部の **ロジック信号**を FPGA の外部ピンに結びつけて、外部回路に電気信号を出すことを意味します。

そのためには次の手順が必要です。

---

## 1. HDL で出力信号を定義

VHDL や Verilog で **entity / module の port** に `out` 信号を定義します。

### VHDL の例

```vhdl
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity blinky is
    Port (
        clk : in  std_logic;    -- クロック入力
        led : out std_logic     -- 出力ピン (LED などに接続)
    );
end blinky;

architecture Behavioral of blinky is
    signal counter : integer := 0;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            counter <= counter + 1;
            if counter = 50000000 then
                led <= not led;  -- 出力トグル
                counter <= 0;
            end if;
        end if;
    end process;
end Behavioral;
```

> signal: 内部回路で用いることが出来る、配線やレジスタのようなもの
>
> processで使う予定のportを定義。
>
> counterをインクリメント
>


## 2. 制約ファイル（ピンアサイン）の作成

FPGA の **論理信号名**と **物理ピン番号**を関連付けます。

このファイルは FPGA ベンダーごとに形式が異なります。

* **Xilinx (Vivado)** → `.xdc` ファイル
* **Intel/Altera (Quartus)** → `.qsf` ファイル

### Xilinx Vivado (XDC) 例

```tcl
set_property PACKAGE_PIN W5 [get_ports {led}]
set_property IOSTANDARD LVCMOS33 [get_ports {led}]
```

### Intel Quartus (QSF) 例

```tcl
set_location_assignment PIN_W5 -to led
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to led
```

---

## 3. ビルド・書き込み

1. HDL コードを合成・配置配線（Synthesis & Implementation）
2. ビットストリーム (bit / sof ファイル) を生成
3. FPGA に書き込む

---

## 4. 外部回路への接続

* LED, センサ, GPIO など外部回路に配線
* 電圧レベル（3.3V, 1.8V など）に注意
* 電流制限抵抗やバッファを入れることもある

---

✅ まとめると：

1. HDL で `out` 信号を定義する
2. 制約ファイルでその信号を FPGA のピン番号に割り当てる
3. 合成・配置配線・書き込み
4. 実機でピンから電気信号が出る

---

ご希望は **「LED点滅のようなシンプルな出力例」**が良いですか？

それとも **「特定の信号を外部機器に出力する一般的な方法」**を詳しく知りたいですか？
