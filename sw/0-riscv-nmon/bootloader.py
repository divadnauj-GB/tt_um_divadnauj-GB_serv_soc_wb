#!/usr/bin/env python3

import argparse
import serial
import time
from elftools.elf.elffile import ELFFile
from tqdm import tqdm

PROMPT = b"nmon> "


# ----------------------------
# ELF LOADER
# ----------------------------
def extract_pairs(elf_path):
    pairs = []

    with open(elf_path, "rb") as f:
        elf = ELFFile(f)

        for seg in elf.iter_segments():
            if seg["p_type"] != "PT_LOAD":
                continue

            addr = seg["p_paddr"]
            data = seg.data()

            # align to 4 bytes
            if len(data) % 4:
                data += b"\x00" * (4 - len(data) % 4)

            for i in range(0, len(data), 4):
                val = int.from_bytes(data[i:i+4], "little")
                pairs.append((addr + i, val))

    return pairs


# ----------------------------
# WAIT FOR PROMPT (EXPECT STYLE)
# ----------------------------
def wait_for_prompt(ser, timeout=10):
    buf = bytearray()
    start = time.time()

    while time.time() - start < timeout:
        c = ser.read(1)
        if c:
            buf += c

            # keep buffer small
            if len(buf) > 64:
                buf = buf[-64:]

            if PROMPT in buf:
                return True

    return False


# ----------------------------
# SEND COMMAND (NO EXTRA CHARS)
# ----------------------------
def send_cmd(ser, addr, val):
    cmd = f"w{addr:08X}{val:08X}"
    ser.write(cmd.lower().encode("ascii"))
    ser.flush()



# ----------------------------
# MAIN
# ----------------------------
def main():

    parser = argparse.ArgumentParser(description="nmon ELF loader (Expect-equivalent)")

    parser.add_argument("port")
    parser.add_argument("elf")
    parser.add_argument("-b", "--baudrate", type=int, default=115200)
    parser.add_argument("-t", "--timeout", type=float, default=5.0)

    parser.add_argument("--verbose", action="store_true")

    args = parser.parse_args()

    print(f"[INFO] ELF: {args.elf}")
    pairs = extract_pairs(args.elf)
    print(f"[INFO] Words to load: {len(pairs)}")

    try:
        with serial.Serial(args.port, args.baudrate, timeout=1) as ser:

            print("[INFO] Waiting for nmon prompt...")

            time.sleep(1.0)
            ser.reset_input_buffer()

            if not wait_for_prompt(ser, args.timeout):
                cmd = f"1"
                ser.write(cmd.lower().encode("ascii"))
                ser.flush()
                if not wait_for_prompt(ser, args.timeout):
                    raise TimeoutError("No initial nmon prompt")

            print("[INFO] Connected")
            print(f"[INFO] Loading your program: {args.elf}")

            #for i, (addr, val) in enumerate(pairs):
            i=0
            for addr, val in tqdm(pairs, unit="words", dynamic_ncols=True):
                if args.verbose:
                    print(f"{i}: {addr:08X} -> {val:08X}")

                send_cmd(ser, addr, val)

                if not wait_for_prompt(ser, args.timeout):
                    raise TimeoutError(f"Lost nmon prompt at {i}")

                #if (i + 1) % 100 == 0:
                #    print(f"[INFO] Sent {i+1}/{len(pairs)}")
                i += 1
            cmd = f"g{pairs[0][0]:08X}"
            ser.write(cmd.lower().encode("ascii"))
            ser.flush()
            print("[SUCCESS] Program loaded and started!")
            print("[INFO] Open a serial terminal to see the output (115200 8N1)")
            time.sleep(1)


    except serial.SerialException as e:
        print(f"[SERIAL ERROR] {e}")

    except TimeoutError as e:
        print(f"[TIMEOUT] {e}")


if __name__ == "__main__":
    main()