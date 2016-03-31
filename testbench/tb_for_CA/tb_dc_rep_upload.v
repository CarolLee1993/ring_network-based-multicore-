/*******************************************************************
date:2016/3/31
designer:ZhaiShaoMin
module name:tb_dc_rep_upload
module function:find out errors in the design unit
********************************************************************/
`timescale 1ns/1ps

module tb_dc_rep_upload();
  
//input
reg                          clk;
reg                          rst;
reg         [175:0]          dc_flits_rep;
reg                          v_dc_flits_rep;
reg         [3:0]            flits_max;
reg                          en_flits_max;
reg                          rep_fifo_rdy;
//output
wire        [15:0]            dc_flit_out;
wire                          v_dc_flit_out;
wire        [1:0]             dc_ctrl_out;
wire                          dc_rep_upload_state;

//instante
dc_rep_upload          uut(//input
                          .clk(clk),
                          .rst(rst),
                          .dc_flits_rep(dc_flits_rep),
                          .v_dc_flits_rep(v_dc_flits_rep),
                          .flits_max(flits_max),
                          .en_flits_max(en_flits_max),
                          .rep_fifo_rdy(rep_fifo_rdy),
                          //output
                          .dc_flit_out(dc_flit_out),
                          .v_dc_flit_out(v_dc_flit_out),
								          .dc_ctrl_out(dc_ctrl_out),
                          .dc_rep_upload_state(dc_rep_upload_state)
                          );
                          
  //initial inputs
  initial begin
    
     clk=1'b0;
     rst=1'b1;
     dc_flits_rep=176'h0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
     v_dc_flits_rep=1'b0;
     en_flits_max=1'b0;
     flits_max=4'b0000;
     rep_fifo_rdy=1'b0;
   end
   
   `define clk_step #14;
   
   always #7 clk=~clk;
   
   //////////////////////////////////////////////////////////////////
   ////////////BEGIN TEST////////////////////////////////////////////
   
   initial begin
   
        `clk_step
        
        rst=1'b0; 
        
        `clk_step
        
        ////////////////////////////////////////////////////////////////
        //////////////1st case:one flit long msg such as C2Cinvrep//////                       
                  
                  ///this time dc_flits_rep is not ready
                  dc_flits_rep=176'h2011_2010_2009_2008_2007_2006_2005_2004_2003_2002_2001;
                  v_dc_flits_rep=1'b0;
                  en_flits_max=1'b1;
                  flits_max=4'b0001;
                  rep_fifo_rdy=1'b1;
                          
                  `clk_step
                  
                  ///this cycle dc_flits_rep is ready !
                  dc_flits_rep=176'h2011_2010_2009_2008_2007_2006_2005_2004_2003_2002_2001;
                  v_dc_flits_rep=1'b1;
                  en_flits_max=1'b0;
                  flits_max=4'b0000;
                  rep_fifo_rdy=1'b1;
                          
                  `clk_step
                  
                  ///by the end of this cycle ,the upload will be empty for that's a one-flit msg
                  dc_flits_rep=176'h2016_2015_2014_2013_2012_2011_2010_2009_2008_2007_2006;                v_dc_flits_rep=1'b1;
                  en_flits_max=1'b0;
                  flits_max=4'b0000;
                  rep_fifo_rdy=1'b1;
                   
                   `clk_step
                   
                   ///next six cycles there is no valid msg coming!
                   v_dc_flits_rep=1'b0;       
                   
                   `clk_step
                             
                   `clk_step
                                
                   `clk_step
                                
                   `clk_step
                          
                   `clk_step      
                   
              ////////////////////////////////////////////////////////////////////////////////
              /////////2nd case: 9-flits msg is coming!///////////////////////////////////////
                   en_flits_max=1'b1;
                   flits_max=4'b1000;
                   
                   `clk_step
                   
                   v_dc_flits_rep=1'b1;
                   dc_flits_rep=176'hc0de_c1de_c2de_c3de_c4de_c5de_c6de_c7de_c8de_c9de_cade;
                   
                   `clk_step
                   
                   v_dc_flits_rep=1'b0;
                   en_flits_max=1'b0;
                   //first flit is poped to rep fifo
                   `clk_step
                   //second flit is poped to rep fifo
                   `clk_step
                   // 3rd flit is poped to rep fifo
                   `clk_step
                   ///now assume that rep fifo is full
                    rep_fifo_rdy=1'b0;
                    
                   `clk_step 
                   ///now assume that rep fifo is full
                   `clk_step
                   
                   ///now assume that rep fifo is full
                   `clk_step
                   
                   ///now assume that rep fifo is full
                   `clk_step
                   
                   ///now assume that rep fifo is not full! And 4th flit is poped to rep fifo
                   `clk_step
                   rep_fifo_rdy=1'b1;
                   
                   `clk_step
                   ///5th flit is poped to rep fifo
                   
                   `clk_step
                   ///6th flit is poped to rep fifo
                   
                   `clk_step
                   ///7th flit is poped to rep fifo
                   
                   `clk_step
                   ///now assume rep fifo become full once again!
                   rep_fifo_rdy=1'b0;
                   
                   `clk_step
                   ///still full
                   
                   `clk_step
                   ///still full
                   
                   `clk_step
                   ///rep fifo is not full now! So the 8th flit is poped to rep fifo
                   rep_fifo_rdy=1'b1;
                    
                   `clk_step
                   /// the last flit is poped to rep fifo!
                   `clk_step
                   ///dc_rep_upload will be idle
                   
                   en_flits_max=1'b1;
                   flits_max=4'b1010;
                   rep_fifo_rdy=1'b0;
                   
                   `clk_step
                   
                ////////////////////////////////////////////////////////////////////////////
                //////////////3rd case: 11-flits msg is coming!/////////////////////////////
                   v_dc_flits_rep=1'b1;
                   dc_flits_rep=176'h0331_0401_0402_0403_0404_0405_0406_0407_0408_0409_040a;
                   
                   `clk_step
                   
                   //due to rep fifo being full,no flit poped to rep fifo
                   `clk_step
                   
                   `clk_step
                   
                   `clk_step
                   //now rep fifo become not full and first flit is poped to rep fifo
                   
                   `clk_step
                   //due to fifo being full ,second flit still sit in dc_rep_upload 
                   
                   `clk_step
                   //now rep fifo become not full , second flit is poped to rep fifo
                   
                   `clk_step
                   //3rd flit to rep fifo
                   
                   `clk_step
                   //4th flit to rep fifo
                   
                   `clk_step
                   //5th flit to reo fifo
                   
                   `clk_step
                   //6th flit ro rep fifo
                   
                   `clk_step
                   ///// rep fifo become full again!
                    rep_fifo_rdy=1'b0;
                   `clk_step
                   
                   `clk_step
                   
                   `clk_step
                   ///rep fifo changes to be not full, and 7th flit to rep fifo
                   rep_fifo_rdy=1'b1;
                   `clk_step
                   //8th flit to rep fifo
                   
                   `clk_step
                   //9th flit to rep fifo
                   
                   `clk_step
                   //10th flit to rep fifo
                   
                   `clk_step
                   //11th flit to rep fifo
                   
                   `clk_step
                   //////dc_rep_upload become idle!
                   `clk_step
                   
                   $stop;
                 end
              endmodule
              
                     
                                     