// alu.sv — 組合邏輯 ALU（已完成，tb/test_alu.py 會對照 Python model 驗證）
module alu
  import core_pkg::*;
(
  input  alu_op_e op,
  input  word_t   a,
  input  word_t   b,
  output word_t   y
);

  logic [4:0] shamt;
  assign shamt = b[4:0];

  always_comb begin
    unique case (op)
      ALU_ADD:    y = a + b;
      ALU_SUB:    y = a - b;
      ALU_SLL:    y = a << shamt;
      ALU_SLT:    y = {31'b0, $signed(a) < $signed(b)};
      ALU_SLTU:   y = {31'b0, a < b};
      ALU_XOR:    y = a ^ b;
      ALU_SRL:    y = a >> shamt;
      ALU_SRA:    y = $signed(a) >>> shamt;
      ALU_OR:     y = a | b;
      ALU_AND:    y = a & b;
      ALU_PASS_B: y = b;
      default:    y = '0;
    endcase
  end

endmodule
