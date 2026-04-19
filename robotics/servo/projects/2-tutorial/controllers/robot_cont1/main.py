from robot_controller import RobotController

# 1. ロボットインスタンスの作成
robot = RobotController()



# 6. シミュレーションループ
while robot.step(robot.timestep) != -1:
    # 左右のモーターに同じ速度を設定して前進
    # robot.run()
    robot.run_vector_field()

    # robot.run_pid()