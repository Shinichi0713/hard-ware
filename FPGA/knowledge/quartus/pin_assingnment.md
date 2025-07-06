
https://www.macnica.co.jp/business/semiconductor/articles/intel/95585/

資料
[ELS1411_Q1510_10__1.pdf](https://www.macnica.co.jp/business/semiconductor/articles/pdf/ELS1411_Q1510_10__1.pdf)

「Quartus Prime はじめてガイド - ピン・アサインの方法 ver.15.1」（ツール・バージョン：Ver.15.1 用ドキュメント）

ELS1364_Q1400_20__1.pdf

「Quartus II はじめてガイド - ピン・アサインの方法 ver.14」（ツール・バージョン：Ver.14.0 用ドキュメント（Rev.2））


## Live I/O Check
※ 事前に Analysis & Synthesis（Processing メニュー ＞ Start ＞ Start Analysis & Synthesis）以上のプロセスが実行されている必要があります。

 

Live I/O Check 機能の操作は、以下のとおりです。

 

① Pin Planner を起動します。（Assignments メニュー ＞ Pin Planner）

 

② View メニュー ＞ Live I/O Check Status Window を選択し、ウィンドウを表示させます。

 

③ Live I/O Check Status ウィンドウ内の Turn On Live I/O Check ボタン、

　 または Pin Planner 上の Processing メニュー ＞ Enable Live I/O Check ボタンをクリックし、ピン・アサインのチェックを実行します。


④ デザインで使用するユーザー I/O ピンや未使用ユーザー I/O ピンのアサイン (ピン番号、I/O 規格、Reserved オプションなど) を行います。

　 その都度チェックが行われ、I/O ルールに違反している場合は、Live I/O Check ウィンドウにエラーまたはワーニング・メッセージの数が

　 表示されます。同時に Pin Planner 上に現れた Messages ウィンドウ (System タブ) に、その内容がアナウンスされます。

　 メッセージの内容を確認し、メッセージのヘルプを活用しながら問題を回避します。


⑤ Live I/O Check ですべてのエラーを回避したら、I/O Assignment Analysis を実行し、さらに I/O ルールの検証を行います。

　 (I/O Assignment Analysis による検証後は、コンパイルを必ず実行してください。)