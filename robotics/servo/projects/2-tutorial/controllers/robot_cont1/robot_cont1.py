from controller import Robot
from mtn import MTN
import os
TIME_STEP = 64
MTN_REPLAY = 5

robot = Robot()

# MTN 読み込み
dir_curr = os.path.dirname(os.path.abspath(__file__))
motion = os.path.join(dir_curr, "data", "WWFWD.MTN")
mtn = MTN(motion)
if mtn is None:
    raise RuntimeError("Failed to load MTN")

loop = -1

# main loop

while robot.step(TIME_STEP) != -1:
    # MTN update
    mtn.step(TIME_STEP)


# MTN 終了時のループ処理
if mtn.isOver() and loop < MTN_REPLAY:
    mtn.play()
    loop += 1


# clean up
mtn.delete()
