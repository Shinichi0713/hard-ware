とても良い質問です。

SystemVerilog（Verilogの拡張版、IEEE 1800規格）を動かせるシミュレータには、**商用ツール**と**オープンソースツール**の両方があります。

以下に、代表的なものを用途別に整理して説明します👇

---

## 🏢 【商用シミュレータ】（企業・研究開発で主流）

| ツール名                                         | 提供元                          | 特徴・概要                                                                               |
| ------------------------------------------------ | ------------------------------- | ---------------------------------------------------------------------------------------- |
| **Synopsys VCS**                           | Synopsys社                      | 高速・高機能。SystemVerilogの検証機能（UVM, Assertions, Coverage）に完全対応。業界標準。 |
| **Cadence Xcelium**                        | Cadence社                       | VCSと並ぶ代表的シミュレータ。強力なデバッグGUI（SimVision）付き。                        |
| **Siemens Questa (旧 ModelSim/QuestaSim)** | Siemens EDA (旧Mentor Graphics) | 教育・商用両対応。ModelSimは入門・教育向け、QuestaはUVM対応の上位版。                    |
| **Aldec Riviera-PRO**                      | Aldec社                         | GUIが軽量で使いやすい。SystemVerilog＋VHDL混在も得意。教育機関でも人気。                 |

🧩 いずれも **UVM (Universal Verification Methodology)** や **SystemVerilog Assertions (SVA)** に対応しています。

プロの開発環境ではこれらのいずれかがほぼ必須です。

---

## 💻 【オープンソース／無料シミュレータ】

| ツール名                             | 特徴                                                                                                                                                                        |
| ------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Verilator**                  | C++へ変換して高速実行するオープンソースシミュレータ。SystemVerilogの**設計構文（RTL部分）**に対応。ただし**検証構文（クラス・UVMなど）は未対応** 。高速・軽量。 |
| **Icarus Verilog (iverilog)**  | 軽量なVerilogシミュレータ。古いVerilog構文中心で、SystemVerilogの対応は限定的（部分対応）。テスト用には便利。                                                               |
| **Veriwell**                   | 歴史あるオープンソースVerilogシミュレータ。ただし更新が止まっており、SystemVerilogには非対応。                                                                              |
| **GHDL + VHPI/Verilog Bridge** | 主にVHDL用ですが、一部Verilog/SystemVerilogを扱えるような拡張があります。混在設計用。                                                                                       |

---

## 🎓 【教育・個人開発でよく使われる構成例】

| 用途                                        | 推奨ツール                                                         | 備考                                      |
| ------------------------------------------- | ------------------------------------------------------------------ | ----------------------------------------- |
| SystemVerilog RTL設計・簡易シミュレーション | **Verilator**                                                | 高速・C++モデル化できる。UVM不可。        |
| 初学者のVerilog/SystemVerilog基礎学習       | **QuestaSim (ModelSim Student Edition)**                     | 無料版あり。GUIで波形も見やすい。         |
| FPGA開発と連携（Intel/AMD環境）             | **ModelSim-Intel Edition**/**Xilinx Vivado Simulator** | FPGAツールに付属。SystemVerilog RTL対応。 |

---

## 🚀 まとめ

| 種類         | 代表的なツール                       | SystemVerilog対応 | 用途           |
| ------------ | ------------------------------------ | ----------------- | -------------- |
| 商用         | VCS / Xcelium / Questa / Riviera-PRO | ◎ 完全対応       | 業務・研究開発 |
| 無料         | Verilator / ModelSim Student         | △ 部分対応       | 学習・個人利用 |
| 非対応・古い | Icarus Verilog / Veriwell            | × または限定     | Verilogのみ    |

---

もしあなたが

💡「自分のPCで無料でSystemVerilogを試したい」

という場合には、

→  **Verilator + GTKWave** （波形表示ツール）

の組み合わせがおすすめです。
