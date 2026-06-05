# Retia Nibble Zero - Release Package (OLED Support Enabled)

This directory contains the latest stable binaries and automated scripts for the Nibble Zero.

## Contents
- **`flash_nibble.sh`**: Automated flashing and provisioning script.
- **`test_link.sh`**: RF communication test.
- **`bin/factory.bin`**: Combined binary for single-pass flashing.
- **`bin/`**: Individual component binaries.

## Usage

### 1. Flash a Device
Connect the device and run:
```bash
./flash_nibble.sh /dev/ttyACM0
```

### 2. Test Communication (Requires 2 Devices)
```bash
./test_link.sh /dev/ttyACM0 /dev/ttyACM1
```

## Hardware Details
- **MCU**: ESP32-S3
- **LoRa**: SX1262
- **Display**: SSD1306 (I2C: SDA=8, SCL=7)
- **Identity**: Homebrew RNode (f0:fe:ff)

## Test Results (Verified 2026-06-05)
- **RF Link**: SUCCESS (Verified via `test_link.sh` between 2 nodes)
- **OLED Display**: SUCCESS (Confirmed by user)
- **Autoflash**: SUCCESS (Reset and bootloader modes automated)
