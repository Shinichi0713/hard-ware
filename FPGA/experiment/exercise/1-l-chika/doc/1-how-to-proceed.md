## 目的
MAX10を用いたLチカを行います

## 参考
[参考](https://www.macnica.co.jp/business/semiconductor/articles/intel/113049/)

## Lチカ
基板上のプッシュボタンを押したときだけ LED が点灯し、
プッシュボタンを離すと消灯する、
この動作を FPGA を介して行わせます。
![alt text](image/1.png)

## 準備
- Quartus® Prime Standard Edition
- ModelSim* - Intel® FPGA Edition
- MAX® 10 FPGA 開発キット

## 開発ボードの接続構成

![alt text](image/2.png)

プッシュボタンとLEDは基盤上で図のような接続構成となっている

プッシュボタンを押したらLEDが点灯してプッシュを話すとLEDも消灯する。

FPGAのピンとLEDにつながっているFPGAのピンを単純につなげばよい。

- FPGAの中身は空っぽの箱
- プッシュボタンからの入力信号をFPGAが受信してFPGAを通る
- 信号をLEDへ出力するためのデジタル論理回路を設計

### 1. Quartus Prime  
インテル FPGA の開発ソフトウェア Quartus Prime を使用

#### 1. 論理回路を設計する
ここでは、プロジェクト名と最上位エンティティ名を presspb_led に設定します。 

ターゲットデバイスは、MAX 10 ファミリーの 10M50DAF484C6GES を選択します。

```vhdl
-- VHDL sample : presspb_led.vhd


library ieee;
use ieee.std_logic_1164.all;


entity presspb_led is
	port (
		PB	 :  in  std_logic;
		LED 	 :  out std_logic
	     );
end;


architecture rtl of presspb_led is 
begin 
	LED <= PB;			
end rtl;
```

```vhdl
// Verilog HDL sample : presspb_led.v


module presspb_led
(
	input	 PB,
	output LED
);


	assign LED = PB;


endmodule
```

#### 2. 論理シミュレーションをする
ModelSimで作成したデザインのRTLレベルシミュレーションを行う

>RTLレベル
>レジスタ転送レベル（レジスタてんそうレベル、英: register transfer level、RTL）は、論理回路の動作記述などにおいて、「ゲートレベル」よりも一段抽象的な記述レベルである。
>ゲートレベルでは、組合せ論理回路の（すなわち、状態を持たない）ゲートのネットリストを記述するが、レジスタ転送レベルでは、状態を持つラッチ回路など順序回路に相当する最小の部分を「レジスタ」として抽象化（ブラックボックス化）する。
>


>ネットリスト
>FPGA 内の電子回路（ハードウェア）の構成は、HDL というコードを使って書くことができます。

ネットリストとは、回路ブロックの接続関係を示したコードのことです。HDL を変換することで、ネットリストを作ることができます。
>HDL をネットリストに変換することを、「論理合成」とよびます。
>最終的に FPGA に書き込むのは、HDL のプログラムファイルではなく、このネットリストです。

https://zenn.dev/nekoallergy/articles/fpga-basic-02
ここを読んでください


>動作レベル　　　　　（抽象度：高）　: 普通のプログラミングはコレ
>レジスタ転送レベル　（抽象度：中）　: HDL で書くのはコレ
>ゲートレベル　　　　（抽象度：低）　: 実際に FPGA に書き込むのはコレ

