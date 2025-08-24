#include <TM1637.h>

// TM1637 CLK と DIO ピン
#define CLK 3
#define DIO 2

TM1637 tm;

int counter = 0;

void setup() {
  Serial.begin(115200);
  Serial.println("Type your text for the third display.");
  Serial.println("Now displaying \"----\".");

  tm.begin(CLK, DIO, 4);    //  clockpin, datapin, #digits
  tm.displayClear();
  tm.setBrightness(7);
}

void loop() {
  tm.displayInt(counter);   // カウンタ表示（整数、0～9999）

  counter++;
  if (counter > 9999) counter = 0;

  delay(1000); // 1秒ごとに更新
}