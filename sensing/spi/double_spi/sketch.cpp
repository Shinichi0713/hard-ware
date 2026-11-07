// 74HC595 ダブル SPI スレーブ（ソフト SPI）
// SHCP（クロック）と DS（データ）を共通
// STCP（ラッチ = CS相当）だけを別ピンで制御

#define SHCP_PIN  18   // シフトレジスタクロック（共通）
#define DS_PIN    19   // シリアルデータ（共通）
#define STCP1     17   // デバイス1のラッチ
#define STCP2     20   // デバイス2のラッチ

void softSpiBegin() {
  pinMode(SHCP_PIN, OUTPUT);
  pinMode(DS_PIN, OUTPUT);
  pinMode(STCP1, OUTPUT);
  pinMode(STCP2, OUTPUT);
  digitalWrite(SHCP_PIN, LOW);
  digitalWrite(DS_PIN, LOW);
  digitalWrite(STCP1, LOW);
  digitalWrite(STCP2, LOW);
}

// MSB ファーストで 1 バイト送信
void softSpiTransfer(uint8_t data) {
  for (int i = 7; i >= 0; i--) {
    digitalWrite(DS_PIN, (data >> i) & 0x01);
    digitalWrite(SHCP_PIN, HIGH);
    delayMicroseconds(2);
    digitalWrite(SHCP_PIN, LOW);
    delayMicroseconds(2);
  }
}

// 指定した STCP ピンのみでデータをラッチ
void sendTo595(uint8_t stcpPin, uint8_t data) {
  digitalWrite(stcpPin, LOW);
  delayMicroseconds(5);
  softSpiTransfer(data);
  delayMicroseconds(5);
  digitalWrite(stcpPin, HIGH);
  delayMicroseconds(10);
}

void setup() {
  Serial.begin(115200);
  softSpiBegin();

  // 初期状態：全消灯
  sendTo595(STCP1, 0x00);
  sendTo595(STCP2, 0x00);

  Serial.println("[OK] Dual 74HC595 initialized");
}

void loop() {
  // デバイス1：Q0〜Q3 を順番に点灯
  // デバイス2：Q0〜Q3 を逆順に点灯
  for (int i = 0; i < 4; i++) {
    sendTo595(STCP1, 1 << i);           // デバイス1：左から順
    sendTo595(STCP2, 1 << (3 - i));     // デバイス2：右から順
    Serial.print("Dev1=0x"); Serial.print(1 << i, HEX);
    Serial.print(" Dev2=0x"); Serial.println(1 << (3 - i), HEX);
    delay(500);
  }

  // 両方同時に全点灯
  sendTo595(STCP1, 0x0F);
  sendTo595(STCP2, 0x0F);
  Serial.println("Both ON");
  delay(1000);

  // 両方消灯
  sendTo595(STCP1, 0x00);
  sendTo595(STCP2, 0x00);
  Serial.println("Both OFF");
  delay(500);
}