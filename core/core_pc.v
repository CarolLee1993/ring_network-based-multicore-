// date:2016/3/11
// engineer:ZhaiShaoMin
// module name program counter module
module core_pc(//input
               clk,
               rst,
               btb_target,
               ras_target,
               pc_go,
               stall,
               // from id module
               good_target, // target from decode stage, correct target
               id_pc_src,  // if 1 ,meaning pc scoure is from decode ,0,otherwise
               // from BTB module
               btb_v,
               btb_type,
               //output
               pc_out,
               v_pc_out,
               pc_plus4
               );
//parameter 
parameter  initial_addr=32'h00040000;
// para used in btb
parameter  br_type=2'b00;
parameter  j_type=2'b01;
parameter  jal_type=2'b10;
parameter  jr_type=2'b11;
//input
input           clk;
input           rst; 
input  [31:0]   btb_target;
input  [31:0]   ras_target;
input           id_pc_src;
input           stall;
input           pc_go;
input  [31:0]   good_target;
input  [1:0]    btb_type;
input           btb_v;


//output
output  [31:0]    pc_out;
output            v_pc_out;
output  [31:0]    pc_plus4;


//figure out pc src sel
wire     [1:0]   pc_src;
wire     [1:0]   pc_src1;

assign    pc_src1=(btb_v&&(btb_type==br_type||btb_type==j_type||btb_type==jal_type))?2'b11:(btb_v&&btb_type==jr_type)?2'b10:2'b01;
assign    pc_src=(id_pc_src==1'b1)?2'b00:pc_src1;

//reg
reg  [31:0]     pc;
always@(posedge clk)
begin
  if(rst)
    pc<=initial_addr;
  else if(pc_go)
    begin
      if(pc_src==2'b00)
      pc<=good_target;
      else if(pc_src==2'b01)
      pc<=pc_plus4;
      else if(pc_src==2'b10)
      pc<=ras_target;
      else if(pc_src==2'b11)
      pc<=btb_target;
     end
end
assign  pc_plus4=pc+4;
assign  v_pc_out=pc_go&&stall?1'b0:1'b1;
assign  pc_out=pc;
endmodule