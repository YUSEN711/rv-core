// tb_top.sv — 系統層 testbench 頂層：core + memory。clock/reset 由 cocotb 驅動。
module tb_top
  import core_pkg::*;
(
  input logic clk,
  input logic rst_n
);

  word_t      imem_addr, imem_rdata;
  logic       dmem_we;
  logic [3:0] dmem_be;
  word_t      dmem_addr, dmem_wdata, dmem_rdata;

  logic       retire_valid;
  word_t      retire_pc, retire_instr, retire_rd_wdata;
  logic [4:0] retire_rd;

  core_top u_core (.*);

  mem u_mem (
    .clk    (clk),
    .iaddr  (imem_addr),
    .irdata (imem_rdata),
    .dwe    (dmem_we),
    .dbe    (dmem_be),
    .daddr  (dmem_addr),
    .dwdata (dmem_wdata),
    .drdata (dmem_rdata)
  );

endmodule
