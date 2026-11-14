"""系統層測試：載入 riscv-tests 的 hex，跑到程式寫 tohost 為止。

riscv-tests 慣例：
  tohost == 1              → PASS
  tohost == (n << 1) | 1   → 第 n 個子測試 FAIL
"""
import os

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge

TOHOST = int(os.environ.get("TOHOST", "0x80001000"), 0)
MAX_CYCLES = int(os.environ.get("MAX_CYCLES", "100000"))


@cocotb.test()
async def run_program(dut):
    Clock(dut.clk, 10, "ns").start()
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1

    retired = 0
    for cyc in range(MAX_CYCLES):
        await RisingEdge(dut.clk)
        if int(dut.retire_valid.value):
            retired += 1
        if int(dut.dmem_we.value) and int(dut.dmem_addr.value) == TOHOST:
            v = int(dut.dmem_wdata.value)
            assert v == 1, f"FAILED at sub-test #{v >> 1}（tohost=0x{v:x}）"
            cpi = cyc / retired if retired else float("nan")
            dut._log.info(f"PASS: {cyc} cycles, {retired} retired, CPI = {cpi:.2f}")
            return

    assert False, f"timeout after {MAX_CYCLES} cycles: 程式沒有寫 tohost (0x{TOHOST:08x})"
