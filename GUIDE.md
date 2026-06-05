# Retia Nibble Zero - Flashing & Setup Guide

This guide provides both automated and manual instructions for setting up your Nibble Zero RNode.

## Automated Setup (Recommended)
The easiest way to flash your device is using the provided script.

1. **Connect your Nibble Zero** via USB.
2. **Run the flasher**:
   ```bash
   cd ~/Reticulum/Release
   ./flash_nibble.sh /dev/ttyACM0
   ```
   *Note: If your device is on a different port, replace `/dev/ttyACM0`.*

---

## Manual Setup Guide
If you prefer to perform the steps manually or are on a system without the helper scripts, follow these instructions.

### 1. Prerequisites
Ensure you have `esptool` and `rnodeconf` installed:
```bash
pip install esptool rns
```

### 2. Enter Bootloader Mode
The Nibble Zero (ESP32-S3) can be put into bootloader mode by:
- **Software**: Set the serial port baud rate to `1200`.
- **Hardware**: Hold the **BOOT** button, press **RESET**, then release **BOOT**.

### 3. Flash the Firmware
Flash the combined `factory.bin` to address `0x0`:
```bash
esptool --chip esp32s3 --port /dev/ttyACM0 --baud 921600 \
  --before default_reset --after hard_reset write_flash -z \
  --flash_mode dio --flash_freq 80m --flash_size 4MB \
  0x0 factory.bin
```

### 4. Provision the Device
After flashing, the device needs to be identified as an RNode in its EEPROM.
```bash
rnodeconf /dev/ttyACM0 -r --platform 80 --product f0 --model fe --hwrev 1
```

### 5. Set the Firmware Hash
To ensure Reticulum recognizes the firmware version correctly:
1. Calculate the SHA256 hash of the `RNode_Firmware.ino.bin` (or use the provided `partition_hashes` script).
2. Set it:
   ```bash
   rnodeconf /dev/ttyACM0 --firmware-hash <YOUR_HASH>
   ```

---

## Verification
To verify your setup is working correctly:
```bash
rnodeconf --info /dev/ttyACM0
```
You should see:
- **Product**: Hombrew RNode
- **Firmware version**: 1.85
- **Device mode**: Normal (host-controlled)

## Testing the Link
If you have two devices, use the `test_link.sh` script to verify RF communication:
```bash
./test_link.sh /dev/ttyACM0 /dev/ttyACM1
```
