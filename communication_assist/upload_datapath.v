/// date :2016/3/3
/// engineer :ZhaiShaoMin
/// module name: data path of FSM_upload_flit
/// module function : combination of needed state elment,which are controled by FSM_upload_flit
module   upload_datapath(// input
                         clk,
                         rst,
                         clr_max,
                         clr_inv_ids,
                         clr_sel_cnt_inv,
                         clr_sel_cnt,
                         inc_sel_cnt,
                         inc_sel_cnt_inv,
                         en_flit_max_in,
                         en_for_reg,
                         en_inv_ids,
                         inv_ids_in,
                         dest_sel,
                         flit_max_in,
                         head_flit,
                         addrhi,
                         addrlo,
            /*             datahi1,
                         datalo1,
                         datahi2,
                         datalo2,
                         datahi3,
                         datalo3,
                         datahi4,
                         datalo4,   */
                         //output 
                         flit_out,
                         cnt_eq_max,
                         cnt_invs_eq_3,
                         cnt_eq_0,
                         inv_ids_reg_out,
                         sel_cnt_invs_out
                         );
                         
                         
   ///////////////////////////////////////////////////////////////////////////////////
   ///////////////////////////////////////////////////////////////////////////////////
   ///////////////////Datapath Unit///////////////////////////////////////////////////
   input                                 clk;
   input                                 rst;
   input           [3:0]                 inv_ids_in;   // invreq vector used for generating every invreqs
   input                                 en_for_reg;   // enable for all kinds of flits regs
   input           [15:0]                head_flit;
   input           [15:0]                addrhi;
   input           [15:0]                addrlo;
/*   input           [15:0]                datahi1;
   input           [15:0]                datalo1;
   input           [15:0]                datahi2;
   input           [15:0]                datalo2;
   input           [15:0]                datahi3;
   input           [15:0]                datalo3;
   input           [15:0]                datahi4;
   input           [15:0]                datalo4; */
   input                                 clr_max;
   input                                 clr_inv_ids;
   input                                 clr_sel_cnt_inv;
   input                                 clr_sel_cnt;
   input                                 inc_sel_cnt;
   input                                 inc_sel_cnt_inv;
   input                                 en_for_reg;
   input                                 en_inv_ids;
   input           [3:0]                 inv_ids_in;
   input           [3:0]                 flit_max_in;
   input                                 en_flit_max_in;
   input                                 dest_sel;
   
   // output

   output          [15:0]                flit_out;
   output                                cnt_eq_max;
   output                                cnt_invs_eq_3;
   output                                cnt_eq_0;
   output          [3:0]                 inv_ids_reg_out;
   output          [1:0]                 sel_cnt_invs_out;
 

// register max_number of flits of a message
reg [3:0]      flits_max;
always@(posedge clk)
begin
  if(rst||clr_max)
    flits_max<=4'b0000;
  else if(en_flit_max_in)
    flits_max<=flit_max_in;
end

// register current needed invreqs vector
reg [3:0]      inv_ids_reg;
always@(posedge clk)
begin
  if(rst||clr_inv_ids)
    inv_ids_reg<=4'b0000;
  else if(en_inv_ids)
    inv_ids_reg<=inv_ids_in;
end

wire     [3:0]  inv_ids_reg_out;
assign   inv_ids_reg_out=inv_ids_reg;
// selection counter for mux flit among 11 flit regs
reg [3:0]   sel_cnt;
always@(posedge clk)
begin
  if(rst||clr_sel_cnt)
    sel_cnt<=4'b0000;
  else if(inc_sel_cnt)
    sel_cnt<=sel_cnt+1;
end

// selection counter for invreqs_vector generating different invreqs with different dest id
reg [1:0] sel_cnt_invs;
always@(posedge clk)
begin
  if(rst||clr_sel_cnt_inv)
    sel_cnt_invs<=2'b00;
  else if(inc_sel_cnt_inv)
    sel_cnt_invs<=sel_cnt_invs+1;
end

wire     [1:0]    sel_cnt_invs_out;
assign   sel_cnt_invs_out=sel_cnt_invs;

wire    cnt_eq_0;
assign  cnt_eq_0=(sel_cnt==4'b0000);

wire cnt_eq_max;
assign  cnt_eq_max=(sel_cnt==flits_max);

wire    cnt_invs_eq_3;
assign  cnt_invs_eq_3=(sel_cnt_invs==2'b11);


   reg   [15:0]      head_flit_reg;
   reg   [15:0]      addrhi_reg;
   reg   [15:0]      addrlo_reg;
   /*reg   [15:0]      datahi1_reg;
   reg   [15:0]      datalo1_reg;
   reg   [15:0]      datahi2_reg;
   reg   [15:0]      datalo2_reg;
   reg   [15:0]      datahi3_reg;
   reg   [15:0]      datalo3_reg;
   reg   [15:0]      datahi4_reg;
   reg   [15:0]      datalo4_reg; */
   
   always@(posedge clk)
   begin
     if(rst)
       begin
         head_flit_reg<=16'h0000;
         addrhi_reg<=16'h0000;
         addrlo_reg<=16'h0000;
     /*    datahi1_reg<=16'h0000;
         datalo1_reg<=16'h0000;
         datahi2_reg<=16'h0000;
         datalo2_reg<=16'h0000;
         datahi3_reg<=16'h0000;
         datalo3_reg<=16'h0000;
         datahi4_reg<=16'h0000;
         datalo4_reg<=16'h0000;   */
       end
  else if(en_for_reg)
       begin
         head_flit_reg<=head_flit;
         addrhi_reg<=addrhi;
         addrlo_reg<=addrlo;
  /*      datahi1_reg<=datahi1;
         datalo1_reg<=datahi1;
         datahi2_reg<=datahi1;
         datalo2_reg<=datalo2;
         datahi3_reg<=datahi3;
         datalo3_reg<=datalo3;
         datahi4_reg<=datahi4;
         datalo4_reg<=datalo4;    */ 
       end
end

// dest selection if 0 :scORinvreqs ;1 :wbORflushreqs
wire [1:0]  dest_seled_id;
assign dest_seled_id=dest_sel?head_flit_reg[15:14]:sel_cnt_invs;

// select flit outputting  to req fifo
reg   [15:0]   flit_seled_out;

always@(*)
begin
 // if(en_sel)
//    begin
      case(sel_cnt)
        4'b0000:flit_seled_out={dest_seled_id,head_flit_reg[13:0]};
        4'b0001:flit_seled_out=addrhi_reg;
        4'b0010:flit_seled_out=addrlo_reg;
       /* 4'b0011:flit_seled_out=datahi1_reg;
        4'b0100:flit_seled_out=datalo1_reg;
        4'b0101:flit_seled_out=datahi2_reg;
        4'b0110:flit_seled_out=datalo2_reg;
        4'b0111:flit_seled_out=datahi3_reg;
        4'b1000:flit_seled_out=datalo3_reg;
        4'b1001:flit_seled_out=datahi4_reg;
        4'b1010:flit_seled_out=datalo4_reg; */
        default:flit_seled_out=head_flit_reg;
      endcase 
 //   end 
end

endmodule