
センシングの設計スキルを取得しようと思えばやはり手を動かして結果を考えるのが一番です。
本稿ではセンシングのうちUARTを例にとって演習を行い、センシングのスキル取得をはかるパッケージを提供します。

## 本演習で理解できること
今回の記事の内容で得られるセンシングのスキルについて整理しました。

### 1. 通信プロトコルの実務的理解

| スキル | 演習での対応 |
|---|---|
| **ボーレート・フレーム構造の理解** | 演習1で115200bps設定と文字化け原因を体感 |
| **非同期通信のタイミング管理** | `delay()` と送信周期の関係を確認 |
| **プロトコルパラメータの選定** | データビット・パリティ・ストップビットの設定理由を理解 |

### 2. センサデータの構造化と転送

| スキル | 演習での対応 |
|---|---|
| **CSVフォーマットによるデータ構造化** | 演習2で `DATA,温度,湿度,気圧` の形式を実装 |
| **パケット識別子の設計** | 先頭に `DATA` を付けて受信側で判別 |
| **疑似データ生成とノイズ付加** | `random()` でセンサ値を変動させ、実環境を模倣 |
| **浮動小数点の精度管理** | `Serial.print(value, 2)` で小数点以下2桁を制御 |

### 3. 双方向通信（コマンド/レスポンス）の設計

| スキル | 演習での対応 |
|---|---|
| **コマンドパーサの実装** | `handleCommand()` で文字列コマンドを分岐処理 |
| **エラーハンドリング** | 不明コマンドに `ERR,UNKNOWN` を返す |
| **状態管理** | `ledState`・`loopCount` でデバイス状態を保持・返信 |
| **受信バッファの扱い** | `Serial.available()` と `readStringUntil('\n')` の使い方 |

### 4. センサインターフェース（I2C → UART パイプライン）

| スキル | 演習での対応 |
|---|---|
| **I2Cデバイスの初期化** | MPU6050のスリープ解除（`0x6B` レジスタ書き込み） |
| **レジスタアドレスからの読み出し** | `Wire.write(0x3B)` → `Wire.requestFrom()` の流れ |
| **16bitデータの復元** | `(high << 8) \| low` で生データを結合 |
| **センサ生値のUART転送** | I2C取得 → フォーマット変換 → UART送信のパイプライン |

### 5. デバッグ・検証の手法

| スキル | 演習での対応 |
|---|---|
| **シリアルモニタによる動作確認** | Wokwi内蔵モニタで送受信をリアルタイム確認 |
| **ボーレート不一致の切り分け** | 文字化けが設定ミスであることを体感 |
| **コマンド単体テスト** | `GET_SENSOR`・`LED_ON` 等を個別に入力して応答確認 |

## UARTの復習

演習に入る前に、UARTの基本フレーム構造を確認します。UARTは**非同期通信**で、スタートビットから始まり、データビット、オプションのパリティ、ストップビットで終わります。
もしUARTの基本について知りたい場合は[こちら](https://zenn.dev/yoshinn/articles/sensing_protcol_uart)も併せてご覧ください。

__UARTフレーム構造__

![alt text](image.png)

| 項目 | 本演習での設定値 | 備考 |
|---|---|---|
| ボーレート | 115200 bps | 1秒間に115200ビット転送 |
| データビット | 8bit | 1バイトを一度に送る |
| パリティ | None | エラーチェックなし（簡易版） |
| ストップビット | 1bit | 1bitでフレーム終了 |

> **ポイント:** Wokwiではシリアルモニタが内蔵されているため、PCに実機を接続しなくても、ブラウザ上で送信された文字列を直接確認できます。

__ポーレートの指定__

ボーレート（Baud Rate）は、「1秒間に何ビット送るか」という通信速度の約束です。UARTが非同期通信であるがゆえに、この約束が必須になります。

因みにポーレートの指定が必須な理由ですが。
UARTはクロック線を共有しません。つまり、送信側と受信側は別々の時計（クロック）を持っています。
双方が同じ間隔でビットを送受信しないと、受信側は「いつ読めばいいか」が分からなくなります。


## 演習1: Hello UART（単純送信）

まずは基本中の基本。マイコン（ESP32/Arduino）からシリアルモニタへ文字列を送信し、通信が成立することを確認します。

### 演習内容

- Wokwiで **ESP32 DevKitC** プロジェクトを新規作成
- ボーレート115200で「Hello UART from Wokwi!」を1秒ごとに送信
- シリアルモニタで文字列が表示されることを確認

### 解答コード（diagram.json不要、sketch.inoのみ）

```cpp
void setup() {
  // UART初期化: 115200bps
  Serial.begin(115200);

  // 起動メッセージ（送信側の確認用）
  Serial.println("=== UART Exercise 1 ===");
  Serial.println("Hello UART from Wokwi!");
}

void loop() {
  // 1秒ごとにメッセージ送信
  Serial.println("Hello UART from Wokwi!");
  delay(1000);
}
```

### 確認ポイント

- シリアルモニタのボーレートが `115200` に設定されているか
- 文字化けした場合はボーレート不一致が最も多い原因
- `Serial.print()` と `Serial.println()` の違い（改行の有無）を確認


うまくいくと画面したのコンソール画面に "Hello UART from Wokwi!" が1secごとに表示されます。

![alt text](image-1.png)

## 演習2: センサデータのフォーマット送信

ロボット制御では、複数のセンサ値をまとめて送受信することが多いです。ここでは「温度・湿度・気圧」をカンマ区切り（CSV形式）で送信する演習を行います。

### 演習内容

今回は仮想のセンサを使った演習→センサをマイコンに配線する必要はありません。

- 仮想的な温度・湿度・気圧センサ値を生成（実際のセンサ不要）
- `DATA,23.50,45.00,1013.25` のようなフォーマットで500msごとに送信
- 先頭に `DATA,` を付けることで、受信側でデータパケットを識別できるようにする

### 解答コード

```cpp
// 仮想的なセンサ値（本来はI2C/SPIでセンサから取得）
float temperature = 23.5;    // °C
float humidity    = 45.0;    // %
float pressure    = 1013.25; // hPa

void setup() {
  Serial.begin(115200);
  Serial.println("=== UART Exercise 2: Sensor Data ===");
}

void loop() {
  // センサ値をわずかに変動させる（疑似ノイズ）
  temperature += random(-10, 11) / 100.0;  // ±0.1°C
  humidity    += random(-20, 21) / 100.0;  // ±0.2%
  pressure    += random(-50, 51) / 100.0;  // ±0.5hPa

  // CSVフォーマットで送信
  // フォーマット: DATA,temperature,humidity,pressure
  Serial.print("DATA,");
  Serial.print(temperature, 2);  // 小数点以下2桁
  Serial.print(",");
  Serial.print(humidity, 2);
  Serial.print(",");
  Serial.println(pressure, 2);

  delay(500);
}
```

> **なぜ CSV形式か:** 受信側（PythonやProcessing）で `line.split(",")` するだけで数値を復元できるため、プロトコル解析が不要で扱いやすい。ロボットのTelemetry（テレメトリ）送信でも一般的な形式です。

うまくいくとコンソールにカンマ区切りの文字列が表示されます。

![1792218012209](image/1_wokwi_uart/1792218012209.png)


## 演習3: 双方向通信（コマンド受信と応答）

ロボット制御では、上位PCから「センサ値を送れ」「モーターを止めろ」といった**コマンドを受信**し、それに応答する必要があります。ここでは双方向UART通信を実装します。

![1792218254403](image/1_wokwi_uart/1792218254403.png)

### 演習内容

- シリアルモニタから文字列コマンドを送信（Wokwiのシリアルモニタは双方向対応）
- コマンドに応じた動作を実行し、結果を返信

### コマンド仕様

| 受信コマンド | 動作 | 返信例 |
|---|---|---|
| `GET_SENSOR` | 現在のセンサ値を送信 | `SENSOR,23.50,45.00,1013.25` |
| `LED_ON` | LED点灯（仮想的） | `OK,LED_ON` |
| `LED_OFF` | LED消灯（仮想的） | `OK,LED_OFF` |
| `STATUS` | 動作状態を返す | `STATUS,RUNNING,100` |
| その他 | 不明コマンド | `ERR,UNKNOWN` |

### 解答コード

```cpp
float temperature = 23.5;
float humidity    = 45.0;
float pressure    = 1013.25;
bool ledState     = false;
int loopCount     = 0;

void setup() {
  Serial.begin(115200);
  Serial.println("=== UART Exercise 3: Command/Response ===");
  Serial.println("Commands: GET_SENSOR, LED_ON, LED_OFF, STATUS");
}

void loop() {
  // --- 受信処理 ---
  if (Serial.available() > 0) {
    String cmd = Serial.readStringUntil('\n'); // 改行まで読み込み
    cmd.trim();                                 // 前後の空白・改行除去

    handleCommand(cmd);
  }

  // --- センサ値の疑似更新 ---
  temperature += random(-10, 11) / 100.0;
  humidity    += random(-20, 21) / 100.0;
  pressure    += random(-50, 51) / 100.0;
  loopCount++;

  delay(100);
}

void handleCommand(String cmd) {
  if (cmd == "GET_SENSOR") {
    Serial.print("SENSOR,");
    Serial.print(temperature, 2);
    Serial.print(",");
    Serial.print(humidity, 2);
    Serial.print(",");
    Serial.println(pressure, 2);
  }
  else if (cmd == "LED_ON") {
    ledState = true;
    Serial.println("OK,LED_ON");
  }
  else if (cmd == "LED_OFF") {
    ledState = false;
    Serial.println("OK,LED_OFF");
  }
  else if (cmd == "STATUS") {
    Serial.print("STATUS,");
    Serial.print(ledState ? "LED_ON" : "LED_OFF");
    Serial.print(",");
    Serial.println(loopCount);
  }
  else {
    Serial.print("ERR,UNKNOWN:");
    Serial.println(cmd);
  }
}
```

### Wokwiでの操作方法

1. コードを貼り付けてシミュレーション開始（▶ボタン）
2. 画面下部の「Serial Monitor」を開く
3. 入力欄に `GET_SENSOR` と入力しEnter → センサ値が返信される
4. `LED_ON`、`STATUS` 等も試す

> **ロボット制御との接続:** の「コマンド受信→応答」の構造は、PCからロボットへ目標位置を送る、もしくはロボットからPCへ現在状態を送る、という実用的なパターンと全く同じです。

![1792218330020](image/1_wokwi_uart/1792218330020.png)

## 発展4: 実際のセンサ（MPU6050）を接続する

Wokwiには**MPU6050（I2C接続の6軸IMU）** の部品が備わっています。演習3の疑似センサ値を、実際のIMUデータに置き換えることができます。

### Wokwiでの配線（diagram.json）

この部分を貼り換えてください。

![1792218441720](image/1_wokwi_uart/1792218441720.png)

```json
{
  "version": 1,
  "author": "Your Name",
  "editor": "wokwi",
  "parts": [
    { "type": "board-esp32-devkit-c-v4", "id": "esp", "top": 0, "left": 0 },
    { "type": "wokwi-mpu6050", "id": "imu", "top": -30, "left": 180 }
  ],
  "connections": [
    ["esp:3V3", "imu:VCC", "red", ["h30"]],
    ["esp:GND.2", "imu:GND", "black", ["h30"]],
    ["esp:21", "imu:SDA", "green", ["h40"]],
    ["esp:22", "imu:SCL", "blue", ["h40"]]
  ]
}
```

するとIMUと接続された状態となります。

![1792218476908](image/1_wokwi_uart/1792218476908.png)

### IMU値をUART送信するコード（一部）

```cpp
#include <Wire.h>
const int MPU_ADDR = 0x68;

void setup() {
  Serial.begin(115200);
  Wire.begin();
  Wire.beginTransmission(MPU_ADDR);
  Wire.write(0x6B);  // PWR_MGMT_1
  Wire.write(0);     // スリープ解除
  Wire.endTransmission(true);
}

void loop() {
  int16_t ax, ay, az, gx, gy, gz;

  Wire.beginTransmission(MPU_ADDR);
  Wire.write(0x3B);  // ACCEL_XOUT_H
  Wire.endTransmission(false);
  Wire.requestFrom(MPU_ADDR, 14, true);

  ax = (Wire.read() << 8) | Wire.read();
  ay = (Wire.read() << 8) | Wire.read();
  az = (Wire.read() << 8) | Wire.read();
  // ...温度、ジャイロも同様に読み出し

  // UARTでIMUデータを送信
  Serial.print("IMU,");
  Serial.print(ax); Serial.print(",");
  Serial.print(ay); Serial.print(",");
  Serial.println(az);

  delay(100);
}
```

このコードは、「I2CでIMUセンサからデータを読み出し、UARTでPC等に送信する」というセンシングパイプラインを実現しています。

データの流れはこんな感じとなります。

```code
[MPU6050] --I2C--> [ESP32] --UART--> [PC/シリアルモニタ]
  (物理世界)          (読み出し・変換)      (表示・記録)
```

- MPU6050は出荷時にスリープモードになっているため、0x6Bレジスタ（PWR_MGMT_1）に0を書き込むことで動作を開始します。
- MPU6050は各データを16bit（2バイト） で出力します。I2Cは1バイトずつ読むため、上位バイトと下位バイトを結合して元の値を復元します。

> **ポイント:** これが「I2Cでセンサからデータ取得 → UARTでPCへ転送」という、ロボットのセンシングパイプラインの基本形です。


うまくいくとIMUを操作して、その時の値をシリアル通信により取得、コンソール画面に出力される様子が確認できます。

![1792218534804](image/1_wokwi_uart/1792218534804.png)

## 総括

シリアル通信の本質は、**「1本の道を使って、順番に、しかし確実に、意味のある塊を運ぶ」** ことにあります。

### 1. 物理的な本質：「順番に送る」

パラレル通信（複数線で同時に送る）と異なり、シリアル通信は**1ビットずつ時系列でデータを流します**。これは配線を極限まで減らせる一方で、「何ビット目がどのデータか」を双方で認識し続ける必要があります。

### 2. 非同期通信の本質：「約束がタイミングを作る」

UARTにクロック線がないのは、**「時間そのものを共有するのではなく、時間の刻み方を事前に約束する」** からです。ボーレートは単なる速度ではなく、**「この間隔でお互いに世界を観測しよう」という合意**です。スタートビットはその合意の合図になります。

### 3. データの本質：「生の値に意味を付ける」

演習2のCSV形式（`DATA,23.50,45.00,1013.25`）が示す通り、シリアル通信で流れるのは**ただのバイト列**です。それが「温度」なのか「湿度」なのか、どこからどこまでが1つのメッセージなのかは、**送受信双方の約束（プロトコル）が決めます**。通信の本質は電気信号ではなく、**「意味の共有」** にあります。

### 4. 双方向性の本質：「話すことと聞くことの分離」

TXとRXが別々にあるのは、**「送受信を同時に独立して行える」** ことを意味します（厳密には半二重の場合もありますが）。演習3のコマンド/レスポンスは、**「相手の状態を問いかけ、答えを得る」** という対話の最小単位です。これはセンシングの本質でもあります。

### 5. パイプラインの本質：「世界を数値化し、運ぶ」

演習4のI2C→UARTパイプライン（MPU6050の加速度を読んでPCへ送る）は、**「物理現象 → 電気信号 → デジタル値 → 通信 → 解釈」** というセンシングの連鎖を意味しています。シリアル通信はその連鎖の中で「数値をデバイスを超えて運ぶ役割」を担っています。

### 一言まとめ

> **シリアル通信の本質は「時間の約束によって1ビットずつ意味のある塊を運び、送受信双方がその意味を共有することで、物理世界の情報を別の場所・別の時間に再現する」ことにある。**
