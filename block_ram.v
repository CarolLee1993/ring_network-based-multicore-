//    BLOCK RAM
// Simple dual-Port RAM with Synchronous Read
// mainly used for fifo
module SDP_BRAM_SRd(clk, wren,rden, wa, ra, di, do);
  parameter ram_width=19;
  parameter ram_dipth=16;
  parameter addr_width=5;
input clk;
input wren;
input  rden;
input [addr_width-1:0] ra;
input [addr_width-1:0] wa;
input  [ram_width-1:0] di;
output [ram_width-1:0] do;
reg [ram_width-1:0] ram [ram_dipth-1:0];
reg [addr_width-1:0] read_a;
always @(posedge clk) begin
if (wren)
ram[wa] <= di;
if (rden)
read_a <= ra;
end
assign do = ram[read_a];
endmodule


//
// Single-Port RAM with Synchronous Read
//
module SP_BRAM_SRd(clk, we, re, a, di, do);
  parameter ram_depth=16;
  parameter ram_width=6;
  parameter ram_addr_width=4;
input clk;
input we;
input re;
input [ram_addr_width-1:0] a;
input [ram_width-1:0] di;
output [ram_width-1:0] do;
reg [ram_width-1:0] ram [ram_depth-1:0];
reg [ram_addr_width-1:0] read_a;
always @(posedge clk) begin
if (we)
ram[a] <= di;
read_a <= a;
end
assign do = re?ram[read_a]:'z;
endmodule