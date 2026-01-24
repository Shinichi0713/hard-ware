import struct
import os
from controller import Robot

class MTNData:
    def __init__(self):
        self.roll = self.pitch = self.yaw = 0
        self.interpolation_frames = 0
        self.length = 0
        self.joints = []

class MTNPlayer:
    def __init__(self, robot, filename):
        self.robot = robot
        self.keyframes = []
        self.joints_prm = []
        self.device_tags = []
        self.is_playing = False
        self.error_message = ""
        
        if not self._load_mtn(filename):
            print(f"MTN Error: {self.error_message}")

    def _read_string(self, f):
        """1バイトの長さ指定がある文字列を読み込む"""
        raw_len = f.read(1)
        if not raw_len: return ""
        length = struct.unpack('B', raw_len)[0]
        if length == 0: return ""
        # 文字列本体を読み込み、不要なNULL文字を除去
        string_data = f.read(length)
        return string_data.decode('utf-8', errors='ignore').strip('\x00')

    def _load_mtn(self, filename):
        try:
            with open(filename, 'rb') as f:
                # 1. Magic (4 bytes)
                magic = f.read(4).decode('utf-8', errors='ignore')
                if magic != "OMTN":
                    self.error_message = f"Invalid format: {magic}"
                    return False

                # 2. Section 0 (Header)
                f.seek(12, os.SEEK_CUR)
                # リトルエンディアンで統一
                self.major_version, self.minor_version, self.num_keyframes, self.frame_rate = struct.unpack('<hhhh', f.read(8))
                f.seek(4, os.SEEK_CUR)

                # 3. Section 1 (Info)
                sec1_start = f.tell()
                f.seek(4, os.SEEK_CUR) # skip section number
                sec1_size = struct.unpack('<i', f.read(4))[0]
                self.motion_name = self._read_string(f)
                self.creator = self._read_string(f)
                self.design_label = self._read_string(f)
                # 次のセクションへ強制ジャンプ（文字列の読み取りエラー対策）
                f.seek(sec1_start + 8 + sec1_size, os.SEEK_SET)

                # 4. Section 2 (Joints)
                sec2_start = f.tell()
                f.seek(4, os.SEEK_CUR) 
                sec2_size = struct.unpack('<i', f.read(4))[0]
                self.num_joints = struct.unpack('<h', f.read(2))[0]
                
                print(f"Loading Motion: '{self.motion_name}', Joints: {self.num_joints}, Frames: {self.num_keyframes}")

                for i in range(self.num_joints):
                    prm_name = self._read_string(f)
                    self.joints_prm.append(prm_name)
                    tag = self.robot.getDevice(prm_name)
                    if not tag:
                        # ここが空文字なら読み込み位置がずれている
                        print(f"Warning: Joint '{prm_name}' not found.")
                    self.device_tags.append(tag)
                
                # 次のセクションへ強制ジャンプ
                f.seek(sec2_start + 8 + sec2_size, os.SEEK_SET)

                # 5. Section 3 (Keyframes)
                f.seek(12, os.SEEK_CUR)
                for i in range(self.num_keyframes):
                    data = MTNData()
                    if i > 0:
                        raw = f.read(4)
                        if len(raw) < 4: break
                        data.interpolation_frames = struct.unpack('<i', raw)[0]
                    
                    raw = f.read(12) # roll, pitch, yaw
                    if len(raw) < 12: break
                    data.roll, data.pitch, data.yaw = struct.unpack('<iii', raw)
                    
                    for _ in range(self.num_joints):
                        raw = f.read(4)
                        if len(raw) < 4: break
                        val = struct.unpack('<i', raw)[0]
                        data.joints.append(val / 1000000.0)
                    
                    # C言語の計算式を再現
                    if i > 0:
                        self.keyframes[i-1].length = (data.interpolation_frames + 1) * self.frame_rate
                    
                    self.keyframes.append(data)
                
                print(f"Successfully loaded {len(self.keyframes)} keyframes.")
                return True
        except Exception as e:
            self.error_message = f"Parse Error: {str(e)}"
            return False

    def play(self):
        if self.keyframes:
            self.current_keyframe = 0
            self.current_keyframe_time = 0
            self.is_playing = True

    def is_over(self):
        return not self.is_playing

    def step(self, ms):
        if not self.is_playing or self.current_keyframe >= len(self.keyframes):
            return

        key = self.keyframes[self.current_keyframe]
        
        # キーフレーム開始タイミング
        if self.current_keyframe_time == 0:
            for j in range(min(len(self.device_tags), len(key.joints))):
                if self.device_tags[j]:
                    self.device_tags[j].setPosition(key.joints[j])

        self.current_keyframe_time += ms
        
        # 次のキーフレームへの移行
        if self.current_keyframe_time >= key.length:
            self.current_keyframe += 1
            self.current_keyframe_time = 0
            if self.current_keyframe >= len(self.keyframes):
                self.is_playing = False