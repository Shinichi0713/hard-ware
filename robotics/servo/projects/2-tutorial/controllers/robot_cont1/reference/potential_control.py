from controller import Robot
import math

# 初期設定
robot = Robot()
timestep = int(robot.getBasicTimeStep())
max_speed = 6.28

# デバイス取得
left_motor = robot.getDevice('left wheel motor')
right_motor = robot.getDevice('right wheel motor')
left_motor.setPosition(float('inf'))
right_motor.setPosition(float('inf'))

# センサー取得
ps = [robot.getDevice(f'ps{i}') for i in range(8)]
for s in ps: s.enable(timestep)

# 目標地点までの角度（グローバルプランナーが計算済みと想定）
target_angle = 1.57 # 例：右90度方向に目標がある

while robot.step(timestep) != -1:
    # 1. 障害物ベクトルを計算 (近接センサー ps0-ps7)
    # センサー値が大きいほど障害物が近い（壁がある）
    obs_x, obs_y = 0.0, 0.0
    for i in range(8):
        val = ps[i].getValue()
        if val > 100: # 閾値
            # 各センサーの向きに応じたベクトルを逆方向に加算（斥力）
            angle = (i / 8.0) * 2 * math.pi
            obs_x -= val * math.cos(angle)
            obs_y -= val * math.sin(angle)
    
    # 2. 目標ベクトルを計算 (引き寄せる力)
    goal_x = math.cos(target_angle)
    goal_y = math.sin(target_angle)
    
    # 3. 合成ベクトル (目標 + 障害物回避)
    final_x = goal_x + obs_x * 0.001
    final_y = goal_y + obs_y * 0.001
    
    # 4. 目標角度の再計算
    new_angle = math.atan2(final_y, final_x)
    
    # 5. モーター制御 (簡易的なPD制御)
    speed_diff = new_angle * 2.0
    left_speed  = max_speed * 0.5 + speed_diff
    right_speed = max_speed * 0.5 - speed_diff
    
    left_motor.setVelocity(left_speed)
    right_motor.setVelocity(right_speed)