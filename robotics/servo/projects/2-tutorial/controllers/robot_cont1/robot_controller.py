from controller import Robot


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
        self.MAX_SPEED = 6.28 # e-puckの最大角速度(rad/s)
        self.THRESHOLD = 80.0  # 壁を検知するしきい値（値が大きいほど壁に近い）

        # 最大角速度(rad/s)
        self.speed = self.MAX_SPEED * 0.5

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