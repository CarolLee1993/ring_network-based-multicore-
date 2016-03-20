/// date: 2016/2/24
/// engineer: ZhaiShaoMIn
/// module name: fsm_download_flit(from IN_local fifos)
/// fsm for controlling datapath from IN_local to the regs
/// used to process rep msgs and req msgs.
module FSM_download_flit(
                        //input 
                         req_flit,
                         req_rdy,
                         rep_flit,
                         rep_rdy,
                         clk,
                         rst,
                         cache_rst,
                         //output
                         en_deq_req,
                         en_deq_rep,
                         rf_rdy_for_cache_out,
                         head_flit,
                         addrHI_flit,
                         addrLO_flit,
                         data1HI_flit,
                         data1LO_flit,
                         data2HI_flit,
                         data2LO_flit,
                         data3HI_flit,
                         data3LO_flit,
                         data4HI_flit,
                         data4LO_flit
                         );
  //input 
input          [17:0]              req_flit;  // with ctrl (2 bits)
input                              req_rdy;
input          [17:0]              rep_flit;  // with ctrl (2 bits)
input                              rep_rdy;
input                              clk;
input                              rst;
input                              cache_rst;
 //output
output                             en_deq_req;
output                             en_deq_rep;
output                             rf_rdy_for_cache_out;
output          [15:0]              head_flit;
output          [15:0]              addrHI_flit;
output          [15:0]              addrLO_flit;
output          [15:0]              data1HI_flit;
output          [15:0]              data1LO_flit;
output          [15:0]              data2HI_flit;
output          [15:0]              data2LO_flit;
output          [15:0]              data3HI_flit;
output          [15:0]              data3LO_flit;
output          [15:0]              data4HI_flit;
output          [15:0]              data4LO_flit;
//wires for interconnection
wire       [1:0]  ctrl_rep;
wire       [1:0]  ctrl_req;
assign ctrl_rep=rep_flit[17:16];
assign ctrl_req=req_flit[17:16];
//arbitration
wire tCbusy;
wire req_cacheORhome;
wire rep_cacheORhome;
assign req_cacheORhome=req_flit[13];
assign rep_cacheORhome=rep_flit[13];

//fake regs
reg deq_rep_on;
reg deq_req_on;

always@(tCbusy or rep_rdy or req_rdy  or req_cacheORhome  or rep_cacheORhome or ctrl)
  begin
  if(~tCbusy&&rep_rdy&&~rep_cacheORhome&&(ctrl_rep==2'b01))
      begin
        deq_rep_on=1;
        deq_req_on=0;
      end
  else if(~tCbusy&&req_rdy&&~req_cacheORhome&&(ctrl_req==2'b01))
     begin
        deq_rep_on=0;
        deq_req_on=1;
     end
  else
     begin
        deq_rep_on=0;
        deq_req_on=0;
      end   
    //defult: signals
    deq_req_on=0;
    deq_rep_on=0;
 end
 
 
//parameters
parameter  idle=3'b000;
parameter  load_req=3'b001;
parameter  load_rep=3'b101;
parameter  wait_req=3'b010;
parameter  wait_rep=3'b110;
//FSM
reg  [2:0]    rstate;
reg  [2:0]    nstate;
reg en_deq_req;
reg en_deq_rep;
reg en_load;
reg en_cnt;
reg rst_cnt;
reg en_read_all;
reg C_busy;

// generate flit to flit registers   
wire [17:0] temp_flit;
wire [15:0] flit;
wire [1:0]  ctrl;
assign temp_flit=en_deq_rep?rep_flit:req_flit;             
assign ctrl=temp_flit[17:16];
assign flit=temp_flit[15:0]; 

always@(deq_rep_on  or deq_req_on or rep_rdy  or req_rdy  or ctrl )
begin
   //defult value for all signals !//
   /*no state change by default*/
   nstate=rstate;
   en_deq_req=1'b0;
   en_deq_rep=1'b0;
   en_load=1'b0;
   en_cnt=1'b0;
   rst_cnt=1'b0;
   en_read_all=1'b0;
   case(rstate)
     idle:
        begin
          if(deq_rep_on|deq_req_on)
            begin
              C_busy=1; 
              rst_cnt=1;
              if(deq_rep_on)
                nstate=load_rep;
              else
                nstate=load_req;
             end
        end
      load_req:
         begin
           if(req_rdy==1'b0)
             begin
               nstate=wait_req;
             end
           else if(ctrl!=2'b11)
             begin
               en_deq_req=1'b1;
               en_cnt=1'b1;
               en_load=1'b1;
             end
           else if(ctrl==2'b11)
             begin
               nstate=idle;
               en_read_all=1'b1;
             end
         end
      wait_req:
      begin
           if(req_rdy==1'b1)
          begin
            if(ctrl==2'b11)
             begin
               nstate=idle;
               en_read_all=1'b1;
             end
           else
             begin
               nstate=load_req;
             end
               en_deq_req=1'b1;
               en_load=1'b1;
               en_cnt=1'b1;
          end
      end
      load_rep:
         begin
            if(rep_rdy==1'b0)
             begin
               nstate=wait_rep;
             end
            else if(ctrl!=2'b11)
             begin
               en_deq_rep=1'b1;
               en_cnt=1'b1;
               en_load=1'b1;
             end
            else if(ctrl==2'b11)
             begin
               nstate=idle;
               en_load=1'b1;
               en_deq_rep=1'b1;
               en_read_all=1'b1;
             end
         end
      wait_rep:
         begin
           if(rep_rdy==1'b1)
             begin
              if(ctrl==2'b11)
                begin
               nstate=idle;
               en_read_all=1'b1;
                end
              else 
                begin 
               nstate=load_rep;
                end
              en_deq_rep=1'b1;
              en_cnt=1'b1;
              en_load=1'b1;
             end
         end 
      endcase
end   
//counter for write address to flit regs
reg [3:0]  cnt;
always@(posedge clk)
begin
 if(rst_cnt|rst)
   cnt<=4'b0000;
 else if(en_cnt)
   cnt<=cnt+1'b1;
 else
   cnt<=cnt;
end

//wire [3:0] cnt_sel;
//assign cnt_sel=cnt;     
//Cache_busy register
reg        Cbusy;
always@(posedge clk)
begin
 if(rst==1'b0|cache_rst==1'b1)
   Cbusy<=1'b0;
 else if(C_busy==1'b1)
   Cbusy<=1'b1;
 else
   Cbusy<=Cbusy;
end
assign tCbusy=Cbusy;

// reg indicate flit regs are ready!
reg        rf_rdy_for_cache;
always@(posedge clk)
begin
 if(rst==1'b0|cache_rst==1'b1)
   rf_rdy_for_cache<=1'b0;
 else if(C_busy==1'b1)
   rf_rdy_for_cache<=1'b1;
 else
   rf_rdy_for_cache<=rf_rdy_for_cache;
end

wire rf_rdy_for_cache_out;  //IN_local flit regs busy output!
assign rf_rdy_for_cache_out=rf_rdy_for_cache;           
               
//FSM reg               
always @(posedge  clk) 
begin
  if (rst)
   rstate <= idle; //reset to idle state
  else
   rstate <= nstate;
end

// instance of flit regfile
SP_rf_LUT_RAM  #(11,16,4) flit_regs (
                                      .clk(clk),
                                      .we(en_load),
                                      .wa(cnt),
                                      .di(flit),
                                      .re(en_read_all),
                           //           .flit_rdy(flit_rdy_out),
                                      .do0(head_flit),
                                      .do1(addrHI_flit),
                                      .do2(addrLO_flit),
                                      .do3(data1HI_flit),
                                      .do4(data1LO_flit),
                                      .do5(data2HI_flit),
                                      .do6(data2LO_flit),
                                      .do7(data3HI_flit),
                                      .do8(data3LO_flit),
                                      .do9(data4HI_flit),
                                      .do10(data4LO_flit)
                                      );
endmodule                           

      
