#!/usr/bin/env python3
# One TSV line every 60 s:
#   mouse%  mouseCharge  keyboard%  keyboardMilliVolt  keyboardCharge
# -1 when a device does not answer. Charge: 0 not charging, 1 charging, 2 full.
#
# Mouse: Corsair Scimitar Elite Wireless behind the Slipstream receiver (1b1c:1bdc), vendor interface
#        (usage page 0xFF42, usage 1); battery = command [0x09, 0x02, 0x0f], u16 LE /10 at [3:5];
#        charge = [0x09, 0x02, 0x10], status at [3] (1 charging, 3 full, otherwise not charging).
# Keyboard: Keychron K3 Max custom firmware, raw HID (usage page 0xFF60) on the Keychron Link receiver
#           (3434:d030) or on the cable (3434:0a31); battery = [0xA7, 0xF0].

import glob
import os
import select
import sys
import time

INTERVAL = 60


def find_hidraw(vid, pid, descriptor_prefix):
    for d in sorted(glob.glob("/sys/class/hidraw/hidraw*")):
        try:
            with open(d + "/device/uevent") as f:
                uevent = f.read()
            with open(d + "/device/report_descriptor", "rb") as f:
                desc = f.read()
        except OSError:
            continue
        if f"HID_ID=0003:0000{vid:04X}:0000{pid:04X}" in uevent and desc.startswith(descriptor_prefix):
            return "/dev/" + os.path.basename(d)
    return None


def transfer(path, payload, size, match, timeout=1.5):
    """Write one report (report id 0) and return the first reply accepted by match(), or None."""
    try:
        fd = os.open(path, os.O_RDWR | os.O_NONBLOCK)
    except OSError:
        return None
    try:
        while select.select([fd], [], [], 0)[0]:
            os.read(fd, 64)
        os.write(fd, bytes([0]) + bytes(payload).ljust(size, b"\0"))
        deadline = time.monotonic() + timeout
        while True:
            left = deadline - time.monotonic()
            if left <= 0 or not select.select([fd], [], [], left)[0]:
                return None
            reply = os.read(fd, 64)
            if match(reply):
                return reply
    except OSError:
        return None
    finally:
        os.close(fd)


def mouse_battery():
    path = find_hidraw(0x1B1C, 0x1BDC, b"\x06\x42\xff\x09\x01")
    if not path:
        return -1, -1
    reply = transfer(path, [0x09, 0x02, 0x0F], 64, lambda r: len(r) >= 5 and r[1] == 0x02)
    if not reply or reply[2] != 0:
        return -1, -1
    level = int.from_bytes(reply[3:5], "little")
    if not 0 < level <= 1000:
        return -1, -1
    reply = transfer(path, [0x09, 0x02, 0x10], 64, lambda r: len(r) >= 4 and r[1] == 0x02)
    status = reply[3] if reply and reply[2] == 0 else -1
    charge = {1: 1, 3: 2}.get(status, 0 if status >= 0 else -1)
    return min(100, level // 10), charge


def keyboard_battery():
    for pid in (0x0A31, 0xD030):  # cable first, then the 2.4 GHz receiver
        path = find_hidraw(0x3434, pid, b"\x06\x60\xff")
        if not path:
            continue
        # A sleeping keyboard drops the first request (it only wakes it up): ask again
        for _ in range(3):
            reply = transfer(path, [0xA7, 0xF0], 32, lambda r: len(r) >= 7 and r[0] in (0xA7, 0xFF))
            if reply is None:
                continue
            if reply[0] == 0xA7 and reply[1] == 0xF0 and reply[2] == 0:
                return reply[3], reply[4] | reply[5] << 8, reply[6]
            break  # firmware without the battery command
    return -1, -1, -1


while True:
    mouse, mouse_charge = mouse_battery()
    kb, mv, charge = keyboard_battery()
    print(f"{mouse}\t{mouse_charge}\t{kb}\t{mv}\t{charge}", flush=True)
    time.sleep(INTERVAL)
