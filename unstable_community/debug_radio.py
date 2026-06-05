import serial
import time
import sys

FEND = 0xC0

port_name = sys.argv[1]
print(f"Opening {port_name}...")
with serial.Serial(port_name, 115200, timeout=0.1) as ser:
    ser.read_all()
    
    # 868,000,000 Hz = 0x33BE7E55
    print(f"Setting frequency to 868,000,000 Hz...")
    ser.write(bytes([FEND, 0x01, 0x33, 0xBE, 0x7E, 0x55, FEND]))
    
    print("Setting Bandwidth to 125,000 Hz...")
    ser.write(bytes([FEND, 0x02, 0x00, 0x01, 0xE8, 0x48, FEND]))
    
    print("Setting TX Power to 2 dBm...")
    ser.write(bytes([FEND, 0x03, 0x02, FEND]))
    
    print("Setting SF to 7...")
    ser.write(bytes([FEND, 0x04, 0x07, FEND]))
    
    print("Setting CR to 5...")
    ser.write(bytes([FEND, 0x05, 0x05, FEND]))
    
    print("Setting radio state to ON...")
    ser.write(bytes([FEND, 0x06, 0x01, FEND]))
    
    time.sleep(1)
    
    print("Requesting radio state back...")
    ser.write(bytes([FEND, 0x06, 0xFF, FEND]))
    
    start = time.time()
    while time.time() - start < 2:
        line = ser.readline()
        if line:
            print(f"RAW: {line}")
        time.sleep(0.1)
