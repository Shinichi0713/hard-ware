とても良いステップですね！

ModelSim（またはQuestaSim）でも、**SystemVerilogの構文を使ったRTL＋テストベンチ**を動かすことができます。

ここでは、**カウンタ回路のSystemVerilog例**を使って、ModelSimで動かす最小構成の例題を紹介します。

（このまま動かせるシンプルなものです）

---

## 🧩 例題：4ビットアップカウンタ（SystemVerilog）

### 📄 `counter.sv`（デザイン本体）

```systemverilog
// 4ビットアップカウンタ
module counter (
    input  logic        clk,      // クロック
    input  logic        rst_n,    // 非同期リセット（負論理）
    output logic [3:0]  count     // カウント出力
);

    // カウンタ本体
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            count <= 4'd0;        // リセットで0
        else
            count <= count + 1;   // カウントアップ
    end

endmodule
```

> 🔸 `always_ff` は SystemVerilogの構文です。
>
> Verilogの `always @(posedge clk or negedge rst_n)` と同じ意味ですが、「フリップフロップ動作」であることを明示します。

---

### 📄 `tb_counter.sv`（テストベンチ）

```systemverilog
`timescale 1ns/1ps

module tb_counter;
    logic clk;
    logic rst_n;
    logic [3:0] count;

    // DUT（Device Under Test）のインスタンス
    counter dut (
        .clk   (clk),
        .rst_n (rst_n),
        .count (count)
    );

    // クロック生成：10ns周期
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // テストシーケンス
    initial begin
        // 初期化
        rst_n = 0;
        #12;
        rst_n = 1;

        // しばらくカウント
        #100;

        // 終了
        $finish;
    end

    // 波形表示（シミュレーションログ）
    initial begin
        $monitor("Time=%0t | rst_n=%b | count=%d", $time, rst_n, count);
    end

endmodule
```

---

## 🧰 ModelSimでのシミュレーション手順

以下はWindows版 ModelSim のGUI またはターミナル手順です。

### ① 新しいプロジェクトを作成

* [File] → [New] → [Project]
* 例：

  Project name: `sv_counter`

  Add Existing File: `counter.sv` と `tb_counter.sv` を追加

### ② コンパイル

ModelSimのTranscript（コマンドライン）で：

```bash
vlog counter.sv tb_counter.sv
```

成功すると：

```
-- Compiling module counter
-- Compiling module tb_counter
```

のように表示されます。

> ✅ `vlog` は SystemVerilogも自動認識します（拡張子 `.sv` の場合）。

---

### ③ シミュレーション実行

```bash
vsim tb_counter
```

---

### ④ 波形を表示

GUIの場合：

1. メニューから「Add → To Wave → All items in region」
2. 「Run 100 ns」または「run -all」で実行

またはコマンドラインで：

```bash
add wave *
run 100ns
```

---

### ⑤ 結果の確認

Transcript出力例：

```
# Time=0 | rst_n=0 | count=0
# Time=15 | rst_n=1 | count=0
# Time=25 | rst_n=1 | count=1
# Time=35 | rst_n=1 | count=2
# Time=45 | rst_n=1 | count=3
...
```

波形でも `count`が0→1→2→3…とカウントアップする様子が確認できます。

---

## ✅ ポイントまとめ

| 要素         | 内容                                   |
| ------------ | -------------------------------------- |
| 言語         | SystemVerilog (`.sv`)                |
| クロック駆動 | `always_ff`（推奨）                  |
| テストベンチ | `initial`ブロックと `$monitor`     |
| コマンド     | `vlog`,`vsim`,`add wave`,`run` |
| 出力確認     | Transcript または Waveウィンドウ       |

---

希望があれば次の例も紹介できます：

* ✅ SystemVerilogの `interface`を使った信号接続例
* ✅ UVMなしで書ける簡単な検証テストベンチ例
* ✅ 同じカウンタをFPGA合成向けに修正したRTL版

どれを見てみたいですか？
