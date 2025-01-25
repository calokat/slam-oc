import numpy as np
import sys
import c3d

c3d_file = sys.argv[1]

positions = []

with open(c3d_file, 'rb') as file:
    reader = c3d.Reader(file)
    for i, frame in enumerate(reader.read_frames()):
        positions.append(list(frame[1]))

positions = np.array(positions, dtype=np.float32)

p_bytes = positions.tobytes()

total_frames = positions.shape[0].to_bytes(length=4, byteorder="little")
total_nodes = positions.shape[1].to_bytes(length=4, byteorder="little")
vector_length = positions.shape[2].to_bytes(length=4, byteorder="little")

output = total_frames + total_nodes + vector_length + p_bytes

with open("{}.bin".format(c3d_file.split('.')[0]), 'wb') as file:
    file.write(output)
