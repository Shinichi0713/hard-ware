## QuartusでIP

https://www.macnica.co.jp/business/semiconductor/articles/intel/133360/


## IPの使い方

1.  Quartus の IP Catalog (Tools メニュー) から生成したい IP を選び、ダブルクリック もしくは Add ボタンを押します。

![alt text](image.png)

2. 生成するフォルダ先とその末尾に IP のファイル名 (今回は sqrt ) を指定し、生成する言語の種類 (今回は Verilog) を選択　(図2)

![alt text](image-1.png)

3. 選択した IP の画面 (ウィザード) が表示されます。

このウィザードを用いて自分の仕様を満たす IP を簡単にパラメータ設定できます。　(図3)

また、この IP の詳細情報は、右上の Documentation ボタンをクリックすることで、ユーザーガイドが表示されます。

![alt text](image-2.png)

この ALTSQRT という IP の機能は「入力値を平方した値を出力する」というものです。
設定が完了したら Finish をクリックします。

なんと、コードが出現しました！　(図8)

私の想いが伝わったのかもしれません。

 

…でも実は、(後から先輩に教わったのですが)

図4 の Open (File メニュー) で sqrt.v ファイルを指定した後に

"Open as オプション" を "Auto" から "Text" に切り替えて [開く(O)] ボタンをクリックすれば、sqrt.v がテキスト・エディタで開くのだそうです。

あぁ、私が無知なだけでした。お恥ずかしい…。

 

コードを下にスクロールすると module 宣言、ポート接続、インスタンス化を行っている HDL コードも確認できました。

sqrt.v をプロジェクトの最上位デザインとして登録し、コンパイルを実行します。

![alt text](image-3.png)
