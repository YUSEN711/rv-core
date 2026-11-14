#!/usr/bin/env bash
# 逐一跑 build/riscv-tests/*.hex，印出 PASS/FAIL 總表。log 在 build/logs/
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIR="$ROOT/build/riscv-tests"
LOGS="$ROOT/build/logs"
SIM="${SIM:-verilator}"
mkdir -p "$LOGS"

pass=0; fail=0; failed=()
for hex in "$DIR"/*.hex; do
  t="$(basename "$hex" .hex)"
  if TOHOST="$(cat "$DIR/$t.tohost")" make -C "$ROOT/tb" TEST=core SIM="$SIM" HEX="$hex" \
       > "$LOGS/$t.log" 2>&1 && grep -q "FAIL=0" "$LOGS/$t.log"; then
    printf "  %-8s PASS\n" "$t"; pass=$((pass+1))
  else
    printf "  %-8s FAIL  (see build/logs/%s.log)\n" "$t" "$t"; fail=$((fail+1)); failed+=("$t")
  fi
done

echo "------------------------------"
echo "PASS $pass / $((pass+fail))"
[ "$fail" -eq 0 ] || { echo "failed: ${failed[*]}"; exit 1; }
