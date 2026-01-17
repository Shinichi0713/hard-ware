from controller import Robot, Motor
import math
import common_resources
import robot_motioner

# ロボットの初期化
robot = Robot()

# 基本タイムステップの取得
timestep = int(robot.getBasicTimeStep())
print("Aibo Trot Controller started!")

# --- 全デバイス名をリストアップする（デバッグ用） ---
print("--- 搭載されている全デバイス名 ---")
for i in range(robot.getNumberOfDevices()):
    device = robot.getDeviceByIndex(i)
    print(f"Index {i}: {device.getName()}")
print("---------------------------------")

# --- 1. デバイス名定義 (ユーザー提供リストより) ---
# ※ この定義ブロックは、コードの先頭（importとrobot()の間）に移動し、
#    一度定義されたJOINTS辞書を再利用できるようにするのが理想です。
# Aibo Joint Device Mapping
JOINTS = {
    # 首・頭・口
    'neck_tilt': {'motor': 'PRM:/r1/c1-Joint2:11', 'sensor': None},
    'head_pan':  {'motor': 'PRM:/r1/c1/c2-Joint2:12', 'sensor': None},
    'head_tilt': {'motor': 'PRM:/r1/c1/c2/c3-Joint2:13', 'sensor': None},
    'jaw':       {'motor': 'PRM:/r1/c1/c2/c3/c4-Joint2:14', 'sensor': None},

    # 前左 (Left Foreleg - r2)
    'fl_j1': {'motor': 'PRM:/r2/c1-Joint2:21', 'sensor': 'RM:/r2/c1-JointSensor2:21'}, # ここが RM:
    'fl_j2': {'motor': 'PRM:/r2/c1/c2-Joint2:22', 'sensor': 'PRM:/r2/c1/c2-JointSensor2:22'},
    'fl_j3': {'motor': 'PRM:/r2/c1/c2/c3-Joint2:23', 'sensor': 'PRM:/r2/c1/c2/c3-JointSensor2:23'},

    # 後左 (Left Hindleg - r3)
    'rl_j1': {'motor': 'PRM:/r3/c1-Joint2:31', 'sensor': 'PRM:/r3/c1-JointSensor2:31'},
    'rl_j2': {'motor': 'PRM:/r3/c1/c2-Joint2:32', 'sensor': 'PRM:/r3/c1/c2-JointSensor2:32'},
    'rl_j3': {'motor': 'PRM:/r3/c1/c2/c3-Joint2:33', 'sensor': 'PRM:/r3/c1/c2/c3-JointSensor2:33'},

    # 前右 (Right Foreleg - r4)
    'fr_j1': {'motor': 'PRM:/r4/c1-Joint2:41', 'sensor': 'PRM:/r4/c1-JointSensor2:41'},
    'fr_j2': {'motor': 'PRM:/r4/c1/c2-Joint2:42', 'sensor': 'PRM:/r4/c1/c2-JointSensor2:42'},
    'fr_j3': {'motor': 'PRM:/r4/c1/c2/c3-Joint2:43', 'sensor': 'PRM:/r4/c1/c2/c3-JointSensor2:43'},

    # 後右 (Right Hindleg - r5)
    'rr_j1': {'motor': 'PRM:/r5/c1-Joint2:51', 'sensor': 'PRM:/r5/c1-JointSensor2:51'},
    'rr_j2': {'motor': 'PRM:/r5/c1/c2-Joint2:52', 'sensor': 'PRM:/r5/c1/c2-JointSensor2:52'},
    'rr_j3': {'motor': 'PRM:/r5/c1/c2/c3-Joint2:53', 'sensor': 'PRM:/r5/c1/c2/c3-JointSensor2:53'},
}


# --- 2. デバイスの取得と初期化 ---
motors = {}
sensors = {}
for key, ids in JOINTS.items():
    device = robot.getDevice(ids['motor'])
    if device:
        motors[key] = device
        motors[key].setPosition(0.0)
        # 初期状態は0。ループ内で動かす際に適切な速度を設定します。
        motors[key].setVelocity(0.0)
        motors[key].setTorque(0.0)
    
    if ids['sensor']:
        sensor_device = robot.getDevice(ids['sensor'])
        if sensor_device:
            sensors[key] = sensor_device
            sensors[key].enable(timestep)

print(motors)
# --- 2. カメラの有効化 ---
# if camera is not None:
#     camera.enable(timestep)
#     print(f"カメラを有効化しました: {JOINTS['camera']}")
# else:
#     print("WARNING: カメラが見つかりませんでした。")


# --- 3. 歩行パラメータの微調整 ---
motioner = robot_motioner.MotionController(robot, motors, sensors)
# 数値を小さめから始めて、徐々に大きくするのがコツです
while robot.step(timestep) != -1:
    motioner.walk()