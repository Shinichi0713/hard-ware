VHDLの **`generic`** に相当するSystemVerilogの機能は、**`parameter`** です。

VHDLの `generic` と同様に、モジュールの設計時に値を固定せず、**インスタンス化する際に外部から値を書き換える（カスタマイズする）**ために使用します。

---

## 1. 基本的な書き方

SystemVerilogでは、モジュール名の直後の `#( )` の中に `parameter` を定義します。

### SystemVerilogでの定義 (`parameter`)

**コード スニペット**

```
module my_module #(
    parameter int WIDTH = 8,        // VHDLの generic に相当（デフォルト値8）
    parameter int DEPTH = 16
)(
    input  logic [WIDTH-1:0] data_in,
    output logic [WIDTH-1:0] data_out
);
    // 内部処理
    assign data_out = data_in;
endmodule
```

### インスタンス化（値の渡し方）

インスタンス化の際にも `#( )` を使って値を指定します。

**コード スニペット**

```
// WIDTHを16に書き換えてインスタンス化
my_module #( .WIDTH(16) ) inst1 (
    .data_in(sig_a),
    .data_out(sig_b)
);
```

---

## 2. VHDLとSystemVerilogの対応表

| **機能**           | **VHDL (generic)**           | **SystemVerilog (parameter)**     |
| ------------------------ | ---------------------------------- | --------------------------------------- |
| **定義場所**       | `entity`の `generic`句         | `module`名直後の `#( )`             |
| **デフォルト値**   | `:=`で指定                       | `=`で指定                             |
| **型指定**         | `integer`,`std_logic_vector`等 | `int`,`bit`,`logic`等（型省略可） |
| **インスタンス時** | `generic map`を使用              | `#( )`を使用                          |

---

## 3. さらに高度な機能：`localparam` と `specparam`

SystemVerilogには、用途に応じて `parameter` 以外のバリエーションもあります。

* **`parameter`** : 外部（上位モジュール）から値を変更可能。VHDLの `generic` そのもの。
* **`localparam`** : モジュール内部のみで有効な定数。**外部からは変更できません。** VHDLで `package` や `architecture` 内に定義する `constant` に近いです。
* **`type parameter`** : データ型そのものをパラメータ化できます。これはVHDLの `generic` よりも強力な機能です。

### `type parameter` の例

**コード スニペット**

```
module wrapper #(
    parameter type T = logic [7:0] // 型そのものをパラメータにする
)(
    input T data_in,
    output T data_out
);
    assign data_out = data_in;
endmodule

// インスタンス化の際に型を指定できる
wrapper #( .T(int) ) inst_int (...);
```
