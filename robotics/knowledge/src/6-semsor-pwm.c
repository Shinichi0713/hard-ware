
#include <Servo.h>

#define PIN_SERVO 9
Servo myServo;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(115200);
  Serial.println("setting initialized.");

  myServo.attach(PIN_SERVO);
  
}

void loop() {
  // put your main code here, to run repeatedly:

}
