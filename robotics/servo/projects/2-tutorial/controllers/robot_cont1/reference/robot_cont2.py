from controller import Robot

# ロボットの初期化
robot = Robot()
timestep = int(robot.getBasicTimeStep())

# モーターやセンサーのデバイスを取得（例: 頭のモーター）
head_tilt = robot.getDevice('head_tilt_motor') 

while robot.step(timestep) != -1:
    # 制御ロジックをここに記述
    head_tilt.setPosition(0.5)  # 首を動かす
    pass
