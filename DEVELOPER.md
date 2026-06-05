# Retia Nibble Zero - Developer Guide

This document explains how to build the RNode firmware for the Nibble Zero and how to modify its configuration.

## Environment Setup
We use `arduino-cli` to compile the firmware.

### 1. Install Dependencies
```bash
./setup_nibble_zero.sh
```
This script installs:
- `arduino-cli`
- ESP32-S3 core (v2.0.17)
- Required libraries (`Adafruit SSD1306`, `Adafruit SH110X`, `XPowersLib`, `Crypto`, etc.)
- Fixes the Bluetooth buffer sizes in the ESP32 core.

## Compilation
To compile the firmware for the Nibble Zero:
```bash
cd ~/Reticulum/RNode_Firmware
make firmware-retia_nibble
```
The resulting binaries will be in `build/esp32.esp32.esp32s3/`.

## Board Configuration
The Nibble Zero configuration is defined in:
- **`Boards.h`**: Hardware definitions (`BOARD_RETIA_NIBBLE`).
- **`Display.h`**: OLED pin mappings and initialization.
- **`variant.h`**: (In the setup folder) Pinouts for the ESP32-S3.

### Key Definitions
- `BOARD_MODEL`: `0xFF` (Retia Nibble)
- `LoRa Chip`: SX1262
- `OLED`: SSD1306 on pins 7 (SCL) and 8 (SDA)

## Creating a Release
To package a new release:
1. Update `Stable_OLED/bin/` with the new `.bin` files from the `build` directory.
2. Merge the bins into a `factory.bin`:
   ```bash
   esptool --chip esp32s3 merge_bin -o factory.bin \
     0x0000 bootloader.bin \
     0x8000 partitions.bin \
     0xe000 boot_app0.bin \
     0x10000 firmware.bin \
     0x210000 console_image.bin
   ```
