#define STEP_PIN 3
#define DIR_PIN 2
#define PIR_PIN 4               // choose the input pin (for PIR sensor)

void setup() {
  pinMode(STEP_PIN, OUTPUT);
  pinMode(DIR_PIN, OUTPUT);
  pinMode(PIR_PIN, INPUT);    // センサの入力ピン

  // 初期方向
  digitalWrite(DIR_PIN, HIGH); // HIGH で1方向、LOWで逆方向
}

void loop() {
  // 1回転のステップ数（モータ仕様により調整）
  int steps = 200;
  int valPir = digitalRead(PIR_PIN);
  // 1方向に回転
  digitalWrite(DIR_PIN, HIGH);
  if(valPir){
    for (int i = 0; i < steps; i++) {
      digitalWrite(STEP_PIN, HIGH);
      delayMicroseconds(800); // STEP ON 時間
      digitalWrite(STEP_PIN, LOW);
      delayMicroseconds(800); // STEP OFF 時間
    }
  }
  
}
