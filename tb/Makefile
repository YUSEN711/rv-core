# cocotb testbench Makefile（需要 cocotb >= 2.0）
#   make TEST=alu | regfile | core [SIM=icarus] [HEX=...] [SEED=...]
# 通常從上層 Makefile 呼叫：make test-alu / make sim HEX=...

SIM ?= verilator
TOPLEVEL_LANG = verilog
TEST ?= alu

RTL := $(abspath ../rtl)
PKG := $(RTL)/core_pkg.sv

ifeq ($(TEST),alu)
  VERILOG_SOURCES     = $(PKG) $(RTL)/alu.sv
  COCOTB_TOPLEVEL     = alu
  COCOTB_TEST_MODULES = test_alu
else ifeq ($(TEST),regfile)
  VERILOG_SOURCES     = $(PKG) $(RTL)/regfile.sv
  COCOTB_TOPLEVEL     = regfile
  COCOTB_TEST_MODULES = test_regfile
else ifeq ($(TEST),decoder)
  VERILOG_SOURCES     = $(PKG) $(RTL)/decoder.sv
  COCOTB_TOPLEVEL     = decoder
  COCOTB_TEST_MODULES = test_decoder
else ifeq ($(TEST),core)
  VERILOG_SOURCES     = $(PKG) $(RTL)/alu.sv $(RTL)/regfile.sv $(RTL)/mem.sv \
                        $(RTL)/core_top.sv $(abspath tb_top.sv)
  COCOTB_TOPLEVEL     = tb_top
  COCOTB_TEST_MODULES = test_core
  ifndef HEX
    $(error TEST=core 需要 HEX=path/to/prog.hex)
  endif
  COCOTB_PLUSARGS += +hex=$(HEX)
  PLUSARGS        += +hex=$(HEX)
else
  $(error unknown TEST=$(TEST))
endif

SIM_BUILD = sim_build/$(TEST)_$(SIM)

ifeq ($(SIM),verilator)
  # --trace-fst 產生波形 dump.fst，可用 VS Code 的 Surfer 擴充套件打開
  EXTRA_ARGS += --trace --trace-structs -Wno-fatal
endif
ifeq ($(SIM),icarus)
  COMPILE_ARGS += -g2012
  WAVES = 1
endif

include $(shell cocotb-config --makefiles)/Makefile.sim
