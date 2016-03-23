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
parameter        jal_btb_type=2'b10;
parameter        jr_btb_type=2'b11;
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

// I/O about pc
wire          v_pc;
wire  [31:0]  pc;
wire  [31:0]  pc_plus4;

// I/O about btb
//wire          if_flush;
//wire  [31:0]  pc_plus4_reg;
//wire  [31:0]  inst_reg;
wire  [1:0]   btb_type_out;
wire  [31:0]  btb_target_out;
wire          btb_v;
wire          en_btb_pred;

// output of PHT
wire       pred_out;
wire [2:0] BHR_rd;
wire [1:0] PHT_out;

//output of RAS
wire     [31:0]  ret_addr_out;

//output of if_id_reg
wire [31:0] if_id_pred_target_out;
wire [1:0]  if_id_delayed_PHT_out;
wire [2:0]  if_id_delayed_BHR_out;
wire [1:0]  if_id_btb_type_out;
wire        if_id_btb_v_out;                   
//wire [31:0]  pred_target;
wire [31:0]  pc_out;
wire [31:0]  pc_plus_4_out;
wire [31:0]  inst_word_out;

//output of id
wire                  stall_pipeline_alu;
wire                  stall_pipeline_br;
wire   [31:0]         id_btb_target_out;
wire                  update_btb_target_out;
wire   [1:0]          id_btb_type_out;
wire                  update_BP_out;
wire                  pred_right_out;
wire                  taken;
wire   [1:0]          delayed_PHT_out;
wire   [2:0]          delayed_BHR_out;
wire                  recover_push;
wire   [31:0]         recover_push_addr;
wire                  recover_pop;
wire                  wb_regwrite;
wire                  wb_memtoreg;
//wire                  mem_branch;
wire                  mem_memread;
wire                  mem_memwrite;
wire   [3:0]          ex_aluop;
wire   [1:0]          ex_alusrc;
wire                  ex_regdst;
wire   [31:0]         regread1;
wire   [31:0]         regread2;
wire   [4:0]          if_id_regrs;
wire   [4:0]          if_id_regrd;
wire   [4:0]          if_id_regrt;
wire                  if_flush;             
wire   [1:0]          pc_src;
wire                  ll_mem;
wire                  sc_mem;
wire   [31:0]         sign_extend;
//output of id_ex_reg
wire                      ex_wb_reg_write;
wire                      ex_wb_memtoreg;
wire                      ex_mem_memread;
wire                      ex_mem_memwrite;
wire                      ex_mem_ll_mem;
wire                      ex_mem_sc_mem;
wire                      ex_regdst_reg;
wire     [1:0]            ex_aluop_reg;
wire                      ex_alusrc_reg;
wire     [31:0]           ex_regread1;
wire     [31:0]           ex_regread2;
wire     [31:0]           ex_sign_extend;
wire     [4:0]            ex_reg_rs;
wire     [4:0]            ex_reg_rt;
wire     [4:0]            ex_reg_rd; 

//output of ex
wire [31:0] alu_result;
wire [31:0] data_to_mem;
wire [4:0]  ex_dest_rd;
wire        zero;


 //output of ex_mem
//wire          mem_branch_reg;
wire          mem_mem_read;
wire          mem_mem_write;
wire          mem_ll_mem;
wire          mem_sc_mem;
wire          mem_reg_write;
wire          mem_memtoreg;
wire          mem_alu_zero;
wire  [31:0]  mem_addr;
wire  [31:0]  mem_data;
wire  [4:0]   mem_dest_reg;


// output of mem_wb
wire            wb_regwrite_reg;
wire            wb_memtoreg_reg;
wire  [31:0]    wb_aluresult;
wire  [31:0]    wb_read_memdata;
wire  [4:0]     wb_dest_reg;  

//input to pc
wire     pc_go;
wire     stall;

core_pc   pc_dut(//input
               .clk(clk),
               .rst(rst),
               .btb_target(btb_target_out),
               .ras_target(ret_addr_out),
               .pc_go(v_inst),
               .stall(stall),
               .good_target(id_btb_target_out),
               .id_pc_src(update_btb_target_out),
               .btb_v(en_btb_pred),
               .btb_type(btb_type_out),
               //output
               .pc_out(pc),
               .v_pc_out(v_pc),
               .pc_plus4(pc_plus4)
               );
               
              
core_btb      btb_dut(//input
                  .clk(clk),
                  .rst(rst),
                  .pc(pc),
                  .update_btb_tag(update_btb_target_out),
                  .update_btb_target(update_btb_target_out),
                  .btb_target_in(id_btb_target_out),
                  .btb_type_in(id_btb_type_out),
                  .PHT_pred_taken(pred_out),
                  //output
                  .btb_type_out(btb_type_out),
                  .btb_target_out(btb_target_out),
                  .btb_v(btb_v),
                  .en_btb_pred(en_btb_pred) // only valid when both btb_v and PHT_pred_taken valid are vallid
                  );
                  
core_pht        pht_dut(//input
                   .clk(clk),
                   .rst(rst),
                   .if_pc(pc[10:5]),  // pc[10:5]
                   .id_pc(pc_out[10:5]),  // pc[10:5]
                   .update_BP(update_BP_out),
                   .pred_right(pred_right_out),
                   .taken(taken),
                   .BHR_in(delayed_BHR_out),
                   //delayed PHT_out from previous stage , useful to avoid reading PHT when update PHT
                   .delayed_PHT(delayed_PHT_out),
                   //output
                   .pred_out(pred_out),
                   .BHR_rd(BHR_rd),
                   .PHT_out(PHT_out)
                   );
                   
core_ras        ras_dut(
                   .clk(clk),
                   .rst(rst),
                   //inst fetch stage prediction 
                   .en_call_in((btb_v&&(btb_type_out==jal_btb_type))), //in my previous version ,it equals en_ret_addr_in 
                   .en_ret_in((btb_v&&(btb_type_out==jr_btb_type))),//in my previous version ,it equals en_ret_addr_out
                   .ret_addr_in(pc_plus4[31:2]),// which is gened by call inst
                   // decode stage recover something wrong,which caused by misprediction in btb, in RAS.
                   .recover_push(recover_push),//previous inst was preded as a JR inst incorrectly.
                   .recover_push_addr(recover_push_addr[31:2]),//push back the top return addr to RAs
                   .recover_pop(recover_pop),// previous inst was preded as a jal inst incorrectly.
                   
                   ////output
                   //inst fetch stage poping top addr
                   .ret_addr_out(ret_addr_out)
                   );
wire    [31:0]  pred_target;
assign     pred_target=(btb_type_out==jr_btb_type)? ret_addr_out:btb_target_out;                                    
core_if_id    if_id_reg(//input
                       .clk(clk),
                       .rst(rst),
                      // stall,
                       .if_id_we(stall),
                       .if_flush(if_flush),
                       .pc_plus_4(pc_plus4),
                       .inst_word(inst),
                       //used for update Branch predictor
                       .pc(pc),
                       .pred_target(pred_target),
                       .delayed_PHT(PHT_out),
                       .delayed_BHR(BHR_rd),
                       .btb_type(btb_type_out),
                       .btb_v(btb_v),
                       //output
                       .pc_plus_4_out(pc_plus_4_out),
                       .inst_word_out(inst_word_out),
                       .pc_out(pc_out),
                       .pred_target_out(if_id_pred_target_out),
                       .delayed_PHT_out(if_id_delayed_PHT_out),
                       .delayed_BHR_out(if_id_delayed_BHR_out),
                       .btb_type_out(if_id_btb_type_out),
                       .btb_v_out(if_id_btb_v_out)
                       ); 

// from  wb stage
wire   [31:0]   wb_mux_regdata;      
core_id    id_dut   (//input
                  .clk(clk),
                  .rst(rst),
                   //btb banch predict
                  .btb_v(if_id_btb_v_out),
                  .btb_type(if_id_btb_type_out),
                  .pred_target(if_id_pred_target_out),
                  .delayed_PHT(if_id_delayed_PHT_out),
                  .delayed_BHR(if_id_delayed_BHR_out),
                  .if_id_inst_word(inst_word_out),
                  //hazard_detection_for_alu
                  .id_ex_memread(ex_mem_memread),
                  .id_ex_regrt(ex_reg_rt),
                  //branch target 
                  .if_id_plus_4(pc_plus_4_out),
                  //hazard_detection_for_branch
                  .id_ex_wb_regwrite(ex_wb_reg_write),
                  .mem_mem_read(mem_mem_read),
                  .ex_dest_reg(ex_dest_rd),
                  .mem_dest_reg(mem_dest_reg),
                  //forwarding_unit_id
                  .ex_mem_regwrite(mem_reg_write),
                  .mem_wb_regwrite(wb_regwrite_reg),
                  .ex_mem_regrd(mem_dest_reg),
                  .mem_wb_regrd(wb_dest_reg),
                  .ex_mem_regdata(mem_addr),
                  .mem_wb_regdata(wb_mux_regdata),
                  //output 
                  //output to if stage
                  .stall_pipeline_alu(stall_pipeline_alu),
                  .stall_pipeline_br(stall_pipeline_br),
                  .update_btb_target_out(update_btb_target_out),
                  .btb_target_out(id_btb_target_out),
                  .btb_type_out(id_btb_type_out),
                  .update_BP_out(update_BP_out),
                  .pred_right_out(pred_right_out),
                  .taken(taken),
                  .delayed_PHT_out(delayed_PHT_out),
                  .delayed_BHR_out(delayed_BHR_out),
                  .recover_push(recover_push),
                  .recover_push_addr(recover_push_addr),
                  .recover_pop(recover_pop),
                  //output to next stage
                  .wb_regwrite(wb_regwrite),
                  .wb_memtoreg(wb_memtoreg),
                 // .mem_branch(mem_branch),
                  .mem_memread(mem_memread),
                  .mem_memwrite(mem_memwrite),
                //  ex_reg_dest,
                  .ex_aluop(ex_aluop),
                  .ex_alusrc(ex_alusrc),
                  .ex_regdst(ex_regdst),
                  .regread1(regread1),
                  .regread2(regread2),
                  .reg_rs(if_id_regrs),
                  .reg_rt(if_id_regrt),
                  .reg_rd(if_id_regrd),
                  .if_flush(if_flush),
                  .pc_src(pc_src),
                  .ll_mem(ll_mem),
                  .sc_mem(sc_mem),
                  .sign_extend(sign_extend)
                 // .id_inst_lo(id_inst_lo)
                  );   
assign    stall=stall_pipeline_alu||stall_pipeline_br;
 
          
core_id_ex   id_ex_reg_dut(//input
                      .clk(clk),
                      .rst(rst),
                   //   .inst_lo(id_inst_lo),
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
                  //    .ex_inst_lo(ex_inst_lo),
                      .ex_wb_reg_write(ex_wb_reg_write),
                      .ex_wb_memtoreg(ex_wb_memtoreg),
                      .ex_mem_memread(ex_mem_memread),
                      .ex_mem_memwrite(ex_mem_memwrite),
                      .ex_mem_ll_mem(ex_mem_ll_mem),
                      .ex_mem_sc_mem(ex_mem_sc_mem),
                      .ex_regdst(ex_regdst_reg),
                      .ex_aluop(ex_aluop_reg),
                      .ex_alusrc(ex_alusrc_reg),
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
              //    .inst_lo(ex_inst_lo),
                  .regdst(ex_regdst),
                  .alusrc(ex_alusrc),
                  .id_ex_rs(ex_reg_rs),
                  .id_ex_rt(ex_reg_rt),
                  .id_ex_rd(ex_reg_rd),
                  .mem_regwrite(mem_reg_write),
                  .wb_regwrite(wb_regwrite_reg),
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
                    //  .branch(branch),
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
                   //   .mem_branch(mem_branch),
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
                     .wb_regwrite(wb_regwrite_reg),
                     .wb_memtoreg(wb_memtoreg_reg),
                     .wb_aluresult(wb_aluresult),
                     .wb_read_memdata(wb_read_memdata),
                     .wb_dest_reg(wb_dest_reg)
                     );

assign wb_mux_regdata=wb_memtoreg?wb_read_memdata:wb_aluresult;

endmodule