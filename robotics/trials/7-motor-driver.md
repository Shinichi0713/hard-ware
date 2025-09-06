## 目的

モータードライバを使ったモータ動作できないかを確認する。




## Using the A4988 Stepper Driver

[wokwi-a4988 Reference | Wokwi Docs](https://docs.wokwi.com/parts/wokwi-a4988#using-the-a4988-stepper-driver)

Connect the stepper motor pins to the 1B/1A/2A/2B pins of the driver. The RESET pin has to be HIGH, so you can connect it to the adjacent SLEEP pin (which is pulled HIGH by default). Alternatively, you can enable/disable the stepper motor driver from your code by connecting the RESET/SLEEP pins to your microcontroller.

Use the STEP pin to move the stepper motor. Every HIGH pulse on this pin will move the motor one step (or microstep, depending on the MS1/MS2/MS3 pins). When the DIR pin is HIGH, the stepper motor will move clockwise. When the DIR pin is LOW, the motor will move counterclockwise.

For example, if DIR, MS1 and MS3 are LOW, and MS2 is HIGH (1/4 step mode), then pulsing the STEP pin will move the motor 1/4 step (0.45 degrees) counterclockwise.

## Simulator Examples

* [A4988 control using a button + switch](https://wokwi.com/projects/327823888123691604) - press the green button to move the motor one step, and move the switch to change the direction.
* [4-Motor GCODE controller](https://wokwi.com/projects/327761195587076690) - Type "G00 X10 Y25" to move the first motor 10 steps, and the second one 25 steps.

あった！情報

[Arduino と A4988 でステッピングモーターを制御する方法 - Arduino - 基礎からの IoT 入門](https://iot.keicode.com/arduino/arduino-stepper-motor-a4988.php)

![1757019738432](image/7-motor-driver/1757019738432.png)

**ENABLE** は LOW にすると出力が有効となり、HIGH にすると出力が無効 (ディスエーブル) になります。

**MS1, MS2, MS3** はステップモードを設定します (下表)。プルダウン抵抗があり、何も接続しないと全て LOW になります。この場合フルステップです。

![1757020089431](image/7-motor-driver/1757020089431.png)
