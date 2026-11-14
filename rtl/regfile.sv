// regfile.sv — 32 x 32-bit，2 讀 1 寫，x0 恆為 0（已完成）
// 內含 write-through bypass：WB 寫入與 ID 讀取同一拍時，讀到的是新值，
// 所以 pipeline 不需要額外處理「WB → ID」這條 hazard。
module regfile
  import core_pkg::*;
(
  input  logic       clk,
  input  logic       we,
  input  logic [4:0] waddr,
  input  word_t      wdata,
  input  logic [4:0] raddr1,
  input  logic [4:0] raddr2,
  output word_t      rdata1,
  output word_t      rdata2
);

  word_t regs [32];

  always_ff @(posedge clk) begin
    if (we && waddr != 5'd0) regs[waddr] <= wdata;
  end

  always_comb begin
    if (raddr1 == 5'd0)                rdata1 = '0;
    else if (we && raddr1 == waddr)    rdata1 = wdata;
    else                               rdata1 = regs[raddr1];

    if (raddr2 == 5'd0)                rdata2 = '0;
    else if (we && raddr2 == waddr)    rdata2 = wdata;
    else                               rdata2 = regs[raddr2];
  end

endmodule
