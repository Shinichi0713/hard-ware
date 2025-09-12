## 目的

デバッグを7segで、センサー＆モータの回路を動作させる。

# 7seg ディスプレイ

ライブラリ間違えてしまう。。。

"TM1637_RT"が正しい。

![1757365263800](image/8-7seg-sensor-motor/1757365263800.png)

![1757365295806](image/8-7seg-sensor-motor/1757365295806.png)

## 使うセンサー

今回はフォトレジスタセンサにします。

光の強さを検知できます。

[wokwi-photoresistor-sensor Reference | Wokwi Docs](https://docs.wokwi.com/parts/wokwi-photoresistor-sensor)

# ✅ フォトレジスタセンサーとは

**フォトレジスタ（Photoresistor）** は、

**光の強さによって電気抵抗値が変化する素子** です。

* 別名： **CdSセル（硫化カドミウムセル）** , LDR（Light Dependent Resistor）
* **明るいほど抵抗が小さくなり、暗いほど抵抗が大きくなる** 特性を持ちます。
* 単体では「抵抗器」ですが、Arduinoなどのマイコンと組み合わせると **光センサー** として利用できます。

---

# ⚙ 仕組み

* 半導体材料（CdSなど）を使った抵抗素子。
* 光が当たると電子が励起され、電気を流しやすくなる → 抵抗値が下がる。
* 光が弱いと電子が少なく → 抵抗値が上がる。

👉 つまり **光の強さ = 抵抗値の変化** に変換する仕組みです。

---

# 📌 特徴

* **安価で扱いやすい**
* 光に対して反応するが、応答速度は数十ms〜数百ms程度とやや遅い
* 紫外線や赤外線には鈍感（可視光に近い領域で動作）

---

# 🔍 利用例

* 自動点灯の街灯（暗くなるとON）
* スマホの画面の明るさ自動調整
* 簡易的な光センサー（Arduinoロボットのライントレーサーなど）
* セキュリティ装置（レーザー光を遮ったかどうか検知）

---

# 🛠️ Arduinoでの使い方（例）

フォトレジスタを **抵抗と直列に接続して分圧回路** を作り、

その電圧をアナログ入力ピンで読み取ります。

```cpp
int sensorPin = A0;  // フォトレジスタを接続したアナログピン
int sensorValue = 0;

void setup() {
  Serial.begin(9600);
}

void loop() {
  sensorValue = analogRead(sensorPin);  // 0〜1023の値を取得
  Serial.println(sensorValue);
  delay(500);
}
```

---

# 🧠 まとめ

* フォトレジスタ = **光の強さで抵抗値が変わる素子**
* 明るい → 抵抗小、暗い → 抵抗大
* 安価・簡単に光センサーを作れるが、応答速度は遅め
* Arduinoなどと組み合わせると「明るさセンサー」として活躍




了解しました 👍

ここでは **Arduino（AVR系マイコン）** を使って、**ステッピングモータの回転数を制御する基本コード** を紹介します。

---

# ✅ 前提条件

* ドライバIC（例：A4988, DRV8825 など）を使ってステッピングモータを駆動する
* ドライバには通常
  * `STEP` ピン（パルス入力で1ステップ進む）
  * `DIR` ピン（回転方向指定）

    を接続する

---

# ✅ Arduinoコード例：回転数制御

```cpp
#define STEP_PIN 3   // STEP 信号を出すピン
#define DIR_PIN  4   // 回転方向を指定するピン

// 設定
int stepsPerRev = 200;    // モータ1回転のステップ数（例: 1.8°/step → 200）
int rpm = 60;             // 回転数（1分間の回転数）

void setup() {
  pinMode(STEP_PIN, OUTPUT);
  pinMode(DIR_PIN, OUTPUT);

  digitalWrite(DIR_PIN, HIGH); // 回転方向（HIGH: 正転, LOW: 逆転）
}

void loop() {
  // 1回転あたりのステップ周期計算
  // → 60秒 / (rpm × stepsPerRev) = 1ステップあたりの秒数
  float stepDelay = (60.0 * 1000000.0) / (rpm * stepsPerRev); // μs単位

  // 1回転分だけ回す
  for (int i = 0; i < stepsPerRev; i++) {
    digitalWrite(STEP_PIN, HIGH);
    delayMicroseconds(500);  // パルス幅 (HIGH時間)
    digitalWrite(STEP_PIN, LOW);
    delayMicroseconds(stepDelay - 500); // 残り時間をLOWで保持
  }

  delay(1000); // 1秒待機してまた回転
}
```

---

# ✅ ポイント

1. **回転数の計算**
   * RPM（回転数/分）からステップ周期を計算しています。
   * `stepDelay` を短くすると高速回転、長くすると低速回転。
2. **DIRピン**
   * `HIGH` / `LOW` で回転方向を制御できます。
3. **加速・減速制御**
   * 実際には「急に高速にすると脱調」するので、ランプ（加速・減速制御）が必要です。
   * 簡易コードでは固定速度にしています。

---

# ✅ 改良（加速・減速制御）

もし実用的にしたいなら、`AccelStepper` ライブラリを使うと便利です：

```cpp
#include <AccelStepper.h>

#define STEP_PIN 3
#define DIR_PIN 4

AccelStepper stepper(AccelStepper::DRIVER, STEP_PIN, DIR_PIN);

void setup() {
  stepper.setMaxSpeed(1000);   // 最大速度 (steps/sec)
  stepper.setAcceleration(200); // 加速度 (steps/sec^2)
}

void loop() {
  stepper.setSpeed(400);  // 回転速度 (steps/sec)
  stepper.runSpeed();     // 常にこの速度で回す
}
```

👉 このライブラリを使うと「滑らかな加減速」や「非ブロッキング制御」が簡単にできます。

---

# 🧠 まとめ

* ステッピングモータは **STEPパルスの周期** で回転数を制御できる
* `delayMicroseconds()` でパルス間隔を調整すれば RPM を設定可能
* 実用的には **AccelStepperライブラリ** を使うのがおすすめ
