はい！HC-SR04は**超音波距離センサー**で、超音波の反射を使って物体までの距離を測定する安価で有名なモジュールです。ArduinoやRaspberry Piなどでよく使われます。

---

## 📌 HC-SR04 の概要

* **Trig ピン** （入力）：測定開始のためのトリガ信号を送る
* **Echo ピン** （出力）：物体からの反射波を受けたときにパルスを出す
* **VCC** ：5V電源
* **GND** ：グランド

測定範囲は  **約 2cm ～ 400cm** 、精度は数mm程度です。

---

## 📌 動作原理

1. **Trigピンに 10µs 以上の HIGH パルス**を送ると、HC-SR04 が **40kHz の超音波を8回**発射します。
2. 超音波が物体に当たり、反射して戻ってくると **Echo ピンが HIGH になる時間**で距離を測定します。
3. Echo ピンの HIGH の時間が、超音波の往復時間を表します。

距離計算式は：

距離(cm)=EchoのHIGH時間(μs)58距離(cm) = \frac{EchoのHIGH時間(\mu s)}{58}
または

距離=音速×Echo時間2距離 = \frac{音速 \times Echo時間}{2}
（÷2 するのは「往復」だから）

---

## 📌 Arduino での接続例

* VCC → 5V
* GND → GND
* Trig → Arduino デジタルピン (例: 9)
* Echo → Arduino デジタルピン (例: 10)

---

## 📌 Arduino サンプルコード

```cpp
#define TRIG 9
#define ECHO 10

void setup() {
  Serial.begin(9600);
  pinMode(TRIG, OUTPUT);
  pinMode(ECHO, INPUT);
}

void loop() {
  // トリガー信号を送る
  digitalWrite(TRIG, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG, LOW);

  // Echoの時間を計測
  long duration = pulseIn(ECHO, HIGH);

  // 距離に変換（cm）
  long distance = duration / 58;

  Serial.print("Distance: ");
  Serial.print(distance);
  Serial.println(" cm");

  delay(500);
}
```

---

## 📌 注意点

* 近すぎると（2cm以下）は測定できない
* 布や柔らかいものは反射が弱く、正しく測れない
* 複数のHC-SR04を近くで同時に使うと超音波が干渉する
* Echoピンは 5V 出力なので、**3.3Vマイコン（Raspberry Piなど）では抵抗分圧が必要**

---

👉 ここまでで、Arduinoを想定した説明をしました。

ユーザーさんは **Arduinoで使う予定ですか？** それとも **Raspberry Piや別の環境**を想定していますか？
