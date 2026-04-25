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

        # IMUキャリブレーション用の変数
        self.accel_bias = [0.0, 0.0, 0.0]  # 加速度計バイアス
        self.gyro_bias = [0.0, 0.0, 0.0]   # ジャイロバイアス

        # 姿勢推定用の変数（ロール・ピッチ・ヨー）
        self.roll = 0.0
        self.pitch = 0.0
        self.yaw = 0.0

        # 相補フィルタの係数（加速度計とジャイロの重み）
        self.alpha = 0.98  # ジャイロの重み（高周波成分）
        self.beta = 0.02   # 加速度計の重み（低周波成分）

        # Visual Odometry用の変数
        self.prev_frame = None          # 前フレームの画像
        self.prev_keypoints = None      # 前フレームの特徴点
        self.prev_points = None         # 前フレームの特徴点座標（numpy）
        self.prev_timestamp = None      # 前フレームのタイムスタンプ

        # 特徴点検出器（FASTコーナー）
        self.feature_detector = cv2.FastFeatureDetector_create(threshold=20)

        # Lucas-Kanadeオプティカルフローのパラメータ
        self.lk_params = dict(winSize=(15, 15),
                              maxLevel=2,
                              criteria=(cv2.TERM_CRITERIA_EPS | cv2.TERM_CRITERIA_COUNT, 10, 0.03))

        # ===== プロトタイプVIO用の状態ベクトル =====
        # 状態ベクトル: x = [p, v, q]^T
        # p: 位置 (x, y, z) [m]（zは0と仮定）
        # v: 速度 (vx, vy, vz) [m/s]
        # q: 姿勢（クォータニオン）またはオイラー角（roll, pitch, yaw）
        # ===== プロトタイプVIO用の状態ベクトル =====
        self.position = np.array([0.0, 0.0, 0.0])   # 初期位置 (0, 0, 0)
        self.velocity = np.array([0.0, 0.0, 0.0])   # 初期速度 0

        # カメラのスケールファクタ（ピクセル移動量をメートルに変換する係数）
        # 実際にはキャリブレーションが必要だが、ここでは仮の値を使用
        self.pixel_to_meter = 0.01  # 1ピクセル = 1cm と仮定（スケールを大きく）

        # update_with_camera 内
        k_camera = 0.8  # カメラ観測の重みを増やす

        # 可視化用の変数
        self.viz_canvas_size = 400  # 可視化キャンバスのサイズ（ピクセル）
        self.viz_scale = 100.0      # 1m = 100ピクセル
        self.viz_center = self.viz_canvas_size // 2  # キャンバスの中心

        # 可視化ウィンドウの作成
        cv2.namedWindow("VIO Navigation", cv2.WINDOW_NORMAL)
        cv2.resizeWindow("VIO Navigation", self.viz_canvas_size, self.viz_canvas_size)

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
        # frame = cv2.resize(img_array, (52, 52), interpolation=cv2.INTER_NEAREST)
        frame = img_array

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

    # 障害のある方向を認識
    def __aware_direction(self):
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
            angle, val_sensor = self.__aware_direction()

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

    def visualize_features(self, frame, prev_points, curr_points):
        """
        現在のフレームに特徴点と追跡結果を描画する。
        frame: 現在のフレーム（カラー画像）
        prev_points: 前フレームの特徴点座標（numpy配列）
        curr_points: 現フレームの特徴点座標（numpy配列）
        """
        # フレームをコピー（元画像を変更しないため）
        viz_frame = frame.copy()

        if prev_points is not None and curr_points is not None:
            # 特徴点を描画（緑の円）
            for pt in curr_points:
                x, y = pt.ravel()
                cv2.circle(viz_frame, (int(x), int(y)), 3, (0, 255, 0), -1)  # 緑

            # 追跡線を描画（赤い線）
            for i in range(len(prev_points)):
                x1, y1 = prev_points[i].ravel()
                x2, y2 = curr_points[i].ravel()
                cv2.line(viz_frame, (int(x1), int(y1)), (int(x2), int(y2)), (0, 0, 255), 1)  # 赤

        # ウィンドウに表示
        cv2.imshow("Feature Tracking", viz_frame)
        cv2.waitKey(1)

    def visualize_navigation(self, target_x, target_y):
        """
        現在の推定位置と目標位置を可視化する。
        """
        # キャンバスの作成（白背景）
        canvas = np.ones((self.viz_canvas_size, self.viz_canvas_size, 3), dtype=np.uint8) * 255

        # 座標系の変換：世界座標 → キャンバス座標
        # キャンバスの中心を原点 (0, 0) とする
        x_px = int(self.position[0] * self.viz_scale) + self.viz_center
        y_px = int(-self.position[1] * self.viz_scale) + self.viz_center  # y軸は反転
        target_x_px = int(target_x * self.viz_scale) + self.viz_center
        target_y_px = int(-target_y * self.viz_scale) + self.viz_center

        # 目標位置を描画（赤い円）
        cv2.circle(canvas, (target_x_px, target_y_px), 8, (0, 0, 255), -1)  # 赤
        cv2.putText(canvas, "Target", (target_x_px + 10, target_y_px),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 0, 255), 1)

        # 現在の推定位置を描画（青い円）
        cv2.circle(canvas, (x_px, y_px), 6, (255, 0, 0), -1)  # 青
        cv2.putText(canvas, "Robot", (x_px + 10, y_px),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 0, 0), 1)

        # 軌跡（過去の位置）を描画（オプション：必要に応じてリストで保持）
        # ここでは簡易的に現在位置のみ表示

        # グリッド線を描画（オプション）
        grid_step = 50  # 50ピクセルごと
        for i in range(0, self.viz_canvas_size, grid_step):
            cv2.line(canvas, (i, 0), (i, self.viz_canvas_size), (200, 200, 200), 1)
            cv2.line(canvas, (0, i), (self.viz_canvas_size, i), (200, 200, 200), 1)

        # 原点（キャンバス中心）を描画
        cv2.circle(canvas, (self.viz_center, self.viz_center), 2, (0, 0, 0), -1)

        # ウィンドウに表示
        cv2.imshow("VIO Navigation", canvas)
        cv2.waitKey(1)  # 描画を更新


    # ===== IMUキャリブレーション =====
    def calibrate_imu(self, duration=3.0):
        """
        静止時のIMUバイアスを測定する。
        duration: キャリブレーション時間（秒）
        """
        print("IMUキャリブレーション開始：ロボットを静止させてください...")

        # モーターを停止
        self.left_motor.setVelocity(0.0)
        self.right_motor.setVelocity(0.0)

        start_time = self.getTime()
        accel_sum = [0.0, 0.0, 0.0]
        gyro_sum = [0.0, 0.0, 0.0]
        count = 0

        while self.step(self.timestep) != -1:
            current_time = self.getTime()
            if current_time - start_time >= duration:
                break

            # IMUデータ取得
            accel_values = self.accelerometer.getValues()
            gyro_values = self.gyro.getValues()

            # 合計に加算
            for i in range(3):
                accel_sum[i] += accel_values[i]
                gyro_sum[i] += gyro_values[i]
            count += 1

        # 平均をバイアスとして保存
        if count > 0:
            self.accel_bias = [accel_sum[i] / count for i in range(3)]
            self.gyro_bias = [gyro_sum[i] / count for i in range(3)]

        print(f"IMUキャリブレーション完了（{count}サンプル）")
        print(f"Accel Bias: {self.accel_bias}")
        print(f"Gyro Bias: {self.gyro_bias}")

    # ===== 姿勢推定（相補フィルタ） =====
    def update_attitude(self, dt):
        """
        加速度計とジャイロから姿勢（ロール・ピッチ・ヨー）を推定する。
        dt: 前回からの経過時間（秒）
        """
        # IMUデータ取得（バイアス補正）
        accel_raw = self.accelerometer.getValues()
        gyro_raw = self.gyro.getValues()

        accel = [accel_raw[i] - self.accel_bias[i] for i in range(3)]
        gyro = [gyro_raw[i] - self.gyro_bias[i] for i in range(3)]

        # 加速度計からロール・ピッチを計算（重力方向）
        ax, ay, az = accel
        norm = math.sqrt(ax*ax + ay*ay + az*az)
        if norm > 0:
            ax, ay, az = ax/norm, ay/norm, az/norm

        # ロール（x軸周りの回転）
        roll_acc = math.atan2(ay, az)
        # ピッチ（y軸周りの回転）
        pitch_acc = math.atan2(-ax, math.sqrt(ay*ay + az*az))

        # ジャイロから角速度を積分
        gx, gy, gz = gyro
        self.roll += gx * dt
        self.pitch += gy * dt
        self.yaw += gz * dt

        # 相補フィルタで姿勢を更新
        self.roll = self.alpha * self.roll + self.beta * roll_acc
        self.pitch = self.alpha * self.pitch + self.beta * pitch_acc

        # 角度を -pi〜pi の範囲に正規化
        self.roll = self.normalize_angle(self.roll)
        self.pitch = self.normalize_angle(self.pitch)
        self.yaw = self.normalize_angle(self.yaw)

        return self.roll, self.pitch, self.yaw

    def normalize_angle(self, angle):
        """
        角度を -pi〜pi の範囲に正規化する。
        """
        while angle > math.pi:
            angle -= 2 * math.pi
        while angle < -math.pi:
            angle += 2 * math.pi
        return angle

    # ===== Visual Odometry：特徴点抽出・追跡・運動推定 =====
    def extract_features(self, frame, max_features=100):
        """
        現在のフレームから特徴点を抽出する。
        frame: グレースケール画像
        max_features: 最大特徴点数
        """
        # FASTコーナー検出
        keypoints = self.feature_detector.detect(frame, None)

        # 特徴点数を制限
        if len(keypoints) > max_features:
            keypoints = sorted(keypoints, key=lambda x: -x.response)[:max_features]

        # キーポイントを numpy 配列に変換（オプティカルフロー用）
        points = np.array([kp.pt for kp in keypoints], dtype=np.float32).reshape(-1, 1, 2)

        return keypoints, points

    def track_features(self, prev_frame, curr_frame, prev_points):
        """
        前フレームの特徴点を現フレームに追跡する（Lucas-Kanadeオプティカルフロー）。
        """
        if prev_points is None or len(prev_points) == 0:
            return None, None

        # オプティカルフロー計算
        curr_points, status, _ = cv2.calcOpticalFlowPyrLK(
            prev_frame, curr_frame, prev_points, None, **self.lk_params)

        # 追跡成功した点のみ抽出
        if status is not None:
            good_prev = prev_points[status.flatten() == 1]
            good_curr = curr_points[status.flatten() == 1]
            return good_prev, good_curr
        else:
            return None, None

    def estimate_motion(self, prev_points, curr_points):
        """
        対応点からカメラの相対運動（ホモグラフィ）を推定し、回転・並進を近似する。
        """
        if prev_points is None or curr_points is None or len(prev_points) < 8:
            return None, None

        # ホモグラフィ推定（RANSACで外れ値除去）
        H, mask = cv2.findHomography(prev_points, curr_points, cv2.RANSAC, 5.0)

        if H is None:
            return None, None

        # ホモグラフィから回転・並進を分解（簡易近似）
        num_inliers = np.sum(mask)
        print(f"Homography inliers: {num_inliers} / {len(prev_points)}")

        # ホモグラフィの平行移動成分を並進の近似として使用
        tx = H[0, 2]
        ty = H[1, 2]

        # 回転成分の近似（スケールは無視）
        print(f"Estimated motion - Translation: ({tx:.2f}, {ty:.2f}) pixels")

        return H, (tx, ty)

    # ===== プロトタイプVIO：IMU予測＋カメラ更新 =====
    def predict_with_imu(self, dt):
        """
        IMUから短時間の姿勢・速度・位置の変化を予測する。
        dt: 予測時間（秒）
        """
        # IMUデータ取得（バイアス補正済み）
        accel_raw = self.accelerometer.getValues()
        gyro_raw = self.gyro.getValues()
        accel = [accel_raw[i] - self.accel_bias[i] for i in range(3)]
        gyro = [gyro_raw[i] - self.gyro_bias[i] for i in range(3)]

        # 姿勢更新（既存の update_attitude を利用）
        roll, pitch, yaw = self.update_attitude(dt)

        # 速度・位置の予測（簡易モデル）
        # 加速度を世界座標系に変換（簡易近似）
        ax_world = accel[0] * math.cos(yaw) - accel[1] * math.sin(yaw)
        ay_world = accel[0] * math.sin(yaw) + accel[1] * math.cos(yaw)
        az_world = accel[2]  # 重力成分は既に補正済みと仮定

        # 速度を更新
        self.velocity[0] += ax_world * dt
        self.velocity[1] += ay_world * dt
        self.velocity[2] += az_world * dt

        # 位置を更新
        self.position[0] += self.velocity[0] * dt
        self.position[1] += self.velocity[1] * dt
        self.position[2] += self.velocity[2] * dt

        return self.position, self.velocity, (roll, pitch, yaw)

    def update_with_camera(self, visual_motion, dt):
        """
        カメラの相対運動（Visual Odometry）を状態ベクトルに反映する。
        visual_motion: (tx, ty) [pixels]
        dt: 前回からの経過時間（秒）
        """
        if visual_motion is None:
            return

        tx_pixels, ty_pixels = visual_motion

        # ピクセル移動量をメートルに変換
        tx_meters = tx_pixels * self.pixel_to_meter
        ty_meters = ty_pixels * self.pixel_to_meter

        # 簡易的な補正：位置をカメラの観測に近づける
        # 実際のVIOではカルマンフィルタなどを使うが、ここでは単純な補正
        k_camera = 0.5  # カメラ観測の重み（0〜1）

        self.position[0] = (1 - k_camera) * self.position[0] + k_camera * tx_meters
        self.position[1] = (1 - k_camera) * self.position[1] + k_camera * ty_meters

        print(f"VIO Update - Position: ({self.position[0]:.3f}, {self.position[1]:.3f}) m")

    # 速度の計算：目的地への制御量を計算する関数
    def compute_control_to_target(self, target_x, target_y):
        x, y = self.position[0], self.position[1]
        yaw = self.yaw

        dx = target_x - x
        dy = target_y - y
        distance = math.sqrt(dx*dx + dy*dy)

        target_yaw = math.atan2(dy, dx)
        dyaw = target_yaw - yaw
        while dyaw > math.pi:
            dyaw -= 2 * math.pi
        while dyaw < -math.pi:
            dyaw += 2 * math.pi

        # 1. 距離が近いほど速度を落とす（安全第一）
        max_speed = self.MAX_SPEED * 0.5
        if distance < 0.5:
            base_speed = max_speed * (distance / 0.5)  # 0.5m以内で減速
        else:
            base_speed = max_speed

        # 2. 姿勢誤差が大きいときは、まず向きを合わせる（速度を落とす）
        if abs(dyaw) > math.radians(30):  # 30度以上ずれている場合
            base_speed *= 0.3  # 速度を落とす
            kp_yaw = 1.5       # 旋回を強く
        else:
            kp_yaw = 0.8       # 通常時は穏やかに

        omega = kp_yaw * dyaw
        omega = max(min(omega, self.MAX_SPEED), -self.MAX_SPEED)

        left_speed = base_speed - omega
        right_speed = base_speed + omega

        left_speed = max(min(left_speed, self.MAX_SPEED), -self.MAX_SPEED)
        right_speed = max(min(right_speed, self.MAX_SPEED), -self.MAX_SPEED)

        return left_speed, right_speed, distance, dyaw

    # ===== VIO用：センサデータの取得と同期 + IMUキャリブレーション・姿勢推定 + Visual Odometry + VIO統合 =====
    def run_sensor_sync(self):
        """
        VIOのためのセンサデータ取得と同期のデモ。
        カメラ画像とIMUデータを同じタイムステップで取得し、タイムスタンプを記録します。
        """
        # サンプリング周期（Hz）の設定（例：10 Hz）
        sampling_hz = 10
        sampling_period_ms = 1000 // sampling_hz  # ミリ秒

        # 前回のサンプリング時刻
        last_sample_time = self.getTime()

        # IMUキャリブレーションを実行
        self.calibrate_imu(duration=3.0)

        # 姿勢推定用の前回時刻
        last_attitude_time = self.getTime()

        # VIO用の前回時刻
        last_vio_time = self.getTime()

        while self.step(self.timestep) != -1:
            current_time = self.getTime()

            # サンプリング周期が経過したらセンサデータを取得
            if (current_time - last_sample_time) * 1000 >= sampling_period_ms:
                # タイムスタンプ（秒）
                timestamp = current_time

                # 1. カメラ画像の取得（52x52に縮小）
                image_bgr = self.get_image()
                frame_gray = cv2.cvtColor(image_bgr, cv2.COLOR_BGR2GRAY)

                # 2. IMUデータの取得（バイアス補正済み）
                accel_raw = self.accelerometer.getValues()
                gyro_raw = self.gyro.getValues()
                accel = [accel_raw[i] - self.accel_bias[i] for i in range(3)]
                gyro = [gyro_raw[i] - self.gyro_bias[i] for i in range(3)]

                # 3. Visual Odometry：特徴点抽出・追跡・運動推定
                visual_motion = None
                if self.prev_frame is None:
                    # 初回は特徴点を抽出するだけ
                    keypoints, points = self.extract_features(frame_gray, max_features=100)
                    self.prev_frame = frame_gray.copy()
                    self.prev_keypoints = keypoints
                    self.prev_points = points
                    self.prev_timestamp = timestamp
                    print(f"[{timestamp:.3f}s] First frame: {len(keypoints)} features extracted")
                else:
                    # 特徴点追跡
                    prev_points_good, curr_points_good = self.track_features(
                        self.prev_frame, frame_gray, self.prev_points)

                    if prev_points_good is not None and len(prev_points_good) > 0:
                        # 運動推定
                        H, motion = self.estimate_motion(prev_points_good, curr_points_good)
                        visual_motion = motion

                    # 次のフレームのために更新
                    keypoints, points = self.extract_features(frame_gray, max_features=100)
                    self.prev_frame = frame_gray.copy()
                    self.prev_keypoints = keypoints
                    self.prev_points = points
                    self.prev_timestamp = timestamp

                # 4. VIO：IMU予測＋カメラ更新
                dt_vio = current_time - last_vio_time
                if dt_vio > 0:
                    # IMUによる予測
                    position_pred, velocity_pred, attitude_pred = self.predict_with_imu(dt_vio)

                    # カメラによる更新（Visual Odometryの結果を反映）
                    self.update_with_camera(visual_motion, dt_vio)

                    # VIOの結果をログ出力
                    roll, pitch, yaw = attitude_pred
                    print(f"[{timestamp:.3f}s] VIO State - "
                          f"Position: ({self.position[0]:.3f}, {self.position[1]:.3f}) m | "
                          f"Attitude: Roll={math.degrees(roll):.1f}°, Pitch={math.degrees(pitch):.1f}°, Yaw={math.degrees(yaw):.1f}°")

                    last_vio_time = current_time

                # 5. IMUデータのログ
                print(f"[{timestamp:.3f}s] "
                      f"Accel: ({accel[0]:.3f}, {accel[1]:.3f}, {accel[2]:.3f}) | "
                      f"Gyro: ({gyro[0]:.3f}, {gyro[1]:.3f}, {gyro[2]:.3f})")

                # 前回サンプリング時刻を更新
                last_sample_time = current_time

            # 姿勢推定（高頻度で更新）
            dt_attitude = current_time - last_attitude_time
            if dt_attitude > 0:
                roll, pitch, yaw = self.update_attitude(dt_attitude)
                # 姿勢をログ出力（必要に応じて）
                # print(f"Attitude: Roll={math.degrees(roll):.1f}°, Pitch={math.degrees(pitch):.1f}°, Yaw={math.degrees(yaw):.1f}°")
                last_attitude_time = current_time

            # ロボットの基本動作（例：前進）
            self.left_motor.setVelocity(self.speed)
            self.right_motor.setVelocity(self.speed)

    def run_vio_step(self, dt_vio):
        """
        1ステップだけVIOを更新し、特徴点を可視化する。
        dt_vio: 前回からの経過時間（秒）
        """
        # カメラ画像の取得（52x52に縮小）
        image_bgr = self.get_image()
        frame_gray = cv2.cvtColor(image_bgr, cv2.COLOR_BGR2GRAY)

        # IMUデータの取得（バイアス補正済み）
        accel_raw = self.accelerometer.getValues()
        gyro_raw = self.gyro.getValues()
        accel = [accel_raw[i] - self.accel_bias[i] for i in range(3)]
        gyro = [gyro_raw[i] - self.gyro_bias[i] for i in range(3)]

        # Visual Odometry：特徴点抽出・追跡・運動推定
        visual_motion = None
        if self.prev_frame is None:
            # 初回は特徴点を抽出するだけ
            keypoints, points = self.extract_features(frame_gray, max_features=100)
            self.prev_frame = frame_gray.copy()
            self.prev_keypoints = keypoints
            self.prev_points = points
            self.prev_timestamp = self.getTime()
            print(f"[{self.prev_timestamp:.3f}s] First frame: {len(keypoints)} features extracted")
        else:
            # 特徴点追跡
            prev_points_good, curr_points_good = self.track_features(
                self.prev_frame, frame_gray, self.prev_points)

            # 特徴点の可視化
            self.visualize_features(image_bgr, prev_points_good, curr_points_good)

            if prev_points_good is not None and len(prev_points_good) > 0:
                # 運動推定
                H, motion = self.estimate_motion(prev_points_good, curr_points_good)
                visual_motion = motion

            # 次のフレームのために更新
            keypoints, points = self.extract_features(frame_gray, max_features=100)
            self.prev_frame = frame_gray.copy()
            self.prev_keypoints = keypoints
            self.prev_points = points
            self.prev_timestamp = self.getTime()

        # IMUによる予測
        position_pred, velocity_pred, attitude_pred = self.predict_with_imu(dt_vio)

        # カメラによる更新（Visual Odometryの結果を反映）
        self.update_with_camera(visual_motion, dt_vio)

        # VIOの結果をログ出力（任意）
        roll, pitch, yaw = attitude_pred
        print(f"[{self.prev_timestamp:.3f}s] VIO State - "
            f"Position: ({self.position[0]:.3f}, {self.position[1]:.3f}) m | "
            f"Attitude: Roll={math.degrees(roll):.1f}°, Pitch={math.degrees(pitch):.1f}°, Yaw={math.degrees(yaw):.1f}°")
    
    def run_autonomous_navigation(self, target_x, target_y, tolerance=0.1):
        """
        目的地 (target_x, target_y) まで自律移動し、可視化する。
        tolerance: 到着とみなす距離 [m]
        """
        # IMUキャリブレーション
        self.calibrate_imu(duration=3.0)

        # VIO用の前回時刻
        last_vio_time = self.getTime()

        while self.step(self.timestep) != -1:
            current_time = self.getTime()

            # VIO更新（一定周期で実行）
            dt_vio = current_time - last_vio_time
            if dt_vio > 0:
                # VIOを1ステップ更新
                self.run_vio_step(dt_vio)

                # 目的地への制御量を計算
                left_speed, right_speed, distance, dyaw = self.compute_control_to_target(target_x, target_y)

                # ログ出力
                print(f"Distance to target: {distance:.3f} m, Yaw error: {math.degrees(dyaw):.1f}°")

                # 可視化
                self.visualize_navigation(target_x, target_y)

                # 到着判定
                if distance < tolerance:
                    print("目標地点に到着しました。停止します。")
                    self.left_motor.setVelocity(0.0)
                    self.right_motor.setVelocity(0.0)
                    # 到着後も可視化を続ける（任意）
                    while self.step(self.timestep) != -1:
                        self.visualize_navigation(target_x, target_y)
                    break  # ループ終了

                # モータ駆動
                self.left_motor.setVelocity(left_speed)
                self.right_motor.setVelocity(right_speed)

                last_vio_time = current_time

# メイン実行部分
if __name__ == "__main__":
    controller = RobotController()
    # VIO用のセンサ同期デモを実行（IMUキャリブレーション＋姿勢推定＋Visual Odometry＋VIO統合）
    controller.run_sensor_sync()