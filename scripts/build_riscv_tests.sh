#!/usr/bin/env bash
# 下載 riscv-tests，用精簡環境（sw/env）編譯 rv32ui 測試，輸出 .elf/.hex/.dump/.tohost
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/third_party/riscv-tests"
OUT="$ROOT/build/riscv-tests"
PREFIX="${RISCV_PREFIX:-riscv64-unknown-elf-}"

if [ ! -d "$SRC" ]; then
  git clone --depth 1 https://github.com/riscv-software-src/riscv-tests.git "$SRC"
fi
mkdir -p "$OUT"

# rv32ui 中不需要 CSR / fence.i / misaligned 支援的測試
TESTS="simple add addi and andi auipc beq bge bgeu blt bltu bne jal jalr
       lb lbu lh lhu lui lw or ori sb sh sll slli slt slti sltiu sltu
       sra srai srl srli sub sw xor xori"

for t in $TESTS; do
  "${PREFIX}gcc" -march=rv32i_zicsr -mabi=ilp32 -static -mcmodel=medany \
    -fvisibility=hidden -nostdlib -nostartfiles \
    -I"$ROOT/sw/env" -I"$SRC/isa/macros/scalar" \
    -T"$ROOT/sw/env/link.ld" \
    "$SRC/isa/rv32ui/$t.S" -o "$OUT/$t.elf"
  "${PREFIX}objcopy" -O binary "$OUT/$t.elf" "$OUT/$t.bin"
  "${PREFIX}objdump" -d "$OUT/$t.elf" > "$OUT/$t.dump"
  python3 "$ROOT/scripts/bin2hex.py" "$OUT/$t.bin" "$OUT/$t.hex"
  echo "0x$("${PREFIX}nm" "$OUT/$t.elf" | awk '$3=="tohost"{print $1}')" > "$OUT/$t.tohost"
  echo "built $t"
done
