// date:2016/3/11
// engineer:ZhaiShaoMin
// module name program counter module
module core_pc(//input
               clk,
               rst,
               br_addr,
               j_addr,
               pc_src,
               pc_go,
               stall,
               //output
               pc_out,
               v_pc_out,
               pc_plus4
               );
//parameter 
parameter  initial_addr=32'h0000;
//input
input           clk;
input           rst; 
input  [31:0]   br_addr;
input  [31:0]   j_addr;
input  [1:0]    pc_src;
input           stall;
input           pc_go;

//output
output  [31:0]    pc_out;
output            v_pc_out;
output  [31:0]    pc_plus4;

//reg
reg  [31:0]     pc;
always@(posedge clk)
begin
  if(rst)
    pc<=initial_addr;
  else if(pc_go)
    begin
      if(pc_src==2'b00)
      pc<=pc_plus4;
      else if(pc_src==2'b01)
      pc<=br_addr;
      else if(pc_src==2'b10)
      pc<=j_addr;
     end
end
assign  pc_plus4=pc+4;
assign  v_pc_out=pc_go&&stall?1'b0:1'b1;
assign  pc_out=pc;
endmodule