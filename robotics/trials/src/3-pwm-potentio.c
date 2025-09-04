
int portPin = A0;   // ポテンショメータ入力
int ledPin = 5;    // LED出力 (PWM対応)
int portValue = 0;  // 読み取った値
int ledValue = 0;  // LEDに出力する値 (0~255)

void setup() {
  pinMode(ledPin,OUTPUT);
  Serial.begin(9600);
}

void loop() {
  //ポテンショメータ読取り
  portValue = analogRead(portPin);
  // 0~1023 を 0~255 にマッピング
  ledValue = map(portValue, 0, 1023, 0, 255);

  // LEDの明るさをPWMで制御
  analogWrite(ledPin, ledValue);

  // デバッグ出力
  Serial.print("Potentiometer: ");
  Serial.print(portValue);
  Serial.print(" -> LED PWM: ");
  Serial.println(ledValue);

  delay(10); // 少し待つ
}