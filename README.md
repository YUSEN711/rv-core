# rv-core

自己從零寫的 RISC-V 核心，從 RV32I 五級 pipeline 一路升級到 out-of-order。
每個階段都配上驗證（cocotb、對照 golden model、SVA、coverage）。

## Phase 0：環境安裝（Mac）

```bash
# 1. 解壓縮後進到資料夾，初始化 git
cd rv-core
git init && git add . && git commit -m "initial skeleton"

# 2. 一鍵安裝（Homebrew 工具 + RISC-V toolchain + Python venv + cocotb）
chmod +x scripts/*.sh
./scripts/setup_mac.sh

# 3. 之後每次開新 terminal
source .venv/bin/activate
```

> `riscv-tools` 是從原始碼編譯的，第一次要 30–60 分鐘，可以先跳過，等到要跑 riscv-tests 時再裝。

用 VS Code 打開資料夾後，右下角會提示安裝推薦擴充套件（`.vscode/extensions.json`），按 Install All 即可。

### 確認環境正常

```bash
make test-alu       # 應該看到 TESTS=1 PASS=1 FAIL=0
make test-regfile
make lint           # 骨架階段會有一些警告，正常
```

波形檔在 `tb/sim_build/.../dump.fst`，在 VS Code 裡用 Surfer 打開。

## 目錄結構

```
rtl/
  core_pkg.sv     型別、opcode、ALU op、pipeline register struct
  alu.sv          ✅ 完成
  regfile.sv      ✅ 完成（含同拍寫讀 bypass）
  mem.sv          ✅ 模擬用雙埠記憶體，+hex= 載入程式
  core_top.sv     🚧 Phase 1：你要完成的五級 pipeline
tb/
  test_alu.py     ALU 隨機測試（對照 Python model）
  test_regfile.py Regfile 隨機測試
  test_core.py    跑程式直到寫 tohost，回報 PASS/FAIL 和 CPI
  tb_top.sv       core + mem
sw/env/           精簡版 riscv-tests 環境（不需要 CSR）
scripts/          安裝、編譯測試程式、批次跑測試
```

## Phase 1：RV32I 五級 pipeline

所有要寫的地方都在 `rtl/core_top.sv`，標了 `TODO(Phase 1)`。

**建議順序**
1. 在 `core_pkg.sv` 定義 `id_ex_t`、`ex_mem_t`、`mem_wb_t`
2. 寫 `rtl/decoder.sv`（opcode、funct3/7、五種 imm 格式、控制訊號），**順便寫 `tb/test_decoder.py`**
3. 接好 ID→EX→MEM→WB，先跑沒有相依性的指令
4. Forwarding：EX/MEM→EX、MEM/WB→EX
5. Load-use stall（插一個 bubble）
6. Branch/jump：在 EX 決定，flush IF/ID 和 ID/EX，驅動 `redirect`
7. Load/store：byte enable、對齊、LB/LH 的符號延伸
8. FENCE 當 NOP
9. 接上 `retire_*` 訊號

**跑 ISA 測試**
```bash
make riscv-tests                        # 下載並編譯 rv32ui
make sim HEX=build/riscv-tests/add.hex  # 跑單一測試
make isa                                # 全部跑一輪，印總表
```
失敗時：`build/logs/<test>.log` 會寫是第幾個子測試失敗（tohost >> 1），
對照 `build/riscv-tests/<test>.dump` 找到那段指令，再看波形。

**Phase 1 完成標準**
- [ ] `make isa` 全部 PASS
- [ ] 記錄每個測試的 CPI
- [ ] `make lint` 拿掉 `-Wno-UNUSED*` 後也乾淨
- [ ] `docs/bug_log.md`：每個 bug 寫「症狀 → 怎麼 debug → root cause → 怎麼預防」

## 常用指令

| 指令 | 用途 |
|---|---|
| `make test-alu SEED=123` | 用固定 seed 重現失敗 |
| `make test-alu SIM=icarus` | 改用 Icarus Verilog |
| `make clean` | 清掉 build 產物 |

## 下一步（Phase 2）

把 `retire_*` 的每條指令和 Spike 的 commit log（`spike -l --log-commits`）逐條比對，
加上 cocotb 隨機指令產生器、SVA assertions、functional coverage。
