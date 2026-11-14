// mem.sv — 模擬用的統一記憶體（指令 + 資料），雙埠
//   指令埠：組合讀取（Phase 1 先這樣，Phase 4 換成 cache）
//   資料埠：組合讀取、同步寫入、byte enable
// 程式由 plusarg 載入：+hex=path/to/prog.hex（一行一個 32-bit little-endian word）
// 只用位址低位元索引，所以 0x8000_0000 對應到 mem[0]。
module mem
  import core_pkg::*;
#(
  parameter int DEPTH_WORDS = 16384   // 64 KB
)(
  input  logic       clk,
  // instruction port
  input  word_t      iaddr,
  output word_t      irdata,
  // data port
  input  logic       dwe,
  input  logic [3:0] dbe,
  input  word_t      daddr,
  input  word_t      dwdata,
  output word_t      drdata
);

  localparam int AW = $clog2(DEPTH_WORDS);

  word_t storage [DEPTH_WORDS];

  logic [AW-1:0] iidx, didx;
  assign iidx = iaddr[AW+1:2];
  assign didx = daddr[AW+1:2];

  string hexfile;
  initial begin
    if ($value$plusargs("hex=%s", hexfile)) begin
      $display("[mem] loading %s", hexfile);
      $readmemh(hexfile, storage);
    end
  end

  assign irdata = storage[iidx];
  assign drdata = storage[didx];

  always_ff @(posedge clk) begin
    if (dwe) begin
      for (int i = 0; i < 4; i++) begin
        if (dbe[i]) storage[didx][8*i +: 8] <= dwdata[8*i +: 8];
      end
    end
  end

endmodule
