from controller import Robot, Motor
import math
import common_resources
import robot_motioner

# ロボットの初期化
robot = Robot()

# 基本タイムステップの取得
timestep = int(robot.getBasicTimeStep())
print("Aibo Trot Controller started!")

# --- 1. デバイス名定義 (ユーザー提供リストより) ---
# ※ この定義ブロックは、コードの先頭（importとrobot()の間）に移動し、
#    一度定義されたJOINTS辞書を再利用できるようにするのが理想です。
JOINTS = {
    # 頭と尻尾
    'head_pan': 'PRM:/r1/c1-Joint2:11',
    'head_tilt': 'PRM:/r1/c1/c2-Joint2:12',
    'tail_pan': 'PRM:/r6/c1-Joint2:61',
    'camera': 'PRM:/r1/c1/c2/c3/i1-FbkImageSensor:F1',

    # 前右 (FR) - r2
    'fr_hip': 'PRM:/r2/c1-Joint2:21',
    'fr_knee': 'PRM:/r2/c1/c2-Joint2:22',
    'fr_ankle': 'PRM:/r2/c1/c2/c3-Joint2:23',
    
    # 前左 (FL) - r3
    'fl_hip': 'PRM:/r3/c1-Joint2:31',
    'fl_knee': 'PRM:/r3/c1/c2-Joint2:32',
    'fl_ankle': 'PRM:/r3/c1/c2/c3-Joint2:33',
    
    # 後右 (RR) - r4
    'rr_hip': 'PRM:/r4/c1-Joint2:41',
    'rr_knee': 'PRM:/r4/c1/c2-Joint2:42',
    'rr_ankle': 'PRM:/r4/c1/c2/c3-Joint2:43',
    
    # 後左 (RL) - r5
    'rl_hip': 'PRM:/r5/c1-Joint2:51',
    'rl_knee': 'PRM:/r5/c1/c2-Joint2:52',
    'rl_ankle': 'PRM:/r5/c1/c2/c3-Joint2:53',
}

# --- 2. デバイスの取得と初期化 ---
motors = {}
for name, device_id in JOINTS.items():
    motor = robot.getDevice(device_id)
    if motor and isinstance(motor, Motor):
        # 重要な変更点：初期トルクと速度を制限して急激な動きを防ぐ
        motor.setPosition(0.0)  # 最初はホームポジションへ
        motor.setVelocity(2.0)  # 爆発を防ぐため速度を制限（後で調整可）
        # motor.setAvailableTorque(10.0) # 必要に応じてトルク制限
        motors[name] = motor


# --- 2. カメラの有効化 ---
# if camera is not None:
#     camera.enable(timestep)
#     print(f"カメラを有効化しました: {JOINTS['camera']}")
# else:
#     print("WARNING: カメラが見つかりませんでした。")


# --- 3. 歩行パラメータの微調整 ---
motioner = robot_motioner.MotionController(robot, motors)
# 数値を小さめから始めて、徐々に大きくするのがコツです
while robot.step(timestep) != -1:
    motioner.walk()