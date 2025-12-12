以下に、教育・研修・採用試験などで利用できる「適度な難度の SystemVerilog 課題」を体系化して提示します。
演習目的、難易度、解答のポイントを整理しているため、そのまま課題資料として利用できます。

---

# SystemVerilog 課題セット

## 1. 基礎課題（初級）

### 課題1：符号なし4ビット加算器のモジュールを実装せよ

**目的**
module 宣言、`logic` 型、assign、連結、桁上がりの理解。

**仕様**

* 入力 A, B は 4bit
* 出力 SUM は 4bit
* 桁上がり CARRY_OUT を 1bit で出力すること

**課題**

```sv
module adder4 (
    input  logic [3:0] A,
    input  logic [3:0] B,
    output logic [3:0] SUM,
    output logic       CARRY_OUT
);
    // 実装せよ
endmodule
```

---

## 2. コンビネーション回路（初級）

###課題2：3入力優先度付きエンコーダを設計せよ
**仕様**

* IN2 > IN1 > IN0 の優先度
* 出力は2bitの ENCODE
* 入力が 000 の場合、VALID=0

---

## 3. 順序回路（中級）

###課題3：8bit レジスタファイル（1 read, 1 write）を作成せよ
**仕様**

* レジスタ数：8
* 各レジスタのビット幅：8 bit
* write: `we=1` のとき `reg[wr_addr] = wr_data`
* read: `rd_data = reg[rd_addr]`（組み合わせ論理で良い）
* 初期化はリセット時に 0

---

## 4. FSM（中級）

### 課題4：交通信号制御器の有限状態マシンを作れ

**目的**
SystemVerilog の `enum`, `always_ff`, `always_comb`, `unique case` の使用。

**仕様**

* 状態
  * S_RED (3秒)
  * S_GREEN (3秒)
  * S_YELLOW (1秒)
* クロック 1 Hz を想定
* 状態遷移：RED→GREEN→YELLOW→RED

**課題**

* FSM を `enum logic [1:0] state_t` で定義
* カウンタを用いて時間を管理せよ

---

## 5. Testbench（中級）

### 課題5：任意の DUT に対してテストベンチを書け

対象は課題1（4-bit adder）でよい。

**Testbench 要件**

* 動的配列または `for-loop` を使って複数のパターンを自動テスト
* `$display` または `assert` を利用
* 波形出力（dump）を有効化
* ランダムテストも追加すること
  * `repeat (10) begin A=$urandom; B=$urandom; end`

---

## 6. Interface（中級〜上級）

### 課題6：簡易バスインタフェースを interface で定義せよ

**仕様**

* 以下の信号を持つ：
  * `addr[7:0]`, `wdata[7:0]`, `rdata[7:0]`, `we`, `re`, `valid`, `ready`
* Master/Slave モジュールを分ける
* Master がリクエストし、Slave が応答する構造

**課題**

* interface を作成
* modport master/slave を定義
* bus_master.sv, bus_slave.sv を作る
* 簡易テストベンチで動作確認

---

## 7. Class と Randomize（上級）

### 課題7：SystemVerilog の OOP を用いてランダムトランザクションクラスを作れ

**仕様**

* トランザクション `Transaction` class
  * addr: rand logic[7:0]
  * data: rand logic[7:0]
  * direction: rand bit (0=read, 1=write)
* 制約
  * addr は 0x10〜0xF0 の範囲
  * write のときは data != 0
* randomize() によるパターン生成
* 10個のトランザクションを作成して表示する

---

## 8. UVM（最上級）

### 課題8：軽量 UVM 環境でバストランザクションを検証せよ

**構成**

* sequence
* driver
* monitor
* scoreboard
* environment

**課題**

* 単純な write/read シーケンスを動作させ
* Monitor 経由で scoreboard で一致検証を行う。

---

# 必要であれば

以下も作成可能です。

* 各課題の模範解答
* テストベンチのフルコード
* 課題を PDF に整形
* 内容を初学者向けに簡易化
* UVM なしの中規模プロジェクト課題
* FPGA（Intel/AMD）向け課題

必要な形式を教えてください。
