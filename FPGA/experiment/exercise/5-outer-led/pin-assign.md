`clk_50mhz`のピン配置は、使用するMAX10開発ボードによって異なります。以下に主要なボードでの配置を示します：

## **主要なMAX10開発ボード**

### **1. DE10-Lite（Terasic）**

**clk_50mhz → PIN_P11**

* []()
* []()
* []()
* []()
* **ピン名** : PIN_P11
* **I/O Standard** : 3.3-V LVTTL
* **ボード上の表記** : CLK (50MHz oscillator)

### **2. MAX10 NEEK（Altera/Intel）**

**clk_50mhz → PIN_N14**

* []()
* []()
* []()
* []()
* **ピン名** : PIN_N14
* **I/O Standard** : 3.3-V LVTTL

### **3. MAX10 Development Kit**

**clk_50mhz → PIN_M9**

* []()
* []()
* []()
* []()
* **ピン名** : PIN_M9
* **I/O Standard** : 2.5V

## **ピン配置の確認方法**

### **方法1: ボードのマニュアル確認**

1. 開発ボードのユーザーマニュアルを確認
2. "Clock Input" または "Oscillator" のセクションを探す
3. 50MHzクロック入力のピン番号を確認

### **方法2: サンプルプロジェクトの確認**

1. ボードメーカーのサンプルプロジェクトをダウンロード
2. `.qsf`ファイル内のクロックピン配置を確認
3. 以下のような記述を探す：

**set_location_assignment PIN_P11 -to clk_50mhz**

* []()
* []()
* []()
* []()

### **方法3: ボード上の表記確認**

開発ボード上で以下を探す：

* **CLK**
* **OSC**
* **50MHz**
* **CLOCK**

## **Quartus Primeでの設定方法**

### **Pin Plannerでの設定**

1. **Assignments → Pin Planner** を開く
2. `clk_50mhz` の行で **Location** 列にピン番号を入力
3. **I/O Standard** を適切に設定

### **.qsfファイルでの設定**

プロジェクトの `.qsf`ファイルに以下を追加：

**# DE10-Liteの場合**

**set_location_assignment PIN_P11 -to clk_50mhz**

**set_instance_assignment -name IO_STANDARD "3.3-V L**VTTL" -to clk_50mhz

* []()
* []()
* []()
* []()

## **注意事項**

### **1. 電圧レベル**

* 3.3V ボード: `3.3-V LVTTL`
* 2.5V ボード: `2.5V`
* 1.8V ボード: `1.8V`

### **2. クロック制約**

SDCファイルにクロック制約を追加：

**create_clock -name clk_50mhz -period 20.000 [get_p**orts clk_50mhz]

* []()
* []()
* []()
* []()

### **3. 信号品質**

* クロック信号は専用のクロックピンに配置
* グローバルクロックネットワークを使用
* 適切な終端抵抗を確保

## **不明な場合の対処法**

1. **ボードの型番を確認**
2. **メーカーのWebサイトでマニュアルをダウンロード**
3. **開発環境のサンプルプロジェクトを参照**
4. **ボード上のシルク印刷を確認**

使用している具体的なボード名があれば、より正確なピン配置をお教えできます。
