/// date:2016/3/5  3/6 am: 10:57 done!
/// engineer:ZhaiShaoMin
/// module function: determine  where head flits of req/rep  go?
///                  inst cache or data cache or memory according to 
///                  the fsm states of three kinds of downloadregs.
///                  if ic_fsm_state is idle, then rep to inst cache is 
///                  free to go,same way for dc_downloadregs and mem_downloadregs
module     arbiter_IN_node(//input
                           clk,
                           rst,
                           in_req_rdy,
                           in_rep_rdy,
                           req_ctrl_in,
                           rep_ctrl_in,
                           req_flit_in,
                           rep_flit_in,
                           ic_download_state_in,
                           dc_download_state_in,
                           mem_download_state_in,
                           //output
                           ack_req,
                           ack_rep,
                           v_ic,
                           flit_ic,
                           ctrl_ic,
                           v_dc,
                           flit_dc,
                           ctrl_dc,
                           v_mem,
                           flit_mem,
                           ctrl_mem
                           );
  //input
input                           clk;
input                           rst;
input                           in_req_rdy;
input                           in_rep_rdy;
input         [1:0]             req_ctrl_in;
input         [1:0]             rep_ctrl_in;
input         [15:0]            req_flit_in;
input         [15:0]            rep_flit_in;
input         [1:0]             ic_download_state_in;
input         [1:0]             dc_download_state_in;
input         [1:0]             mem_download_state_in;
//output
output                          ack_req;
output                          ack_rep;
output                          v_ic;
output         [15:0]           flit_ic;
output         [1:0]            ctrl_ic;
output                          v_dc;
output         [15:0]           flit_dc;
output         [1:0]            ctrl_dc;
output                          v_mem;
output         [15:0]           flit_mem;
output         [1:0]            ctrl_mem;

reg   [3:0] rep_nstate;
reg   [2:0] req_nstate;
reg   [3:0] rep_state;
reg   [2:0] req_state;
// rep_cmd parameter
parameter        instrep_cmd=5'b10100;
// rep fsm state parameter
parameter      rep_idle=4'b0001;
parameter      rep_ic_downloading=4'b0010;
parameter      rep_dc_downloading=4'b0100;
parameter      rep_mem_downloading=4'b1000;
// req fsm state  parameter
parameter      req_idle=3'b001;
parameter      req_dc_downloading=3'b010;
parameter      req_mem_downloading=3'b100;
// state parameter of donwload
parameter      ic_idle=2'b00;
parameter      dc_idle=2'b00;
parameter      mem_idle=2'b00;

  reg          ack_req;
  reg          ack_rep;
  reg          v_ic;
  reg          v_dc;
  reg          v_mem;
  reg [15:0]   flit_ic;
  reg [1:0]    ctrl_ic;
  reg [15:0]   flit_dc;
  reg [1:0]    ctrl_dc;
  reg [15:0]   flit_mem;
  reg [1:0]    ctrl_mem;
  reg          rep_win;
/// fsm of arbiter_for_rep
always@(*)
begin
  ack_rep=1'b0;
  v_ic=1'b0;
  v_dc=1'b0;
  v_mem=1'b0;
  flit_ic=16'h0000;
  ctrl_ic=2'b00;
  flit_dc=16'h0000;
  ctrl_dc=2'b00;
  flit_mem=16'h0000;
  ctrl_mem=2'b00;
  rep_nstate=rep_state;
  rep_win=1'b0;
  case(rep_state)
    rep_idle:
      begin
        if(rep_flit_in[9:5]==instrep_cmd&&rep_ctrl_in==2'b01&&in_rep_rdy&&ic_download_state_in==ic_idle)
          begin
            ack_rep=1'b1;
            v_ic=1'b1;
            flit_ic=rep_flit_in;
            ctrl_ic=rep_ctrl_in;
            rep_nstate=rep_ic_downloading;
          end
      else if(rep_flit_in[13]==1'b0&&rep_ctrl_in==2'b01&&in_rep_rdy&&dc_download_state_in==dc_idle)
          begin
            ack_rep=1'b1;
            v_dc=1'b1;
            flit_dc=rep_flit_in;
            ctrl_dc=rep_ctrl_in;
            rep_nstate=rep_dc_downloading;
            rep_win=1'b1;
          end
      else if(rep_flit_in[13]==1'b1&&rep_ctrl_in==2'b01&&in_rep_rdy&&mem_download_state_in==mem_idle)
          begin
            ack_rep=1'b1;
            v_mem=1'b1;
            flit_mem=rep_flit_in;
            ctrl_mem=rep_ctrl_in;
            rep_nstate=rep_mem_downloading;
            rep_win=1'b1;
          end
      end
    rep_ic_downloading:
      begin
        if(in_rep_rdy==1'b1)
          begin
            if(rep_ctrl_in==2'b11)
              begin
                rep_nstate=rep_idle;
              end
            ack_rep=1'b1;
            v_ic=1'b1;
            flit_ic=rep_flit_in;
            ctrl_ic=rep_ctrl_in;
          end
      end
    rep_dc_downloading:
      begin
        if(in_rep_rdy==1'b1)
          begin
            if(rep_ctrl_in==2'b11)
              begin
                rep_nstate=rep_idle;
              end
            ack_rep=1'b1;
            v_dc=1'b1;
            flit_dc=rep_flit_in;
            ctrl_dc=rep_ctrl_in;
          end
      end
    rep_mem_downloading:
      begin
        if(in_rep_rdy==1'b1)
          begin
            if(rep_ctrl_in==2'b11)
              begin
                rep_nstate=rep_idle;
              end
            ack_rep=1'b1;
            v_mem=1'b1;
            flit_mem=rep_flit_in;
            ctrl_mem=rep_ctrl_in;
          end
      end
  endcase
end
/// fsm of arbiter_for_req
always@(*)
begin
  ack_req=1'b0;
  v_dc=1'b0;
  v_mem=1'b0;
  flit_dc=16'h0000;
  ctrl_dc=2'b00;
  flit_mem=16'h0000;
  ctrl_mem=2'b00;
  req_nstate=req_state;
  case(req_state)
    req_idle:
      begin
        if(rep_win==1'b0&&req_ctrl_in==2'b01&&in_req_rdy)
          begin
            if(req_flit_in[13]==1'b0&&dc_download_state_in==dc_idle)
              begin
                ack_req=1'b1;
                v_dc=1'b1;
                flit_dc=req_flit_in;
                ctrl_dc=req_ctrl_in;
                req_nstate=req_dc_downloading;
              end
            else if(req_flit_in[13]==1'b1&&mem_download_state_in==mem_idle)
              begin
                ack_req=1'b1;
                v_mem=1'b1;
                flit_mem=req_flit_in;
                ctrl_mem=req_ctrl_in;
                req_nstate=req_mem_downloading;
              end
          end
      end
    req_dc_downloading: 
      begin
        if(in_rep_rdy==1'b1)
          begin
            if(rep_ctrl_in==2'b11)
              begin
                rep_nstate=rep_idle;
              end
            ack_rep=1'b1;
            v_dc=1'b1;
            flit_dc=rep_flit_in;
            ctrl_dc=rep_ctrl_in;
          end
      end     
    rep_mem_downloading:
      begin
        if(in_req_rdy)         
            begin
            if(req_ctrl_in==2'b11)
              begin
                req_nstate=req_idle;
              end
            ack_req=1'b1;
            v_mem=1'b1;
            flit_mem=req_flit_in;
            ctrl_mem=req_ctrl_in;
            end 
      end
    endcase
end
// fsm regs
always@(posedge clk)
begin
  if(rst)
    rep_state<=4'b0001;
  else
    rep_state<=rep_nstate;
end

always@(posedge clk)
begin
  if(rst)
    req_state<=3'b001;
  else
    req_state<=req_nstate;
end
endmodule 