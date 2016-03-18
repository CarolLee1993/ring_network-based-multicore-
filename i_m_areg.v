/// date:2016/3/9
/// engineer: ZhaiShaoMin
module   i_m_areg(//input
                   clk,
                   rst,
                   i_flits_m,
                   v_i_flits_m,
                   mem_done_access,
                   //output
                   i_m_areg_flits,
                   v_i_areg_m_flits
                   );
//input
input                   clk;
input                   rst;
input      [47:0]       i_flits_m;
input                   v_i_flits_m;
input                   mem_done_access;
                   //output
output                   i_m_areg_flits;
output     [47:0]        v_i_areg_m_flits;

reg      i_m_cstate;
reg      [47:0]   flits_reg;

assign   i_m_areg_state=i_m_cstate;// when m_d_cstate is 1, it means this module is busy and
                                   // can't receive other flits. oterwise,able to receiving flits
always@(posedge clk)
begin
  if(rst||mem_done_access)
    flits_reg<=48'h0000;
else if(v_i_flits_m)
    flits_reg<=i_flits_m;
end

always@(posedge clk)
begin
  if(rst||mem_done_access)
    i_m_cstate<=1'b0;
  else if(v_i_flits_m)
    i_m_cstate<=1'b1;
end
endmodule