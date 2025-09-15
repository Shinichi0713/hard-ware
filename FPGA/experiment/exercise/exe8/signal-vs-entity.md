# signal VS entity

FPGA 設計（VHDL）の中で **`signal` と `entity` のポート変数**はよく混同されがちですが、それぞれ役割が違います。

---

# 🔹 `entity` のポート変数

* **FPGA の外部入出力インターフェース**を定義するものです。
* つまり「このモジュールが外の世界とやり取りする窓口」を表します。

### 例

```vhdl
entity my_module is
    Port (
        clk  : in  std_logic;    -- 入力ポート
        rst  : in  std_logic;    -- 入力ポート
        led  : out std_logic     -- 出力ポート
    );
end my_module;
```

* `clk`, `rst` は **外部から入力される信号**
* `led` は **外部に出力される信号**

これらは **モジュールの外との接点**なので、モジュール内部で直接値を保持する記憶領域ではありません。

> entityは外部インターフェースを定義するためのもの。
>
> モジュールが外の世界とやり取りする窓口。→外部からの入力と、外部への出力を示す。


---

# 🔹 `signal`

* **entity 内部の回路（アーキテクチャ内）で使う配線・レジスタ的なもの**です。
* 内部で状態を保持したり、処理の中間結果を渡すのに使います。

### 例

```vhdl
architecture rtl of my_module is
    signal counter : integer := 0;  -- 内部信号（レジスタとして動作）
begin
    process(clk, rst)
    begin
        if rst = '1' then
            counter <= 0;
            led <= '0';
        elsif rising_edge(clk) then
            counter <= counter + 1;
            if counter = 1000000 then
                led <= not led;
                counter <= 0;
            end if;
        end if;
    end process;
end rtl;
```

* `counter` は **signal** → 内部でカウント値を保持する
* `led` は **port** → 外部ピンに出力される


## 3. **Variable**

* **プロセス内限定で使える一時的な変数** 。
* 宣言例：
  <pre class="overflow-visible!" data-start="915" data-end="1086"><div class="contain-inline-size rounded-2xl relative bg-token-sidebar-surface-primary"><div class="sticky top-9"><div class="absolute end-0 bottom-0 flex h-9 items-center pe-2"><div class="bg-token-bg-elevated-secondary text-token-text-secondary flex items-center gap-4 rounded-sm px-2 font-sans text-xs"></div></div></div><div class="overflow-y-auto p-4" dir="ltr"><code class="whitespace-pre! language-vhdl"><span>process(clk)
    variable temp_var : integer := 0;
  begin
    if rising_edge(clk) then
      temp_var := temp_var + 1;  -- 即時反映
    end if;
  end process;
  </span></code></div></div></pre>
* 特徴：
  * 値の更新は  **即時** （C言語の変数に近い）。
  * そのプロセスの中でのみ有効。他のプロセスからは見えない。
  * クロック同期で使えば、最終的にはレジスタとして合成される。
  * 一方で、組み合わせ回路の一時的な計算にも使える。

# 🔹 `signal` と `entity port` の違いまとめ


| 種類               | 用途                 | 可視範囲         | 更新タイミング   | 実体化イメージ             |
| ------------------ | -------------------- | ---------------- | ---------------- | -------------------------- |
| **Port**     | モジュールの入出力   | モジュール外部   | 外部から制御     | FPGAピンや上位回路との接続 |
| **Signal**   | 内部の配線・状態保持 | モジュール内全体 | イベント後に反映 | 配線 or フリップフロップ   |
| **Variable** | 計算用一時変数       | プロセス内のみ   | 即時反映         | 組み合わせ回路 or レジスタ |

# 🔹 「signal として定義しないとどうなるか？」

* **内部で計算結果や状態を保持できなくなる**
  * 例えばカウンタを作るとき、`signal counter` がないと値が蓄積できない。
* **ポートに直接処理を書くことは基本できない**
  * `led <= led + 1;` のようにポートに直接書いても、コンパイルエラーになったり、シミュレーションでは動いても合成では不正になる場合が多い。
* つまり、**内部処理は必ず `signal`（または `variable`）を介す**のが普通です。

---

✅ まとめると

* `entity port` = 外部との接点（入出力の窓口）
* `signal` = 内部で値を保持したりやり取りする配線・レジスタ
* `signal` を使わないと「中間値や状態が記録できない」ので、ほとんどの実用回路は `signal` が必須
