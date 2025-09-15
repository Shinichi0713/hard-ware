# 作成物

こんな回路。

入力ボタンにより点滅速度を制御する論理回路。

![1757912863997](image/explanation/1757912863997.png)

PLL回路：クロック信号の周波数を逓倍や分周、クロックの位相をシフトする回路

カウンタ回路：入力されたクロックの家運とを行う回路

セレクタ回路：複数入力のうち、一つを選択する回路


ご提示のエラーを見ると、**Quartus Prime がトップレベルのエンティティ（デザインの最上位モジュール）を見つけられない** ことが原因です。順を追って解消方法を整理します。

---

## 1️⃣ エラー内容の整理

```
Error (12007): Top-level design entity "light-illumination" is undefined
```

* Quartus が **"light-illumination" という名前のトップモジュール** を探しているが、存在しない
* 原因は主に以下です：
  1. エンティティ名の誤り
  2. VHDL/Verilogファイルがプロジェクトに追加されていない
  3. トップレベルとして指定した名前と実際のエンティティ名が一致していない

---

## 2️⃣ 解消手順

### Step 1: ファイルとエンティティ名を確認

* VHDLの場合：

```vhdl
library ieee;
use ieee.std_logic_1164.all;

entity light_illumination is  -- ← ここが正しい名前か？
    port(
        ...
    );
end light_illumination;
```

* **注意** : `light-illumination` とハイフン `-` はVHDLでエンティティ名として使えません。

  → エラーの原因はここです。VHDLでは `_` を使いましょう。

### Step 2: プロジェクトに正しいファイルを追加

* Quartus Project Navigator で
  * **Project → Add/Remove Files in Project**
  * トップレベルエンティティが書かれたファイルが追加されているか確認
* 追加されていなければ追加する

### Step 3: トップレベルエンティティの指定を修正

* **Assignments → Settings → General → Top-level entity**
  * トップレベルのエンティティ名を正しいものに変更
  * VHDLなら `light_illumination` のように `_` を使う

### Step 4: 再コンパイル

* 変更後 **Compile → Start Compilation**
* エラーが解消されるはず

---

## 3️⃣ 注意点

* VHDLでは **ハイフン `-` は識別子として使用不可**
* Verilog でもハイフンはNG（アンダースコア `_` を使う）
* ファイル名とエンティティ名は一致させる必要はないが、**トップレベルエンティティの名前は正確に指定すること**

---

💡 **まとめ**

1. トップレベルエンティティ名にハイフンを使っていないか確認
2. VHDL/Verilogファイルがプロジェクトに追加されているか確認
3. Quartusでトップレベルエンティティを正しい名前に設定
4. 再コンパイル

---

もしよければ、私は **ハイフンを `_` に修正したVHDLトップレベル例** を示して、Quartusでコンパイルできる形に直すこともできます。

作ってほしいですか？
