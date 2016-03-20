/// date:2016/3/3
/// engineer:ZhaiShaoMin
/// module name:upload_fsm_datapath
/// module function:combine fsm of upload and datapath of upload
module   upload_fsm_datapath(//input
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

FSM_upload_flit   req_fsm_dut (// input
                              .clk(clk),
                              .rst(rst),
                              .en_for_reg(v_flits_in),
                              .out_req_fifo_rdy(out_req_fifo_rdy_in),
                              .cnt_invs_eq_3(cnt_invs_eq_3),
                              .cnt_eq_max(cnt_eq_max),
                              .head_flit(head_flit),
                              .inv_ids_reg(inv_ids_reg_net),
                              .sel_cnt_invs(sel_cnt_invs_net),
                              .sel_cnt_eq_0(sel_cnt_eq_0_net),
                              // output
                              .en_inv_ids(en_inv_ids_net),
                              .en_flit_max_in(en_flit_max_in_net),
                              .inc_sel_cnt_invs(inc_sel_cnt_invs_net),
                              .inc_sel_cnt(inc_sel_cnt_net),
                              .ctrl(ctrl_out),
                              .clr_max(clr_max_net),
                              .clr_inv_ids(clr_inv_ids),
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
                         .flit_out(flit_out_net),
                         .cnt_eq_max(cnt_eq_max_net),
                         .cnt_invs_eq_3(cnt_invs_eq_3_net),
                         .cnt_eq_0(cnt_eq_0_net),
                         .inv_ids_reg_out(inv_ids_reg_net),
                         .sel_cnt_invs_out(sel_cnt_invs_net)
                         
                                    );
  endmodule