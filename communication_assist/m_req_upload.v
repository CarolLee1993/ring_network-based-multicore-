/// date:2016/3/9
/// engineer: ZhaiShaoMin 
module    m_req_upload(//input
                             clk,
                             rst,
                             v_flits_in,
                             out_req_fifo_rdy_in,
                             en_inv_ids,
                             inv_ids_in,
                             flits_max_in,
                             head_flit,
                             addrhi,
                             addrlo,
              //               datahi1,
              //               datalo1,
              //               datahi2,
              //               datalo2,
              //               datahi3,
              //               datalo3,
              //               datahi4,
              //               datalo4,
                             //output
                             ctrl_out,
                             flit_out,
                             fsm_state,
                             v_flit_to_req_fifo
                             );
// input
input                                   clk;
input                                   rst;
input                                   v_flits_in;
input                                   out_req_fifo_rdy_in;
input                                   en_inv_ids;
input        [3:0]                      inv_ids_in;
input        [3:0]                      flits_max_in;
input        [15:0]                     head_flit;
input        [15:0]                     addrhi;
input        [15:0]                     addrlo;
/*input        [15:0]                     datahi1;
//input        [15:0]                     datalo1;
input        [15:0]                     datahi2;
input        [15:0]                     datalo2;
input        [15:0]                     datahi3;
input        [15:0]                     datalo3;
input        [15:0]                     datahi4;
input        [15:0]                     datalo4;
  */                           
//output
output       [1:0]                      ctrl_out;
output       [15:0]                     flit_out;
output       [1:0]                      fsm_state;
output                                  v_flit_to_req_fifo;


wire      [3:0]        inv_ids_reg_net;
wire      [1:0]        sel_cnt_invs_net;
wire      [15:0]       flit_out_net;
wire                   cnt_eq_max_net;
wire                   cnt_invs_eq_3_net;
wire                   cnt_eq_0_net;
wire                   dest_sel_net;
wire                         clr_max_net;
wire                         clr_inv_ids_net;
wire                         clr_sel_cnt_inv_net;
wire                         clr_sel_cnt_net;
wire                         inc_sel_cnt_net;
wire                         inc_sel_cnt_inv_net;
wire                         en_flit_max_in_net;
wire                         en_inv_ids_net;
FSM_upload_flit   req_fsm_dut (// input
                              .clk(clk),
                              .rst(rst),
                              .en_for_reg(v_flits_in),
                              .out_req_fifo_rdy(out_req_fifo_rdy_in),
                              .cnt_invs_eq_3(cnt_invs_eq_3_net),
                              .cnt_eq_max(cnt_eq_max_net),
                              .head_flit(head_flit),
                              .inv_ids_reg(inv_ids_reg_net),
                              .sel_cnt_invs(sel_cnt_invs_net),
                              .sel_cnt_eq_0(cnt_eq_0_net),
                              // output
                              .en_inv_ids(en_inv_ids_net),
                              .en_flit_max_in(en_flit_max_in_net),
                              .inc_sel_cnt_invs(inc_sel_cnt_inv_net),
                              .inc_sel_cnt(inc_sel_cnt_net),
                              .ctrl(ctrl_out),
                              .clr_max(clr_max_net),
                              .clr_inv_ids(clr_inv_ids_net),
                              .clr_sel_cnt_inv(clr_sel_cnt_inv_net),
                              .clr_sel_cnt(clr_sel_cnt_net),
                              .dest_sel(dest_sel_net),
                              .fsm_state_out(fsm_state),
                              .en_flit_out(v_flit_to_req_fifo)
                                       );
upload_datapath   req_datapath_dut(// input
                         .clk(clk),
                         .rst(rst),
                         .clr_max(clr_max_net),
                         .clr_inv_ids(clr_inv_ids_net),
                         .clr_sel_cnt_inv(clr_sel_cnt_inv_net),
                         .clr_sel_cnt(clr_sel_cnt_net),
                         .inc_sel_cnt(inc_sel_cnt_net),
                         .inc_sel_cnt_inv(inc_sel_cnt_inv_net),
                         .en_flit_max_in(en_flit_max_in_net),
                         .en_for_reg(v_flits_in),
                         .en_inv_ids(en_inv_ids),
                         .inv_ids_in(inv_ids_in),
                         .dest_sel(dest_sel_net),
                         .flit_max_in(flits_max_in),
                         .head_flit(head_flit),
                         .addrhi(addrhi),
                         .addrlo(addrlo),
               /*          .datahi1(datahi1),
                         .datalo1(datalo1),
                         .datahi2(datahi2),
                         .datalo2(datalo2),
                         .datahi3(datahi3),
                         .datalo3(datalo3),
                         .datahi4(datahi4),
                         .datalo4(datalo4),   */
                         //output 
                         .flit_out(flit_out),
                         .cnt_eq_max(cnt_eq_max_net),
                         .cnt_invs_eq_3(cnt_invs_eq_3_net),
                         .cnt_eq_0(cnt_eq_0_net),
                         .inv_ids_reg_out(inv_ids_reg_net),
                         .sel_cnt_invs_out(sel_cnt_invs_net)
                         
                                    );
  endmodule






















/*//input
                        clk,
                        rst,
                        m_flits_req,
                        v_m_flits_req,
                        req_fifo_rdy,
                        //output
                        m_flit_out,
                        v_m_flit_out,
                        m_req_upload_state
                        );
//input
input                         clk;
input                         rst;
input       [47:0]            m_flits_req;
input                         v_m_flits_req;
input                         req_fifo_rdy;
//output
output      [15:0]             m_flit_out;
output                         v_m_flit_out;
output                         m_req_upload_state;

//parameter 
parameter    m_req_upload_idle=1'b0;
parameter    m_req_upload_busy=1'b1;

//reg          m_req_nstate; 
reg          m_req_state;
reg  [47:0]  m_req_flits;
reg  [1:0]   sel_cnt;
reg          v_m_flit_out;
reg          fsm_rst;
reg          next;
reg          en_flits_in;
reg          inc_cnt;
assign m_req_upload_state=m_req_state;
always@(*)
begin
  //default value
 // ic_req_nstate=ic_req_state;
  v_m_flit_out=1'b0;
  inc_cnt=1'b0;
  fsm_rst=1'b0;
  en_flits_in=1'b0;
  next=1'b0;
  
  case(m_req_state)
    m_req_upload_idle:
       begin
         if(v_m_flits_req)
           begin
             en_flits_in=1'b1;
             next=1'b1;
           end
       end
    m_req_upload_busy:
       begin
         if(req_fifo_rdy)
           begin
             if(sel_cnt==2'b10)
               fsm_rst=1'b1;
             inc_cnt=1'b1;
             v_m_flit_out=1'b1;
           end
       end
    endcase
end

// fsm state
always@(posedge clk)
begin
  if(rst||fsm_rst)
    m_req_state<=1'b0;
else if(next)
    m_req_state<=1'b1;
end
// flits regs
always@(posedge clk)
begin
  if(rst||fsm_rst)
    m_req_flits<=48'h0000;
  else if(en_flits_in)
    m_req_flits<=m_flits_req;
end
reg  [15:0]  m_flit_out;
always@(*)
begin
  case(sel_cnt)
    2'b00:m_flit_out=m_req_flits[47:32];
    2'b01:m_flit_out=m_req_flits[31:16];
    2'b10:m_flit_out=m_req_flits[15:0];
    default:m_flit_out=m_req_flits[47:32];
  endcase
end

///sel_counter
always@(posedge clk)
begin
  if(rst||fsm_rst)
    sel_cnt<=2'b00;
  else if(inc_cnt)
    sel_cnt<=sel_cnt+1;
end

endmodule  */