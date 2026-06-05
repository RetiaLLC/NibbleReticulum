#!/usr/bin/env python3
import os
import sys
import time
import argparse

# Add Reticulum to path from the pipx environment
sys.path.append(os.path.expanduser("~/.local/share/pipx/venvs/rns/lib/python3.13/site-packages"))

try:
    import RNS
except ImportError:
    print("Could not import RNS. Please ensure Reticulum is installed.")
    sys.exit(1)

def setup_rns(config_dir, port):
    os.makedirs(config_dir, exist_ok=True)
    os.makedirs(os.path.join(config_dir, "storage"), exist_ok=True)
    config_path = os.path.join(config_dir, "config")
    with open(config_path, "w") as f:
        f.write(f"""
[reticulum]
enable_transport = True
share_instance = No

[interfaces]
  [[RNode_Test]]
    type = RNodeInterface
    interface_enabled = True
    port = {port}
    frequency = 868000000
    bandwidth = 125000
    txpower = 2
    spreadingfactor = 7
    codingrate = 5
""")
    r = RNS.Reticulum(config_dir)
    return r

def server_mode(config_dir, port):
    print(f"Starting receiver on {port}...")
    r = setup_rns(config_dir, port)
    
    # PLAIN destination
    dest = RNS.Destination(None, RNS.Destination.IN, RNS.Destination.PLAIN, "test", "ping")
    
    def packet_callback(data, packet):
        msg = data.decode("utf-8")
        print(f"\n[RECEIVER] Received: {msg}")
        print("[RECEIVER] Packet verified!")
        with open("/tmp/rnode_test_success", "w") as f:
            f.write("OK")
    
    dest.set_packet_callback(packet_callback)
    
    print("[RECEIVER] Waiting for packets...")
    try:
        while True:
            time.sleep(1)
            if os.path.exists("/tmp/rnode_test_success"):
                time.sleep(2)
                break
    except KeyboardInterrupt:
        pass
    print("Receiver exiting")

def client_mode(config_dir, port):
    print(f"Starting sender on {port}...")
    r = setup_rns(config_dir, port)
    
    dest = RNS.Destination(None, RNS.Destination.OUT, RNS.Destination.PLAIN, "test", "ping")
    
    msg = "Ping from Node B".encode("utf-8")
    pkt = RNS.Packet(dest, msg)
    
    print("[SENDER] Sending plain packet over RF...")
    pkt.send()
    
    time.sleep(5)
    print("[SENDER] Done.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--mode", choices=["server", "client"], required=True)
    parser.add_argument("--port", required=True)
    parser.add_argument("--config", required=True)
    
    args = parser.parse_args()
    
    if args.mode == "server":
        server_mode(args.config, args.port)
    else:
        client_mode(args.config, args.port)
