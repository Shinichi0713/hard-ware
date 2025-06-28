


https://www.macnica.co.jp/business/semiconductor/articles/lattice/140830/

https://www.macnica.co.jp/business/semiconductor/articles/lattice/140830/


Seeed Studioの「7セグメント，4桁 LED 英数字表示器，赤」をFPGAで制御し、FPGAで読み取った値を表示したいということですね。

この表示器は多くの場合、「TM1637」や「74HC595」などのドライバICが搭載されているか、または「共通アノード/カソード型」で直接制御するタイプです。  
ここでは**一般的な4桁7セグメントLED（共通カソード/アノード型）**をFPGAで制御する方法を説明します。  
（もしTM1637などのI2C/シリアル制御IC搭載型の場合は、その旨を教えてください。）

---

## 1. 7セグメント4桁LEDの基本

- **7セグメントLED**：各桁にa～gの7本のLED＋小数点（dp）があり、合計8本の制御線。
- **4桁**：桁ごとに共通アノードまたはカソードがあり、ダイナミック点灯（タイムマルチプレクス）で制御するのが一般的。

### ピン構成例
- a, b, c, d, e, f, g, dp（セグメント制御，8本）
- digit1, digit2, digit3, digit4（桁制御，4本）

---

## 2. FPGAからの制御方法（ダイナミック点灯）

### 基本手順

1. **表示したい値（例：1234）を各桁ごとに分解**
2. **各桁の数字を7セグメントのビットパターンに変換**
3. **高速で桁ごとに制御線を切り替え（ダイナミック点灯）**
    - 例：1msごとにdigit1～digit4を順にONにし、その間に該当するセグメントを点灯
    - 目に見えるのは4桁同時点灯

---

## 3. Verilog設計例

以下は「FPGAで読み込んだ値（例：12ビットのADC値）」を4桁7セグメントLEDに表示する最小構成例です。

```verilog
module seg7_4digit(
    input wire clk,          // システムクロック（例：50MHz）
    input wire rst,          // リセット
    input wire [13:0] value, // 表示したい値（0～9999）
    output reg [7:0] seg,    // セグメント(a,b,c,d,e,f,g,dp)
    output reg [3:0] digit   // 桁アクティブ（1本だけLow/High）
);

reg [13:0] val;
reg [3:0] digit_num[3:0];
reg [1:0] scan; // 0~3

// クロック分周（例：1kHz周期で桁を切り替え）
reg [15:0] cnt;
always @(posedge clk or posedge rst) begin
    if(rst) cnt <= 0;
    else cnt <= cnt + 1;
end
wire tick = (cnt == 0);

// 10進変換（BCD変換）
always @(*) begin
    val = value;
    digit_num[0] = val % 10;
    val = val / 10;
    digit_num[1] = val % 10;
    val = val / 10;
    digit_num[2] = val % 10;
    val = val / 10;
    digit_num[3] = val % 10;
end

// 桁スキャン
always @(posedge clk or posedge rst) begin
    if(rst) scan <= 0;
    else if(tick) scan <= scan + 1;
end

// 桁アクティブ（共通カソードの場合、1本だけLow）
always @(*) begin
    digit = 4'b1111;
    digit[scan] = 0;
end

// 7セグメントパターン（共通カソード用、a~g,dp,active=Low）
function [7:0] seg_pattern;
    input [3:0] num;
    case(num)
        4'd0: seg_pattern = 8'b11000000;
        4'd1: seg_pattern = 8'b11111001;
        4'd2: seg_pattern = 8'b10100100;
        4'd3: seg_pattern = 8'b10110000;
        4'd4: seg_pattern = 8'b10011001;
        4'd5: seg_pattern = 8'b10010010;
        4'd6: seg_pattern = 8'b10000010;
        4'd7: seg_pattern = 8'b11111000;
        4'd8: seg_pattern = 8'b10000000;
        4'd9: seg_pattern = 8'b10010000;
        default: seg_pattern = 8'b11111111; // blank
    endcase
endfunction

// 現在の桁の数字を表示
always @(*) begin
    seg = seg_pattern(digit_num[scan]);
end

endmodule
```

---

## 4. 接続例

- **seg[7:0]**をLEDのa,b,c,d,e,f,g,dpピンに接続
- **digit[3:0]**を各桁の共通カソード/アノードに接続（ボード仕様に合わせて極性注意）

---

## 5. 注意点

- **共通カソード/アノードの違い**によって極性が逆になるので、ボード仕様を必ず確認してください。
- **FPGAの出力電流制限**に注意。場合によってはトランジスタや外部ドライバICを使うこと。
- **TM1637等のIC搭載型**の場合は、この例ではなくI2Cライクなシリアル制御が必要です（その場合は再度ご質問ください）。

---

## 6. 応用

- ADC値やセンサ値を`value`に入れることで、リアルタイムに計測値を表示できます。
- 小数点(dp)の制御や、英字表示も可能（追加のパターン定義が必要）。

---

もし使っている表示器が「TM1637」等のIC搭載型でしたら、その旨ご指摘いただければ**TM1637用のFPGA制御例**もご案内します。

以上です。