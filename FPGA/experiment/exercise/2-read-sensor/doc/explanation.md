## FPGAでセンサーread

FPGA（MAX10）を使って「センサー→UART→FPGA→PC」へデータを送る構成を実現する場合、  
以下のようなシステム構成が一般的です。

### 1. **全体構成イメージ**

```
[センサー] --UART--> [MAX10 FPGA] --UARTまたはUSB, RS232--> [PC]
```

### 2. **構成要素と役割**

#### (1) **センサー**
- UARTインターフェースでデータを出力

#### (2) **MAX10 FPGA**
- センサーからのUARTデータを受信（UART Rx回路）
- 必要ならデータ整形やバッファリング
- PCにデータを送信（UART Tx回路）

#### (3) **PC**
- FPGAからのデータを受信（USB-UARTコンバータやRS232などを利用）
- 受信ソフト（ターミナルソフトや自作プログラム等）


### 3. **具体的な構成例**

#### A. **UART to UART（PCにシリアルポートがある場合）**

1. センサーからのUART信号をFPGAで受信
2. FPGAは受信データをそのまま、または加工してUARTでPCに送信
3. PCはUSB-UART変換器（例：FT232, CP2102など）で受信

**メリット**: シンプル  
**注意点**: UARTの電圧レベル（3.3V/5V）に注意


#### B. **UART to USB（PCにシリアルポートがない場合）**

1. FPGAのUART Tx/RxをUSB-UART変換IC（例：FT232RL, CP2102）に接続
2. USBケーブルでPCに接続
3. PC側はCOMポートとして認識される


#### C. **FPGAでUSBデバイスを実装（難易度高）**

- MAX10でUSBデバイスコアを実装し、直接USB通信を行う  
（ただしUSBプロトコルの実装は難易度が高い）


### 4. **信号レベルの注意**

- センサーとFPGA、FPGAとUSB-UART変換器の**電圧レベル**（3.3V/5V）を必ず確認してください。
- 必要ならレベルシフタを使用。


### 5. **FPGA側の主な回路・設計例**

- **UART Rx回路**（センサーから受信）
- **バッファ or FIFO**（データを一時保存）
- **UART Tx回路**（PCへ送信）
- 必要なら**プロトコル変換やパケット化**


### 6. **PC側のソフト例**

- ターミナルソフト（TeraTerm, PuTTYなど）
- Python等でシリアル通信プログラム（`pyserial`など）


### まとめ

> **センサー(UART)→MAX10 FPGA(UART受信・送信)→USB-UART変換IC→PC(シリアル受信)**  
> の構成がシンプルかつ現実的です。FPGAではUART受信・送信回路（IPコアや自作）を用意し、PCとはUSB-UART変換器経由で通信するのが一般的です。

---

![alt text](image.png)

ここでかいてある温度はどこの？
内部温度らしいで。

```vhdl
-------------------------------------------------------------------------------
-- Project   : MAX10 Evaluation Kit (TSD温度読み出し)
-- File      : top.vhd
-- Title     : Top
--------------------------------------------------------------------------------
--+-----+-----------+-----------------------------------------------------------
-- Ver   Date        Description
--+-----+-----------+-----------------------------------------------------------
-- 00.00 2020/12/07  Created
--+-----+-----------+-----------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity top is
  PORT
  (
    clk_i       : in  std_logic;      -- 50MHz
    rst_ni      : in  std_logic       -- リセット(負論理)
  );
end top;

architecture rtl of top is
-- コンポーネント宣言
component max10_adc is
  port (
    clk_clk       : in std_logic := 'X'; -- clk
    reset_reset_n : in std_logic := 'X'  -- reset_n
  );
end component max10_adc;

begin
-- モジュール接続
u_max10_adc : component max10_adc
  port map (
    clk_clk       => clk_i,       --   clk.clk
    reset_reset_n => rst_ni       -- reset.reset_n
  );

end rtl;
```

__ADCピン__  
AD変換を行うことが出来るピン


__JTAG__  
JTAG(ジェイタグ)とは、シリアル通信でICの内部回路と通信する仕組み
最初にJTAGが登場したとき(1990年ごろ)は、「基板検査」のための標準規格
その手軽さゆえに、いまでは各メーカーがオプション機能やプライベート命令を使って勝手に拡張し、もはや「総合デバッグインタフェース」として使われています。

JTAGの信号線
JTAGは4本の信号で、いろいろな信号をやりとりします。

TCK（クロック）
TDI（データ入力）
TDO（データ出力）
TMS（状態制御）
このほかに、TRSTというリセット信号が含まれる場合があります。

JTAG信号の電気的特性
これらの信号の電気的特性は、規格では定められていません。
各デバイスごとに、CMOSだったり、LVTTLだったり、LVCMOS18だったり、まちまちです。

JTAGは何ができるの？
FPGAの書き込みや、CPUのデバッグ、基板検査、ICの内部回路とパソコン間での通信などができます。



## 温度センサーの値を読み込む

https://tetsufuku-blog.com/max10-adc-temperature/

## ADC ツールキット
Quartus® Prime ソフトウェアで提供されるADC ツールキットを使用して、 MAX® 10 ADC ブロックにおけるアナログ信号チェーンの性能を知ることができます。
ADC ツールキットは、アルテラモジュラーADC またはアルテラモジュラー・デュアルADC IP コアのどちらの使用においても、ADC のモニタリングをサポートします。ただし、ADC ツールキットはADC ブロックを一度に1 つのみモニタリングすることができます。 アルテラモジュラー・デュアルADC IP コアを使用する場合、IP コアでDebug Path のパラメーターを設定して、ADC ツールキットに接続させたいADC ブロックを選択します。

## ADCツールキットはどのようにしてFPGAの値を可視化しているのか

---

## 1. ADCツールキットとは？

ここでいう「ADCツールキット」とは、たとえばNI LabVIEWの「Analog-to-Digital Converter Toolkit」や、FPGA開発ボードに付属するアナログ信号観測用のツール群（例：XilinxのXADC、IntelのADC IPコア）などを指していると仮定します。

---

## 2. 可視化の仕組み

### （1）FPGA内でのデータ取得

FPGAにはADC（アナログ-デジタル変換器）が搭載されている場合があります。  
- 外部アナログ信号（例：センサ出力）をADCでデジタル値に変換します。
- そのデジタル値は、FPGAの内部ロジック（Verilog/VHDLやHLSで記述）で取得できます。

### （2）データの転送

FPGA内で取得したデジタル値を、PCやホスト側に送る必要があります。  
これにはいくつかの方法があります：

- **JTAG経由**  
  開発環境（例：Vivado、Quartus）からJTAG経由でFPGA内の信号をモニタリングできる。
- **UARTやUSB経由**  
  FPGAからシリアル通信やUSB通信でPCに値を送る。
- **Ethernet経由**  
  Ethernetコントローラを使い、ネットワーク経由でデータを送る。
- **オンチップ・デバッグ用IPコア**  
  Xilinxなら「ILA（Integrated Logic Analyzer）」、Intelなら「SignalTap」など、FPGA内信号をリアルタイムでPCに可視化する専用IPコアを使うことも多い。

### （3）PC側での可視化

PC側で受け取ったデータは、  
- LabVIEWやMATLABなどのツールでグラフ表示  
- VivadoやQuartusのデバッグツールでリアルタイム波形表示  
- 独自アプリ（Pythonなど）でプロット  

など、さまざまな方法で「可視化」できます。

---

## 3. 具体例：Xilinx FPGA + XADC + Vivado

1. **アナログ信号**をXADCピンに入力  
2. **XADC IPコア**でデジタル値を取得  
3. 取得値をFPGA内部バスに展開  
4. **ILA（Integrated Logic Analyzer）IPコア**に信号を接続  
5. Vivado HW ManagerからJTAG経由でリアルタイム波形観測

---

## 4. まとめ

- ADCツールキットは、「FPGA内のADC回路で取得した値」を「何らかの通信経路（JTAG, UART, USB, Ethernet, オンチップデバッグ）」でPCに送り、**PC側の可視化ツールでグラフや波形として表示**しています。
- そのためには、**FPGA側の設計（IPコアや通信回路）とPC側の可視化アプリ**が連携しています。

---

もし具体的なFPGAボードやADCツールキット名がわかれば、さらに詳細な説明やサンプルもご案内できます。

以上です。

