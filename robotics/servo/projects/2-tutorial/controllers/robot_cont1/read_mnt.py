import os
import struct

def read_omtn(path):
    with open(path, 'rb') as f:
        data = f.read()

    magic = data[0:4]
    assert magic == b'OMTN'

    # extract header fields
    header_size   = struct.unpack('<I', data[8:12])[0]
    joint_count   = struct.unpack('<I', data[12:16])[0]
    frame_count   = struct.unpack('<H', data[16:18])[0]
    fps           = struct.unpack('<H', data[18:20])[0]

    # name offset
    name_offset   = struct.unpack('<I', data[28:32])[0]

    name = data[name_offset:].split(b'\x00',1)[0].decode('ascii', errors='ignore')

    # motion data offset (immediately after header)
    data_offset = header_size
    values = []

    # joint angles are int16
    for fidx in range(frame_count):
        frame_vals = []
        for j in range(joint_count):
            raw = struct.unpack('<h', data[data_offset:data_offset+2])[0]
            data_offset += 2
            frame_vals.append(raw / 100.0)  # convert to degrees
        values.append(frame_vals)

    return {
        'joints': joint_count,
        'frames': frame_count,
        'fps': fps,
        'name': name,
        'angles_deg': values
    }


dir_curr = os.path.dirname(os.path.abspath(__file__))
motion = os.path.join(dir_curr, "data", "WWFWD.MTN")
motion = read_omtn(motion)

print('joints:', motion['joints'])
print('first frame:', motion['angles_deg'][0])
print('total frames:', len(motion['angles_deg']))
