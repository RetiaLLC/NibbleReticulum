#!/bin/bash
# Retia Nibble Zero - Kali Linux Setup & Flashing Script
# Automatically compiles and flashes the RNode firmware.

set -e

echo "========================================="
echo " Nibble Zero RNode Setup Script for Kali "
echo "========================================="

# 1. System Dependencies
echo "[*] Installing required system dependencies..."
sudo apt update
sudo apt install -y python3-pip git make curl jq pipx

# 2. Python Dependencies
echo "[*] Installing Python tools (esptool, rnodeconf, nomadnet)..."
pipx install esptool || true
pipx install rnodeconf || true
pipx install nomadnet || true
pipx ensurepath

# 3. Install Arduino CLI
if ! command -v arduino-cli &> /dev/null; then
    echo "[*] Installing arduino-cli..."
    curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | sh
    sudo mv bin/arduino-cli /usr/local/bin/
else
    echo "[*] arduino-cli is already installed."
fi

# 4. Clone Repository
WORKDIR="/tmp/RNode_Firmware"
if [ -d "$WORKDIR" ]; then
    echo "[*] Cleaning up old workspace..."
    rm -rf "$WORKDIR"
fi

echo "[*] Cloning bwasserm/RNode_Firmware (nibble-dev)..."
git clone -b nibble-dev https://github.com/bwasserm/RNode_Firmware.git "$WORKDIR"
cd "$WORKDIR"

# 5. Fix Arduino CLI Config & Prepare ESP32 Core
echo "[*] Preparing Arduino ESP32 core..."
# Remove the broken unsigned.io index
sed -i 's/- http:\/\/unsigned.io\/arduino\/package_unsignedio_UnsignedBoards_index.json//g' arduino-cli.yaml
sed -i 's/- https:\/\/unsigned.io\/arduino-board-index\/package_unsignedio_UnsignedBoards_index.json//g' arduino-cli.yaml
make prep-esp32

# 6. Fix Bluetooth Buffer Sizes
echo "[*] Fixing ESP32 Bluetooth buffer sizes..."
BT_FILE=$(find ~/.arduino15/packages/esp32/hardware/esp32/ -name "BluetoothSerial.cpp" | head -n 1)
if [ -n "$BT_FILE" ]; then
    sed -i 's/#define RX_QUEUE_SIZE 512/#define RX_QUEUE_SIZE 6144/' "$BT_FILE"
    sed -i 's/#define TX_QUEUE_SIZE 32/#define TX_QUEUE_SIZE 384/' "$BT_FILE"
else
    echo "[!] Could not find BluetoothSerial.cpp to fix buffers. Compilation may fail."
fi

# 7. Compile Firmware
echo "[*] Compiling firmware for Nibble Zero..."
make firmware-retia_nibble

# 8. Flashing Process
echo ""
echo "========================================="
echo "       PREPARE DEVICE FOR FLASHING       "
echo "========================================="
echo "1. Connect the Nibble Zero via USB."
echo "2. Put it into Download/Boot mode by holding the BOOT button, pressing RESET, then releasing BOOT."
if [ "$AUTO" != "1" ]; then
    read -p "Press ENTER when the device is ready..."
fi

PORT="/dev/ttyACM0"
if [ ! -e "$PORT" ]; then
    PORT="/dev/ttyUSB0"
fi
echo "[*] Using port $PORT"

echo "[*] Flashing main firmware..."
arduino-cli upload -p "$PORT" --fqbn "esp32:esp32:esp32s3:CDCOnBoot=cdc,PSRAM=enabled"

# 9. SPIFFS Flash
echo "[*] Flashing SPIFFS Console Image..."
$HOME/.local/bin/esptool --chip esp32s3 --port "$PORT" --baud 115200 --before default_reset --after hard_reset write_flash -z --flash_mode dio --flash_freq 80m --flash_size 4MB 0x210000 ./Release/console_image.bin

if [ "$AUTO" == "1" ]; then
    echo "[*] AUTO mode enabled. Exiting before bootstrap so device can be manually reset."
    exit 0
fi

# 10. Provisioning
echo ""
echo "========================================="
echo "       PREPARE DEVICE FOR BOOTSTRAP      "
echo "========================================="
echo "The device is currently in boot mode. Please press the RESET button on the Nibble Zero once to boot into the new firmware."
if [ "$AUTO" != "1" ]; then
    read -p "Press ENTER when the device has been reset..."
fi

echo "[*] Bootstrapping EEPROM..."
$HOME/.local/bin/rnodeconf "$PORT" -r --platform 80 --product f0 --model fe --hwrev 1

echo "[*] Setting Firmware Hash..."
HASH=$($HOME/.local/share/pipx/venvs/rnodeconf/bin/python ./partition_hashes ./build/esp32.esp32.esp32s3/RNode_Firmware.ino.bin)
$HOME/.local/bin/rnodeconf "$PORT" --firmware-hash "$HASH"

echo ""
echo "[+] Setup Complete! Your Nibble Zero RNode is ready."
echo "[+] You can verify its status with: rnodeconf --info $PORT"
