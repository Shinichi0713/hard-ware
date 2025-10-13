# 基本構文

Verilogの基本構文について学習する。

Verilogで設計を始める際、最も基本的な単位となるのが「モジュール（module）」。


## モジュール
モジュールは、回路の構成要素を表しており、入出力や内部構造を記述する場所。

moduleというキーワードでモジュールを定義し、endmoduleで終了します。

```verilog
module AND_gate (
    input wire a, // 入力a
    input wire b, // 入力b
    output wire y // 出力y
);
    assign y = a & b; // AND演算
endmodule
```

## データ型の種類
- wire: 配線を表します。信号を接続する
- reg: レジスタを表します。クロックに同期して値を保持するために利用。
wireとreg
regはレジスタ。クロック同期の値を保持する。
```verilog
module Example (
    input wire clk,    // クロック入力
    input wire rst,    // リセット入力
    input wire a,      // 入力a
    output reg y       // 出力y
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            y <= 0;    // リセット時、出力を0に
        else
            y <= a;    // クロック時、入力aを出力yに代入
    end
endmodule
```

## always
組合せや、順序回路における基本構文。
繰り返し実行されるプロセスを定義するための構文。

```verilog
always @(感度リスト) begin
    // 実行したい処理
end
```

🔹 感度リストとは？

@() の中に、「どんな信号の変化でこの処理を実行するか」を書きます。
これによって、どのような回路が合成されるかが決まります。

例: 組み合わせ回路
```verilog
always @(*) begin
    y = a & b | c;
end
```
- @(*) は すべての入力信号の変化に反応する、という意味。
- begin〜end内で、**代入演算子は=（ブロッキング代入）**を使うのが一般的。
- 合成結果は**論理回路（ゲートなど）**になります。

例: 順序回路
```verilog
always @(posedge clk or negedge reset_n) begin
    if (!reset_n)
        q <= 0;
    else
        q <= d;
end
```
- posedge clk … クロックの立ち上がりで処理を実行
- negedge reset_n … リセット信号の立ち下がりで処理を実行
- 非ブロッキング代入 <= を使うのが原則（レジスタ動作）
- 合成結果はフリップフロップになります。


### 並列処理の考え方
Verilogは、並行処理が可能なハードウェアの記述をサポート
alwaysブロックごとに独立したプロセスが実行され、実際のハードウェア回路に近い動作を記述できる。

```verilog
always @(posedge clk) begin
    a <= b + 1;
end

always @(posedge clk) begin
    c <= d - 1;
end
```

シミュレーションと合成の違い
シミュレーション: 設計した回路が期待通りに動作するかをソフトウェア上で検証するプロセス。
合成: 設計を実際のハードウェアに変換するプロセス。
Verilogでは、シミュレーション用に記述されたコード（例えばinitialブロック）は、合成には使われません。そのため、合成可能なコードと、シミュレーション用のコードを明確に分けることが重要です。


## 制御構造（if, case）
### if
条件分岐にif文を利用する。

```verilog
always @(posedge clk) begin
    if (a == 1'b1)
        y <= 1'b0;  // aが1の場合、yを0に設定
    else
        y <= 1'b1;  // それ以外の場合、yを1に設定
end
```

### case
複数の条件を分岐したい場合、caseを利用すると効率的。
状態遷移を表す例。

```verilog
always @(state) begin
    case (state)
        2'b00: y = 1'b0;
        2'b01: y = 1'b1;
        2'b10: y = 1'b0;
        2'b11: y = 1'b1;
        default: y = 1'bx; // 不明な状態
    endcase
end
```

## 代入
- ブロッキング代入：一連の処理が順次実行される。プログラムが順番に実行されるソフトウェアのように動作
- ノンブロッキング代入：並行して値が更新される。並行して動作するハードウェアを正確に記述する際に用いられる。

```verilog
always @(posedge clk) begin
    a = b;     // ブロッキング代入
    c <= d;    // ノンブロッキング代入
end
```
