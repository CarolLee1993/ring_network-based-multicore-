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

reg  [31:0]     pc_temp;
always@(*)
begin
   case(pc_src)
	2'b00:pc_temp=good_target;
	2'b01:pc_temp=pc_plus4;
	2'b10:pc_temp=ras_target;
	2'b11:pc_temp=btb_target;
	default:pc_temp=pc_plus4;
	endcase
end
//reg
reg  [31:0]     pc;
always@(posedge clk)
begin
  if(rst)
    pc<=32'h00040000;
  else if(pc_go&&!stall)
    begin
      pc<=pc_temp;
     end
end
assign  pc_plus4=pc+4;
assign  v_pc_out=(pc_go&&!stall);//?1'b0:1'b1;
assign  pc_out=pc;
endmodule