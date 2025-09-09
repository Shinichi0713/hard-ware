#include <TM1637.h>

#define PIN_CLOCK 2
#define PIN_DIO 3
TM1637 tmSeg;

int counter = 0;

void setup() {
  // put your setup code here, to run once:
  tmSeg.begin(PIN_CLOCK, PIN_DIO, 4);
  tmSeg.displayClear();
  tmSeg.setBrightness(7);
}

void loop() {
  // put your main code here, to run repeatedly:
  tmSeg.displayInt(counter);

  counter++;

  delay(1000);
}
