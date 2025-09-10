#include <TM1637.h>
#include <LiquidCrystal_I2C.h>

#define PIN_CLOCK 2
#define PIN_DIO 3
#define PIN_LDR 4

TM1637 tmSeg;
LiquidCrystal_I2C lcd(0x27, 20, 4);

const float GAMMA = 0.7;
const float RL10 = 50;

float readPhotoSensor(){
  int analogValue = analogRead(A0);
  float voltage = analogValue / 1024. * 5;
  float resistance = 2000 * voltage / (1 - voltage / 5);
  float lux = pow(RL10 * 1e3 * pow(10, GAMMA) / resistance, (1 / GAMMA));
  return lux;
}

void setup() {
  // put your setup code here, to run once:
  tmSeg.begin(PIN_CLOCK, PIN_DIO, 4);
  tmSeg.displayClear();
  tmSeg.setBrightness(7);

  pinMode(PIN_LDR, INPUT);
  lcd.init();
  lcd.backlight();
}

void loop() {
  // put your main code here, to run repeatedly:
  
  lcd.setCursor(2, 0);
  float valueLDR = readPhotoSensor();


  // counter++;
  tmSeg.displayInt(valueLDR);
  // delay(1000);
}
