//date:2016/3/11
//engineer:ZhaiShaoMin
//module name:inter registers between inst fetch stage and inst decode stage
module     core_if_id(//input
                       clk,
                       rst,
                      // stall,
                       if_id_we,
                       if_flush,
                       pc_plus_4,
                       inst_word,
                       //used for update Branch predictor
                       pc,
                       pred_target,
                       delayed_PHT,
                       delayed_BHR,
                       btb_type,
                       btb_v,
                       //output
                       pc_plus_4_out,
                       inst_word_out,
                       pc_out,
                       pred_target_out,
                       delayed_PHT_out,
                       delayed_BHR_out,
                       btb_type_out,
                       btb_v_out
                       );
//input
input        clk;
input        rst;
input [31:0] pc_plus_4;
input [31:0] inst_word;
input [31:0] pc;
input [31:0] pred_target;
input [1:0]  delayed_PHT;
input [2:0]  delayed_BHR;
input [1:0]  btb_type;
input        btb_v;
//input        stall;
input        if_id_we;
input        if_flush;

//output
output [31:0] pc_plus_4_out;
output [31:0] inst_word_out;
output [31:0] pc_out;
output [31:0] pred_target_out;
output [1:0]  delayed_PHT_out;
output [2:0]  delayed_BHR_out;
output [1:0]  btb_type_out;
output        btb_v_out;

//reg 
reg  [31:0]  inst_word_out;
reg  [31:0]  pc_plus_4_out;
reg  [31:0]  pc_out;
reg  [31:0]  pred_target_out;
reg  [1:0]   delayed_PHT_out;
reg  [2:0]   delayed_BHR_out;
reg  [1:0]   btb_type_out;
reg          btb_v_out;
always@(posedge clk)
begin
  if(rst||if_flush)
    begin
      pc_plus_4_out<=32'h0000;
      inst_word_out<=32'h0000;
      pc_out<=32'h0000;
      pred_target_out<=32'h0000;
      delayed_PHT_out<=2'b00;
      delayed_BHR_out<=3'b000;
      btb_type_out<=2'b00;
      btb_v_out<=1'b0;
    end
    else if(if_id_we)
      begin
        pc_plus_4_out<=pc_plus_4;
        inst_word_out<=inst_word;
        pc_out<=pc;
        pred_target_out<=pred_target;
        delayed_PHT_out<=delayed_PHT;
        delayed_BHR_out<=delayed_BHR;
        btb_type_out<=btb_type;
        btb_v_out<=btb_v;
      end
end
endmodule

