
#include <Servo.h>
#include <math.h>
// #include <TM1637.h>

#define PIN_TRIG 5
#define PIN_ECHO 4
#define PIN_SERVO 9
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
  // put your setup code here, to run once:
  myServo.attach(PIN_SERVO);
  Serial.begin(9600);
  Serial.println("setting initialized.");

  pinMode(PIN_TRIG, OUTPUT);
  pinMode(PIN_ECHO, INPUT);
  
}

void loop() {
  // put your main code here, to run repeatedly:
  digitalWrite(PIN_TRIG, LOW);
  delayMicroseconds(2);
  digitalWrite(PIN_TRIG, HIGH);
  delayMicroseconds(10);
  digitalWrite(PIN_TRIG, LOW);

  long duration = pulseIn(PIN_ECHO, HIGH);
  long distance = duration / 58;
  long angleDesire = static_cast<long>((static_cast<double>(distance) / 400.0) * 180.0);
  // Serial.println(angleDesire);
  if(true){
    int inputAngle = angleDesire; 
    if(inputAngle>=0 && inputAngle<=180){
      startAngle = myServo.read();
      targetAngle = inputAngle;
      currentStep = 0;
      lastUpdate = millis();
      moving = true;
      int angleDiff = abs(targetAngle - startAngle);
      totalSteps = angleDiff * 3; // 1度あたり3ステップとか
      // Serial.print("Moving to angle: ");
      // Serial.println(targetAngle);
    }
    else{
      Serial.println("Invalid input! Example: 150");
    }

    // while (Serial.available() > 0) Serial.read();
  }

  if(moving){
    unsigned long now = millis();   //マイコンの起動経過時間
    // if(now - lastUpdate >= stepInterval){
    lastUpdate = now;
    currentStep++;
    float t = (float)currentStep / totalSteps;
    // Serial.println(t);
    if(t>1) t=1;
    int angle = startAngle + round((targetAngle - startAngle) * easeInOutCubic(t));
    Serial.println(angle);
    myServo.write(angle);
    if(t>=1) moving = false;
    // }
  }
  // Serial.print(distance);
}
