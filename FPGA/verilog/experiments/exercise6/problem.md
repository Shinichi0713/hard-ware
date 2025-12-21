## FSM（中級）

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
