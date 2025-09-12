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
