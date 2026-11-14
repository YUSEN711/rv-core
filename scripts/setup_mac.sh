#!/usr/bin/env bash
# Phase 0：Mac 開發環境一鍵安裝
#   用法：在 repo 根目錄執行 ./scripts/setup_mac.sh
set -euo pipefail

command -v brew >/dev/null || { echo "請先安裝 Homebrew：https://brew.sh"; exit 1; }

echo "==> HDL 工具"
brew install verilator icarus-verilog yosys python@3.12

echo "==> RISC-V GCC toolchain + Spike（從原始碼編譯，第一次可能要 30–60 分鐘）"
brew tap riscv-software-src/riscv
brew install riscv-tools

echo "==> Python 虛擬環境 + cocotb"
python3.12 -m venv .venv
# shellcheck disable=SC1091
source .venv/bin/activate
pip install --upgrade pip
pip install "cocotb>=2.0" pytest

echo
echo "==> 版本檢查（cocotb 2.x 需要 Verilator >= 5.036）"
verilator --version
iverilog -V 2>&1 | head -1
riscv64-unknown-elf-gcc --version | head -1
spike --help 2>&1 | head -1 || true
python -c "import cocotb; print('cocotb', cocotb.__version__)"

echo
echo "完成。之後每次開新 terminal 先執行：source .venv/bin/activate"
