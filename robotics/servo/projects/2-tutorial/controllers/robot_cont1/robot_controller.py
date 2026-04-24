from controller import Robot, Display
import math
import cv2
import numpy as np


class RobotController(Robot):
    def __init__(self):
        super().__init__()
        self.sensors = []
        # ロボットに搭載されている全デバイスの数を取得
        n_devices = self.getNumberOfDevices()

        print(f"--- Device list for {self.getName()} ---")
        for i in range(n_devices):
            device = self.getDeviceByIndex(i)
            name = device.getName()
            # デバイスの型（Node Type）も取得可能
            node_type = device.getNodeType()
            print(f"Index: {i} | Name: {name} | Type ID: {node_type}")
        print("------------------------------------------")

        # 2. タイムステップの取得
        self.timestep = int(self.getBasicTimeStep())

        # 3. モーターの取得
        self.left_motor = self.getDevice('left wheel motor')
        self.right_motor = self.getDevice('right wheel motor')
        # 4. モーターを速度制御モードに設定 (positionを無限大に設定)
        self.left_motor.setPosition(float('inf'))
        self.right_motor.setPosition(float('inf'))
        # 5. 初期速度を設定 (0)
        self.left_motor.setVelocity(0.0)
        self.right_motor.setVelocity(0.0)

        # 前進速度の設定 (最大速度の半分程度)
        self.MAX_SPEED = 6.28  # e-puckの最大角速度(rad/s)
        self.THRESHOLD = 80.0  # 壁を検知するしきい値（値が大きいほど壁に近い）

        # 最大角速度(rad/s)
        self.speed = self.MAX_SPEED * 0.5
        self.sensor_angles = [
            -0.3, -0.79, -1.57, -2.62,  # ls0, ls1, ls2, ls3
            2.62, 1.57, 0.79, 0.3       # ls4, ls5, ls6, ls7 (近似値)
        ]
        self.__get_sensor()

    def __get_sensor(self):
        # 近接センサー（ps0〜ps7）のセットアップ
        sensor_names = [
            'ps0', 'ps1', 'ps2', 'ps3',
            'ps4', 'ps5', 'ps6', 'ps7'
        ]

        for name in sensor_names:
            sensor = self.getDevice(name)
            sensor.enable(self.timestep)
            self.sensors.append(sensor)

        # カメラの取得・有効化
        self.camera = self.getDevice("camera")
        self.camera.enable(self.timestep)

        # IMU（加速度計・ジャイロ）の取得・有効化
        self.accelerometer = self.getDevice("accelerometer")
        self.accelerometer.enable(self.timestep)
        self.gyro = self.getDevice("gyro")
        self.gyro.enable(self.timestep)

        # self.display = self.getDevice("display")
        # self.display.attachCamera(self.camera)

    def get_image(self):
        # カメラから画像を取得してOpenCV形式に変換
        width = self.camera.getWidth()
        height = self.camera.getHeight()
        image = self.camera.getImage()

        # Webotsのカメラ画像はBGRA形式なので、OpenCVのBGR形式に変換
        img_array = np.frombuffer(image, dtype=np.uint8).reshape((height, width, 4))
        # VIO用に解像度を 52x52 に縮小（軽量化）
        frame = cv2.resize(img_array, interpolation=cv2.INTER_NEAREST)

        return frame

    def __aware_obstacle(self):
        # 障害物を検知したかどうかを返す
        ps_values = [s.getValue() for s in self.sensors]
        # 右側（ps0, ps1, ps2）と左側（ps5, ps6, ps7）の反応を確認
        # ※ ps0, ps7が正面
        right_obstacle = ps_values[0] > self.THRESHOLD or ps_values[1] > self.THRESHOLD or ps_values[2] > self.THRESHOLD
        left_obstacle = ps_values[5] > self.THRESHOLD or ps_values[6] > self.THRESHOLD or ps_values[7] > self.THRESHOLD

        return left_obstacle, right_obstacle

    def run(self):
        # メインループ
        while self.step(self.timestep) != -1:
            left_obstacle, right_obstacle = self.__aware_obstacle()

            if left_obstacle:
                # 左に障害物がある場合、右に旋回
                self.left_motor.setVelocity(self.speed)
                self.right_motor.setVelocity(-self.speed)
            elif right_obstacle:
                # 右に障害物がある場合、左に旋回
                self.left_motor.setVelocity(-self.speed)
                self.right_motor.setVelocity(self.speed)
            else:
                # 障害物がない場合、前進
                self.left_motor.setVelocity(self.speed)
                self.right_motor.setVelocity(self.speed)

    def __aware_dirction(self):
        direction_x = 0.0
        direction_y = 0.0
        # 障害物の方向を数値で返す（-1: 右, 0: 前, 1: 左）
        ps_values = [max(0.0, s.getValue() / 4000.0) for s in self.sensors]
        print(f"Sensor Values: {[f'{v:.2f}' for v in ps_values]}")  # センサー値のデバッグ出力
        index_max = ps_values.index(max(ps_values))
        if max(ps_values) > 0.1:
            angle = self.sensor_angles[index_max]
        else:
            angle = math.pi
        return angle, ps_values[index_max]

    def run_vector_field(self):
        base_speed = self.MAX_SPEED / 2.0  # 基本の進行速度

        while self.step(self.timestep) != -1:
            angle, val_sensor = self.__aware_dirction()

            # 方向ベクトルを正規化
            if val_sensor > 0.1:
                if math.fabs(angle) < math.pi / 2:  # ある程度の角度がある場合のみ旋回
                    target_angle = angle
                    print(f"Direction Vector: ({math.cos(target_angle)*val_sensor:.2f}, {math.sin(target_angle)*val_sensor:.2f}), Target Angle: {math.degrees(target_angle):.2f} degrees, Total Brightness: {val_sensor:.2f}")
                    if angle > 0:
                        self.left_motor.setVelocity(base_speed)
                        self.right_motor.setVelocity(-base_speed)
                    else:
                        self.left_motor.setVelocity(-base_speed)
                        self.right_motor.setVelocity(base_speed)
                else:
                    self.left_motor.setVelocity(base_speed)
                    self.right_motor.setVelocity(base_speed)
            else:
                self.left_motor.setVelocity(base_speed)
                self.right_motor.setVelocity(base_speed)

            image = self.get_image()
            cv2.imshow("e-puck Camera View", image)
            cv2.waitKey(1)

    def run_pid(self):
        target_value = 100.0  # 目標とする壁との距離（センサー値）
        kp = 0.15              # 比例ゲイン（反応の強さ）
        ki = 0.001             # 積分ゲイン（残留偏差の解消）
        kd = 0.05              # 微分ゲイン（ガタつきの抑制）

        integral = 0.0
        last_error = 0.0
        base_speed = 3.0      # 基本の進行速度

        while self.step(self.timestep) != -1:
            # 現在のセンサー値を取得
            current_value = self.sensors[0].getValue()

            # 1. 偏差（エラー）を計算
            error = target_value - current_value

            # 2. 積分項（過去の蓄積）
            integral += error

            # 3. 微分項（変化の速さ）
            derivative = error - last_error

            # PID計算：ステアリング（旋回）量を決める
            # 目標より壁が遠い（error > 0）なら右へ、近いなら左へ
            steering = (kp * error) + (ki * integral) + (kd * derivative)

            # モーター速度の計算
            left_speed = base_speed + steering
            right_speed = base_speed - steering

            print(f"Sensor:{current_value}, SensorError: {error:.2f}, Steering: {steering:.2f}, Left Speed: {left_speed:.2f}, Right Speed: {right_speed:.2f}")

            # 速度を制限（MAX_SPEEDを超えないように）
            left_speed = max(min(left_speed, self.MAX_SPEED), -self.MAX_SPEED)
            right_speed = max(min(right_speed, self.MAX_SPEED), -self.MAX_SPEED)

            # 適用
            self.left_motor.setVelocity(left_speed)
            self.right_motor.setVelocity(right_speed)

            # 次のループのためにエラーを保存
            last_error = error

    # ===== VIO用：センサデータの取得と同期 =====
    def run_sensor_sync(self):
        """
        VIOのためのセンサデータ取得と同期のデモ。
        カメラ画像とIMUデータを同じタイムステップで取得し、タイムスタンプを記録します。
        """
        # サンプリング周期（Hz）の設定（例：10 Hz）
        # Webotsの基本タイムステップに合わせて調整してください
        sampling_hz = 10
        sampling_period_ms = 1000 // sampling_hz  # ミリ秒

        # 前回のサンプリング時刻
        last_sample_time = self.getTime()

        while self.step(self.timestep) != -1:
            current_time = self.getTime()

            # サンプリング周期が経過したらセンサデータを取得
            if (current_time - last_sample_time) * 1000 >= sampling_period_ms:
                # タイムスタンプ（秒）
                timestamp = current_time

                # 1. カメラ画像の取得（52x52に縮小）
                image = self.get_image()

                # 2. IMUデータの取得
                accel_values = self.accelerometer.getValues()  # [ax, ay, az]
                gyro_values = self.gyro.getValues()           # [gx, gy, gz]

                # 3. タイムスタンプとセンサデータをログ or 保存
                print(f"[{timestamp:.3f}s] "
                      f"Accel: ({accel_values[0]:.3f}, {accel_values[1]:.3f}, {accel_values[2]:.3f}) | "
                      f"Gyro: ({gyro_values[0]:.3f}, {gyro_values[1]:.3f}, {gyro_values[2]:.3f})")

                # ここで画像とIMUデータをVIOアルゴリズムに渡す処理を追加
                # 例：self.vio_update(timestamp, image, accel_values, gyro_values)

                # 前回サンプリング時刻を更新
                last_sample_time = current_time

            # ロボットの基本動作（例：前進）
            self.left_motor.setVelocity(self.speed)
            self.right_motor.setVelocity(self.speed)


# メイン実行部分
if __name__ == "__main__":
    controller = RobotController()
    # 通常の走行を試す場合は controller.run() など
    # VIO用のセンサ同期デモを実行
    controller.run_sensor_sync()