//date:2016/3/13
//engineer:ZhaiShaoMin
//module name: it includes all  pipeline stages and has interfaces with inst cache and data cache
// and all necessary instances are refered here!
module   core(//input
                clk,
                rst,
                v_inst,
                inst,
                v_data,
                data,
                //output
                pc,
                v_pc,
                v_mem,
                mem_head,
                mem_addr,
                mem_data
                );
//input
input                clk;
input                rst;
input                v_inst;
input    [31:0]      inst;
input                v_data;
input    [31:0]      data;
//output
output   [31:0]       pc;
output                v_pc;
output                v_mem;
output   [3:0]        mem_head;
output   [31:0]       mem_addr;
output   [31:0]       mem_data;

wire  [31:0]  br_target;
wire  [31:0]  j_target;
wire  [1:0]   pc_src;
wire          pc_go;
wire          stall;
wire  [31:0]  pc_plus4;
core_pc   pc_dut(//input
               .clk(clk),
               .rst(rst),
               .br_addr(br_target),
               .j_addr(j_target),
               .pc_src(pc_src),
               .pc_go(pc_go),
               .stall(stall),
               //output
               .pc_out(pc),
               .v_pc_out(v_pc),
               .pc_plus4(pc_plus4)
               ); 
wire          if_flush;
wire  [31:0]  pc_plus4_reg;
wire  [31:0]  inst_reg;

core_if_id  if_id_reg_dut(//input
                       .clk(clk),
                       .rst(rst),
                      // stall,
                       .if_id_we(v_inst&&!stall),
                       .if_flush(if_flush),
                       .pc_plus_4(pc_plus4),
                       .inst_word(inst),
                       //output
                       .pc_plus_4_out(pc_plus4_reg),
                       .inst_word_out(inst_reg)
                       );  
wire   [4:0]    id_ex_regrt_net;
wire            id_ex_memread_net;
wire            id_ex_wb_regwrite_net;
wire            ex_mem_memread_net;
wire   [4:0]    ex_dest_reg_net;
wire   [4:0]    mem_dest_reg_net;
wire            ex_mem_regwrite;
wire            mem_wb_regwrite;
wire            ex_mem_regrd;
wire            mem_wb_regrd;
wire            ex_mem_regdata;
wire            mem_wb_regdata;  
               //output
wire                  stall_pipeline_alu;
wire                  stall_pipeline_br;
wire                  wb_regwrite;
wire                  wb_memtoreg;
wire                  mem_branch;
wire                  mem_memread;
wire                  mem_memwrite;
wire                  ex_aluop;
wire                  ex_alusrc;
wire                  ex_regdst;
wire                  regread1;
wire                  regread2;
wire                  if_id_regrs;
wire                  if_id_regrt;
wire                  if_id_regrd;
wire                  ll_mem;
wire                  sc_mem;   
wire                  ex_reg_rt; 
// from  wb stage
wire   [31:0]   wb_mux_regdata;      
core_id    id_dut   (//input
                  .clk(clk),
                  .rst(rst),
                  .if_id_inst_word(inst_reg),
                  //hazard_detection_for_alu
                  .id_ex_memread(ex_mem_memread),
                  .id_ex_regrt(ex_reg_rt),
                  //branch target 
                  .if_id_plus_4(pc_plus4_reg),
                  //hazard_detection_for_branch
                  .id_ex_wb_regwrite(ex_wb_reg_write),
                  .ex_mem_memread(ex_mem_memread),
                  .ex_dest_reg(ex_dest_rd),
                  .mem_dest_reg(mem_dest_reg),
                  //forwarding_unit_id
                  .ex_mem_regwrite(mem_reg_write),
                  .mem_wb_regwrite(wb_regwrite),
                  .ex_mem_regrd(mem_dest_reg),
                  .mem_wb_regrd(wb_dest_reg),
                  .ex_mem_regdata(mem_addr),
                  .mem_wb_regdata(wb_mux_regdata),
                  //output
                  .stall_pipeline_alu(stall_pipeline_alu),
                  .stall_pipeline_br(stall_pipeline_br),
                  .branch_target(br_target),
                  .jump_target(j_target),
                  .wb_regwrite(wb_regwrite),
                  .wb_memtoreg(wb_memtoreg),
                  .mem_branch(mem_branch),
                  .mem_memread(mem_memread),
                  .mem_memwrite(mem_memwrite),
                //  ex_reg_dest,
                  .ex_aluop(ex_aluop),
                  .ex_alusrc(ex_alusrc),
                  .ex_regdst(ex_regdst),
                  .regread1(regread1),
                  .regread2(regread2),
                  .if_id_regrs(if_id_regrs),
                  .if_id_regrt(if_id_regrt),
                  .if_id_regrd(if_id_regrd),
                  .if_flush(if_flush),
                  .pc_src(pc_src),
                  .ll_mem(ll_mem),
                  .sc_mem(sc_mem),
                  .sign_extend(sign_extend),
                  .id_inst_fun(id_inst_fun)
                  );   
assign    stall=stall_pipeline_alu||stall_pipeline_br;
wire                      ex_wb_memtoreg;
wire                      ex_mem_memwrite;
wire                      ex_mem_ll_mem;
wire                      ex_mem_sc_mem;
wire                      ex_regread1;
wire                      ex_regread2;
wire                      ex_reg_rs;
wire                      ex_reg_rd;  
          
core_id_ex   id_ex_reg_dut(//input
                      .clk(clk),
                      .rst(rst),
                      .inst_fun(id_inst_fun),
                      .wb_reg_write(wb_regwrite),
                      .wb_memtoreg(wb_memtoreg),
                      .mem_memread(mem_memread),
                      .mem_memwrite(mem_memwrite),
                      .mem_ll_mem(ll_mem),
                      .mem_sc_mem(sc_mem),
                      .regdst(ex_regdst),
                      .aluop(ex_aluop),
                      .alusrc(ex_alusrc),
                      .regread1(regread1),
                      .regread2(regread2),
                      .sign_extend(sign_extend),
                      .reg_rs(if_id_regrs),
                      .reg_rt(if_id_regrt),
                      .reg_rd(if_id_regrd),
                      //output
                      .ex_inst_fun(ex_inst_fun),
                      .ex_wb_reg_write(ex_wb_reg_write),
                      .ex_wb_memtoreg(ex_wb_memtoreg),
                      .ex_mem_memread(ex_mem_memread),
                      .ex_mem_memwrite(ex_mem_memwrite),
                      .ex_mem_ll_mem(ex_mem_ll_mem),
                      .ex_mem_sc_mem(ex_mem_sc_mem),
                      .ex_regdst(ex_regdst),
                      .ex_aluop(ex_aluop),
                      .ex_alusrc(ex_alusrc),
                      .ex_regread1(ex_regread1),
                      .ex_regread2(ex_regread2),
                      .ex_sign_extend(ex_sign_extend),
                      .ex_reg_rs(ex_reg_rs),
                      .ex_reg_rt(ex_reg_rt),
                      .ex_reg_rd(ex_reg_rd)
                      );


core_ex    ex_dut   (//input
                  .alusrc_a(ex_regread1),
                  .alusrc_b(ex_regread2),
                  .aluop(ex_aluop),
                  .inst_fun(ex_inst_fun),
                  .regdst(ex_regdst),
                  .alusrc(ex_alusrc),
                  .id_ex_rs(ex_reg_rs),
                  .id_ex_rt(ex_reg_rt),
                  .id_ex_rd(ex_reg_rd),
                  .mem_regwrite(mem_reg_write),
                  .wb_regwrite(wb_regwrite),
                  .mem_regrd(mem_dest_reg),
                  .wb_regrd(wb_dest_reg),
                  .mem_reg_data(mem_addr),
                  .wb_reg_data(wb_aluresult),
                  .id_ex_sign_extend(ex_sign_extend),
                  //output
                  .alu_result(alu_result),
                  .data_to_mem(data_to_mem),
                  .ex_dest_rd(ex_dest_rd),
                  .zero(zero)
                  );
 
                  
core_ex_mem   ex_mem_reg_dut(//input
                      .clk(clk),
                      .rst(rst),
                      .branch(branch),
                      .mem_read(ex_mem_memread),
                      .mem_write(ex_mem_memwrite),
                      .ll_mem(ex_mem_ll_mem),
                      .sc_mem(ex_mem_sc_mem),
                      .reg_write(ex_wb_reg_write),
                      .memtoreg(ex_wb_memtoreg),
                      .alu_zero(zero),
                      .alu_result(alu_result),
                      .reg_read2(data_to_mem),
                      .dest_reg(ex_dest_rd),
                      //output
                      .mem_branch(mem_branch),
                      .mem_mem_read(mem_mem_read),
                      .mem_mem_write(mem_mem_write),
                      .mem_ll_mem(mem_ll_mem),
                      .mem_sc_mem(mem_sc_mem),
                      .mem_reg_write(mem_reg_write),
                      .mem_memtoreg(mem_memtoreg),
                      .mem_alu_zero(mem_alu_zero),
                      .mem_alu_result(mem_addr),
                      .mem_reg_read2(mem_data),
                      .mem_dest_reg(mem_dest_reg)
                      );
assign    mem_head[3]=mem_mem_write?1'b1:1'b0;
assign    mem_head[2]=mem_mem_read||mem_mem_write;  
assign    mem_head[1:0]={!mem_ll_mem,!mem_sc_mem};   
assign    v_mem=mem_mem_read||mem_mem_write;   // a waste of logic ,but it's necessary for data cache               
core_mem_wb  mem_wb_dut(//input
                     .clk(clk),
                     .rst(rst),
                     .regwrite(mem_reg_write),
                     .memtoreg(mem_memtoreg),
                     .aluresult(mem_addr),
                     .read_memdata(data),
                     .valid_read_memdata(v_data),
                     .dest_reg(mem_dest_reg),
                     //output
                     .wb_regwrite(wb_regwrite),
                     .wb_memtoreg(wb_memtoreg),
                     .wb_aluresult(wb_aluresult),
                     .wb_read_memdata(wb_read_memdata),
                     .wb_dest_reg(wb_dest_reg)
                     );

assign wb_mux_regdata=wb_memtoreg?wb_read_memdata:wb_aluresult;

endmodule