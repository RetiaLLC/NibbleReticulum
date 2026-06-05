# Retia Nibble Zero - Flashing Troubleshooting Guide

## The Issue
During the firmware flashing process via `esptool.py`, the ESP32-S3 chip abruptly stops responding, leading to a `A fatal error occurred: The chip stopped responding` or `Serial data stream stopped` error. 

This issue has occurred consistently across three different Nibble Zero boards at various stages of the flashing process (usually during the erase or write phase of the main firmware payload).

## Troubleshooting Steps Attempted
To rule out software configuration issues, we attempted the following flashing parameters:
1. **Standard Flash:** 921600 baud, standard stub, compressed payload.
2. **Reduced Speed:** 115200 baud, standard stub, compressed payload.
3. **Very Low Speed:** 38400 baud, standard stub, compressed payload.
4. **No-Stub Mode:** 115200 baud, ROM bootloader only (no stub).
5. **Uncompressed Mode:** 115200 baud, no stub, raw uncompressed binary transmission.

Because the failure persists regardless of the software configuration, the root cause is almost certainly **hardware-related**, specifically concerning USB communication and power delivery.

## Suspected Causes
The ESP32-S3 requires significant bursts of current when erasing and writing to its internal flash memory. If the supplied voltage drops even momentarily during these spikes, the ESP32-S3's internal USB PHY (which provides the native USB connection) will reset, immediately dropping the connection to the host PC.

1. **Power Delivery (Brownouts):** The host USB port cannot supply enough instantaneous current for the flash operations.
2. **USB Cable Quality:** The USB-C cable being used may have high resistance, causing a voltage drop under load.
3. **USB Hub Interference:** Unpowered USB hubs, or even powered hubs with cheap controllers, frequently struggle to maintain stable connections with raw ESP32 serial data streams.

## Recommendations for the Next Attempt
Once the host machine has been rebooted, please ensure the following hardware conditions are met before trying again:

1. **Direct Connection:** Plug the Nibble Zero directly into a USB port on the motherboard of the computer. Do **not** use a USB hub, monitor pass-through, or front-panel USB ports.
2. **Change the Cable:** Try the shortest, highest-quality USB-C data cable you have available. A thick cable is preferred as it carries power better.
3. **Powered Hub (Alternative):** If direct connection fails, try a high-quality *externally powered* USB hub that can guarantee 5V/1A+ per port.
4. **Remove Peripherals:** If the Nibble Zero has any high-draw peripherals attached (like a display or radio module on a breadboard), ensure they are not causing a short or pulling too much current during boot.

Once your system is back online and hardware has been adjusted, we will run the flashing script again.