"""Decoder 單元測試：先測一條已知指令，再用隨機指令對照 Python model。"""
import random

import cocotb
from cocotb.triggers import Timer


def fields(x: int) -> dict:
    return {
        "opcode": x & 0x7F,
        "rd": (x >> 7) & 0x1F,
        "funct3": (x >> 12) & 0x7,
        "rs1": (x >> 15) & 0x1F,
        "rs2": (x >> 20) & 0x1F,
        "funct7": (x >> 25) & 0x7F,
    }


@cocotb.test()
async def addi_example(dut):
    """addi x5, x1, 10 = 0x00A08293"""
    dut.instr.value = 0x00A08293
    await Timer(1, "ns")
    assert int(dut.opcode.value) == 0b0010011, "opcode 錯了"
    assert int(dut.rd.value) == 5, "rd 應該是 x5"
    assert int(dut.funct3.value) == 0, "funct3 應該是 000 (ADD)"
    assert int(dut.rs1.value) == 1, "rs1 應該是 x1"


@cocotb.test()
async def fields_random(dut):
    for _ in range(2000):
        x = random.getrandbits(32)
        dut.instr.value = x
        await Timer(1, "ns")
        for name, exp in fields(x).items():
            got = int(getattr(dut, name).value)
            assert got == exp, f"instr=0x{x:08x} {name}: got {got}, expected {exp}"
