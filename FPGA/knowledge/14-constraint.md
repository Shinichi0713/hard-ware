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

> qsfファイル：ピン配置、I/O規格を記述するファイル。自動で.qsfに書き込まれる

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

セットアップ時間

クロック前にデータを安定化させる必要がある時間

* **次のクロックエッジが到来する前に、入力データが安定していなければならない時間** 。
* もしデータが直前に変わると、フリップフロップは正しくデータを取り込めず、誤動作やメタステーブル状態になる可能性があります。

ホールド時間

クロック後にデータを保持しておく必要がある時間

* **クロックエッジが到来した後も、入力データを一定時間保持し続けなければならない時間** 。
* クロック直後にデータが変わってしまうと、まだ内部でラッチ処理中のため、誤ったデータが取り込まれる可能性があります。


### 例：タイミング解析除外

```tcl
# 解析対象外とする経路を指定
set_false_path -from [get_ports async_reset]
```

👉 **.sdc = クロックやタイミング制約を定義するファイル**

> タイミング制約を指定するファイル。
>
> 記載すべきはクロック制約、入出力遅延制約(セットアップ時間を指定、ホールド時間を指定。タイミング解析除外。

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


# タイミング制約が必要となる理由

FPGAやASICの設計で「制約ファイル（.sdc など）」に**遅延制約**を書いておくのは、単なる形式ではなく**タイミングが守れなければ動かない回路になるから**です。順序立てて説明しますね。

## 1. FPGAにおける「遅延」とは？

FPGA内部の信号は、

* LUT（論理素子）を通過する遅延
* 配線リソースを経由する遅延
* フリップフロップのクロック-出力遅延（TcoT_{co}）

  などによって、クロックエッジからエッジまでの**データ到達時間**が変わります。

この遅延が大きすぎると、**次のクロックまでに信号が届かず setup 違反**を起こします。

逆に遅延が小さすぎると、**クロック直後に変化して hold 違反**を起こします。

## 2. 制約ファイルが必要な理由

ツール（Quartus, Vivado など）は、自分で「外部クロックは何Hzか」「外部I/Oのタイミングは何nsか」を **自動では理解できません** 。

→ 設計者が **制約ファイル (.sdc)** で条件を与える必要があります。

たとえば：

* `create_clock -period 10 [get_ports clk]`

  → クロックは 100MHz (周期 10ns) で動作する
* `set_input_delay` / `set_output_delay`

  → 外部デバイスとのデータのやり取りで、何ns遅れても良いか

ツールは外部クロックは何Hzか、外部I/Oのタイミングはnsかは自動では理解できない

→設計者が制約ファイルで条件を当てえる必要がある。

## 3. 制約をしないとどうなるか？

* ツールは「クロックや外部I/Oの条件が分からない」ので、タイミング解析を正しくできない。
* 結果として、**見た目は論理が正しくても実機で動かない**ことがある。
  * クロックに間に合わない → データ化け、誤動作
  * 配線遅延でシフトしてしまう → 外部デバイスとの通信が失敗

> クロックや外部I/Oの条件が分からないため、タイミング解析を正しくできない
>
> →結果として見た目や論理は正しくても実機が動作しないことがある

## 4. まとめ

* **遅延制約は、実機で回路が正しく動作するために必須** 。
* 制約を書いて初めて、ツールが
  * 「setup/hold を満たしているか？」
  * 「配線遅延を考慮しても動作可能か？」

    をチェックできます。
* 制約がなければ、ツールは正しく最適化できず、「動くかどうかは運任せ」になります。

👉 イメージすると「設計者がツールに伝える“約束事”」です。

例えば **「この回路は100MHzで動かしたいよ。外のメモリはデータをクロックに対して 3ns 遅れて出してくるよ」** と伝えておかないと、ツールはその条件を考慮できません。



## クロックの役割

「なぜツールはクロックを解析する必要があるのか？」を整理すると、次の理由になります。

## 1. クロックが「動作の基準」だから

デジタル回路（特に同期回路）は、**フリップフロップのクロックエッジ**を基準にしてデータを受け渡します。

* セットアップ時間：次のクロックまでに信号が到着しているか？
* ホールド時間：クロック直後にデータが安定しているか？

このチェックを行うためには、ツールは **クロックの周期・位相・ジッタ** を知る必要があります。

→ だから制約で「クロック周期を○ns」と伝える。

## 2. 遅延の合否を判定するため

ツールが行う **タイミング解析 (Static Timing Analysis: STA)** は、

「レジスタ → 論理回路 → 配線 → レジスタ」までの**信号の伝播遅延**を計算し、

それがクロックのタイミングに間に合っているかをチェックします。

もしクロック情報がなければ、

* 伝播遅延が 5ns なのか、10ns なのかは分かっても、
* **それが “間に合う” のか “遅い” のかを判定できない** 。

## 3. 最適化の指標になる

配置配線ツールは「クロック制約」をもとに、どの程度高速化する必要があるか判断します。

* 例：クロック周期 10ns (100MHz) の制約 → 遅延を 10ns 未満に収めるように最適化
* 制約がない場合 → 「緩い条件」と見なされ、必要以上の高速化をしない（結果、実機では間に合わない）

## 4. 複数クロックドメインの扱い

FPGA では、PLL などで生成した **複数クロック** が存在するのが普通です。

ツールはクロックごとの

* 周期
* 位相関係
* 立ち上がり/立ち下がりエッジ

  を理解して、クロック間のデータ転送（クロックドメインクロッシング, CDC）を正しく解析します。

## まとめ

ツールがクロックを解析するのは：

1. **同期回路の動作基準がクロックだから**
2. **遅延が間に合うかどうかの合否判定に必要だから**
3. **配置配線の最適化目標を決めるため**
4. **複数クロックの関係を理解して CDC を扱うため**

---

👉 つまり、クロック解析は「回路が本当に指定した周波数で動作できるか？」を保証するために必須です。
