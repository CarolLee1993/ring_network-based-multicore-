/*******************************************************************
date:2016/3/31
designer:ZhaiShaoMin
module name:tb_m_rep_upload
module function :find out bugs in m_rep_upload
********************************************************************/

`timescale 1ns/1ps

module  tb_m_rep_upload();
  
    
//input
reg                          clk;
reg                          rst;
reg         [175:0]          m_flits_rep;
reg                          v_m_flits_rep;
reg         [3:0]            flits_max;
reg                          en_flits_max;
reg                          rep_fifo_rdy;

//output
wire        [15:0]            m_flit_out;
wire                          v_m_flit_out;
wire        [1:0]             m_ctrl_out;
wire                          m_rep_upload_state;

m_rep_upload        uut(//input
                        .clk(clk),
                        .rst(rst),
                        .m_flits_rep(m_flits_rep),
                        .v_m_flits_rep(v_m_flits_rep),
                        .flits_max(flits_max),
                        .en_flits_max(en_flits_max),
                        .rep_fifo_rdy(rep_fifo_rdy),
                        //output
                        .m_flit_out(m_flit_out),
                        .v_m_flit_out(v_m_flit_out),
								        .m_ctrl_out(m_ctrl_out),
                        .m_rep_upload_state(m_rep_upload_state)
                        );
   //initial inputs
   
   initial begin
        clk=1'b0;
        rst=1'b1;
        m_flits_rep=144'h0000_0000_0000_0000_0000_0000_0000_0000_0000;
        v_m_flits_rep=1'b0;
        en_flits_max=1'b0;
        flits_max=1'b1;
        rep_fifo_rdy=1'b0;
      end
      
      `define clk_step # 14;
      
      always #7 clk=~clk;
      
      /////////////////////////////////////////////////////////////
      ////////////////////////////BEGIN TEST!//////////////////////
      
      initial begin
        
        `clk_step
        
        rst=1'b0;
        
        `clk_step
        /////////////////////////////////////////////////////////////
        //////////1st case: a msg which is only one flit long////////
        en_flits_max=1'b1;
        flits_max=4'b0000;
        rep_fifo_rdy=1'b1;
        
        `clk_step
        en_flits_max=1'b0;
        m_flits_rep=144'hc0de_c1de_c2de_c3de_c4de_c5de_c6de_c7de_c8de;
        v_m_flits_rep=1'b1;
        
        `clk_step
        //since rey fifo is ready to receive flit ,so the only flit is poped to rep fifo
        v_m_flits_rep=1'b0;
        `clk_step
        //this cycle m_rep_upload is idle
        
        //in the meantime, preparing for next msg
        en_flits_max=1'b1;
        flits_max=4'b0010;
        
        /////////////////////////////////////////////////////////////
        /////////////2nd case: a msg with 3 flits is coming!/////////
        
        `clk_step
        
        v_m_flits_rep=1'b1;
        m_flits_rep=144'habc1_abc2_abc3_abc4_abc5_abc6_abc7_abc8_abc9;
        
        `clk_step
        ///the 1st flit is transfered to rep fifo
        
        `clk_step
        ///this cycle rep fifo become full ,so 2nd flit still sit  in the regs of m_upload
        rep_fifo_rdy=1'b0;
        `clk_step
        //still full
        
        `clk_step
        //still full
        
        `clk_step
        //rep fifo become not full! And 2nd flit can be transfered to rep fifo
        rep_fifo_rdy=1'b1;
        
        `clk_step
        ///3rd flit also last flit to rep fifo
        
        `clk_step
        /// m_rep_upload become idle
        
        //////////////////////////////////////////////////////////////////
        //////////// 3rd case: a msg with 9 flits is coming!//////////////
        `clk_step
        en_flits_max=1'b1;
        flits_max=4'b1000;
        
        `clk_step
        m_flits_rep=144'h0123_1234_2345_3456_4567_5678_6789_7890_8901;
        v_m_flits_rep=1'b1;
        
        `clk_step
        //since rep fifo is ready to receive flit, first flit will get out of m_rep_upload!
        
        `clk_step
        //2nd flit get out
        
        `clk_step
        //3rd flit get out
        
        `clk_step
        ////rep fifo become full
        rep_fifo_rdy=1'b0;
        
        `clk_step
        //still full
        
        `clk_step
        `clk_step
        `clk_step
        `clk_step
        `clk_step
        `clk_step
        `clk_step
        `clk_step
        
        `clk_step
        //rep fifo has empty slots now! And 4th flit get to rep fifo
        rep_fifo_rdy=1'b1;
        
        `clk_step
        //5th flit get out
        
        `clk_step
        //full again!
        rep_fifo_rdy=1'b0;
        
        `clk_step
        //rep fifo has empty slots now! And 6th flit get to rep fifo
        rep_fifo_rdy=1'b1;
        
        `clk_step
        //7th get out 
        
        `clk_step
        //8th get out 
        
        `clk_step
        //9th get out
        
        `clk_step
        //////m_rep_upload become idle now !
        
        `clk_step
        
        $stop;
      end
  endmodule
          
        
        
        
      