import math

class MotionController():
    def __init__(self, robot, motors, sensors):
        self.robot = robot
        self.motors = motors
        self.sensors = sensors
        self.t0 = robot.getTime()

        self.freq = 1.4
        self.A_hip  = 0.26
        self.A_knee = 0.18
        self.A_roll = 0.05
        self.knee_offset = 0.55
        self.forward_pitch = 0.05

    def set_joint(self, name, pos, vel=3.0):
        m = self.motors[name]
        m.setVelocity(abs(vel))
        m.setPosition(pos)

    def update_leg(self, leg, phase):
        s = math.sin(phase)
        c = math.sin(phase + math.pi/2)

        swing = s > 0.0

        hip_pitch = self.A_hip * s
        knee = self.A_knee * c + self.knee_offset
        if not swing:
            knee -= 0.06  # stance push

        hip_roll = self.A_roll * math.sin(2.0 * phase)

        self.set_joint(f"{leg}_j1", hip_roll)
        self.set_joint(f"{leg}_j2", hip_pitch)
        self.set_joint(f"{leg}_j3", knee)

    def walk(self):
        t = self.robot.getTime() - self.t0
        phase = 2.0 * math.pi * self.freq * t

        ramp = min(1.0, t / 1.2)
        phase *= ramp

        self.update_leg('fl', phase)
        self.update_leg('rr', phase)
        self.update_leg('fr', phase + math.pi)
        self.update_leg('rl', phase + math.pi)

        if 'body_pitch' in self.motors:
            self.set_joint('body_pitch', self.forward_pitch, vel=1.0)
