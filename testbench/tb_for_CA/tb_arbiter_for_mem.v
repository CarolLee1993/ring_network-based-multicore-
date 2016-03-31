/**********************************************************************
date:2016/3/30
designer:ZhaiShaoMin
module name:tb_arbiter_for_mem
module function: find out errors in this module if any
***********************************************************************/
`timescale 1ns/1ps

module  tb_arbiter_for_mem();
  
//input             
 reg                           clk;
 reg                           rst;
 reg                           v_mem_download;
 reg                           v_d_m_areg;
 reg                           v_i_m_areg;
 reg                           mem_access_done;
//output
 wire                           ack_m_download;
 wire                           ack_d_m_areg;
 wire                           ack_i_m_areg;
 wire                           v_m_download_m;
 wire                           v_d_m_areg_m;
 wire                           v_i_m_areg_m;
 
 arbiter_for_mem     uut   (//input
                            .clk(clk),
                            .rst(rst),
                            .v_mem_download(v_mem_download),
                            .v_d_m_areg(v_d_m_areg),
                            .v_i_m_areg(v_i_m_areg),
                            .mem_access_done(mem_access_done),
                            //output
                            .ack_m_download(ack_m_download),
                            .ack_d_m_areg(ack_d_m_areg),
                            .ack_i_m_areg(ack_i_m_areg),
                            .v_m_download_m(v_m_download_m),
                            .v_d_m_areg_m(v_d_m_areg_m),
                            .v_i_m_areg_m(v_i_m_areg_m)
                            );
            initial begin
               clk=1'b0;
               rst=1'b1;
               v_mem_download=1'b0;
               v_d_m_areg=1'b0;
               v_i_m_areg=1'b0;
               mem_access_done=1'b0;
             end
             
             `define clk_step # 14;
              
              always #7 clk=~clk;
              
              /////////////////////////////////////////////////////
              /////////////////BEGIN TEST//////////////////////////
              
              initial begin
                  
                  `clk_step
                  rst=1'b0;
                  
                  `clk_step
                  ///////////////////////////////////////////////////
                  /////////1st case mem ic and dc all are valid//////
                  v_mem_download=1'b1;
                  v_d_m_areg=1'b1;
                  v_i_m_areg=1'b1;
                  mem_access_done=1'b0;
                  
                  `clk_step
                  
                  v_mem_download=1'b1;
                  v_d_m_areg=1'b1;
                  v_i_m_areg=1'b1;
                  mem_access_done=1'b0;
                  
                  `clk_step
                  
                  v_mem_download=1'b1;
                  v_d_m_areg=1'b1;
                  v_i_m_areg=1'b1;
                  mem_access_done=1'b0;
                  
                  `clk_step
                  
                  //mem done access in this cycle 
                  v_mem_download=1'b1;
                  v_d_m_areg=1'b1;
                  v_i_m_areg=1'b1;
                  mem_access_done=1'b1;
                  
                  `clk_step
                  
                  //////////////////////////////////////////
                  //////////2nd case: dc and mem are valid//
                  
                  v_mem_download=1'b1;
                  v_d_m_areg=1'b1;
                  v_i_m_areg=1'b0;
                  mem_access_done=1'b0;
                  
                  `clk_step
                  
                  v_mem_download=1'b1;
                  v_d_m_areg=1'b1;
                  v_i_m_areg=1'b0;
                  mem_access_done=1'b0;
                  
                  `clk_step
                  
                  v_mem_download=1'b1;
                  v_d_m_areg=1'b1;
                  v_i_m_areg=1'b0;
                  mem_access_done=1'b0;
                  
                  `clk_step
                  
                  //mem done access in this cycle 
                  v_mem_download=1'b1;
                  v_d_m_areg=1'b1;
                  v_i_m_areg=1'b0;
                  mem_access_done=1'b1;
                  
                  `clk_step
                  
                  ////////////////////////////////////////////////
                  ////////3rd case: only mem valid ///////////////
                  
                  v_mem_download=1'b1;
                  v_d_m_areg=1'b0;
                  v_i_m_areg=1'b0;
                  mem_access_done=1'b0;
                  
                  `clk_step
                  
                  v_mem_download=1'b1;
                  v_d_m_areg=1'b0;
                  v_i_m_areg=1'b0;
                  mem_access_done=1'b0;
                  
                  `clk_step
                  
                  v_mem_download=1'b1;
                  v_d_m_areg=1'b0;
                  v_i_m_areg=1'b0;
                  mem_access_done=1'b0;
                  
                  `clk_step
                  
                  //mem done access in this cycle 
                  v_mem_download=1'b1;
                  v_d_m_areg=1'b0;
                  v_i_m_areg=1'b0;
                  mem_access_done=1'b1;
                  
                  `clk_step
                  
                  $stop;
                end 
              endmodule
              
              
                  
                  
                  
                  
                                 
                            
                            
                            