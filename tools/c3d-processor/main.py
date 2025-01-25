import numpy as np
import sys
import c3d

c3d_file = sys.argv[1]

positions = []

with open(c3d_file, 'rb') as file:
    reader = c3d.Reader(file)
    for i, frame in enumerate(reader.read_frames()):
        positions.append(list(frame[1][0]))

positions = np.array(positions, dtype=np.float64)
positions.tofile("{}.bin".format(c3d_file.split('.')[0]))
