"""Regfile 單元測試：x0 恆為 0、同拍寫讀 bypass、隨機讀寫對照 Python list。"""
import os
import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer


@cocotb.test()
async def regfile_random(dut):
    seed = int(os.environ.get("SEED", random.randrange(1 << 31)))
    random.seed(seed)
    dut._log.info(f"seed = {seed}")

    Clock(dut.clk, 10, "ns").start()
    ref = [0] * 32

    async def cycle(we, wa, wd, r1, r2):
        dut.we.value = int(we)
        dut.waddr.value = wa
        dut.wdata.value = wd
        dut.raddr1.value = r1
        dut.raddr2.value = r2
        await Timer(1, "ns")  # 組合邏輯穩定（clock 週期 10 ns）

        def exp(r):
            if r == 0:
                return 0
            if we and r == wa:
                return wd  # bypass
            return ref[r]

        for port, r in ((dut.rdata1, r1), (dut.rdata2, r2)):
            got = int(port.value)
            assert got == exp(r), (
                f"read x{r}: got 0x{got:08x}, expected 0x{exp(r):08x} "
                f"(we={int(we)} waddr=x{wa} wdata=0x{wd:08x})"
            )
        await RisingEdge(dut.clk)
        if we and wa != 0:
            ref[wa] = wd

    await RisingEdge(dut.clk)

    # 先把每個暫存器寫過一次，避免讀到未初始化的值
    for r in range(1, 32):
        v = random.getrandbits(32)
        await cycle(True, r, v, 0, 0)

    # 試著寫 x0
    await cycle(True, 0, 0xDEAD_BEEF, 0, 0)

    for _ in range(3000):
        we = random.random() < 0.7
        wa = random.randrange(32)
        wd = random.getrandbits(32)
        r1 = random.randrange(32)
        r2 = wa if random.random() < 0.3 else random.randrange(32)  # 故意製造 bypass
        await cycle(we, wa, wd, r1, r2)
