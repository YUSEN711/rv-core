# rv-core 頂層 Makefile
#   make lint            Verilator lint 所有 RTL
#   make test-alu        ALU 單元測試
#   make test-regfile    Regfile 單元測試
#   make test-unit       所有單元測試
#   make riscv-tests     下載並編譯 rv32ui 測試程式
#   make sim HEX=build/riscv-tests/add.hex   跑單一程式
#   make isa             跑全部 rv32ui 測試並印總表
#   可加 SIM=icarus 改用 Icarus Verilog，SEED=123 重現隨機測試

SIM ?= verilator
RTL_SRCS := rtl/core_pkg.sv rtl/alu.sv rtl/regfile.sv rtl/mem.sv rtl/core_top.sv

# Phase 1 骨架還有很多未使用的訊號，先關掉這幾類警告；核心完成後拿掉 -Wno-UNUSED* 再 lint 一次
LINT_FLAGS := -Wall -Wno-fatal -Wno-UNUSEDSIGNAL -Wno-UNUSEDPARAM

.PHONY: lint test-unit riscv-tests sim isa clean

lint:
	verilator --lint-only $(LINT_FLAGS) --top-module core_top $(RTL_SRCS)

test-unit:

test-%:
	$(MAKE) -C tb TEST=$* SIM=$(SIM)

riscv-tests:
	./scripts/build_riscv_tests.sh

sim:
	TOHOST=$$(cat $(basename $(HEX)).tohost 2>/dev/null || echo 0x80001000) \
	  $(MAKE) -C tb TEST=core SIM=$(SIM) HEX=$(abspath $(HEX))

isa:
	SIM=$(SIM) ./scripts/run_isa.sh

clean:
	rm -rf tb/sim_build tb/results.xml tb/*.fst tb/*.vcd tb/__pycache__ build
