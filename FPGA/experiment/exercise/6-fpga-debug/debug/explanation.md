このエラーは、**VHDLプロジェクトの「work」ライブラリに `in_system_source_inst` というエンティティ（またはアーキテクチャ）が見つからない**ことを示しています。

---
## エラー内容の解説

> Error (10481): VHDL Use Clause error at debug_test.vhd(23): design library "work" does not contain primary unit "in_system_source_inst". Verify that the primary unit exists in the library and has been successfully compiled.

- **workライブラリ**は、通常ユーザーが作成したVHDLファイルがコンパイルされるデフォルトのライブラリです。
- **primary unit**とは、VHDLの`entity`や`package`などのトップレベル設計単位のことです。
- このエラーは「**in_system_source_instというエンティティ（またはパッケージ）がworkライブラリに存在しない**」= **Quartusがその部品の中身を見つけられない**ことを示しています。

---

## 主な原因

1. **in_system_source_inst.vhd**というソースファイルが**プロジェクトに追加されていない**  
2. **in_system_source_inst.vhd**が**コンパイルされていない**  
3. ファイル名やエンティティ名の**スペルミス**  
4. **IPコアや自動生成モジュール**の場合は、その生成やインポートに失敗している  
5. **component宣言だけ**で、**実体（entity/architecture）がない**

---

## 対処方法

### 1. **ソースファイルが存在し、プロジェクトに追加されているか確認**
- `in_system_source_inst.vhd` というVHDLファイルが存在し、Quartusプロジェクトに追加されていますか？

### 2. **エンティティ名の一致を確認**
- ファイル内で
  ```vhdl
  entity in_system_source_inst is
      ...
  end entity;
  ```
  となっていますか？  
  （スペルや大文字・小文字が違うとエラーになります）

### 3. **IPコアの場合**
- もし「in_system_source_inst」が**IPコア**や**Qsys/Platform Designerで自動生成されたモジュール**の場合は、  
  - 必要なファイル（.vhd, .qip, .sopcinfoなど）が**正しく生成・追加**されているか
  - **IP生成後に再度プロジェクトに追加**したか
  を確認してください。

### 4. **コンパイル順序の確認**
- 必要なファイルが**先にコンパイル**されている必要があります。  
  Quartusでは「ファイルの順序」は自動で管理されますが、手動で追加した場合は順序が狂うことがあります。

### 5. **component宣言と実体の違い**
- `component`宣言は**部品の「型」宣言**であり、**本体（entity/architecture）が別途必要**です。

---

## まとめ

- **in_system_source_instの本体（entity/architecture）がプロジェクトに存在し、正しく追加・コンパイルされているか確認してください。**
- IPコアの場合は、**IPコアの再生成とファイルの追加**を行ってください。

---

### 参考：よくある修正手順

1. Quartusで「Project」→「Add/Remove Files in Project」で `in_system_source_inst.vhd` を追加
2. 必要なら「IP Catalog」でIPコアを再生成
3. 「Analysis & Synthesis」を再実行

---

分からない場合は、  
- `in_system_source_inst` の**実体（entity/architecture）を定義したファイルの中身**や  
- そのファイルが**プロジェクトに追加されているかどうか**  
を確認してください。

以上です。