#!/bin/bash

# Retia Nibble Zero - Automated Flasher
# This script handles the entire lifecycle: bootloader entry, flashing, and provisioning.

set -e

PORT=${1:-/dev/ttyACM0}
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
BIN_DIR="$DIR/bin"

if [ ! -e "$PORT" ]; then
    echo "[!] Port $PORT not found!"
    echo "    Please connect your Nibble Zero and specify the port if different (e.g., ./flash_nibble.sh /dev/ttyACM1)."
    exit 1
fi

echo "========================================="
echo "   Nibble Zero Automated Flasher        "
echo "========================================="
echo "[*] Target Port: $PORT"

# 1. Force Bootloader Mode
echo "[*] Triggering Bootloader mode via USB CDC..."
stty -F "$PORT" 1200 || true
sleep 2

# Wait for port to stabilize
if [ ! -e "$PORT" ]; then
    echo "[*] Waiting for port to reappear..."
    for i in {1..10}; do
        if [ -e "$PORT" ]; then break; fi
        sleep 1
    done
fi

# 2. Flashing
if [ -f "$BIN_DIR/factory.bin" ]; then
    echo "[*] Found factory.bin - performing rapid single-pass flash..."
    ~/.local/bin/esptool --chip esp32s3 --port "$PORT" --baud 921600 \
      --before default-reset --after hard-reset write_flash -z \
      --flash-mode dio --flash-freq 80m --flash_size 4MB \
      0x0 "$BIN_DIR/factory.bin"
else
    echo "[*] factory.bin not found - flashing multi-part..."
    ~/.local/bin/esptool --chip esp32s3 --port "$PORT" --baud 921600 \
      --before default-reset --after hard-reset write_flash -z \
      --flash-mode dio --flash-freq 80m --flash-size 4MB \
      0x0000 "$BIN_DIR/RNode_Firmware.ino.bootloader.bin" \
      0x8000 "$BIN_DIR/RNode_Firmware.ino.partitions.bin" \
      0xe000 "$BIN_DIR/boot_app0.bin" \
      0x10000 "$BIN_DIR/RNode_Firmware.ino.bin" \
      0x210000 "$BIN_DIR/console_image.bin"
fi

echo ""
echo "[*] Flashing complete. Waiting for device reboot (5s)..."
sleep 5

# Re-check port
if [ ! -e "$PORT" ]; then
    for i in {1..10}; do
        if [ -e "$PORT" ]; then break; fi
        sleep 1
    done
fi

# 3. Provisioning
echo "[*] Provisioning EEPROM (Hombrew RNode)..."
~/.local/bin/rnodeconf "$PORT" -r --platform 80 --product f0 --model fe --hwrev 1

echo "[*] Setting Firmware Hash..."
HASH=$($HOME/.local/share/pipx/venvs/rns/bin/python "$BIN_DIR/partition_hashes" "$BIN_DIR/RNode_Firmware.ino.bin")
~/.local/bin/rnodeconf "$PORT" --firmware-hash "$HASH"

echo ""
echo "========================================="
echo "   SUCCESS: Nibble Zero RNode Ready     "
echo "========================================="
~/.local/bin/rnodeconf "$PORT" --info
