//date:2016/3/12
//engineer:ZhaiShaoMin
//module name :excution stage of core
module   core_ex(//input
                  alusrc_a,
                  alusrc_b,
                  aluop,
                 // inst_lo,
                  regdst,
                  alusrc,
                  id_ex_rs,
                  id_ex_rt,
                  id_ex_rd,
                  mem_regwrite,
                  wb_regwrite,
                  mem_regrd,
                  wb_regrd,
                  wb_reg_data,
                  mem_reg_data,
                  id_ex_sign_extend,
                  //output
                  alu_result,
                  data_to_mem,
                  ex_dest_rd,
                  zero
                  );
//parameter 
parameter sll_fun=6'b000000;
parameter srl_fun=6'b000010;
parameter sra_fun=6'b000011;
parameter sllv_fun=6'b000100;
parameter srlv_fun=6'b000110;
parameter srav_fun=6'b000111;

parameter addu_fun =6'b100001;
parameter subu_fun =6'b100011;
parameter and_fun  =6'b100100;
parameter or_fun  =6'b100101;
parameter xor_fun =6'b100110;
parameter nor_fun   =6'b100111;
parameter sltu_fun  =6'b101011;

//op of i_type
parameter slti_op=4'b0011;
parameter sltiu_op=4'b0100;
parameter andi_op=4'b0101;
parameter ori_op=4'b0110;
parameter xori_op=4'b0111;
parameter lui_op=4'b1000;

//input
input   [31:0]                alusrc_a;
input   [31:0]                alusrc_b;
input   [3:0]                 aluop;
//input   [5:0]                 inst_fun;
input                         regdst;
input   [1:0]                 alusrc;
input   [4:0]                 id_ex_rs;
input   [4:0]                 id_ex_rt;
input   [4:0]                 id_ex_rd;
input                         mem_regwrite;
input                         wb_regwrite;
input   [4:0]                 mem_regrd;
input   [4:0]                 wb_regrd;
input   [31:0]                mem_reg_data;
input   [31:0]                wb_reg_data;
input   [31:0]                id_ex_sign_extend;
//output
output   [31:0]               alu_result;
output   [31:0]               data_to_mem;
output   [4:0]                ex_dest_rd;
output                        zero;

// mux alu_operand_src for alu
wire   [31:0] alu_src1;
wire   [31:0] alu_src2;
//forwarding_unit_for_alu_src_operand
reg  [1:0]  forwarda;
reg  [1:0]  forwardb;
//alu 
 reg   [31:0]  alu_result;
 reg           zero;
 reg   [31:0]  alu_temp;
 wire  [31:0]  shift_src;
 wire  [31:0]  zero_ext;
 wire  [31:0]  temp_shift;
 wire  [31:0]  alu_src_reg_imm;
 
always@(*)
begin
  //default values
  if(wb_regwrite&&(wb_regrd!=5'b00000)&&!(mem_regwrite&&(mem_regrd!=5'b00000)&&(mem_regrd!=id_ex_rs))&&(wb_regrd==id_ex_rs))
       forwarda=2'b10;
else if(mem_regwrite&&(mem_regrd!=5'b00000)&&(mem_regrd==id_ex_rs))
       forwarda=2'b01;
else
       forwarda=2'b00;
   
   if(wb_regwrite&&(wb_regrd!=5'b00000)&&!(mem_regwrite&&(mem_regrd!=5'b00000)&&(mem_regrd!=id_ex_rt))&&(wb_regrd==id_ex_rt))
       forwardb=2'b10;
else if(mem_regwrite&&(mem_regrd!=5'b00000)&&(mem_regrd==id_ex_rt))
       forwardb=2'b01;
else
       forwardb=2'b00;
end

//forward alu_src


assign  alu_src1=(forwarda==2'b10)? wb_reg_data: ((forwarda==2'b01)? mem_reg_data:alusrc_a);
assign  alu_src2=(forwardb==2'b10)? wb_reg_data: ((forwardb==2'b01)? mem_reg_data:alusrc_b);
assign  alu_src_reg_imm=(alusrc==2'b00)?alu_src2:(alusrc==2'b01)?id_ex_sign_extend:zero_ext;

// mux dest_reg for inst intended to write reg
assign  ex_dest_rd=regdst?id_ex_rd:id_ex_rt;
assign  data_to_mem=alu_src2;
reg       shamt_rs;
reg [3:0] alu_ctrl;
// alu_control unit
always@(*)
begin
  //default values
   shamt_rs=1'b0;  // 0:shamt 1:rs as a shift distence of shift inst
   alu_ctrl=4'b0000;
  case(aluop)
    4'b0000:
    //lw,sw
      begin
        alu_ctrl=4'b0000;
      end
    4'b0001:
    //branch eq
      begin
        alu_ctrl=4'b1111;
      end
    4'b0010:
    // R_type according to fun field
     begin
       case(id_ex_sign_extend[5:0])
         //add
         6'b100000:alu_ctrl=4'b0000;
         //sub
         6'b100010:alu_ctrl=4'b0001;
         //and
         6'b100100:alu_ctrl=4'b0010;
         //or
         6'b100101:alu_ctrl=4'b0011;
         //set on less than
         6'b101010:alu_ctrl=4'b0100;
         //R_type 
         sll_fun:
           begin
             alu_ctrl=4'b0101;
           end
         srl_fun:
         begin
           alu_ctrl=4'b0110;
           end
         sra_fun:
         begin
           alu_ctrl=4'b0111;
           end
         sllv_fun:
         begin
           alu_ctrl=4'b0101;
           shamt_rs=1'b1;
           end
         srlv_fun:
         begin
           alu_ctrl=4'b0110;
           shamt_rs=1'b1;
           end
         srav_fun:
         begin
           alu_ctrl=4'b0111;
           shamt_rs=1'b1;
           end
         addu_fun:
         begin
           alu_ctrl=4'b0000;
           end
         subu_fun:
         begin
           alu_ctrl=4'b0001;
           end
         xor_fun:
         begin
           alu_ctrl=4'b1000;
           end
         nor_fun:
         begin
           alu_ctrl=4'b1001;
           end
         sltu_fun:
         begin
           alu_ctrl=4'b0100;
           end
      endcase
    end
  slti_op:alu_ctrl=4'b0100;
  sltiu_op:alu_ctrl=4'b0100;
  andi_op:alu_ctrl=4'b0001;
  ori_op:alu_ctrl=4'b0011;
  xori_op:alu_ctrl=4'b1000;
  lui_op:alu_ctrl=4'b1010;
   endcase
 end     
 
 
 
 assign  temp_shift={alu_src_reg_imm[31],31'b0000000000000000000000000000000};
 assign  zero_ext={16'h0000,id_ex_sign_extend[15:0]};
 assign  shift_src=shamt_rs?{27'h0000,id_ex_sign_extend[10:6]}:alu_src1;
 always@(*)
 begin
   alu_result=32'h0001;
   zero=1'b0;
   alu_temp=32'h0000;
   case(alu_ctrl)
     //add
     4'b0000:alu_result=alu_src1+alu_src_reg_imm;
     //sub
     4'b0001:
        begin
          alu_result=alu_src1-alu_src_reg_imm;
          if(alu_result==32'h0000)
            zero=1'b1;
        end
     //and
     4'b0010:alu_result=alu_src1&alu_src_reg_imm;
     //or
     4'b0011:alu_result=alu_src1|alu_src_reg_imm;
     //set on less than
     4'b0100:
        begin
          alu_temp=alu_src1-alu_src_reg_imm;
          if(alu_temp[31]==1'b0)
              alu_result=32'h0000;
        end
     //sll
     4'b0101:alu_result=alu_src_reg_imm<<shift_src;
     //srl
     4'b0110:alu_result=alu_src_reg_imm>>shift_src;
     //sra
     4'b0111:alu_result=(alu_src_reg_imm>>shift_src)|(temp_shift>>shift_src);
     //xor
     4'b1000:alu_result=alu_src1^alu_src_reg_imm;
     //nor
     4'b1001:alu_result=!(alu_src1|alu_src_reg_imm);
     //lui
     4'b1010:alu_result={id_ex_sign_extend[15:0],16'h0000};
   endcase
end
endmodule