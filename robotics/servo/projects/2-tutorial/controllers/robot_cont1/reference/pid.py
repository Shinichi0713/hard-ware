from controller import Robot

# ロボットの初期化
robot = Robot()
timestep = int(robot.getBasicTimeStep())

# モーターの設定
MAX_SPEED = 6.28
left_motor = robot.getDevice('left wheel motor')
right_motor = robot.getDevice('right wheel motor')
left_motor.setPosition(float('inf'))
right_motor.setPosition(float('inf'))
left_motor.setVelocity(0.0)
right_motor.setVelocity(0.0)

# 右側の近接センサー（ps0）を使用
ps0 = robot.getDevice('ps0')
ps0.enable(timestep)

# --- PIDパラメータの設定 ---
target_value = 100.0  # 目標とする壁との距離（センサー値）
kp = 1.5              # 比例ゲイン（反応の強さ）
ki = 0.01             # 積分ゲイン（残留偏差の解消）
kd = 0.5              # 微分ゲイン（ガタつきの抑制）

integral = 0.0
last_error = 0.0
base_speed = 3.0      # 基本の進行速度

print("PID Wall Following started...")

while robot.step(timestep) != -1:
    # 現在のセンサー値を取得
    current_value = ps0.getValue()
    
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
    
    # 速度を制限（MAX_SPEEDを超えないように）
    left_speed = max(min(left_speed, MAX_SPEED), -MAX_SPEED)
    right_speed = max(min(right_speed, MAX_SPEED), -MAX_SPEED)
    
    # 適用
    left_motor.setVelocity(left_speed)
    right_motor.setVelocity(right_speed)
    
    # 次のループのためにエラーを保存
    last_error = error