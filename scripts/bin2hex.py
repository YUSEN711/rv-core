#!/usr/bin/env python3
"""把 objcopy -O binary 的輸出轉成 $readmemh 格式（一行一個 32-bit little-endian word）。"""
import sys


def main() -> None:
    if len(sys.argv) != 3:
        sys.exit("usage: bin2hex.py input.bin output.hex")
    with open(sys.argv[1], "rb") as f:
        data = f.read()
    data += b"\0" * (-len(data) % 4)
    with open(sys.argv[2], "w") as f:
        for i in range(0, len(data), 4):
            f.write(f"{int.from_bytes(data[i:i + 4], 'little'):08x}\n")


if __name__ == "__main__":
    main()
