# Lチカ再び
## 目的
以前のLチカが今一つだったので、再トライ。

https://tetsufuku-blog.com/max10-evaluation-kit-led-hw/

![alt text](image-3.png)

LEDが5個あるので2個はハード制御、残り3個はソフト制御

## プログラムできない原因
指定通りしたはずなのに、プログラムがfailしている。
原因について確認する。

ファイル構成は以下のようになっている。
![alt text](image-4.png)

ファイルが一つ不足している。
→あまり関係ないファイルっぽい。

![alt text](image-5.png)

ここみてsdcファイル追加した

http://star.a.la9.jp/Quartus/Quartus17_1/HLS/tutorial7.html