#!/usr/bin/env python3

import argparse
import serial
import time
from elftools.elf.elffile import ELFFile
from tqdm import tqdm

PROMPT = b"nmon> "

def compare_pairs_with_bin(pairs, bin_path):
    # Reconstruct the binary from the extracted pairs
    reconstructed = bytearray()
    for addr, val in pairs:
        reconstructed += val.to_bytes(4, "little")

    with open(bin_path, "rb") as f:
        firmware = f.read()

    print(f"firmware.bin size : {len(firmware)} bytes")
    print(f"pairs image size  : {len(reconstructed)} bytes")

    # Compare only the meaningful bytes from firmware.bin
    if reconstructed[:len(firmware)] != firmware:
        print("\nMismatch detected!")
        for i, (a, b) in enumerate(zip(reconstructed, firmware)):
            if a != b:
                print(f"First mismatch at byte 0x{i:08X}")
                print(f"  reconstructed = 0x{a:02X}")
                print(f"  firmware.bin  = 0x{b:02X}")
                start = max(0, i - 16)
                end = min(len(firmware), i + 16)
                print("\nContext:")
                for j in range(start, end):
                    mark = ">>" if j == i else "  "
                    print(f"{mark} {j:08X}: {reconstructed[j]:02X} {firmware[j]:02X}")
                return False
        print("Mismatch after firmware length?")
        return False
    print("Binary matches perfectly.")
    if len(reconstructed) > len(firmware):
        print(f"Note: reconstructed image contains {len(reconstructed)-len(firmware)} bytes of alignment padding.")
    return True


def compare_words(pairs, bin_path):
    with open(bin_path, "rb") as f:
        data = f.read()
    if len(data) % 4:
        data += b"\x00" * (4 - len(data) % 4)
    expected_words = [
        int.from_bytes(data[i:i+4], "little")
        for i in range(0, len(data), 4)
    ]
    if len(expected_words) != len(pairs):
        print("Different number of words!")
        print(f"pairs: {len(pairs)}")
        print(f"bin  : {len(expected_words)}")
        return False
    for i, ((addr, word), expected) in enumerate(zip(pairs, expected_words)):
        if word != expected:
            print(f"Mismatch at word {i}")
            print(f"Address : 0x{addr:08X}")
            print(f"pairs   : 0x{word:08X}")
            print(f"bin     : 0x{expected:08X}")
            return False

    print("All words match perfectly.")
    return True

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

            with open("bootgen.log","w") as outfp:
                for i, (addr, val) in enumerate(pairs):
                    outfp.write(f"{addr:08X}{val:08X}\n".lower())

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
                return (True, buf.decode("ascii"))

    return (False , "")


# ----------------------------
# SEND COMMAND (NO EXTRA CHARS)
# ----------------------------
def send_cmd(ser, addr, val):
    cmd = f"w{addr:08X}{val:08X}"
    ser.write(cmd.lower().encode("ascii"))
    ser.flush()


def send_rcmd(ser, addr):
    cmd = f"d{addr:08X}"
    ser.write(cmd.lower().encode("ascii"))
    ser.flush()


def load_mem(ser,pairs,args):
    print("[INFO] Waiting for nmon prompt...")
    time.sleep(1.0)
    ser.reset_input_buffer()

    if not wait_for_prompt(ser, args.timeout)[0]:
        cmd = f"1"
        ser.write(cmd.lower().encode("ascii"))
        ser.flush()
        if not wait_for_prompt(ser, args.timeout)[0]:
            raise TimeoutError("No initial nmon prompt")

    print("[INFO] Connected")
    print(f"[INFO] Loading your program: {args.elf}")

    #for i, (addr, val) in enumerate(pairs):
    i=0
    for addr, val in tqdm(pairs, unit="words", dynamic_ncols=True):
        if args.verbose:
            print(f"{i}: {addr:08X} -> {val:08X}")
        send_cmd(ser, addr, val)
        (success, output) = wait_for_prompt(ser, args.timeout)
        if not success:
            raise TimeoutError(f"Lost nmon prompt at {i}")
        i += 1

    print("[INFO] loaded finished...")

def check_mem(ser,pairs,args):
    print("[INFO] checking the loaded program...")
    print("[INFO] Waiting for nmon prompt...")

    time.sleep(1.0)
    ser.reset_input_buffer()

    if not wait_for_prompt(ser, args.timeout)[0]:
        cmd = f"1"
        ser.write(cmd.lower().encode("ascii"))
        ser.flush()
        if not wait_for_prompt(ser, args.timeout)[0]:
            raise TimeoutError("No initial nmon prompt")

    print("[INFO] Connected")
    print(f"[INFO] checking the program: {args.elf}")
    i=0
    for addr, val in tqdm(pairs, unit="words", dynamic_ncols=True):
        if args.verbose:
            print(f"{i}: {addr:08X} -> {val:08X}")
        send_rcmd(ser, addr)
        (success, output) = wait_for_prompt(ser, args.timeout)
        if not success:
            raise TimeoutError(f"Lost nmon prompt at {i}")
        
        if f"{val:08X}".lower() not in output:
                print(f"[ERROR] {i}: {addr:08X} -> {val:08X} (not found in output)")
                raise RuntimeError(f"[ERROR]: while loading addr={addr:08X} -> val={val:08X}")
        i += 1
# ----------------------------
# MAIN
# ----------------------------
def main():

    parser = argparse.ArgumentParser(description="nmon ELF loader (Expect-equivalent)")

    parser.add_argument("port")
    parser.add_argument("elf")
    parser.add_argument("-b", "--baudrate", type=int, default=115200)
    parser.add_argument("-t", "--timeout", type=float, default=5.0)
    parser.add_argument("-c", "--check", action="store_true")
    parser.add_argument("-co", "--check-only", action="store_true")

    parser.add_argument("--verbose", action="store_true")

    args = parser.parse_args()

    print(f"[INFO] ELF: {args.elf}")
    pairs = extract_pairs(args.elf)
    print(f"[INFO] Words to load: {len(pairs)}")

    #res1=compare_pairs_with_bin(
    #pairs,
    #"firmware.bin")
    #res2=compare_words(pairs,"firmware.bin")

    #if res1 and res2:
    #    print("checked ok!")
    #else:
    #    raise("ELF and BIN mismatch")
    
    

    try:
        with serial.Serial(args.port, args.baudrate, timeout=1) as ser:
            if args.check_only:
                check_mem(ser,pairs,args)
            else:
                load_mem(ser,pairs,args)
                if args.check:
                    check_mem(ser,pairs,args)
                    
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
    
    except RuntimeError as e:
        print(f"[RUNTIME] {e}")


if __name__ == "__main__":
    main()