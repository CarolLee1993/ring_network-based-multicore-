/// date:2016/3/9
/// engineer: ZhaiShaoMin
module   dc_req_upload(//input
                          clk,
                          rst,
                          dc_flits_req,
                          v_dc_flits_req,
                          req_fifo_rdy,
                          //output
                          dc_flit_out,
                          v_dc_flit_out,
                          dc_req_upload_state
                          );
//input
input                         clk;
input                         rst;
input       [47:0]            dc_flits_req;
input                         v_dc_flits_req;
input                         req_fifo_rdy;
//output
output      [15:0]             dc_flit_out;
output                         v_dc_flit_out;
output                         dc_req_upload_state;

//parameter 
parameter    dc_req_upload_idle=1'b0;
parameter    dc_req_upload_busy=1'b1;

//reg          dc_req_nstate; 
reg          dc_req_state;
reg  [47:0]  dc_req_flits;
reg  [1:0]   sel_cnt;
reg          v_dc_flit_out;
reg          fsm_rst;
reg          next;
reg          en_flits_in;
reg          inc_cnt;
assign dc_req_upload_state=dc_req_state;
always@(*)
begin
  //default value
 // dc_req_nstate=dc_req_state;
  v_dc_flit_out=1'b0;
  inc_cnt=1'b0;
  fsm_rst=1'b0;
  en_flits_in=1'b0;
  next=1'b0;
  
  case(dc_req_state)
    dc_req_upload_idle:
       begin
         if(v_dc_flits_req)
           begin
             en_flits_in=1'b1;
             next=1'b1;
           end
       end
    dc_req_upload_busy:
       begin
         if(req_fifo_rdy)
           begin
             if(sel_cnt==2'b10)
               fsm_rst=1'b1;
             inc_cnt=1'b1;
             v_dc_flit_out=1'b1;
           end
       end
    endcase
end

// fsm state
always@(posedge clk)
begin
  if(rst||fsm_rst)
    dc_req_state<=1'b0;
else if(next)
    dc_req_state<=1'b1;
end
// flits regs
always@(posedge clk)
begin
  if(rst||fsm_rst)
    dc_req_flits<=48'h0000;
  else if(en_flits_in)
    dc_req_flits<=dc_flits_req;
end
reg  [15:0]  dc_flit_out;
always@(*)
begin
  case(sel_cnt)
    2'b00:dc_flit_out=dc_req_flits[47:32];
    2'b01:dc_flit_out=dc_req_flits[31:16];
    2'b10:dc_flit_out=dc_req_flits[15:0];
    default:dc_flit_out=dc_req_flits[47:32];
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

endmodule