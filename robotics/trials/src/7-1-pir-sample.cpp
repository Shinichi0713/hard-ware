#define STEP_PIN 3
#define DIR_PIN 4
#define PIR_PIN 2

void setup() {
  pinMode(STEP_PIN, OUTPUT);
  pinMode(DIR_PIN, OUTPUT);
  pinMode(PIR_PIN, INPUT);

  digitalWrite(DIR_PIN, HIGH); // 回転方向（HIGHでCW, LOWでCCW）
  Serial.begin(9600);
}

void stepMotor(int steps, int delayMicros) {
  for (int i = 0; i < steps; i++) {
    digitalWrite(STEP_PIN, HIGH);
    delayMicroseconds(delayMicros);
    digitalWrite(STEP_PIN, LOW);
    delayMicroseconds(delayMicros);
  }
}

void loop() {
  int motion = digitalRead(PIR_PIN);

  if (motion == HIGH) {
    Serial.println("Motion detected! Rotating motor...");
    stepMotor(200, 800);  // 200ステップ（1回転分: 1.8°/stepモータの場合）、1ステップあたり 800µs
    delay(1000);          // 次の検知まで待機
  }
}
