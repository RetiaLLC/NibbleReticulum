import serial
import time
import sys

FEND = 0xC0

def read_frames(port, timeout=5):
    start = time.time()
    frame = []
    in_frame = False
    while time.time() - start < timeout:
        b = port.read(1)
        if not b: continue
        byte = b[0]
        if byte == FEND:
            if in_frame:
                if frame:
                    print(f"[{time.time() - start:.3f}s] Frame: {frame}")
                    frame = []
                in_frame = False
            else:
                in_frame = True
                frame = []
        elif in_frame:
            frame.append(byte)

port_name = sys.argv[1]
print(f"Opening {port_name} and listening for 5s...")
with serial.Serial(port_name, 115200, timeout=0.1) as ser:
    read_frames(ser)
