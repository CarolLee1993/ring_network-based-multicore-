/// date:2016/3/5
/// engineer :ZhaiShaoMin  3/6 am: 10:57 done!
/// module function :because accesses come from three different sources:cpu,IN_req/rep(at one time ,only req or rep),mem
/// so here we need a arbiter to determine who can access data cache finally.
module     arbiter_for_dcache(//input
                              clk,
                              rst,
                              dcache_done_access,
                              v_dc_download,
                              dc_download_flits,
                              v_cpu,
                              cpu_access_flits,
                              v_m_d_areg,
                              m_d_areg_flits,
                              //output
                              flits_dc,
                              v_flits_dc,
                              re_dc_download_flits,
                              re_cpu_access_flits,
                              re_m_d_areg_flits,
                              cpu_done_access,
                              dc_download_done_access,
                              m_d_areg_done_access
                              );
//input
input                         clk;
input                         rst;
input                         dcache_done_access;
input                         v_dc_download;
input     [143:0]             dc_download_flits;
input                         v_cpu;
input     [67:0]              cpu_access_flits;
input                         v_m_d_areg;
input     [143:0]             m_d_areg_flits;
//output
output    [143:0]             flits_dc;
output                        v_flits_dc;
output                        re_dc_download_flits;
output                        re_cpu_access_flits;
output                        re_m_d_areg_flits;
output                        cpu_done_access;
output                        dc_download_done_access;
output                        m_d_areg_done_access;
// parameter for fsm state
parameter        idle=4'b0001;
parameter        cpu_busy=4'b0010;
parameter        dc_busy=4'b0100;
parameter        mem_busy=4'b1000;
reg    [2:0]   select;
reg            update_priority_3;
reg            update_priority_2;
reg    [3:0]        nstate;
reg    [3:0]        state;
reg            re_cpu_access_flits;
reg            re_dc_download_flits;
reg            re_m_d_areg_flits;
reg            cpu_done_access;
reg            dc_download_done_access;
reg            m_d_areg_done_access;
reg    [143:0] flits_dc;
reg            v_flits_dc;
wire    [2:0]  v_vector;

reg    [2:0]  priority_3;
reg    [1:0]  priority_2;

assign v_vector={v_dc_download,v_cpu,v_m_d_areg};
always@(*)
begin
  select=3'b000;
  update_priority_3=1'b0;
  update_priority_2=1'b0;
  nstate=state;
  re_cpu_access_flits=1'b0;
  re_dc_download_flits=1'b0;
  re_m_d_areg_flits=1'b0;
  cpu_done_access=1'b0;
  dc_download_done_access=1'b0;
  m_d_areg_done_access=1'b0;
  flits_dc=144'h0000;
  v_flits_dc=1'b0;
  case(state)
    idle:
      begin
        if(v_vector==3'b111)
          begin
            select=priority_3;
            update_priority_3=1'b1;
          end
        else if(v_vector==3'b011)
          begin
            select={1'b0,priority_2};
            update_priority_2=1'b1;
          end
        else if(v_vector==3'b101)
          begin
            select={priority_2[0],1'b0,priority_2[1]};
            update_priority_2=1'b1;
          end
        else if(v_vector==3'b110)
          begin
            select={priority_2,1'b0};
            update_priority_2=1'b1;
          end
        else if(v_vector==3'b001||v_vector==3'b010||v_vector==3'b100)
          begin
            select=v_vector;
          end
      
      if(select==3'b001)
        nstate=mem_busy;
      else if(select==3'b010)
        nstate=dc_busy;
      else if(select==3'b100)
        nstate=cpu_busy;
      end
    cpu_busy:
      begin
        re_cpu_access_flits=1'b1;
        flits_dc={cpu_access_flits,76'h0000};
        v_flits_dc=1'b1;
        if(dcache_done_access)
          begin
            nstate=idle;
            cpu_done_access=1'b1;
          end
      end
    dc_busy:
      begin
        re_dc_download_flits=1'b1;
        flits_dc=dc_download_flits;
        v_flits_dc=1'b1;
        if(dcache_done_access)
          begin
            nstate=idle;
            dc_download_done_access=1'b1;
          end
      end
    mem_busy:
      begin
        re_m_d_areg_flits=1'b1;
        flits_dc=m_d_areg_flits;
        v_flits_dc=1'b1;
        if(dcache_done_access)
          begin
            nstate=idle;
            m_d_areg_done_access=1'b1;
          end
      end
  endcase
end
/// fsm state
always@(posedge clk)
begin
  if(rst)
    state<=4'b0001;
  else
    state<=nstate;
end
/// priority state
always@(posedge clk)
begin
  if(rst)
    priority_3<=3'b001;
  else if(update_priority_3)
    priority_3<={priority_3[1:0],priority_3[2]};
end  
always@(posedge clk)
begin
  if(rst)
    priority_2<=2'b01;
  else if(update_priority_2)
    priority_2<={priority_2[0],priority_2[1]};
end    
          
endmodule