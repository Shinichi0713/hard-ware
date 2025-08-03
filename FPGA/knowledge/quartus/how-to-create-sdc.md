SDC（Synopsys Design Constraints）ファイルの作成手順を詳しく説明します。

## **Step 1: SDCファイルの新規作成**

### **方法1: Quartus Prime内で作成**

1. **File → New** を選択
2. **Other Files** タブを選択
3. **Synopsys Design Constraints File** を選択
4. **OK** をクリック

### **方法2: テキストエディタで作成**

1. プロジェクトフォルダに新しいファイルを作成
2. ファイル名: `led_chaser.sdc` または `プロジェクト名.sdc`
3. 拡張子は必ず `.sdc`

## **Step 2: 基本的なSDCファイルの作成**

Created [led_chaser.sdc](vscode-file://vscode-app/c:/Users/yoshinaga/AppData/Local/Programs/Microsoft%20VS%20Code/resources/app/out/vs/code/electron-browser/workbench/workbench.html)

## **Step 3: SDCファイルをプロジェクトに追加**

### **方法1: プロジェクトに手動追加**

1. **Project → Add/Remove Files in Project** を選択
2. **Files** タブで `led_chaser.sdc` を選択
3. **Add** をクリック

### **方法2: .qsfファイルに直接追加**

プロジェクトの `.qsf` ファイルに以下を追加：

**set_global_assignment -name SDC_FILE led_chaser.sd**c

```sdc
set_global_assignment -name SDC_FILE led_chaser.sdc
```

## **Step 4: SDC制約の詳細説明**

### **クロック制約**

**# 基本クロック定義（50MHz = 20ns周期）**

**create_clock -name clk_50mhz -period 20.000 [get_p**orts clk_50mhz]

**# PLL由来のクロックを自動的に派生**

**derive_pll_clocks -create_base_clocks**

```sdc
# 基本クロック定義（50MHz = 20ns周期）
create_clock -name clk_50mhz -period 20.000 [get_ports clk_50mhz]

# PLL由来のクロックを自動的に派生
derive_pll_clocks -create_base_clocks
```

### **入出力遅延**

**# 入力遅延（外部デバイスからの遅延を考慮）**

**set_input_delay -clock clk_50mhz -max 2.0 [get_por**ts reset_n]

**set_input_delay -clock clk_50mhz -min 0.5 [get_por**ts reset_n]

**# 出力遅延（外部デバイスへの遅延を考慮）**

**set_output_delay -clock [get_clocks {*pll*c0}] -ma**x 2.0 [get_ports led_out[*]]

```
# 入力遅延（外部デバイスからの遅延を考慮）
set_input_delay -clock clk_50mhz -max 2.0 [get_ports reset_n]
set_input_delay -clock clk_50mhz -min 0.5 [get_ports reset_n]

# 出力遅延（外部デバイスへの遅延を考慮）
set_output_delay -clock [get_clocks {*pll*c0}] -max 2.0 [get_ports led_out[*]]
```

### **偽パス設定**

**# 非同期リセットは偽パスとして設定**

**set_false_path -from [get_ports reset_n] -to [all_**registers]

```
# 非同期リセットは偽パスとして設定
set_false_path -from [get_ports reset_n] -to [all_registers]
```

## **Step 5: SDC制約の検証**

### **タイミング解析実行**

1. **Tools → Timing Analyzer** を起動
2. **File → Open SDC File** で作成したSDCファイルを開く
3. **Tasks → Update Timing Netlist** を実行
4. **Tasks → Read SDC File** を実行

### **制約の確認**

1. **Reports → Clocks** でクロック制約を確認
2. **Reports → Setup Summary** でセットアップ時間を確認
3. **Reports → Hold Summary** でホールド時間を確認

## **Step 6: 一般的なSDC制約パターン**

### **マルチサイクルパス**

**# 2クロックサイクルで完了するパス**

**set_multicycle_path -setup -end 2 -from [get_regis**ters counter*] -to [get_registers result*]

**set_multicycle_path -hold -end 1 -from [get_regist**ers counter*] -to [get_registers result*]

```
# 2クロックサイクルで完了するパス
set_multicycle_path -setup -end 2 -from [get_registers counter*] -to [get_registers result*]
set_multicycle_path -hold -end 1 -from [get_registers counter*] -to [get_registers result*]
```

### **最大遅延制約**

**# 組み合わせ論理の最大遅延**

**set_max_delay -from [get_registers data_in*] -to [**get_ports data_out*] 10.0

```
# 組み合わせ論理の最大遅延
set_max_delay -from [get_registers data_in*] -to [get_ports data_out*] 10.0
```

### **クロックグループ**

**# 非同期クロック間の制約を除外**

**set_clock_groups -asynchronous -group [get_clocks **clk_50mhz] -group [get_clocks {*pll*c0}]

```
# 非同期クロック間の制約を除外
set_clock_groups -asynchronous -group [get_clocks clk_50mhz] -group [get_clocks {*pll*c0}]
```

## **Step 7: コンパイル時の確認**

### **制約が適用されているか確認**

1. プロジェクトをコンパイル
2. **Compilation Report → Timing Analyzer** を確認
3. **Setup Slack** と **Hold Slack** が正の値であることを確認

### **警告やエラーの対処**

* **Warning** : 制約が見つからないポートがある場合は、ポート名を確認
* **Error** : 制約の文法エラーがある場合は、SDCファイルを修正

## **トラブルシューティング**

### **よくある問題**

1. **クロック名の不一致** : PLL生成後にクロック名を確認
2. **ポート名の間違い** : VHDLファイルのポート名と一致させる
3. **パス指定の誤り** : ワイルドカード（*）を適切に使用

### **デバッグ方法**

1. Timing Analyzerで制約を個別に確認
2. シンプルな制約から始めて段階的に追加
3. コンパイルレポートでタイミング結果を詳細確認

このSDCファイルにより、適切なタイミング制約が設定され、設計の信頼性が向上します。
