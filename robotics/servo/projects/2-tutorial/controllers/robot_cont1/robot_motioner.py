
import math
import common_resources



# --- 3. 歩行パラメータの設定 (定数としてループ外に保持) ---
FREQUENCY = 1.2
AMPLITUDE_H = 0.15 # 前後スイング
AMPLITUDE_V = 0.15 # 上下（膝）
OFFSET_V = 0.3     # 立ち姿勢の維持（膝を少し曲げた状態が安定します）
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
    def __init__(self, robot, motors):
        self.robot = robot
        self.motors = motors

    def walk(self):
        time = self.robot.getTime()
            
        # 基本の波形（0～2π）
        phase = 2.0 * math.pi * FREQUENCY * time
        
        # A組 (右前 & 左後) と B組 (左前 & 右後) の位相を計算
        # math.sin(phase) が正の時に足を上げ、負の時に地面を蹴るように設計します
        wave_a = math.sin(phase)
        wave_b = math.sin(phase + math.pi)
        # --- 足の制御ロジック ---
        # set_a (FR, RL)
        pos_h_a = wave_a * AMPLITUDE_H
        # 足を上げるとき(wave > 0)だけ大きく膝を曲げる、下げるときは地面を押す
        pos_v_a = (wave_a * AMPLITUDE_V + OFFSET_V) if wave_a > 0 else OFFSET_V

        # set_b (FL, RR)
        pos_h_b = wave_b * AMPLITUDE_H
        pos_v_b = (wave_b * AMPLITUDE_V + OFFSET_V) if wave_b > 0 else OFFSET_V

        print(phase, pos_h_a, pos_v_a, pos_h_a, pos_v_b)
