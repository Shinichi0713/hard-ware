#include <Servo.h>
#include <math.h>

Servo myServo;

int startAngle = 0;
int targetAngle = 0;
int totalSteps = 200;
int currentStep = 0;
unsigned long lastUpdate = 0;
int stepInterval = 10;
bool moving = false;


float easeInOutCubic(float t) {
  if (t < 0.5) {
    return 4 * t * t * t;
  } else {
    return 1 - pow(-2 * t + 2, 3) / 2;
  }
}

void setup() {
  myServo.attach(9);
  Serial.begin(9600);
  Serial.println("Enter target angle (0-180). Example: 120");
}

void loop() {
 
  if (Serial.available() > 0) {
    int inputAngle = Serial.parseInt(); 
    if (inputAngle >= 0 && inputAngle <= 180) {
      startAngle = myServo.read(); 
      targetAngle = inputAngle;
      currentStep = 0;
      lastUpdate = millis();
      moving = true;

      Serial.print("Moving to angle: ");
      Serial.println(targetAngle);
    } else {
      Serial.println("Invalid input! Example: 150");
    }


    while (Serial.available() > 0) Serial.read();
  }


  if (moving) {
    unsigned long now = millis();
    if (now - lastUpdate >= stepInterval) {
      lastUpdate = now;
      currentStep++;
      float t = (float)currentStep / totalSteps;
      if (t > 1) t = 1;
      int angle = startAngle + round((targetAngle - startAngle) * easeInOutCubic(t));
      myServo.write(angle);
      if (t >= 1) {
        moving = false; 
      }
    }
  }
}
