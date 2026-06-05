#!/bin/bash
# test_link.sh - Simple RF broadcast test between two Nibble Zeros

PORT_A=${1:-/dev/ttyACM0}
PORT_B=${2:-/dev/ttyACM1}

if [ ! -e "$PORT_A" ] || [ ! -e "$PORT_B" ]; then
    echo "Error: Need two devices connected."
    exit 1
fi

DIR_A=$(mktemp -d)
DIR_B=$(mktemp -d)
rm -f /tmp/rnode_test_success

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

echo "[*] Starting Receiver (Node A) on $PORT_A..."
"$DIR/test_ping.py" --mode server --port "$PORT_A" --config "$DIR_A" &
PID_A=$!

sleep 10 # Give it time to initialize RNode

echo "[*] Starting Sender (Node B) on $PORT_B..."
"$DIR/test_ping.py" --mode client --port "$PORT_B" --config "$DIR_B"
RESULT=$?

# Wait for receiver to catch the packet
sleep 5

if [ -f /tmp/rnode_test_success ]; then
    SUCCESS=0
else
    SUCCESS=1
fi

echo "[*] Cleaning up..."
kill $PID_A 2>/dev/null
rm -rf "$DIR_A" "$DIR_B" /tmp/rnode_test_success

if [ $SUCCESS -eq 0 ]; then
    echo -e "\n[+] SUCCESS! The two nodes communicated over RF!"
else
    echo -e "\n[-] FAILURE! No packet received."
fi
