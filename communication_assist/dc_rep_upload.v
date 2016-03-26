/// date:2016/3/9
/// engineer: ZhaiShaoMin
module   dc_rep_upload(//input
                          clk,
                          rst,
                          dc_flits_rep,
                          v_dc_flits_rep,
                          flits_max,
                          en_flits_max,
                          rep_fifo_rdy,
                          //output
                          dc_flit_out,
                          v_dc_flit_out,
								  dc_ctrl_out,
                          dc_rep_upload_state
                          );
//input
input                          clk;
input                          rst;
input         [175:0]          dc_flits_rep;
input                          v_dc_flits_rep;
input         [3:0]            flits_max;
input                          en_flits_max;
input                          rep_fifo_rdy;
                          //output
output        [15:0]            dc_flit_out;
output                          v_dc_flit_out;
output       [1:0]              dc_ctrl_out;
output                          dc_rep_upload_state;

//parameter 
parameter    dc_rep_upload_idle=1'b0;
parameter    dc_rep_upload_busy=1'b1;

//reg          dc_req_nstate; 
reg          dc_rep_state;
reg  [175:0]  dc_rep_flits;
reg  [3:0]   sel_cnt;
reg          v_dc_flit_out;
reg          fsm_rst;
reg          next;
reg          en_flits_in;
reg          inc_cnt;
reg  [3:0]   flits_max_reg;
reg  [1:0]   dc_ctrl_out;
assign dc_rep_upload_state=dc_rep_state;
always@(*)
begin
  //default value
 // dc_req_nstate=dc_req_state;
  v_dc_flit_out=1'b0;
  inc_cnt=1'b0;
  fsm_rst=1'b0;
  en_flits_in=1'b0;
  next=1'b0;
  dc_ctrl_out=2'b00;
  case(dc_rep_state)
    dc_rep_upload_idle:
       begin
         if(v_dc_flits_rep)
           begin
             en_flits_in=1'b1;
             next=1'b1;
           end
       end
    dc_rep_upload_busy:
       begin
         if(rep_fifo_rdy)
           begin
             if(sel_cnt==flits_max_reg)
				  begin
               fsm_rst=1'b1;
					dc_ctrl_out=2'b11;
					end
				else if(sel_cnt==3'b000)
				    dc_ctrl_out=2'b01;
				else 	 
				    dc_ctrl_out=2'b10;
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
    dc_rep_state<=1'b0;
else if(next)
    dc_rep_state<=1'b1;
end
// flits regs
always@(posedge clk)
begin
  if(rst||fsm_rst)
    dc_rep_flits<=176'h0000;
  else if(en_flits_in)
    dc_rep_flits<=dc_flits_rep;
end
reg  [15:0]  dc_flit_out;
always@(*)
begin
  case(sel_cnt)
    4'b0000:dc_flit_out=dc_rep_flits[175:160];
    4'b0001:dc_flit_out=dc_rep_flits[159:144];
    4'b0010:dc_flit_out=dc_rep_flits[143:128];
    4'b0011:dc_flit_out=dc_rep_flits[127:112];
    4'b0100:dc_flit_out=dc_rep_flits[111:96];
    4'b0101:dc_flit_out=dc_rep_flits[95:80];
    4'b0110:dc_flit_out=dc_rep_flits[79:64];
    4'b0111:dc_flit_out=dc_rep_flits[63:48];
    4'b1000:dc_flit_out=dc_rep_flits[47:32];
    4'b1001:dc_flit_out=dc_rep_flits[31:16];
    4'b1010:dc_flit_out=dc_rep_flits[15:0];
    default:dc_flit_out=dc_rep_flits[175:160];
  endcase
end

// flits_max
always@(posedge  clk)
begin
  if(rst||fsm_rst)
    flits_max_reg<=4'b0000;
  else if(en_flits_max)
    flits_max_reg<=flits_max;
end
    
///sel_counter
always@(posedge clk)
begin
  if(rst||fsm_rst)
    sel_cnt<=4'b0000;
  else if(inc_cnt)
    sel_cnt<=sel_cnt+4'b0001;
end

endmodule