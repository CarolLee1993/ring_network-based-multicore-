//date:2016/3/12
//engineer:ZhaiShaoMin
//module name :excution stage of core
module   core_ex(//input
                  alusrc_a,
                  alusrc_b,
                  aluop,
                  inst_fun,
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
//input
input   [31:0]                alusrc_a;
input   [31:0]                alusrc_b;
input   [1:0]                 aluop;
input   [5:0]                 inst_fun;
input                         regdst;
input                         alusrc;
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
assign  alu_src_reg_imm=alusrc?id_ex_sign_extend:alu_src2;

// mux dest_reg for inst intended to write reg
assign  ex_dest_rd=regdst?id_ex_rd:id_ex_rt;
assign  data_to_mem=alu_src2;

reg [3:0] alu_ctrl;
// alu_control unit
always@(*)
begin
  //default values
   alu_ctrl=4'b0010;
  case(aluop)
    2'b00:
    //lw,sw
      begin
        alu_ctrl=4'b0010;
      end
    2'b01:
    //branch eq
      begin
        alu_ctrl=4'b0110;
      end
    2'b10:
    // R_type according to fun field
     begin
       case(inst_fun)
         //add
         6'b100000:alu_ctrl=4'b0010;
         //sub
         6'b100010:alu_ctrl=4'b0110;
         //and
         6'b100100:alu_ctrl=4'b0000;
         //or
         6'b100101:alu_ctrl=4'b0001;
         //set on less than
         6'b101010:alu_ctrl=4'b0111;
         default:alu_ctrl=4'b0010;
      endcase
    end
   endcase
 end      
 //alu 
 reg   [31:0]  alu_result;
 reg           zero;
 reg   [31:0]  alu_temp;
 always@(*)
 begin
   alu_result=32'h0001;
   zero=1'b0;
   alu_temp=32'h0000;
   case(alu_ctrl)
     //add
     4'b0010:alu_result=alu_src1+alu_src_reg_imm;
     //sub
     4'b0110:
        begin
          alu_result=alu_src1-alu_src_reg_imm;
          if(alu_result==32'h0000)
            zero=1'b1;
        end
     //and
     4'b0000:alu_result=alu_src1&alu_src_reg_imm;
     //or
     4'b0001:alu_result=alu_src1|alu_src_reg_imm;
     //set on less than
     4'b0111:
        begin
          alu_temp=alu_src1-alu_src_reg_imm;
          if(alu_temp[31]==1'b0)
              alu_result=32'h0000;
        end
    endcase
end
endmodule