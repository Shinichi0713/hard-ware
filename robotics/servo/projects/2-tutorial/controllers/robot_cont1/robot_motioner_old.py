
import math
import common_resources


# 4. 歩行パラメータ（まずは小さめの値から調整）
FREQ = 1.0           # 安定性を高めるため、少しゆっくりに
AMP_HIP = 0.2        # 前後振幅
AMP_KNEE = 0.25      # 膝の振幅（警告回避のため小さく）
OFFSET_KNEE = 0.4    # 膝の曲がり具合
# 足首(J3)の可動域が -0.5236 までなので、余裕を持って設定
OFFSET_ANKLE = -0.4


class MotionController():
    def __init__(self, robot, motors, sensors):
        self.robot = robot
        self.motors = motors
        self.sensors = sensors

    def update_leg(self, leg_prefix, phase):
        wave = math.sin(phase)
        
        # J1: 前後スイング
        target_j1 = wave * AMP_HIP
        
        # J2: 膝の上下（waveが正の時に足を上げ、負の時は接地して後ろに送る）
        if wave > 0:
            target_j2 = OFFSET_KNEE + (wave * AMP_KNEE)
        else:
            target_j2 = OFFSET_KNEE # 接地中は高さを維持
            
        # J3: 足首（膝の動きを打ち消して足裏を水平に保つ）
        target_j3 = OFFSET_ANKLE - (target_j2 - OFFSET_KNEE)
        if target_j3 < -0.52: target_j3 = -0.52  # 物理限界のガード

        # モーターへ適用（安全のため速度を再設定）
        m1, m2, m3 = f'{leg_prefix}_j1', f'{leg_prefix}_j2', f'{leg_prefix}_j3'
        for m in [m1, m2, m3]: self.motors[m].setVelocity(3.0)
        
        self.motors[m1].setPosition(target_j1)
        self.motors[m2].setPosition(target_j2)
        self.motors[m3].setPosition(target_j3)

    def walk(self):
        time = self.robot.getTime()
    
        # 対角線のペア（グループA: 前左・後右, グループB: 前右・後左）
        # 位相を π (180度) ずらして交互に動かします
        phase_a = 2.0 * math.pi * FREQ * time
        phase_b = phase_a + math.pi

        # 頭の揺れを抑える（安定化）
        head_motor = self.robot.getDevice('PRM:/r1/c1-Joint2:11')
        if head_motor: head_motor.setPosition(0)

        # トロット歩行の実行
        self.update_leg('fl', phase_a)
        self.update_leg('rr', phase_a)
        self.update_leg('fr', phase_b)
        self.update_leg('rl', phase_b)

        # 頭と尻尾の固定
        for m in ['neck_tilt', 'head_pan', 'head_tilt']:
            if m in self.motors:
                self.motors[m].setVelocity(0.0)
                self.motors[m].setPosition(0.0)