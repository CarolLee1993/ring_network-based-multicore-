/**************************************************************
date:2016/3/30
designer:ZhaiShaoMin
module name :tb_arbiter_for_IN_node
module function : check out errors about arbiter_for_IN_node
**************************************************************/
`timescale 1ns/1ps

module tb_arbiter_IN_node();
  
  
//input
reg                           clk;
reg                           rst;
reg                           in_req_rdy;
reg                           in_rep_rdy;
reg         [1:0]             req_ctrl_in;
reg         [1:0]             rep_ctrl_in;
reg         [15:0]            req_flit_in;
reg         [15:0]            rep_flit_in;
reg         [1:0]             ic_download_state_in;
reg         [1:0]             dc_download_state_in;
reg         [1:0]             mem_download_state_in;
//output
wire                          ack_req;
wire                          ack_rep;
wire                          v_ic;
wire         [15:0]           flit_ic;
wire         [1:0]            ctrl_ic;
wire                          v_dc;
wire         [15:0]           flit_dc;
wire         [1:0]            ctrl_dc;
wire                          v_mem;
wire         [15:0]           flit_mem;
wire         [1:0]            ctrl_mem;

//instante the design unit

arbiter_IN_node      uut (//input
                           .clk(clk),
                           .rst(rst),
                           .in_req_rdy(in_req_rdy),
                           .in_rep_rdy(in_rep_rdy),
                           .req_ctrl_in(req_ctrl_in),
                           .rep_ctrl_in(rep_ctrl_in),
                           .req_flit_in(req_flit_in),
                           .rep_flit_in(rep_flit_in),
                           .ic_download_state_in(ic_download_state_in),
                           .dc_download_state_in(dc_download_state_in),
                           .mem_download_state_in(mem_download_state_in),
                           //output
                           .ack_req(ack_req),
                           .ack_rep(ack_rep),
                           .v_ic(v_ic),
                           .flit_ic(flit_ic),
                           .ctrl_ic(ctrl_ic),
                           .v_dc(v_dc),
                           .flit_dc(flit_dc),
                           .ctrl_dc(ctrl_dc),
                           .v_mem(v_mem),
                           .flit_mem(flit_mem),
                           .ctrl_mem(ctrl_mem)
                           );
      integer log_file;
      
      //initial inputs
         initial 
           begin
           clk=1'b0;
           rst=1'b1;
           in_req_rdy=1'b0;
           in_rep_rdy=1'b0;
           req_ctrl_in=2'b00;
           rep_ctrl_in=2'b00;
           req_flit_in=16'h0000;
           rep_flit_in=16'h0000;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b00;//dc_idle
           mem_download_state_in=2'b00;//mem_idle   
           log_file=$fopen("log_arbiter_IN_node");
           end
           
      `define clk_step #14;
      
      always #7 clk=~clk;
      
      /////////////////////////////////////////////////////////////////
      /////////////BEGIN TEST!/////////////////////////////////////////
      
      initial begin
        
        `clk_step
        $display("BEGIN TEST!");
        $fdisplay(log_file,"BEGIN TEST!");
        
        rst=1'b0;
        
        /////////////////////////////////////////////////////////////
        ///////////first case : ic rep flit and dc req come////////
        
        ////first flit come anad both ic_download and dc_download are ready
          `clk_step
        
           in_req_rdy=1'b1;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b01;
           rep_ctrl_in=2'b01;
           req_flit_in=16'hc0de;
           rep_flit_in=16'hc280;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b00;//dc_idle
           mem_download_state_in=2'b00;//mem_idle
        
        ///second flits ,both ready
           `clk_step
           
           in_req_rdy=1'b1;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b10;
           rep_ctrl_in=2'b10;
           req_flit_in=16'hc1de;
           rep_flit_in=16'hc380;
           ic_download_state_in=2'b01;//ic_busy
           dc_download_state_in=2'b01;//dc_busy
           mem_download_state_in=2'b00;//mem_idle
           
           ///3rd flits ,both ready
           `clk_step
           
           in_req_rdy=1'b1;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b10;
           rep_ctrl_in=2'b10;
           req_flit_in=16'hc2de;
           rep_flit_in=16'hc480;
           ic_download_state_in=2'b01;//ic_busy
           dc_download_state_in=2'b01;//dc_busy
           mem_download_state_in=2'b00;//mem_idle
           
           ////after a while ,last flits both come
           
           `clk_step
           
           in_req_rdy=1'b1;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b11;
           rep_ctrl_in=2'b11;
           req_flit_in=16'hc3de;
           rep_flit_in=16'hc580;
           ic_download_state_in=2'b01;//ic_busy
           dc_download_state_in=2'b01;//dc_busy
           mem_download_state_in=2'b00;//mem_idle
           
           
           ///this time make ic busy for a moment
           `clk_step
        
           in_req_rdy=1'b1;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b01;
           rep_ctrl_in=2'b01;
           req_flit_in=16'hc0de;
           rep_flit_in=16'hc280;
           ic_download_state_in=2'b10;//ic_busy
           dc_download_state_in=2'b00;
           mem_download_state_in=2'b00;
           
           `clk_step
        
           in_req_rdy=1'b1;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b10;
           rep_ctrl_in=2'b01;
           req_flit_in=16'hc1de;
           rep_flit_in=16'hc280;
           ic_download_state_in=2'b10;//ic_busy
           dc_download_state_in=2'b01;
           mem_download_state_in=2'b00;
           
           `clk_step
        
           in_req_rdy=1'b1;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b10;
           rep_ctrl_in=2'b01;
           req_flit_in=16'hc2de;
           rep_flit_in=16'hc280;
           ic_download_state_in=2'b10;//ic_busy
           dc_download_state_in=2'b01;
           mem_download_state_in=2'b00;
           
            ////now ic_donwload is idle
           `clk_step
        
           in_req_rdy=1'b1;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b11;
           rep_ctrl_in=2'b01;
           req_flit_in=16'hc3de;
           rep_flit_in=16'hc280;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b01;
           mem_download_state_in=2'b00;
           
          
           `clk_step
        
           in_req_rdy=1'b1;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b01;
           rep_ctrl_in=2'b10;
           req_flit_in=16'hc0df;
           rep_flit_in=16'hc0de;
           ic_download_state_in=2'b01;//ic_busy
           dc_download_state_in=2'b10;//dc_rdy
           mem_download_state_in=2'b00;
           
            `clk_step
        
           in_req_rdy=1'b1;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b01;
           rep_ctrl_in=2'b10;
           req_flit_in=16'hc0df;
           rep_flit_in=16'hc1de;
           ic_download_state_in=2'b01;//ic_busy
           dc_download_state_in=2'b10;//dc_rdy
           mem_download_state_in=2'b00;
           
           `clk_step
        
           in_req_rdy=1'b1;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b01;
           rep_ctrl_in=2'b11;
           req_flit_in=16'hc0df;
           rep_flit_in=16'hc2de;
           ic_download_state_in=2'b01;//ic_busy
           dc_download_state_in=2'b10;//dc_rdy
           mem_download_state_in=2'b00;
           
            `clk_step
        ////////////////////////////////////////////////////////////
        ////////////second case :ic rep flit and mem req come ///////
         
          ///both mem and ic idle
          `clk_step
        
           in_req_rdy=1'b1;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b01;
           rep_ctrl_in=2'b01;
           req_flit_in=16'hfed0;
           rep_flit_in=16'hc280;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b00;//dc_idle
           mem_download_state_in=2'b00;//mem_idle
        
        ///second flits ,both ready
           `clk_step
           
           in_req_rdy=1'b1;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b10;
           rep_ctrl_in=2'b10;
           req_flit_in=16'h1234;
           rep_flit_in=16'hc380;
           ic_download_state_in=2'b01;//ic_busy
           dc_download_state_in=2'b01;//dc_busy
           mem_download_state_in=2'b00;//mem_idle
           
           ///3rd flits ,both ready
           `clk_step
           
           in_req_rdy=1'b1;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b10;
           rep_ctrl_in=2'b10;
           req_flit_in=16'habcd;
           rep_flit_in=16'hc480;
           ic_download_state_in=2'b01;//ic_busy
           dc_download_state_in=2'b01;//dc_busy
           mem_download_state_in=2'b00;//mem_idle
           
           ////after a while ,last flits both come
           
           `clk_step
           
           in_req_rdy=1'b1;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b11;
           rep_ctrl_in=2'b11;
           req_flit_in=16'hfed8;
           rep_flit_in=16'hc580;
           ic_download_state_in=2'b01;//ic_busy
           dc_download_state_in=2'b01;//dc_busy
           mem_download_state_in=2'b00;//mem_idle
           
           ///this time make mem rdy for a moment
           
            //first flit to ic and mem download is ready for mem now
           `clk_step
        
           in_req_rdy=1'b1;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b01;
           rep_ctrl_in=2'b01;
           req_flit_in=16'hfed0;
           rep_flit_in=16'hc280;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b00;//dc_idle
           mem_download_state_in=2'b10;//mem_rdy
           
             //second flit to ic and mem is still rdy for m_dl
             `clk_step
        
           in_req_rdy=1'b1;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b01;
           rep_ctrl_in=2'b10;
           req_flit_in=16'hfed0;
           rep_flit_in=16'hc380;
           ic_download_state_in=2'b01;//ic_busy
           dc_download_state_in=2'b00;//dc_idle
           mem_download_state_in=2'b10;//mem_rdy
           
           //third flit to ic and first flit to mem
           `clk_step
        
           in_req_rdy=1'b1;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b01;
           rep_ctrl_in=2'b10;
           req_flit_in=16'hfed0;
           rep_flit_in=16'hc480;
           ic_download_state_in=2'b01;//ic_busy
           dc_download_state_in=2'b00;//dc_idle
           mem_download_state_in=2'b00;//mem_idle
           
           //4th to ic and 2nd to mem
           
           `clk_step
        
           in_req_rdy=1'b1;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b10;
           rep_ctrl_in=2'b10;
           req_flit_in=16'h1234;
           rep_flit_in=16'hc580;
           ic_download_state_in=2'b01;//ic_busy
           dc_download_state_in=2'b00;//dc_idle
           mem_download_state_in=2'b01;//mem_busy
           
           //last to ic and 7th to mem
           `clk_step
        
           in_req_rdy=1'b1;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b10;
           rep_ctrl_in=2'b11;
           req_flit_in=16'habcd;
           rep_flit_in=16'hc980;
           ic_download_state_in=2'b01;//ic_busy
           dc_download_state_in=2'b00;//dc_idle
           mem_download_state_in=2'b01;//mem_busy
           
           //no flit to ic and last to mem
           `clk_step
        
           in_req_rdy=1'b1;
           in_rep_rdy=1'b0;
           req_ctrl_in=2'b11;
           rep_ctrl_in=2'b00;
           req_flit_in=16'h1357;
           rep_flit_in=16'hc980;
           ic_download_state_in=2'b10;//ic_rdy
           dc_download_state_in=2'b00;//dc_idle
           mem_download_state_in=2'b01;//mem_busy
           
        ////////////////////////////////////////////////////////////
        ///////////third case: only ic comes !//////////////////////
           
           `clk_step
        
           in_req_rdy=1'b0;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b00;
           rep_ctrl_in=2'b01;
           req_flit_in=16'h1234;
           rep_flit_in=16'hc280;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b00;//dc_idle
           mem_download_state_in=2'b00;//mem_idle
           
           `clk_step
        
           in_req_rdy=1'b0;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b00;
           rep_ctrl_in=2'b10;
           req_flit_in=16'h1234;
           rep_flit_in=16'hc380;
           ic_download_state_in=2'b01;//ic_idle
           dc_download_state_in=2'b00;//dc_idle
           mem_download_state_in=2'b00;//mem_idle
           
           `clk_step
        
           in_req_rdy=1'b0;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b00;
           rep_ctrl_in=2'b10;
           req_flit_in=16'h1234;
           rep_flit_in=16'hc480;
           ic_download_state_in=2'b01;//ic_idle
           dc_download_state_in=2'b00;//dc_idle
           mem_download_state_in=2'b00;//mem_idle
           
           `clk_step
        
           in_req_rdy=1'b0;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b00;
           rep_ctrl_in=2'b11;
           req_flit_in=16'h1234;
           rep_flit_in=16'hc580;
           ic_download_state_in=2'b01;//ic_idle
           dc_download_state_in=2'b00;//dc_idle
           mem_download_state_in=2'b00;//mem_idle
        ////////////////////////////////////////////////////////////
        ///////////4th case: dc rep and mem req come////////////////
        
           `clk_step
        
           in_req_rdy=1'b1;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b01;
           rep_ctrl_in=2'b01;
           req_flit_in=16'hfed0;
           rep_flit_in=16'hc0de;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b00;//dc_idle
           mem_download_state_in=2'b00;//mem_idle
           
           `clk_step
        
           in_req_rdy=1'b1;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b10;
           rep_ctrl_in=2'b10;
           req_flit_in=16'hfed1;
           rep_flit_in=16'hc1de;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b01;//dc_busy
           mem_download_state_in=2'b01;//mem_busy
           
           `clk_step
        
           in_req_rdy=1'b1;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b10;
           rep_ctrl_in=2'b10;
           req_flit_in=16'hfed2;
           rep_flit_in=16'hc2de;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b01;//dc_busy
           mem_download_state_in=2'b01;//mem_busy
           
           `clk_step
        
           in_req_rdy=1'b1;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b10;
           rep_ctrl_in=2'b10;
           req_flit_in=16'hfed3;
           rep_flit_in=16'hc3de;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b01;//dc_busy
           mem_download_state_in=2'b01;//mem_busy
           
           `clk_step
        
           in_req_rdy=1'b1;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b10;
           rep_ctrl_in=2'b11;
           req_flit_in=16'hfed4;
           rep_flit_in=16'hc4de;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b01;//dc_busy
           mem_download_state_in=2'b01;//mem_busy
           
           `clk_step
        
           in_req_rdy=1'b1;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b10;
           rep_ctrl_in=2'b01;
           req_flit_in=16'hfed5;
           rep_flit_in=16'hc5de;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b10;//dc_rdy
           mem_download_state_in=2'b01;//mem_busy
           
           `clk_step
        
           in_req_rdy=1'b1;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b11;
           rep_ctrl_in=2'b01;
           req_flit_in=16'hfed4;
           rep_flit_in=16'hc4de;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b10;//dc_rdy
           mem_download_state_in=2'b01;//mem_busy
           
        ////////////////////////////////////////////////////////////
        ///////////5th case: mem rep and dc req come/////////////////
           
           `clk_step
        
           in_req_rdy=1'b1;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b01;
           rep_ctrl_in=2'b01;
           req_flit_in=16'hc0de;
           rep_flit_in=16'hfed0;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b00;//dc_idle
           mem_download_state_in=2'b00;//mem_idle
           
           `clk_step
        
           in_req_rdy=1'b1;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b10;
           rep_ctrl_in=2'b10;
           req_flit_in=16'hc1de;
           rep_flit_in=16'hfed1;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b01;//dc_busy
           mem_download_state_in=2'b01;//mem_busy
           
           `clk_step
        
           in_req_rdy=1'b1;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b10;
           rep_ctrl_in=2'b10;
           req_flit_in=16'hc2de;
           rep_flit_in=16'hfed2;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b01;//dc_busy
           mem_download_state_in=2'b01;//mem_busy
           
           `clk_step
        
           in_req_rdy=1'b1;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b11;
           rep_ctrl_in=2'b10;
           req_flit_in=16'hc3de;
           rep_flit_in=16'hfed3;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b01;//dc_busy
           mem_download_state_in=2'b01;//mem_busy
           
           `clk_step
        
           in_req_rdy=1'b1;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b01;
           rep_ctrl_in=2'b11;
           req_flit_in=16'hc0de;
           rep_flit_in=16'hfed4;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b10;//dc_rdy
           mem_download_state_in=2'b01;//mem_busy
           
        ////////////////////////////////////////////////////////////
        ///////////6th case:dc rep and dc req come!/////////////////
           
           // both come  and dc rep win
           `clk_step
        
           in_req_rdy=1'b1;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b01;
           rep_ctrl_in=2'b01;
           req_flit_in=16'hc0de;
           rep_flit_in=16'hc0ef;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b00;//dc_idle
           mem_download_state_in=2'b00;//mem_idle
           
           `clk_step
        
           in_req_rdy=1'b1;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b01;
           rep_ctrl_in=2'b10;
           req_flit_in=16'hc0de;
           rep_flit_in=16'hc1ef;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b01;//dc_busy
           mem_download_state_in=2'b01;//mem_idle
           
           `clk_step
        
           in_req_rdy=1'b1;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b01;
           rep_ctrl_in=2'b10;
           req_flit_in=16'hc0de;
           rep_flit_in=16'hc2ef;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b01;//dc_busy
           mem_download_state_in=2'b01;//mem_idle
           
           `clk_step
        
           in_req_rdy=1'b1;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b01;
           rep_ctrl_in=2'b11;
           req_flit_in=16'hc0de;
           rep_flit_in=16'hc3ef;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b01;//dc_busy
           mem_download_state_in=2'b01;//mem_idle
           
           `clk_step
           `clk_step
           `clk_step
           `clk_step
           
           /////////////////////////////
           //it's turn of dc req//////// 
           in_req_rdy=1'b1;
           in_rep_rdy=1'b0;
           req_ctrl_in=2'b01;
           rep_ctrl_in=2'b01;
           req_flit_in=16'hc0de;
           rep_flit_in=16'hc3ef;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b00;//dc_idle
           mem_download_state_in=2'b00;//mem_idle
           
           `clk_step
           
           in_req_rdy=1'b1;
           in_rep_rdy=1'b0;
           req_ctrl_in=2'b10;
           rep_ctrl_in=2'b01;
           req_flit_in=16'hc1de;
           rep_flit_in=16'hc3ef;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b01;//dc_busy
           mem_download_state_in=2'b01;//mem_idle
           
           `clk_step
           
           in_req_rdy=1'b1;
           in_rep_rdy=1'b0;
           req_ctrl_in=2'b10;
           rep_ctrl_in=2'b01;
           req_flit_in=16'hc2de;
           rep_flit_in=16'hc3ef;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b01;//dc_busy
           mem_download_state_in=2'b01;//mem_idle
           
           `clk_step
           
           in_req_rdy=1'b1;
           in_rep_rdy=1'b0;
           req_ctrl_in=2'b11;
           rep_ctrl_in=2'b01;
           req_flit_in=16'hc2de;
           rep_flit_in=16'hc4ef;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b01;//dc_busy
           mem_download_state_in=2'b01;//mem_idle
           
           //next cycle dc_rdy
           
        ////////////////////////////////////////////////////////////
        ///////////7th case:mem rep and mem req come////////////////
           
           // both come  and mem rep win
           `clk_step
        
           in_req_rdy=1'b1;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b01;
           rep_ctrl_in=2'b01;
           req_flit_in=16'hfed0;
           rep_flit_in=16'hfeb0;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b00;//dc_idle
           mem_download_state_in=2'b00;//mem_idle
           
           `clk_step
        
           in_req_rdy=1'b1;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b01;
           rep_ctrl_in=2'b10;
           req_flit_in=16'hfed0;
           rep_flit_in=16'hfeb1;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b00;//dc_busy
           mem_download_state_in=2'b01;//mem_idle
           
           `clk_step
        
           in_req_rdy=1'b1;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b01;
           rep_ctrl_in=2'b10;
           req_flit_in=16'hfed0;
           rep_flit_in=16'hfeb2;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b00;//dc_busy
           mem_download_state_in=2'b01;//mem_idle
           
           `clk_step
        
           in_req_rdy=1'b1;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b01;
           rep_ctrl_in=2'b11;
           req_flit_in=16'hfed0;
           rep_flit_in=16'hfeb3;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b00;//dc_idle
           mem_download_state_in=2'b01;//mem_busy
           
           `clk_step
           
           in_req_rdy=1'b1;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b01;
           rep_ctrl_in=2'b01;
           req_flit_in=16'hfed0;
           rep_flit_in=16'hfeb3;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b00;//dc_idle
           mem_download_state_in=2'b01;//mem_busy
           
           `clk_step
           `clk_step
           `clk_step
           
           /////////////////////////////
           //it's turn of dc req//////// 
           in_req_rdy=1'b1;
           in_rep_rdy=1'b0;
           req_ctrl_in=2'b01;
           rep_ctrl_in=2'b01;
           req_flit_in=16'hfed0;
           rep_flit_in=16'hfeb3;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b00;//dc_idle
           mem_download_state_in=2'b00;//mem_idle
           
           `clk_step
           
           in_req_rdy=1'b1;
           in_rep_rdy=1'b0;
           req_ctrl_in=2'b10;
           rep_ctrl_in=2'b01;
           req_flit_in=16'hfed1;
           rep_flit_in=16'hfeb3;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b00;//dc_idle
           mem_download_state_in=2'b01;//mem_busy
           
           `clk_step
           
           in_req_rdy=1'b1;
           in_rep_rdy=1'b0;
           req_ctrl_in=2'b10;
           rep_ctrl_in=2'b01;
           req_flit_in=16'hfed2;
           rep_flit_in=16'hfeb3;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b01;//dc_idle
           mem_download_state_in=2'b01;//mem_busy
           
           `clk_step
           
           in_req_rdy=1'b1;
           in_rep_rdy=1'b0;
           req_ctrl_in=2'b11;
           rep_ctrl_in=2'b01;
           req_flit_in=16'hfed3;
           rep_flit_in=16'hfeb0;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b00;//dc_busy
           mem_download_state_in=2'b01;//mem_busy
           
           //mem will reject coming flit whatever kind
           
        ////////////////////////////////////////////////////////////
        //////////8th case:only dc rep comes////////////////////////
           `clk_step
        
           in_req_rdy=1'b0;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b01;
           rep_ctrl_in=2'b01;
           req_flit_in=16'hc0de;
           rep_flit_in=16'hc0ef;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b00;//dc_idle
           mem_download_state_in=2'b00;//mem_idle
           
           `clk_step
        
           in_req_rdy=1'b0;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b01;
           rep_ctrl_in=2'b10;
           req_flit_in=16'hc0de;
           rep_flit_in=16'hc1ef;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b01;//dc_busy
           mem_download_state_in=2'b01;//mem_idle
           
           `clk_step
        
           in_req_rdy=1'b0;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b01;
           rep_ctrl_in=2'b10;
           req_flit_in=16'hc0de;
           rep_flit_in=16'hc2ef;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b01;//dc_busy
           mem_download_state_in=2'b01;//mem_idle
           
           `clk_step
        
           in_req_rdy=1'b0;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b01;
           rep_ctrl_in=2'b11;
           req_flit_in=16'hc0de;
           rep_flit_in=16'hc3ef;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b01;//dc_busy
           mem_download_state_in=2'b01;//mem_idle
           
        ////////////////////////////////////////////////////////////
        ///////////9th case:only dc req come////////////////////////
           
           `clk_step
        
           in_req_rdy=1'b1;
           in_rep_rdy=1'b0;
           req_ctrl_in=2'b01;
           rep_ctrl_in=2'b01;
           req_flit_in=16'hc0de;
           rep_flit_in=16'hc0ef;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b00;//dc_idle
           mem_download_state_in=2'b00;//mem_idle
           
           `clk_step
        
           in_req_rdy=1'b1;
           in_rep_rdy=1'b0;
           req_ctrl_in=2'b01;
           rep_ctrl_in=2'b10;
           req_flit_in=16'hc0de;
           rep_flit_in=16'hc1ef;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b01;//dc_busy
           mem_download_state_in=2'b01;//mem_idle
           
           `clk_step
        
           in_req_rdy=1'b1;
           in_rep_rdy=1'b0;
           req_ctrl_in=2'b01;
           rep_ctrl_in=2'b10;
           req_flit_in=16'hc0de;
           rep_flit_in=16'hc2ef;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b01;//dc_busy
           mem_download_state_in=2'b01;//mem_idle
           
           `clk_step
        
           in_req_rdy=1'b1;
           in_rep_rdy=1'b0;
           req_ctrl_in=2'b01;
           rep_ctrl_in=2'b11;
           req_flit_in=16'hc0de;
           rep_flit_in=16'hc3ef;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b01;//dc_busy
           mem_download_state_in=2'b01;//mem_idle
        ////////////////////////////////////////////////////////////
        ///////////10th case:only mem rep comes/////////////////////
           
           `clk_step
        
           in_req_rdy=1'b0;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b01;
           rep_ctrl_in=2'b01;
           req_flit_in=16'hfed0;
           rep_flit_in=16'hfeb0;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b00;//dc_idle
           mem_download_state_in=2'b00;//mem_idle
           
           `clk_step
        
           in_req_rdy=1'b0;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b01;
           rep_ctrl_in=2'b10;
           req_flit_in=16'hfed0;
           rep_flit_in=16'hfeb1;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b00;//dc_busy
           mem_download_state_in=2'b01;//mem_idle
           
           `clk_step
        
           in_req_rdy=1'b0;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b01;
           rep_ctrl_in=2'b10;
           req_flit_in=16'hfed0;
           rep_flit_in=16'hfeb2;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b00;//dc_busy
           mem_download_state_in=2'b01;//mem_idle
           
           `clk_step
        
           in_req_rdy=1'b0;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b01;
           rep_ctrl_in=2'b11;
           req_flit_in=16'hfed0;
           rep_flit_in=16'hfeb3;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b00;//dc_idle
           mem_download_state_in=2'b01;//mem_busy
           
           `clk_step
           
           in_req_rdy=1'b0;
           in_rep_rdy=1'b1;
           req_ctrl_in=2'b01;
           rep_ctrl_in=2'b01;
           req_flit_in=16'hfed0;
           rep_flit_in=16'hfeb3;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b00;//dc_idle
           mem_download_state_in=2'b01;//mem_busy
        ////////////////////////////////////////////////////////////
        ////////////11th case: only mem req comes //////////////////
           `clk_step
        
           in_req_rdy=1'b1;
           in_rep_rdy=1'b0;
           req_ctrl_in=2'b01;
           rep_ctrl_in=2'b01;
           req_flit_in=16'hfed0;
           rep_flit_in=16'hfeb0;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b00;//dc_idle
           mem_download_state_in=2'b00;//mem_idle
           
           `clk_step
        
           in_req_rdy=1'b1;
           in_rep_rdy=1'b0;
           req_ctrl_in=2'b01;
           rep_ctrl_in=2'b10;
           req_flit_in=16'hfed0;
           rep_flit_in=16'hfeb1;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b00;//dc_busy
           mem_download_state_in=2'b01;//mem_idle
           
           `clk_step
        
           in_req_rdy=1'b1;
           in_rep_rdy=1'b0;
           req_ctrl_in=2'b01;
           rep_ctrl_in=2'b10;
           req_flit_in=16'hfed0;
           rep_flit_in=16'hfeb2;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b00;//dc_busy
           mem_download_state_in=2'b01;//mem_idle
           
           `clk_step
        
           in_req_rdy=1'b1;
           in_rep_rdy=1'b0;
           req_ctrl_in=2'b01;
           rep_ctrl_in=2'b11;
           req_flit_in=16'hfed0;
           rep_flit_in=16'hfeb3;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b00;//dc_idle
           mem_download_state_in=2'b01;//mem_busy
           
           `clk_step
           
           in_req_rdy=1'b1;
           in_rep_rdy=1'b0;
           req_ctrl_in=2'b01;
           rep_ctrl_in=2'b01;
           req_flit_in=16'hfed0;
           rep_flit_in=16'hfeb3;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b00;//dc_idle
           mem_download_state_in=2'b01;//mem_busy
        ////////////////////////////////////////////////////////////
        /////////////12th case: nothing comes///////////////////////
          `clk_step
        
           in_req_rdy=1'b0;
           in_rep_rdy=1'b0;
           req_ctrl_in=2'b01;
           rep_ctrl_in=2'b01;
           req_flit_in=16'hfed0;
           rep_flit_in=16'hfeb0;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b00;//dc_idle
           mem_download_state_in=2'b00;//mem_idle
           
           `clk_step
        
           in_req_rdy=1'b0;
           in_rep_rdy=1'b0;
           req_ctrl_in=2'b01;
           rep_ctrl_in=2'b10;
           req_flit_in=16'hfed0;
           rep_flit_in=16'hfeb1;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b00;//dc_busy
           mem_download_state_in=2'b01;//mem_idle
           
           `clk_step
        
           in_req_rdy=1'b0;
           in_rep_rdy=1'b0;
           req_ctrl_in=2'b01;
           rep_ctrl_in=2'b10;
           req_flit_in=16'hfed0;
           rep_flit_in=16'hfeb2;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b00;//dc_busy
           mem_download_state_in=2'b01;//mem_idle
           
           `clk_step
        
           in_req_rdy=1'b0;
           in_rep_rdy=1'b0;
           req_ctrl_in=2'b01;
           rep_ctrl_in=2'b11;
           req_flit_in=16'hfed0;
           rep_flit_in=16'hfeb3;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b00;//dc_idle
           mem_download_state_in=2'b01;//mem_busy
           
           `clk_step
           
           in_req_rdy=1'b0;
           in_rep_rdy=1'b0;
           req_ctrl_in=2'b01;
           rep_ctrl_in=2'b01;
           req_flit_in=16'hfed0;
           rep_flit_in=16'hfeb3;
           ic_download_state_in=2'b00;//ic_idle
           dc_download_state_in=2'b00;//dc_idle
           mem_download_state_in=2'b01;//mem_busy
           
           `clk_step
           
           $display("FINISH TEST!");
           $fdisplay(log_file,"FINISH TEST!");
           $stop;
           
         end
      endmodule
      