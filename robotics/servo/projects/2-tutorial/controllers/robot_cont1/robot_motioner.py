
import math
import common_resources


# 4. 歩行パラメータ（まずは小さめの値から調整）
FREQ = 1.5           # 歩行速度 (Hz)
AMP_HIP = 0.2        # 前後の振幅 (rad)
AMP_KNEE = 0.3       # 足を上げる高さ (rad)
OFFSET_KNEE = 0.6    # 基本の膝の曲がり（これがないと立てない）
OFFSET_ANKLE = -0.6  # 足首の角度（足裏を平行にする）
# # --- モーターへの出力 ---
# # Set A
# for leg in ['fr', 'rl']:
#     motors[f'{leg}_hip'].setPosition(pos_h_a)
#     motors[f'{leg}_knee'].setPosition(pos_v_a)
#     motors[f'{leg}_ankle'].setPosition(-pos_v_a) # アンクルで接地を並行に

# # Set B
# for leg in ['fl', 'rr']:
#     motors[f'{leg}_hip'].setPosition(pos_h_b)
#     motors[f'{leg}_knee'].setPosition(pos_v_b)
#     motors[f'{leg}_ankle'].setPosition(-pos_v_b)


class MotionController():
    def __init__(self, robot, motors, sensors):
        self.robot = robot
        self.motors = motors
        self.sensors = sensors

    def __control_leg(self, side_keys, phase):
        # サイン波を計算
        wave = math.sin(phase)
        
        # J1 (Hip): 前後スイング
        hip_pos = wave * AMP_HIP
        
        # J2 (Knee): 足を持ち上げる制御
        # wave > 0 のとき（足を前に出すとき）だけ膝を大きく曲げて足を浮かせる
        if wave > 0:
            knee_pos = OFFSET_KNEE + (wave * AMP_KNEE)
        else:
            # 接地フェーズ：一定の曲がりを維持して地面を蹴る
            knee_pos = OFFSET_KNEE
            
        # J3 (Ankle): 足首を膝と逆方向に動かし、足裏を水平に保つ
        ankle_pos = -knee_pos

        # モーターへ値を適用
        for side in side_keys:
            self.motors[side]['j1'].setPosition(hip_pos)
            self.motors[side]['j2'].setPosition(knee_pos)
            self.motors[side]['j3'].setPosition(ankle_pos)

    def walk(self):
        t = self.robot.getTime()
    
        # 基本の位相波形 (0.0 ～ 2π)
        # セットA (FL, RR) と セットB (FR, RL) で 180度 (π) 位相をずらす
        phase_a = 2.0 * math.pi * FREQ * t
        phase_b = phase_a + math.pi

        # トロット歩行：対角線の脚をペアにして動かす
        self.__control_leg(['fl', 'rr'], phase_a)
        self.__control_leg(['fr', 'rl'], phase_b)

        # 頭の揺れを抑える（安定化）
        head_motor = self.robot.getDevice('PRM:/r1/c1-Joint2:11')
        if head_motor: head_motor.setPosition(0)