//date:2016/3/12
//engineer:ZhaiShaoMin
//module name:inst decode stage of core
//module function:including all issues excuted necessarily in id stage
//                they are hazard_detection_for_alu ,hazard_detection_for_branch,
//                decoder,regfile,br_addr_adder ect.
module    core_id(//input
                  clk,
                  rst,
                  if_id_inst_word,
                  //h_d_f_alu
                  id_ex_memread,
                  id_ex_regrt,
                  //branch target 
                  if_id_plus_4,
                  //h_d_f_br
                  id_ex_wb_regwrite,
                  ex_mem_memread,
                  ex_dest_reg,
                  mem_dest_reg,
                  //frowarding_unit_id
                  ex_mem_regwrite,
                  mem_wb_regwrite,
                  ex_mem_regrd,
                  mem_wb_regrd,
                  ex_mem_regdata,
                  mem_wb_regdata,
                  //output
                  stall_pipeline_alu,
                  stall_pipeline_br,
                  branch_target,
                  jump_target,
                  wb_regwrite,
                  wb_memtoreg,
                  mem_branch,
                  mem_memread,
                  mem_memwrite,
                //  ex_reg_dest,
                  ex_aluop,
                  ex_alusrc,
                  ex_regdst,
                  regread1,
                  regread2,
                  if_id_regrs,
                  if_id_regrt,
                  if_id_regrd,
                  if_flush,
                  pc_src,
                  ll_mem,
                  sc_mem,
                  sign_extend,
                  id_inst_fun);
//parameter 
parameter        R_type=6'b000000;
parameter        lw_type=6'b100011;
parameter        sw_type=6'b101011;
parameter        beq_type=6'b000100;
parameter        jump_type=6'b000010;
parameter        ll_type=6'b110000;
parameter        sc_type=6'b111000;
//input
input                  clk;
input                  rst;
input    [31:0]        if_id_inst_word;
                       //h_d_f_alu
input                  id_ex_memread;
input    [4:0]         id_ex_regrt;
                       //branch target 
input    [31:0]        if_id_plus_4;
                       //h_d_f_br
input                  id_ex_wb_regwrite;
input                  ex_mem_memread;
input    [4:0]         ex_dest_reg;
input    [4:0]         mem_dest_reg;
                       //mem  forwarding
input                  ex_mem_regwrite;
input    [4:0]         ex_mem_regrd;
input    [31:0]        ex_mem_regdata;
                       //wb   forwarding
input                  mem_wb_regwrite;
input    [4:0]         mem_wb_regrd;
input    [31:0]        mem_wb_regdata;
                  
//output
output                  stall_pipeline_alu;
output                  stall_pipeline_br;
output   [31:0]         branch_target;
output   [31:0]         jump_target;
output                  wb_regwrite;
output                  wb_memtoreg;
output                  mem_branch;
output                  mem_memread;
output                  mem_memwrite;
//output   [4:0]          ex_reg_dest;
output   [1:0]          ex_aluop;
output                  ex_alusrc;
output                  ex_regdst;
output   [31:0]         regread1;
output   [31:0]         regread2;
output   [4:0]          if_id_regrs;
output   [4:0]          if_id_regrt;
output   [4:0]          if_id_regrd;
output                  if_flush;             
output   [1:0]          pc_src;
output                  ll_mem;
output                  sc_mem;
output   [31:0]         sign_extend;
output   [5:0]          id_inst_fun;
/*regdst=1'b0;
  jump=1'b0;
  branch=1'b0;
  memread=1'b0;
  memtoreg=1'b0;
  aluop=2'b00;
  memwrite=1'b0;
  alusrc=1'b0;
  regwrite=1'b0;*/
//hazard detection for alu
assign stall_pipeline_alu=(id_ex_memread&&(id_ex_regrt==if_id_inst_word[25:21])||(id_ex_regrt==if_id_inst_word[20:16]))?1'b1:1'b0;

//hazard detection for branch target
assign stall_pipeline_br=(   (id_ex_wb_regwrite&&( (ex_dest_reg==if_id_inst_word[25:21]) || (ex_dest_reg==if_id_inst_word[20:16]) ) )   ||
                            (ex_mem_memread&&((mem_dest_reg==if_id_inst_word[25:21])||(mem_dest_reg==if_id_inst_word[20:16]))) )?1'b1:1'b0;
//sign-extend
wire    [31:0]  sign_extend;
wire    [15:0]  temp_sign;
assign  temp_sign=if_id_inst_word[15]?16'hffff:16'h0000;
assign  sign_extend={temp_sign,if_id_inst_word[15:0]};
//shift_left_2
wire    [31:0]  shift_left_2;
assign  shift_left_2={sign_extend[31],sign_extend[28:0],2'b00};
//branch target
assign  branch_target=if_id_plus_4+shift_left_2;
assign  jump_target={if_id_plus_4[31:28],if_id_inst_word[25:0],2'b00};

// inst_fun
assign  id_inst_fun=if_id_inst_word[5:0];
reg       regdst;
reg       jump;
reg       branch;
reg       memread;
reg       memtoreg;
reg [1:0] aluop;
reg       memwrite;
reg       alusrc;
reg       regwrite;
reg       ll_mem;
reg       sc_mem;
assign  wb_memtoreg=memtoreg;
assign  wb_regwrite=regwrite;
assign  mem_memread=memread;
assign  mem_memwrite=memwrite;
assign  reg_rs=if_id_inst_word[25:21];
assign  reg_rt=if_id_inst_word[20:16];
assign  reg_rd=if_id_inst_word[15:11];
//decode block
always@(*)
begin
  //default value
  regdst=1'b0;
  jump=1'b0;
  branch=1'b0;
  memread=1'b0;
  memtoreg=1'b0;
  aluop=2'b00;
  memwrite=1'b0;
  alusrc=1'b0;
  regwrite=1'b0;
  ll_mem=1'b0;
  sc_mem=1'b0;
  case(if_id_inst_word[31:26])
    R_type:
      begin
        regdst=1'b1;
        regwrite=1'b1;
        aluop=2'b10;
      end
    lw_type:
      begin
        alusrc=1'b1;
        memtoreg=1'b1;
        regwrite=1'b1;
        memread=1'b1;
      end
    ll_type:
      begin
        alusrc=1'b1;
        memtoreg=1'b1;
        regwrite=1'b1;
        memread=1'b1;
        ll_mem=1'b1;
      end
    sw_type:
      begin
        alusrc=1'b1;
        memwrite=1'b1;
      end
    sc_type:
      begin
        alusrc=1'b1;
        memwrite=1'b1;
        sc_mem=1'b1;
      end
    beq_type:
      begin
        branch=1'b1;
        aluop=1'b1;
      end
    jump_type:
      begin
        jump=1'b1;
      end
 endcase
end
 
//forwarding_unit_id
reg  [1:0]  forward_a;
reg  [1:0]  forward_b;
always@(*)
begin
    //forward_a
  if(mem_wb_regwrite&&(mem_wb_regrd!=5'b00000)&&   !(ex_mem_regwrite&&(ex_mem_regrd!=5'b00000)&&(ex_mem_regrd!=if_id_regrs)) &&(mem_wb_regrd==if_id_regrs))
    forward_a=2'b01;
else if(ex_mem_regwrite&&(ex_mem_regrd!=5'b00000)&&(ex_mem_regrd==if_id_regrs))
    forward_a=2'b10;
else
    forward_a=2'b00;
    
    //fotward_b
  if(mem_wb_regwrite&&(mem_wb_regrd!=5'b00000)&&   !(ex_mem_regwrite&&(ex_mem_regrd!=5'b00000)&&(ex_mem_regrd!=if_id_regrt)) &&(mem_wb_regrd==if_id_regrt))
    forward_a=2'b01;
else if(ex_mem_regwrite&&(ex_mem_regrd!=5'b00000)&&(ex_mem_regrd==if_id_regrt))
    forward_a=2'b10;
else
    forward_a=2'b00;
end

// regfile
core_id_regfile   regfile(//input
                         .clk(clk),
                         .rst(rst),
                         .raddr1(if_id_inst_word[25:21]),
                         .raddr2(if_id_inst_word[20:16]),
                         .rf_write(wb_reg_write),
                         .waddr(wb_reg_dest),
                         .data(wb_reg_data),
                         //output
                         .rd_data1(regread1),
                         .rd_data2(regread2)
                         );
//beq compare src
reg  [31:0]  cmp_src1;
reg  [31:0]  cmp_src2;
always@(*)
begin
  case(forward_a)
    2'b00:cmp_src1=regread1;
    2'b01:cmp_src1=mem_wb_regdata;
    2'b10:cmp_src1=ex_mem_regdata;
    default:cmp_src1=regread1;
 endcase
end

always@(*)
begin
  case(forward_b)
    2'b00:cmp_src2=regread2;
    2'b01:cmp_src2=mem_wb_regdata;
    2'b10:cmp_src2=ex_mem_regdata;
    default:cmp_src2=regread2;
 endcase
end

assign  src1_eq_src2=cmp_src1==cmp_src2?1'b1:1'b0;
assign  pc_src=(src1_eq_src2&&branch==1'b1)?2'b01:jump?2'b10:2'b00;  
assign  if_flush=|pc_src;
endmodule
