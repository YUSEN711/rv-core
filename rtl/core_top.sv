// core_top.sv — RV32I 五級 pipeline（Phase 1 要你完成的部分）
//
//   IF  →  ID  →  EX  →  MEM  →  WB
//
// 已完成：PC 暫存器、IF 取指、IF/ID pipeline register、regfile 與 ALU 的接線位置
// 待完成：標了 TODO(Phase 1) 的地方
//
// 建議順序：
//   1. 不管 hazard，先讓沒有相依性的指令（中間塞 NOP）跑對
//   2. 加 forwarding（EX/MEM→EX、MEM/WB→EX）
//   3. 加 load-use stall
//   4. 加 branch/jump（在 EX 決定，flush IF/ID 和 ID/EX）
//   5. 跑通 make isa 全部 rv32ui 測試
//
// retire_* 介面：每條指令在 WB 完成時拉高 retire_valid 一拍。
// Phase 2 會用它和 Spike 的 commit log 逐條比對。
module core_top
  import core_pkg::*;
(
  input  logic       clk,
  input  logic       rst_n,

  // instruction memory
  output word_t      imem_addr,
  input  word_t      imem_rdata,

  // data memory
  output logic       dmem_we,
  output logic [3:0] dmem_be,
  output word_t      dmem_addr,
  output word_t      dmem_wdata,
  input  word_t      dmem_rdata,

  // retire trace（Phase 2 驗證用）
  output logic       retire_valid,
  output word_t      retire_pc,
  output word_t      retire_instr,
  output logic [4:0] retire_rd,
  output word_t      retire_rd_wdata
);

  // =========================================================================
  // Hazard / control 訊號
  // =========================================================================
  logic  stall_if;      // TODO(Phase 1): load-use 時拉高
  logic  stall_id;
  logic  flush_id;      // TODO(Phase 1): branch taken / jump 時拉高
  logic  flush_ex;
  logic  redirect;      // EX 決定要跳轉
  word_t redirect_pc;

  assign stall_if    = 1'b0;
  assign stall_id    = 1'b0;
  assign flush_id    = redirect;
  assign flush_ex    = redirect;
  assign redirect    = 1'b0;   // TODO(Phase 1): 由 EX 的 branch/jump 結果驅動
  assign redirect_pc = '0;

  // =========================================================================
  // IF
  // =========================================================================
  word_t pc_q, pc_d;

  always_comb begin
    if (redirect)      pc_d = redirect_pc;
    else if (stall_if) pc_d = pc_q;
    else               pc_d = pc_q + 32'd4;
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) pc_q <= RESET_PC;
    else        pc_q <= pc_d;
  end

  assign imem_addr = pc_q;

  if_id_t if_id_q;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n || flush_id) begin
      if_id_q <= '0;
    end else if (!stall_id) begin
      if_id_q.valid <= 1'b1;
      if_id_q.pc    <= pc_q;
      if_id_q.instr <= imem_rdata;
    end
  end

  // =========================================================================
  // ID
  // =========================================================================
  // TODO(Phase 1): decoder
  //   - 從 if_id_q.instr 拆出 opcode/funct3/funct7/rs1/rs2/rd
  //   - 產生 imm（I/S/B/U/J 五種格式）
  //   - 產生 alu_op、控制訊號
  //   建議寫成獨立的 rtl/decoder.sv，並為它寫一個 cocotb 單元測試

  logic [4:0] rs1_addr, rs2_addr;
  word_t      rs1_data, rs2_data;

  assign rs1_addr = if_id_q.instr[19:15];
  assign rs2_addr = if_id_q.instr[24:20];

  // WB 寫回訊號
  logic       wb_we;
  logic [4:0] wb_rd;
  word_t      wb_data;

  regfile u_regfile (
    .clk    (clk),
    .we     (wb_we),
    .waddr  (wb_rd),
    .wdata  (wb_data),
    .raddr1 (rs1_addr),
    .raddr2 (rs2_addr),
    .rdata1 (rs1_data),
    .rdata2 (rs2_data)
  );

  // TODO(Phase 1): ID/EX pipeline register（id_ex_t，定義在 core_pkg）

  // =========================================================================
  // EX
  // =========================================================================
  alu_op_e ex_alu_op;
  word_t   ex_op_a, ex_op_b, ex_alu_y;

  // TODO(Phase 1): forwarding mux 選 ex_op_a / ex_op_b
  // TODO(Phase 1): branch 比較、算 branch/jump target、驅動 redirect
  assign ex_alu_op = ALU_ADD;
  assign ex_op_a   = '0;
  assign ex_op_b   = '0;

  alu u_alu (
    .op (ex_alu_op),
    .a  (ex_op_a),
    .b  (ex_op_b),
    .y  (ex_alu_y)
  );

  // TODO(Phase 1): EX/MEM pipeline register

  // =========================================================================
  // MEM
  // =========================================================================
  // TODO(Phase 1): SB/SH/SW → dmem_be 與 wdata 對齊；LB/LBU/LH/LHU 的符號延伸
  assign dmem_we    = 1'b0;
  assign dmem_be    = 4'b0000;
  assign dmem_addr  = '0;
  assign dmem_wdata = '0;

  // TODO(Phase 1): MEM/WB pipeline register

  // =========================================================================
  // WB
  // =========================================================================
  assign wb_we   = 1'b0;   // TODO(Phase 1)
  assign wb_rd   = '0;
  assign wb_data = '0;

  assign retire_valid    = 1'b0;   // TODO(Phase 1): mem_wb_q.valid
  assign retire_pc       = '0;
  assign retire_instr    = '0;
  assign retire_rd       = wb_rd;
  assign retire_rd_wdata = wb_data;

endmodule
