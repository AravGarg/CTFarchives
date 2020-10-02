import struct
import sys

with open(sys.argv[1], 'rb') as f:
    d = f.read()

for i in range(0, len(d), 4):
    w, = struct.unpack('<I', d[i:i+4])
    print('{:08x}'.format(w))
