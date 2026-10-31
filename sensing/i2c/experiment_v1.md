
以下、**I2Cバスに複数センサを並列接続し、アドレス指定でそれぞれから状態量を読み取る**Wokwi例題です。BME280（環境センサ）とMPU6050（加速度・ジャイロセンサ）を同じSDA/SCL線に接続し、異なるI2Cアドレスで通信します。


## 例題：I2Cバス上の複数センサから状態量を取得する

### 問題設定

1本のI2Cバス（SDA・SCL）に以下の2台のセンサを並列接続する。

- **BME280**（I2Cアドレス `0x76`）: 温度・湿度・気温度・湿度・気圧を測定
- **MPU6050**（I2Cアドレス `0x68`）: 加速度（X/Y/Z）・ジャイロ（X/Y/Z）を測定

起動時に **I2Cスキャン** を実行して接続デバイスのアドレスを確認し、その後1秒ごとに両センサの値を読み出してシリアルモニタに出力する。

---

### 配線

```
Arduino Uno       BME280              MPU6050
├─ 5V    ───┬───── VCC    ┬────────── VCC
├─ GND   ───┼───── GND    ┼────────── GND
├─ A4    ───┴───── SDA    ┴────────── SDA
└─ A5    ───────── SCL    ─────────── SCL
```

**ポイント**: SDAとSCLは**両センサで共有**（並列接続）。各センサは固有のI2Cアドレスで識別される。

---

### Wokwiでの実装手順

1. [Wokwi](https://wokwi.com/) で新規プロジェクト → **Arduino Uno**
2. 「+」→ 検索「**bme280**」→「BME280」追加
3. 「+」→ 検索「**mpu6050**」→「MPU6050」追加
4. 配線:
   - BME280: VCC→5V, GND→GND, SDA→A4, SCL→A5
   - MPU6050: VCC→5V, GND→GND, SDA→A4, SCL→A5
5. **ライブラリマネージャ**で以下を追加:
   - `Adafruit BME280 Library`
   - `Adafruit Unified Sensor`
   - `MPU6050`（by Electronic Cats）
6. コードを貼り付けて実行

---

### コード

```cpp
#include <Wire.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_BME280.h>
#include <MPU6050.h>

// I2Cアドレス定義
#define BME280_ADDR  0x76   // BME280（SDO=GNDの場合）
#define MPU6050_ADDR 0x68   // MPU6050（デフォルト）

// センサオブジェクト
Adafruit_BME280 bme;
MPU6050 mpu;

// ============================================================
// I2Cスキャン: バス上のデバイスを発見してアドレスを表示
// ============================================================
void scanI2C() {
  Serial.println("\n--- I2C Bus Scan ---");
  Serial.println("Scanning for devices...");

  int deviceCount = 0;
  for (byte addr = 1; addr < 127; addr++) {
    Wire.beginTransmission(addr);
    byte error = Wire.endTransmission();

    if (error == 0) {
      Serial.print("  Device found at address 0x");
      if (addr < 16) Serial.print("0");
      Serial.print(addr, HEX);

      // 既知のデバイス名を表示
      if (addr == BME280_ADDR)  Serial.print("  <-- BME280");
      if (addr == MPU6050_ADDR) Serial.print("  <-- MPU6050");
      Serial.println();
      deviceCount++;
    }
  }

  if (deviceCount == 0) {
    Serial.println("  No I2C devices found! Check wiring.");
  } else {
    Serial.print("  Total devices found: ");
    Serial.println(deviceCount);
  }
  Serial.println("--------------------\n");
}

// ============================================================
// セットアップ
// ============================================================
void setup() {
  Serial.begin(9600);
  while (!Serial);
  delay(1000);

  Serial.println("========================================");
  Serial.println("  I2C Multi-Sensor Read Example");
  Serial.println("  BME280 (0x76) + MPU6050 (0x68)");
  Serial.println("========================================");

  // I2Cバスの初期化（UnoではSDA=A4, SCL=A5）
  Wire.begin();

  // I2Cスキャン実行
  scanI2C();

  // BME280初期化（アドレス指定）
  Serial.println("Initializing BME280...");
  if (!bme.begin(BME280_ADDR)) {
    Serial.println("  ERROR: BME280 not found at 0x76!");
    Serial.println("  Check SDO pin connection.");
  } else {
    Serial.println("  BME280 OK");
  }

  // MPU6050初期化
  Serial.println("Initializing MPU6050...");
  mpu.initialize();
  if (!mpu.testConnection()) {
    Serial.println("  ERROR: MPU6050 connection failed!");
  } else {
    Serial.println("  MPU6050 OK");
  }

  Serial.println("\n--- Starting sensor read loop ---\n");
  delay(500);
}

// ============================================================
// メインループ
// ============================================================
void loop() {
  // -------------------------------------------------
  // 1. BME280読み取り（I2Cアドレス 0x76）
  // -------------------------------------------------
  Serial.println("【BME280 @ 0x76】");
  float temp     = bme.readTemperature();            // ℃
  float humidity = bme.readHumidity();               // %
  float pressure = bme.readPressure() / 100.0F;    // hPa
  float altitude = bme.readAltitude(1013.25);        // m（基準気圧）

  Serial.print("  Temperature : "); Serial.print(temp);     Serial.println(" C");
  Serial.print("  Humidity    : "); Serial.print(humidity); Serial.println(" %");
  Serial.print("  Pressure    : "); Serial.print(pressure); Serial.println(" hPa");
  Serial.print("  Altitude    : "); Serial.print(altitude); Serial.println(" m");

  // -------------------------------------------------
  // 2. MPU6050読み取り（I2Cアドレス 0x68）
  // -------------------------------------------------
  int16_t ax, ay, az;   // 加速度生値
  int16_t gx, gy, gz;   // ジャイロ生値

  mpu.getMotion6(&ax, &ay, &az, &gx, &gy, &gz);

  // 生値を物理量に換算
  // 加速度: ±2g設定時 1LSB = 16384 LSB/g  →  g単位 = 値 / 16384.0
  // ジャイロ: ±250deg/s設定時 1LSB = 131 LSB/(deg/s) → deg/s = 値 / 131.0
  float accX = ax / 16384.0;
  float accY = ay / 16384.0;
  float accZ = az / 16384.0;
  float gyroX = gx / 131.0;
  float gyroY = gy / 131.0;
  float gyroZ = gz / 131.0;

  Serial.println("【MPU6050 @ 0x68】");
  Serial.print("  Accel (g)   : X="); Serial.print(accX, 3);
  Serial.print("  Y="); Serial.print(accY, 3);
  Serial.print("  Z="); Serial.println(accZ, 3);
  Serial.print("  Gyro (deg/s): X="); Serial.print(gyroX, 1);
  Serial.print("  Y="); Serial.print(gyroY, 1);
  Serial.print("  Z="); Serial.println(gyroZ, 1);

  // 簡易姿勢角（ロール・ピッチ）を加速度から計算
  float roll  = atan2(accY, accZ) * 180.0 / PI;
  float pitch = atan2(-accX, sqrt(accY * accY + accZ * accZ)) * 180.0 / PI;
  Serial.print("  Roll        : "); Serial.print(roll, 1);  Serial.println(" deg");
  Serial.print("  Pitch       : "); Serial.print(pitch, 1); Serial.println(" deg");

  Serial.println("----------------------------------------\n");
  delay(1000);
}
```

---

### シリアルモニタの出力例

```
========================================
  I2C Multi-Sensor Read Example
  BME280 (0x76) + MPU6050 (0x68)
========================================

--- I2C Bus Scan ---
Scanning for devices...
  Device found at address 0x68  <-- MPU6050
  Device found at address 0x76  <-- BME280
  Total devices found: 2
--------------------

Initializing BME280...
  BME280 OK
Initializing MPU6050...
  MPU6050 OK

--- Starting sensor read loop ---

【BME280 @ 0x76】
  Temperature : 24.56 C
  Humidity    : 45.30 %
  Pressure    : 1012.80 hPa
  Altitude    : 15.20 m
【MPU6050 @ 0x68】
  Accel (g)   : X=0.023  Y=-0.015  Z=0.998
  Gyro (deg/s): X=1.2  Y=-0.8  Z=0.5
  Roll        : -0.9 deg
  Pitch       : -1.3 deg
----------------------------------------
```

---

### この例題で学べること

| 項目 | 内容 |
|------|------|
| **I2Cバス接続** | SDA/SCLを複数デバイスで共有する並列接続の概念 |
| **I2Cスキャン** | `Wire.beginTransmission(addr)` + `Wire.endTransmission()` で存在確認 |
| **アドレス指定** | `bme.begin(0x76)` のようにアドレスを明示して初期化 |
| **複数デバイス通信** | 同じ `Wire` オブジェクトを使い、ライブラリ内部でアドレスを切り替えて通信 |
| **生値→物理量換算** | MPU6050のLSBからgやdeg/sへの換算（データシートのスケール因子） |
| **姿勢角計算** | 加速度からロール・ピッチを逆算（センサフュージョンの入門） |

---

### I2Cアドレスに関する重要な注意

各I2Cデバイスには**ハードウェアで決まるデフォルトアドレス**がありますが、一部のピン設定で変更可能です。

| デバイス | デフォルト | 変更方法 |
|---------|-----------|---------|
| BME280 | `0x76` | SDOピンをGNDに接続 |
| BME280 | `0x77` | SDOピンをVCCに接続 |
| MPU6050 | `0x68` | AD0ピンをGNDに接続 |
| MPU6050 | `0x69` | AD0ピンをVCCに接続 |

**アドレス衝突**（2台が同じアドレス）が起こると通信が破綻するため、同じバスに同種のセンサを2台接続する場合は、SDOやAD0ピンでアドレスを変える必要があります。

---

### まとめ

> **I2Cは2本の信号線（SDA/SCL）を複数デバイスで共有し、各デバイスの固有アドレスを指定して個別に通信するプロトコルです。この例題ではBME280（0x76）とMPU6050（0x68）を同じバスに接続し、I2Cスキャンで存在確認後、アドレスを指定してそれぞれから環境データと慣性データを読み取ります。**

Wokwi上で各部品をクリックすると、BME280は温度スライダー、MPU6050は加速度・ジャイロの値を調整できるUIが出現するため、値を変えながらシリアル出力が追従する様子を確認できます。
