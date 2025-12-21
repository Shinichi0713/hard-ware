## 順序回路（中級）

###課題3：8bit レジスタファイル（1 read, 1 write）を作成せよ
**仕様**

* レジスタ数：8
* 各レジスタのビット幅：8 bit
* write: `we=1` のとき `reg[wr_addr] = wr_data`
* read: `rd_data = reg[rd_addr]`（組み合わせ論理で良い）
* 初期化はリセット時に 0
