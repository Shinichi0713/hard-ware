# 制約

## 概要

FPGA の「制約条件（constraints）」とは、**論理合成・配置配線のときにツールへ与える設計上の条件や要求仕様**のことを指します。

これを正しく与えないと、シミュレーションでは動いても実機では誤動作することがよくあります。

## 制約条件の種類


### 1. **タイミング制約**

* クロックの周期や立ち上がりタイミングを指定するもの
* 例：

```td
create_clock -period 20.000 -name osc_clk OSC_CLK
derive_pll_clocks
derive_clock_uncertainty

```


役割：

* ツールが「この回路は 50MHz で動作すべき」と理解できる
* その周波数で setup/hold 時間が満たされるよう配置配線を調整する


### 2. **ピン配置制約**

* FPGA の論理ポートを実際のパッケージのどのピンに割り当てるか指定するもの
* 例：

```pgsql
set_location_assignment PIN_A1 -to clk
set_location_assignment PIN_B3 -to reset

```

役割：

* * 論理的な信号（clk, reset, dataなど）を基板上の物理ピンと正しく対応づける


### 3. **電気的制約（I/Oスタンダード）**

* 各ピンが扱う電圧規格や駆動能力を指定するもの
* 例：

```pgsql
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to data[0]

```

役割：

- FPGA ピンの電気特性を基板や他ICと一致させ、誤動作や破損を防ぐ


### 4. **配置・領域制約**

* 論理回路の一部を FPGA 内の特定の領域に配置する指定
* 例：部分再構成やマルチクロック領域で使用


### 5. **その他の制約**

* マルチサイクルパス制約
* false path 制約（タイミングを無視する経路）
* 最大遅延 / 最小遅延の指定
* クロックスキュー、ジッタ許容値


## 総括

1. タイミング制約：クロック周期やセットアップ・ホールド時間
2. ピン配置制約：論理ポートと物理ピンの対応
3. 電気製薬：I/O規格や駆動能力
4. 領域-配置制約：FPGA内部での配置場所指定


## 制約ファイル

**実際に使う制約ファイル**について整理する。


### 🔹 1. **.qsf (Quartus Settings File)**

* プロジェクト設定や I/O ピン配置・I/O 規格を記述するファイル
* Quartus の GUI から設定すると自動で .qsf に書き込まれる

### 例：I/O ピン割り当て

```tcl
# クロック信号を FPGA ピン PIN_A1 に割り当て
set_location_assignment PIN_A1 -to clk

# リセット信号を PIN_B3 に割り当て
set_location_assignment PIN_B3 -to reset

# データバス data[0] を PIN_C5 に割り当て
set_location_assignment PIN_C5 -to data[0]
```

### 例：I/O 規格指定

```tcl
# data[0] の電圧規格を 3.3V LVTTL に設定
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to data[0]
```

👉 **.qsf = ピン配置やI/O規格、プロジェクト全体の設定**

---

### 🔹 2. **.sdc (Synopsys Design Constraints)**

* **タイミング制約**を指定するファイル
* Quartus では TimeQuest Timing Analyzer がこのファイルを読み込む

### 例：クロック制約

```tcl
# クロック osc_clk を 50 MHz（周期 20ns）で定義
create_clock -period 20.000 -name osc_clk [get_ports clk]

# PLL や内部生成クロックを自動導出
derive_pll_clocks
derive_clock_uncertainty
```

### 例：入出力遅延制約

```tcl
# 入力信号 data_in に対してセットアップ時間を指定
set_input_delay -clock osc_clk 5.0 [get_ports data_in]

# 出力信号 data_out に対してホールド時間を指定
set_output_delay -clock osc_clk 2.0 [get_ports data_out]
```

### 例：タイミング解析除外

```tcl
# 解析対象外とする経路を指定
set_false_path -from [get_ports async_reset]
```

👉 **.sdc = クロックやタイミング制約を定義するファイル**

---

## 🔹 まとめ

* **.qsf** → ピン配置・I/O 規格・プロジェクト設定
* **.sdc** → クロック周期やタイミング制約

Quartus プロジェクトでは両方を組み合わせて使うのが一般的です。

---

💡 もしご希望なら、

* 簡単な VHDL トップモジュール
* それに対応する `.qsf` と `.sdc` の具体例

を作って、**Quartus にそのまま読み込める最小構成プロジェクト例**をお見せできますよ。



## 具体例

それでは **最小構成の VHDL トップモジュール** と、それに対応する **.qsf** と **.sdc** の具体例**を紹介します。

---

# ✅ 1. VHDL トップモジュール

（例：クロックを使ってカウンタをLEDに出力する）

```vhdl
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity top is
    port (
        clk     : in  std_logic;              -- クロック入力
        reset_n : in  std_logic;              -- 非同期リセット
        led     : out std_logic_vector(3 downto 0)  -- LED出力
    );
end top;

architecture rtl of top is
    signal counter : std_logic_vector(23 downto 0) := (others => '0');
begin
    process(clk, reset_n)
    begin
        if reset_n = '0' then
            counter <= (others => '0');
        elsif rising_edge(clk) then
            counter <= counter + 1;
        end if;
    end process;

    led <= counter(23 downto 20); -- カウンタの上位ビットをLEDに出力
end rtl;
```

---

# ✅ 2. .qsf（Quartus Settings File）

Quartus が自動生成しますが、自分で書くとこうなります。

```tcl
# FPGA デバイス設定（例: Cyclone V）
set_global_assignment -name FAMILY "Cyclone V"
set_global_assignment -name DEVICE 5CSEMA5F31C6

# トップレベルエンティティ
set_global_assignment -name TOP_LEVEL_ENTITY top

# ピン割り当て
set_location_assignment PIN_A1 -to clk
set_location_assignment PIN_B3 -to reset_n
set_location_assignment PIN_C5 -to led[0]
set_location_assignment PIN_D6 -to led[1]
set_location_assignment PIN_E7 -to led[2]
set_location_assignment PIN_F8 -to led[3]

# I/O スタンダード（3.3V LVTTL を指定）
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to clk
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to reset_n
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to led[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to led[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to led[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to led[3]
```

---

# ✅ 3. .sdc（Synopsys Design Constraints）

タイミング制約を書くファイルです。

```tcl
# クロック信号 clk を 50 MHz（周期 20ns）で定義
create_clock -period 20.0 -name sys_clk [get_ports clk]

# PLL由来のクロックや不確定性を自動導出
derive_pll_clocks
derive_clock_uncertainty

# 入力遅延（外部入力が最大 5ns 遅れてくると仮定）
set_input_delay -clock sys_clk 5.0 [get_ports reset_n]

# 出力遅延（出力が最大 2ns 遅れて外部へ届くと仮定）
set_output_delay -clock sys_clk 2.0 [get_ports led*]
```

---

# ✅ まとめ

* **top.vhd** → 実際の論理回路（LED点滅）
* **project.qsf** → FPGAのデバイス指定 + ピン割り当て + I/O規格
* **project.sdc** → クロックやタイミング制約

これを揃えれば、Quartusで「ピン配置」「タイミング解析」が正しく走るようになります。

---

👉 ご要望があれば、この例を **Quartus Lite 用の完全なプロジェクトフォルダ構成（.qpf, .qsf, .sdc, .vhd）** にまとめて、そのまま読み込める形にしてみましょうか？
