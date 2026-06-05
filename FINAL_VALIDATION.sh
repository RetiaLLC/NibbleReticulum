#!/bin/bash

# Nibble Zero - Final Validation Script
# Runs a battery of checks to ensure the system is ready for delivery.

set -e

PORT_A=${1:-/dev/ttyACM0}
PORT_B=${2:-/dev/ttyACM1}

echo "========================================="
echo "   Nibble Zero Final Validation         "
echo "========================================="

# 1. Binary Integrity
echo "[*] Checking binary files..."
REQUIRED_BINS=("factory.bin" "RNode_Firmware.ino.bin" "RNode_Firmware.ino.bootloader.bin" "RNode_Firmware.ino.partitions.bin" "boot_app0.bin" "console_image.bin")
for bin in "${REQUIRED_BINS[@]}"; do
    if [ ! -f "Release/bin/$bin" ]; then
        echo "[-] ERROR: Missing binary $bin"
        exit 1
    fi
done
echo "[+] All binaries present."

# 2. Hardware Connectivity
echo "[*] Checking device connectivity..."
if [ ! -e "$PORT_A" ]; then
    echo "[-] ERROR: Port $PORT_A not found."
    exit 1
fi
echo "[+] Node A connected on $PORT_A"

if [ -e "$PORT_B" ]; then
    echo "[+] Node B connected on $PORT_B"
else
    echo "[!] Node B not found. Skipping dual-node link tests."
fi

# 3. Provisioning Info
echo "[*] Verifying Node A provisioning..."
~/.local/bin/rnodeconf "$PORT_A" --info | grep "Product" || (echo "[-] ERROR: Node A not provisioned correctly" && exit 1)
echo "[+] Node A provisioning verified."

# 4. RF Link Test (if 2 nodes)
if [ -e "$PORT_B" ]; then
    echo "[*] Running RF Link Test..."
    cd Release
    ./test_link.sh "$PORT_A" "$PORT_B"
    RESULT=$?
    cd ..
    if [ $RESULT -ne 0 ]; then
        echo "[-] ERROR: RF Link Test failed."
        exit 1
    fi
fi

# 5. File System Permissions
echo "[*] Checking script permissions..."
scripts=("Release/flash_nibble.sh" "Release/test_link.sh" "setup_nibble_zero.sh")
for script in "${scripts[@]}"; do
    if [ ! -x "$script" ]; then
        echo "[-] ERROR: $script is not executable."
        exit 1
    fi
done
echo "[+] Script permissions verified."

echo ""
echo "========================================="
echo "   VALIDATION SUCCESSFUL!               "
echo "   Project is ready for delivery.       "
echo "========================================="
