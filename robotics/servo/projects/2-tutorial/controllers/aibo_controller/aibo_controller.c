#include <stdio.h>
#include <webots/robot.h>
#include <webots/motor.h>
#include <webots/accelerometer.h>

#define TIME_STEP 32

int main() {
  wb_robot_init();

  // get devices
  WbDeviceTag camera = wb_robot_get_device("PRM:/r1/c1/c2/c3/i1-FbkImageSensor:F1");
  WbDeviceTag head_distance_near = wb_robot_get_device("PRM:/r1/c1/c2/c3/p1-Sensor:p1");
  WbDeviceTag head_distance_far = wb_robot_get_device("PRM:/r1/c1/c2/c3/p2-Sensor:p2");
  WbDeviceTag chest_distance_sensor = wb_robot_get_device("PRM:/p1-Sensor:p1");
  WbDeviceTag touch_sensor_fore_l = wb_robot_get_device("PRM:/r2/c1/c2/c3/c4-Sensor:24");
  WbDeviceTag touch_sensor_hind_l = wb_robot_get_device("PRM:/r3/c1/c2/c3/c4-Sensor:34");
  WbDeviceTag touch_sensor_fore_r = wb_robot_get_device("PRM:/r4/c1/c2/c3/c4-Sensor:44");
  WbDeviceTag touch_sensor_hind_r = wb_robot_get_device("PRM:/r5/c1/c2/c3/c4-Sensor:54");

  // enable camera and sensors
  wb_camera_enable(camera, TIME_STEP);
  wb_distance_sensor_enable(head_distance_near, TIME_STEP);
  wb_distance_sensor_enable(head_distance_far, TIME_STEP);
  wb_distance_sensor_enable(chest_distance_sensor, TIME_STEP);
  wb_touch_sensor_enable(touch_sensor_fore_l, TIME_STEP);
  wb_touch_sensor_enable(touch_sensor_hind_l, TIME_STEP);
  wb_touch_sensor_enable(touch_sensor_fore_r, TIME_STEP);
  wb_touch_sensor_enable(touch_sensor_hind_r, TIME_STEP);

  const int motor_count = sizeof(motor_names) / sizeof(motor_names[0]);
  WbDeviceTag motors[motor_count];

  // モーター取得
  for (int i = 0; i < motor_count; i++) {
    motors[i] = wb_robot_get_device(motor_names[i]);
    wb_motor_set_position(motors[i], 0.0);
  }

  double t = 0.0;

  printf("Aibo controller started.\n");

  // メインループ
  while (wb_robot_step(TIME_STEP) != -1) {
    t += 0.05;

    // 四足歩行の簡易波形
    double walk_wave = 0.3 * sin(t);

    // 4脚のシンプル歩行リズム
    wb_motor_set_position(motors[0],  walk_wave);  // front right shoulder
    wb_motor_set_position(motors[1], -walk_wave);

    wb_motor_set_position(motors[2], -walk_wave); // front left shoulder
    wb_motor_set_position(motors[3],  walk_wave);

    wb_motor_set_position(motors[4],  walk_wave); // rear right
    wb_motor_set_position(motors[5], -walk_wave);

    wb_motor_set_position(motors[6], -walk_wave); // rear left
    wb_motor_set_position(motors[7],  walk_wave);

    // 頭を上下に振る
    wb_motor_set_position(motors[9], 0.2 * sin(t * 0.8)); // head pitch
    wb_motor_set_position(motors[8], 0.0);                // head yaw fixed

  }

  wb_robot_cleanup();
  return 0;
}
