// core_pkg.sv — 全核心共用的型別與常數
package core_pkg;

  localparam int XLEN = 32;
  typedef logic [XLEN-1:0] word_t;

  // riscv-tests 的 link.ld 從 0x8000_0000 開始放程式
  localparam word_t RESET_PC = 32'h8000_0000;

  // RV32I opcode（instr[6:0]）
  typedef enum logic [6:0] {
    OP_LUI    = 7'b0110111,
    OP_AUIPC  = 7'b0010111,
    OP_JAL    = 7'b1101111,
    OP_JALR   = 7'b1100111,
    OP_BRANCH = 7'b1100011,
    OP_LOAD   = 7'b0000011,
    OP_STORE  = 7'b0100011,
    OP_IMM    = 7'b0010011,
    OP_REG    = 7'b0110011,
    OP_FENCE  = 7'b0001111,   // Phase 1 當 NOP 處理即可
    OP_SYSTEM = 7'b1110011
  } opcode_e;

  // ALU 運算。注意：順序必須和 tb/test_alu.py 的 OPS 清單一致
  typedef enum logic [3:0] {
    ALU_ADD,
    ALU_SUB,
    ALU_SLL,
    ALU_SLT,
    ALU_SLTU,
    ALU_XOR,
    ALU_SRL,
    ALU_SRA,
    ALU_OR,
    ALU_AND,
    ALU_PASS_B    // LUI 用：直接輸出 imm
  } alu_op_e;

  // ---------------- Pipeline registers（Phase 1 依需要擴充欄位） ----------------
  typedef struct packed {
    logic  valid;
    word_t pc;
    word_t instr;
  } if_id_t;

  // TODO(Phase 1): 定義 id_ex_t / ex_mem_t / mem_wb_t
  //   建議欄位：valid, pc, rs1/rs2/rd 編號, 運算元值, imm, alu_op,
  //   mem_read/mem_write/mem_size, reg_write, wb_sel, 以及 instr（給 retire trace 用）

endpackage
