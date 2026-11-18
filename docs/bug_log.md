# Bug Log

格式：症狀 → 怎麼 debug → root cause → 怎麼預防

---

## Phase 0：環境建置

### B0-1 Homebrew 拒絕安裝 RISC-V toolchain
- **症狀**：`brew install riscv-tools` 出現 `Refusing to load formula ... from untrusted tap`
- **Debug**：讀錯誤訊息，它直接提示要用 `brew trust`
- **Root cause**：新版 Homebrew 預設不信任第三方 tap
- **預防**：安裝第三方 tap 前先確認來源可信，再 `brew trust riscv-software-src/riscv`

### B0-2 make test-alu 顯示 "Nothing to be done"
- **症狀**：執行 `make test-alu` 沒有任何動作
- **Debug**：Makefile 裡 test-alu 同時出現在 `.PHONY` 和 `test-%` pattern rule
- **Root cause**：GNU make 不會對 `.PHONY` 目標套用 pattern rule
- **預防**：pattern rule 產生的目標不要放進 `.PHONY`

### B0-3 Verilator 編譯找不到 lz4.h
- **症狀**：`fatal error: 'lz4.h' file not found`
- **Debug**：錯誤出在 `verilated_fst_c.cpp`，表示是 FST 波形功能需要 lz4
- **Root cause**：FST 是壓縮格式，需要 lz4 函式庫，Mac 上的編譯器找不到它的標頭檔
- **預防**：改用 VCD（`--trace`），不需要額外函式庫
