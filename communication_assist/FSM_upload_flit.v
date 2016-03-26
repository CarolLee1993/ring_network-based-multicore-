// date:2016/3/1
// engineer: ZhaiShaoMin
// module name:FSM_unload_flit
//transfer flit of msg from cache or mem to network local out fifos 
//                         parallel msg  to  serial flits stream  for transfering on ring network
module    FSM_upload_flit(// input
                              clk,
                              rst,
                              en_for_reg,
                              out_req_fifo_rdy,
                              cnt_invs_eq_3,
                              cnt_eq_max,
                              head_flit,
                              inv_ids_reg,
                              sel_cnt_invs,
                              sel_cnt_eq_0,
                              // output
                              en_inv_ids,
                              en_flit_max_in,
                              inc_sel_cnt_invs,
                              inc_sel_cnt,
                              ctrl,
                              clr_max,
                              clr_inv_ids,
                              clr_sel_cnt_inv,
                              clr_sel_cnt,
                              dest_sel,
                              fsm_state_out,
                              en_flit_out
                              );
  //input
   input                                 clk;
   input                                 rst;
   input                                 out_req_fifo_rdy;   // enable for inv_ids reg
   input                                 en_for_reg;   // enable for all kinds of flits regs
   input                                 cnt_invs_eq_3;
   input                                 cnt_eq_max;
   input          [15:0]                 head_flit;
   input          [3:0]                  inv_ids_reg;
   input          [1:0]                  sel_cnt_invs;
   input                                 sel_cnt_eq_0;
   // output
   output                                en_inv_ids;
   output                                en_flit_max_in;
   output                                inc_sel_cnt_invs;
   output                                inc_sel_cnt;
   output        [1:0]                   ctrl;
   output                                clr_max;
   output                                clr_inv_ids;
   output                                clr_sel_cnt_inv;
   output                                clr_sel_cnt;
   output                                dest_sel;
   output          [1:0]                 fsm_state_out;
   output                                en_flit_out;
   
///  parameter    for cmd
parameter        shreq_cmd=5'b00000;
parameter        exreq_cmd=5'b00001;
parameter        SCexreq_cmd=5'b00010;
parameter        instreq_cmd=5'b00110;
parameter        wbreq_cmd=5'b00011;
parameter        invreq_cmd=5'b00100;
parameter        flushreq_cmd=5'b00101;
parameter        SCinvreq_cmd=5'b00110;
parameter        wbrep_cmd=5'b10000;
parameter        C2Hinvrep_cmd=5'b10001;
parameter        flushrep_cmd=5'b10010;
parameter        ATflurep_cmd=5'b10011;
parameter        shrep_cmd=5'b11000;
parameter        exrep_cmd=5'b11001;
parameter        SH_exrep_cmd=5'b11010;
parameter        SCflurep_cmd=5'b11100;
parameter        instrep=5'b10100;
parameter        C2Cinvrep_cmd=5'b11011;   
///////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////CONTROL UNIT/////////////////////////////////////////////////
parameter  upload_idle=2'b00;
parameter  upload_scORinvreqs=2'b01;
parameter  upload_wbORflushreqs=2'b10;

reg  [1:0]   upload_rstate;
reg  [1:0]   upload_nstate;
// update FSM
always@(posedge clk)
begin
  if(rst)
    upload_rstate<=2'b00;
  else 
    upload_rstate<=upload_nstate;
end

assign fsm_state_out=upload_rstate;

reg          en_inv_ids;
reg          en_flit_max_in;
reg          inc_sel_cnt_invs;
reg          inc_sel_cnt;
reg  [1:0]   ctrl;
reg          clr_max;
reg          clr_inv_ids;
reg          clr_sel_cnt_inv;
reg          clr_sel_cnt;
reg          dest_sel;
reg          en_flit_out;

// next state function
always@(*)
begin
  //default signals 
  upload_nstate=upload_idle;
  en_inv_ids=1'b0;
  en_flit_max_in=1'b0;
  inc_sel_cnt_invs=1'b0;
  inc_sel_cnt=1'b0;
  ctrl=2'b00;
  clr_max=1'b0;
  clr_inv_ids=1'b0;
  clr_sel_cnt_inv=1'b0;
  clr_sel_cnt=1'b0;
  dest_sel=1'b0;
  en_flit_out=1'b0;
  case(upload_rstate)
    upload_idle:
      begin
        if(en_for_reg&&(head_flit[9:5]==invreq_cmd||head_flit[9:5]==SCinvreq_cmd))
          begin
            upload_nstate=upload_scORinvreqs;
            en_inv_ids=1'b1;
          end
        if(en_for_reg&&(head_flit[9:5]==wbreq_cmd||head_flit[9:5]==flushreq_cmd))
          upload_nstate=upload_wbORflushreqs;
          
        en_flit_max_in=1'b1;
      end
    upload_scORinvreqs:
      begin
        if(out_req_fifo_rdy==1'b0)
          begin
            upload_nstate=upload_scORinvreqs;
          end
        else 
          begin
			   en_flit_out=1'b1;
            if(inv_ids_reg[sel_cnt_invs]==1'b0)
              inc_sel_cnt_invs=1'b1;
            else
              begin
                if(cnt_invs_eq_3==1'b1)
                  begin
                    if(cnt_eq_max==1'b1)
                      begin
                        ctrl=2'b11;
                        clr_max=1'b1;
                        clr_inv_ids=1'b1;
                        clr_sel_cnt_inv=1'b1;
                        clr_sel_cnt=1'b1;
                        upload_nstate=upload_idle;
                      end
                    else
                      begin
                        upload_nstate=upload_scORinvreqs;
                        inc_sel_cnt=1'b1;
                        if(sel_cnt_eq_0)
                          begin
                            ctrl=2'b01;
                            dest_sel=1'b0;
                          end
                        else
                          begin
                            ctrl=2'b10;
                          end
                      end
                  end
                else
                  begin
                    upload_nstate=upload_scORinvreqs;
                    if(cnt_eq_max)
                      begin
                        inc_sel_cnt_invs=1'b1;
                        clr_sel_cnt=1'b1;
                      end
                    else
                      begin
                        inc_sel_cnt=1'b1;
                        if(sel_cnt_eq_0)
                          begin
                            ctrl=2'b01;
                            dest_sel=1'b0;
                          end
                        else
                          begin
                            ctrl=2'b10;
                          end
                      end
                  end
              end//
          end//end of upload_scorinvreqs's else begin              
      end  // end of  upload_scorinvreqs
    upload_wbORflushreqs:
      begin
        if(out_req_fifo_rdy==1'b0)
          begin
            upload_nstate=upload_wbORflushreqs;
          end
        else
          begin
			   en_flit_out=1'b1;
            if(cnt_eq_max)
              begin
                upload_nstate=upload_idle;
                clr_sel_cnt=1'b1;
                clr_max=1'b1;
                ctrl=2'b11;
              end
            else
              begin   
                upload_nstate=upload_wbORflushreqs;   
                inc_sel_cnt=1'b1;
                if(sel_cnt_eq_0)
                  begin
                    ctrl=2'b01;
                    dest_sel=1'b1;
                  end
                else
                  begin
                    ctrl=2'b10;
                  end
              end
          end
      end
  endcase 
end



endmodule