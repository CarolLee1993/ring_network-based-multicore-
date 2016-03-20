//date:2016/3/12
//engineer:ZhaiShaoMin
//module name:inst decode stage of core
//module function:including all issues excuted necessarily in id stage
//                they are hazard_detection_for_alu ,hazard_detection_for_branch,
//                decoder,regfile,br_addr_adder ect.
module    core_id(//input
                  clk,
                  rst,
                  //btb banch predict
                  btb_v,
                  btb_type,
                  pred_target,
                  delayed_PHT,
                  delayed_BHR,
                  if_id_inst_word,
                  //h_d_f_alu
                  id_ex_memread,
                  id_ex_regrt,
                  //branch target 
                  if_id_plus_4,
                  //h_d_f_br
                  id_ex_wb_regwrite,
                  mem_mem_read,
                  ex_dest_reg,
                  mem_dest_reg,
                  //frowarding_unit_id
                  ex_mem_regwrite,
                  mem_wb_regwrite,
                  ex_mem_regrd,
                  mem_wb_regrd,
                  ex_mem_regdata,
                  mem_wb_regdata,
                  ///////////////output
                  // output to if stage
                  stall_pipeline_alu,
                  stall_pipeline_br,
                  update_btb_target_out,
                  btb_target_out,
                  btb_type_out,
                  update_BP_out,
                  pred_right_out,
                  taken,
                  delayed_PHT_out,
                  delayed_BHR_out,
                  recover_push,
                  recover_push_addr,
                  recover_pop,
                  //output to next stage
                  wb_regwrite,
                  wb_memtoreg,
                  mem_branch,
                  mem_memread,
                  mem_memwrite,
                  ex_aluop,
                  ex_alusrc,
                  ex_regdst,
                  regread1,
                  regread2,
                  reg_rs,
                  reg_rt,
                  reg_rd,
                  if_flush,
                  pc_src,
                  ll_mem,
                  sc_mem,
                  sign_extend
             //     id_inst_lo
                   );
//parameter 
parameter        R_type=6'b000000;
parameter        lw_type=6'b100011;
parameter        sw_type=6'b101011;
parameter        beq_type=6'b000100;
parameter        jump_type=6'b000010;
parameter        ll_type=6'b110000;
parameter        sc_type=6'b111000;
parameter        bne_type=6'b000101;
parameter        blez_type=6'b000110;
parameter        bgtz_type=6'b000111;
parameter        bltz_type=6'b000001;
parameter        bgez_type=6'b000001;
parameter        jal_type=6'b000011;
parameter        addiu_type=6'b001001;
parameter        slti_type=6'b001010;
parameter        sltiu_type=6'b001011;
parameter        andi_type=6'b001100;
parameter        ori_type=6'b001101;
parameter        xori_type=6'b001110;
parameter        lui_type=6'b001111;
// parameter
parameter        br_btb_type=2'b00;
parameter        j_btb_type=2'b01;
parameter        jal_btb_type=2'b10;
parameter        jr_btb_type=2'b11;
//input
input                  clk;
input                  rst;
input                  btb_v;
input    [1:0]         btb_type;
input    [31:0]        pred_target;
input    [1:0]         delayed_PHT;
input    [2:0]         delayed_BHR;
input    [31:0]        if_id_inst_word;
                       //h_d_f_alu
input                  id_ex_memread;
input    [4:0]         id_ex_regrt;
                       //branch target 
input    [31:0]        if_id_plus_4;
                       //h_d_f_br
input                  id_ex_wb_regwrite;
input                  mem_mem_read;
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
output   [31:0]         btb_target_out;
output                  update_btb_target_out;
output   [1:0]          btb_type_out;
output                  update_BP_out;
output                  pred_right_out;
output                  taken;
output   [1:0]          delayed_PHT_out;
output   [2:0]          delayed_BHR_out;
output                  recover_push;
output   [31:0]         recover_push_addr;
output                  recover_pop;
output                  wb_regwrite;
output                  wb_memtoreg;
output                  mem_branch;
output                  mem_memread;
output                  mem_memwrite;
output   [3:0]          ex_aluop;
output   [1:0]          ex_alusrc;
output                  ex_regdst;
output   [31:0]         regread1;
output   [31:0]         regread2;
output   [4:0]          reg_rs;
output   [4:0]          reg_rd;
output   [4:0]          reg_rt;
output                  if_flush;             
output   [1:0]          pc_src;
output                  ll_mem;
output                  sc_mem;
output   [31:0]         sign_extend;
//output   [15:0]          id_inst_lo;

// froword delayed PHT and delayed BHR to if stage
assign   delayed_BHR_out=delayed_BHR;
assign   delayed_PHT_out=delayed_PHT;

//hazard detection for alu
assign stall_pipeline_alu=(id_ex_memread&&(id_ex_regrt==if_id_inst_word[25:21])||(id_ex_regrt==if_id_inst_word[20:16]))?1'b1:1'b0;

//hazard detection for branch target
assign stall_pipeline_br=(   (id_ex_wb_regwrite&&( (ex_dest_reg==if_id_inst_word[25:21]) || (ex_dest_reg==if_id_inst_word[20:16]) ) )   ||
                            (mem_mem_read&&((mem_dest_reg==if_id_inst_word[25:21])||(mem_dest_reg==if_id_inst_word[20:16]))) )?1'b1:1'b0;
//sign-extend
wire    [31:0]  sign_extend;
wire    [15:0]  temp_sign;
assign  temp_sign=if_id_inst_word[15]?16'hffff:16'h0000;
assign  sign_extend={temp_sign,if_id_inst_word[15:0]};
//shift_left_2
wire    [31:0]  shift_left_2;
wire    [31:0]  br_target;
wire    [31:0]  j_target;
wire    [31:0]  jal_target;
wire    [31:0]  jr_target;
assign  shift_left_2={sign_extend[31],sign_extend[28:0],2'b00};
//branch target
assign  br_target=if_id_plus_4+shift_left_2;
assign  j_target={if_id_plus_4[31:28],if_id_inst_word[25:0],2'b00};
assign  jal_target={if_id_plus_4[31:28],if_id_inst_word[25:0],2'b00};
assign  jr_target=regread1;
// inst_fun
//assign  id_inst_lo=if_id_inst_word[15:0];
reg       ex_regdst;
reg       jump;
reg       branch;
reg       memread;
reg       memtoreg;
reg [3:0] ex_aluop;
reg       memwrite;
reg [1:0] ex_alusrc;
reg       regwrite;
reg       ll_mem;
reg       sc_mem;
reg       jal;
reg       jr;
reg       jalr; 
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
  ex_regdst=1'b0;
  jump=1'b0;
  branch=1'b0;
  memread=1'b0;
  memtoreg=1'b0;
  ex_aluop=4'b0000;
  memwrite=1'b0;
  ex_alusrc=2'b00;
  regwrite=1'b0;
  ll_mem=1'b0;
  sc_mem=1'b0;
  jal=1'b0;
  jr=1'b0;
  jalr=1'b0;
  case(if_id_inst_word[31:26])
    R_type:
      begin
        if(if_id_inst_word[5:0]==6'b001000)
          begin
            jr=1'b1;
          end
      else if(if_id_inst_word[5:0]==6'b001001)
        begin
          jalr=1'b1;
        end
        ex_regdst=1'b1;
        regwrite=1'b1;
        ex_aluop=4'b0010;
      end
    lw_type:
      begin
        ex_alusrc=2'b01;
        memtoreg=1'b1;
        regwrite=1'b1;
        memread=1'b1;
      end
    ll_type:
      begin
        ex_alusrc=2'b01;
        memtoreg=1'b1;
        regwrite=1'b1;
        memread=1'b1;
        ll_mem=1'b1;
      end
    sw_type:
      begin
        ex_alusrc=2'b01;
        memwrite=1'b1;
      end
    sc_type:
      begin
        ex_alusrc=2'b01;
        memwrite=1'b1;
        sc_mem=1'b1;
      end
    //branch_type
    beq_type:
      begin
        branch=1'b1;
        ex_alusrc=2'b01;
        ex_aluop=4'b0001;
      end
    bne_type:
      begin
        branch=1'b1;
        ex_alusrc=2'b01;
        ex_aluop=4'b1110;
      end
    blez_type:
      begin
        branch=1'b1;
        ex_alusrc=2'b01;
        ex_aluop=4'b1010;
      end
    bgtz_type:
      begin
        branch=1'b1;
        ex_alusrc=2'b01;
        ex_aluop=4'b1011;
      end
    bltz_type:
      begin
        branch=1'b1;
        ex_alusrc=2'b01;
        ex_aluop=4'b1100;
      end
    bgez_type:
      begin
        branch=1'b1;
        ex_alusrc=2'b01;
        ex_aluop=4'b1101;
      end
    //j_type
    jump_type:
      begin
        jump=1'b1;
        ex_aluop=4'b1001;
      end
    jal_type:
      begin
        jal=1'b1;
        ex_aluop=4'b1001;
      end
    ///I-type
    addiu_type:
      begin
        ex_aluop=4'b0000;
        ex_alusrc=2'b01;
        regwrite=1'b1;
      end
    slti_type:
      begin
        ex_aluop=4'b0011;
        ex_alusrc=2'b01;
        regwrite=1'b1;
      end
    sltiu_type:
      begin
        ex_aluop=4'b0100;
        ex_alusrc=2'b01;
        regwrite=1'b1;
      end
    andi_type:
      begin
        ex_aluop=4'b0101;
        ex_alusrc=2'b10;
        regwrite=1'b1;
      end
    ori_type:
      begin
        ex_aluop=4'b0110;
        ex_alusrc=2'b10;
        regwrite=1'b1;
      end
    xori_type:
      begin
        ex_aluop=4'b0111;
        ex_alusrc=2'b10;
        regwrite=1'b1;
      end
    lui_type:
      begin
        ex_aluop=4'b1000;
        regwrite=1'b1;
      end
    
    //
 endcase
end
 
//forwarding_unit_id
reg  [1:0]  forward_a;
reg  [1:0]  forward_b;
always@(*)
begin
    //forward_a
  if(mem_wb_regwrite&&(mem_wb_regrd!=5'b00000)&&   !(ex_mem_regwrite&&(ex_mem_regrd!=5'b00000)&&(ex_mem_regrd!=reg_rs)) &&(mem_wb_regrd==reg_rs))
    forward_a=2'b01;
else if(ex_mem_regwrite&&(ex_mem_regrd!=5'b00000)&&(ex_mem_regrd==reg_rs))
    forward_a=2'b10;
else
    forward_a=2'b00;
    
    //fotward_b
  if(mem_wb_regwrite&&(mem_wb_regrd!=5'b00000)&&   !(ex_mem_regwrite&&(ex_mem_regrd!=5'b00000)&&(ex_mem_regrd!=reg_rt)) &&(mem_wb_regrd==reg_rt))
    forward_a=2'b01;
else if(ex_mem_regwrite&&(ex_mem_regrd!=5'b00000)&&(ex_mem_regrd==reg_rt))
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

//function for generating update infos to btb ,pht and ras of if stage 
wire    jr_valid;         
assign  jr_valid=(!(id_ex_memread&&id_ex_regrt==reg_rs))&&(!(mem_mem_read&&mem_dest_reg==reg_rs))?1'b1:1'b0;
reg        update_btb_target_out;
reg [31:0] btb_target_out;
reg [1:0]  btb_type_out;
reg        update_BP_out;
reg        pred_right_out;
reg        taken;
always@(*)
begin
  //default values
  taken=1'b0;
  update_btb_target_out=1'b0;
  btb_target_out=br_target;
  btb_type_out=br_btb_type;
  update_BP_out=1'b0;
  pred_right_out=1'b0;
  //when  decode find the inst is a jr 
  if(jr&&jr_valid&&(btb_type==jr_btb_type&&pred_target!=jr_target&&btb_v||btb_type!=jr_btb_type||btb_v==1'b0))
    begin
      update_btb_target_out=1'b1;
      btb_target_out=jr_target;
      btb_type_out=jr_btb_type;
      update_BP_out=1'b1;
      taken=1'b1;
      if(delayed_PHT[1]==1'b1)
        pred_right_out=1'b1;
      else
        pred_right_out=1'b0;
    end
    //when  decode find the inst is a j
 else if(jump&&(btb_type==j_btb_type&&pred_target!=j_target&&btb_v||btb_type!=j_btb_type||btb_v==1'b0))
    begin
      update_btb_target_out=1'b1;
      btb_target_out=j_target;
      btb_type_out=j_btb_type;
      update_BP_out=1'b1;
      taken=1'b1;
      if(delayed_PHT[1]==1'b1)
        pred_right_out=1'b1;
      else
        pred_right_out=1'b0;
    end
    //when  decode find the inst is a jal
  else if(jal&&(btb_type==jal_btb_type&&pred_target!=jal_target&&btb_v||btb_type!=jal_btb_type||btb_v==1'b0))
    begin
      update_btb_target_out=1'b1;
      btb_target_out=jal_target;
      btb_type_out=jal_btb_type;
      update_BP_out=1'b1;
      taken=1'b1;
      if(delayed_PHT[1]==1'b1)
        pred_right_out=1'b1;
      else
        pred_right_out=1'b0;
    end
    //when  decode find the inst is a br
  else if(branch&&(btb_type==br_btb_type&&pred_target!=br_target&&btb_v||btb_type!=br_btb_type||btb_v==1'b0))
    begin
      update_btb_target_out=1'b1;
      btb_target_out=br_target;
      btb_type_out=br_btb_type;
      update_BP_out=1'b1;
      taken=1'b1;
      if(delayed_PHT[1]==1'b1)
        pred_right_out=1'b1;
      else
        pred_right_out=1'b0;
    end
    //when  decode find the inst is not a branch or jump  
   else if(!jump&&btb_type!=j_btb_type||!jal&&btb_type!=jal_btb_type
         ||!jr&&btb_type!=jr_btb_type||!branch&&btb_type!=br_btb_type)
         begin
           update_BP_out=1'b1;
           pred_right_out=1'b0;
         end
end

// function of recovering something wrong happened in RAS
reg               recover_push;
reg  [31:0]       recover_push_addr;
reg               recover_pop;
always@(*)
begin
  if(!jal&&btb_type==jal_btb_type&&btb_v)
    begin
      recover_pop=1'b1;
    end
else if(!jr&&btb_type==jr_btb_type&&btb_v)
  begin
     recover_push=1'b1;
     recover_push_addr=pred_target;
   end
 else
   begin
     recover_pop=1'b0;
     recover_push=1'b0;
     recover_push_addr=pred_target;
   end
end
assign  src1_eq_src2=cmp_src1==cmp_src2?1'b1:1'b0;
assign  pc_src=(src1_eq_src2&&branch==1'b1)?2'b01:jump?2'b10:2'b00;  
assign  if_flush=|pc_src;
endmodule
