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
                       //output
                       pc_plus_4_out,
                       inst_word_out
                       );
//input
input        clk;
input        rst;
input [31:0] pc_plus_4;
input [31:0] inst_word;
//input        stall;
input        if_id_we;
input        if_flush;

//output
output [31:0] pc_plus_4_out;
output [31:0] inst_word_out;


//reg 
reg  [31:0]  inst_word_reg;
reg  [31:0]  pc_plus_4_reg;

always@(posedge clk)
begin
  if(rst||if_flush)
    begin
      pc_plus_4_reg<=32'h0000;
      inst_word_reg<=32'h0000;
    end
    else if(if_id_we)
      begin
        pc_plus_4_reg<=pc_plus_4;
        inst_word_reg<=inst_word;
      end
end
endmodule

