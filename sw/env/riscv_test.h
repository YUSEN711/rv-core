// sw/env/riscv_test.h — 精簡版 riscv-tests 環境（取代官方 env/p/riscv_test.h）
//
// 官方版本開機時會用 CSR（mhartid、mtvec、mret、ecall），
// Phase 1 的核心還沒有 CSR，所以這裡改成：
//   - 從 _start 直接進入測試
//   - PASS / FAIL 改成「把結果寫到 tohost」，testbench 監看這個位址的寫入
// 核心需要支援：RV32I + FENCE（當 NOP）。
#ifndef _ENV_MINIMAL_RISCV_TEST_H
#define _ENV_MINIMAL_RISCV_TEST_H

#define RVTEST_RV32U
#define RVTEST_RV64U

#define TESTNUM gp

#define RVTEST_CODE_BEGIN                                               \
        .section .text.init;                                            \
        .align  6;                                                      \
        .globl _start;                                                  \
_start:                                                                 \
        li TESTNUM, 0;

#define RVTEST_CODE_END                                                 \
        unimp

#define RVTEST_PASS                                                     \
        fence;                                                          \
        li TESTNUM, 1;                                                  \
        la t0, tohost;                                                  \
        sw TESTNUM, 0(t0);                                              \
1:      j 1b;

#define RVTEST_FAIL                                                     \
        fence;                                                          \
1:      beqz TESTNUM, 1b;                                               \
        sll TESTNUM, TESTNUM, 1;                                        \
        or TESTNUM, TESTNUM, 1;                                         \
        la t0, tohost;                                                  \
        sw TESTNUM, 0(t0);                                              \
2:      j 2b;

#define EXTRA_DATA

#define RVTEST_DATA_BEGIN                                               \
        EXTRA_DATA                                                      \
        .pushsection .tohost,"aw",@progbits;                            \
        .align 6; .global tohost; tohost: .dword 0;                     \
        .align 6; .global fromhost; fromhost: .dword 0;                 \
        .popsection;                                                    \
        .align 4; .global begin_signature; begin_signature:

#define RVTEST_DATA_END .align 4; .global end_signature; end_signature:

#endif
