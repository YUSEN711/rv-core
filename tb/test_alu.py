"""ALU 單元測試：constrained-random + corner case，對照 Python reference model。"""
import os
import random

import cocotb
from cocotb.triggers import Timer

MASK = 0xFFFF_FFFF
# 順序必須和 rtl/core_pkg.sv 的 alu_op_e 一致
OPS = ["ADD", "SUB", "SLL", "SLT", "SLTU", "XOR", "SRL", "SRA", "OR", "AND", "PASS_B"]
CORNER = [0, 1, 2, 31, 32, 0x7FFF_FFFF, 0x8000_0000, 0x8000_0001, 0xFFFF_FFFE, 0xFFFF_FFFF]


def s32(x: int) -> int:
    return x - (1 << 32) if x & 0x8000_0000 else x


def model(op: str, a: int, b: int) -> int:
    sh = b & 31
    if op == "ADD":
        return (a + b) & MASK
    if op == "SUB":
        return (a - b) & MASK
    if op == "SLL":
        return (a << sh) & MASK
    if op == "SLT":
        return int(s32(a) < s32(b))
    if op == "SLTU":
        return int(a < b)
    if op == "XOR":
        return a ^ b
    if op == "SRL":
        return a >> sh
    if op == "SRA":
        return (s32(a) >> sh) & MASK
    if op == "OR":
        return a | b
    if op == "AND":
        return a & b
    if op == "PASS_B":
        return b
    raise ValueError(op)


def operand() -> int:
    return random.choice(CORNER) if random.random() < 0.3 else random.getrandbits(32)


@cocotb.test()
async def alu_random(dut):
    seed = int(os.environ.get("SEED", random.randrange(1 << 31)))
    random.seed(seed)
    dut._log.info(f"seed = {seed}（重現失敗：make test-alu SEED={seed}）")

    for _ in range(5000):
        idx = random.randrange(len(OPS))
        a, b = operand(), operand()
        dut.op.value = idx
        dut.a.value = a
        dut.b.value = b
        await Timer(1, "ns")
        got = int(dut.y.value)
        exp = model(OPS[idx], a, b)
        assert got == exp, (
            f"{OPS[idx]} a=0x{a:08x} b=0x{b:08x}: got 0x{got:08x}, expected 0x{exp:08x}"
        )
