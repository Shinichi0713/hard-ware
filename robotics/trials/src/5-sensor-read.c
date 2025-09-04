
#include <TM1637.h>
// TM1637 CLK と DIO ピン
#define CLK 3
#define DIO 2

#define PIN_TRIG 5
#define PIN_ECHO 4

TM1637 tm;

int counter=0;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  Serial.println("setting initialized.");
  tm.begin(CLK, DIO, 4);
  tm.displayClear();
  tm.setBrightness(8);

  pinMode(PIN_TRIG, OUTPUT);
  pinMode(PIN_ECHO, INPUT);
}

void loop() {
  // put your main code here, to run repeatedly:
  digitalWrite(PIN_TRIG, HIGH);
  delayMicroseconds(10);
  digitalWrite(PIN_TRIG, LOW);

  long duration = pulseIn(PIN_ECHO, HIGH);
  long distance = duration / 58;

  tm.displayInt(distance);
  counter++;
  if (counter > 9999) counter = 0;
  // Serial.print("Distance: ");
  // Serial.print(distance);
  // delay(500);
}
