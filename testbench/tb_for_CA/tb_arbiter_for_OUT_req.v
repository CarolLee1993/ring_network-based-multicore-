/**********************************************************************
date:2016/3/26
designer:ZhaiShaoMin
project:ring network multicore
module name:tb_arbiter_OUT_rep
module function: figure out what's wrong with it
***********************************************************************/
`timescale 1ns/1ps

module tb_arbiter_for_OUT_req();


//input
reg                               clk;
reg                               rst;
reg                               OUT_req_rdy;
reg                               v_ic_req;
reg                               v_dc_req;
reg                               v_mem_req;
reg     [1:0]                     ic_req_ctrl;
reg     [1:0]                     dc_req_ctrl;
reg     [1:0]                     mem_req_ctrl;
//output
wire                               ack_OUT_req;
wire                               ack_ic_req;
wire                               ack_dc_req;
wire                               ack_mem_req;
wire   [2:0]                       select; // select 1/3


arbiter_for_OUT_req       uut(//input
                               .clk(clk),
                               .rst(rst),
                               .OUT_req_rdy(OUT_req_rdy),
                               .v_ic_req(v_ic_req),
                               .v_dc_req(v_dc_req),
                               .v_mem_req(v_mem_req),
                               .ic_req_ctrl(ic_req_ctrl),
                               .dc_req_ctrl(dc_req_ctrl),
                               .mem_req_ctrl(mem_req_ctrl),
                               //output
                               .ack_OUT_req(ack_OUT_req),
                               .ack_ic_req(ack_ic_req),
                               .ack_dc_req(ack_dc_req),
                               .ack_mem_req(ack_mem_req),
                               .select(select)
                               );
integer log_file;

//define task for compare expected outputs with actural outputs
task cmp_outputs;
   
   input         exp_ack_OUT_req;
   input         exp_ack_ic_req;
   input         exp_ack_dc_req;
   input         exp_ack_mem_req;
   input  [2:0]  exp_select;
   
   begin
     $display("Time:%t\n",$time);
     $fdisplay (log_file, "Time: %t\n", $time);
     
     if (ack_OUT_req != exp_ack_OUT_req)
        begin
          $display("ERROR: Invalid ack_OUT_req\n \t Expected: 0x%x \n \t Acutal: 0x%x", exp_ack_OUT_req,ack_OUT_req);
          $fdisplay(log_file,"ERROR: Invalid ack_OUT_req\n \t Expected: 0x%x \n \t Acutal: 0x%x", exp_ack_OUT_req,ack_OUT_req);
        end 
     
     if (ack_ic_req != exp_ack_ic_req)
        begin
          $display("ERROR: Invalid ack_ic_req\n \t Expected: 0x%x \n \t Acutal: 0x%x", exp_ack_ic_req,ack_ic_req);
          $fdisplay(log_file,"ERROR: Invalid ack_ic_req\n \t Expected: 0x%x \n \t Acutal: 0x%x", exp_ack_ic_req,ack_ic_req);
        end 
        
     if (ack_dc_req != exp_ack_dc_req)
        begin
          $display("ERROR: Invalid ack_dc_req\n \t Expected: 0x%x \n \t Acutal: 0x%x", exp_ack_dc_req,ack_dc_req);
          $fdisplay(log_file,"ERROR: Invalid ack_dc_req\n \t Expected: 0x%x \n \t Acutal: 0x%x", exp_ack_dc_req,ack_dc_req);
        end 
    
     if (ack_mem_req != exp_ack_mem_req)
        begin
          $display("ERROR: Invalid ack_mem_req\n \t Expected: 0x%x \n \t Acutal: 0x%x", exp_ack_mem_req,ack_mem_req);
          $fdisplay(log_file,"ERROR: Invalid ack_mem_req\n \t Expected: 0x%x \n \t Acutal: 0x%x", exp_ack_mem_req,ack_mem_req);
        end 
     
     if (select != exp_select)
        begin
          $display("ERROR: Invalid select\n \t Expected: 0x%x \n \t Acutal: 0x%x", exp_select,select);
          $fdisplay(log_file,"ERROR: Invalid select\n \t Expected: 0x%x \n \t Acutal: 0x%x", exp_select,select);
        end 
      
      if((ack_OUT_req != exp_ack_OUT_req)&&
         (ack_ic_req != exp_ack_ic_req)&&
         (ack_dc_req != exp_ack_dc_req)&&
         (ack_mem_req != exp_ack_mem_req)&&
         (select != exp_select))
         begin
           $display("passed test!");
           $fdisplay(log_file,"passed test!");
         end
      end
  endtask
  
  
//initial inputs
     initial begin
       clk=1'b0;
       rst=1'b1;
       OUT_req_rdy=1'b0;
       v_ic_req=1'b0;
       v_dc_req=1'b0;
       v_mem_req=1'b0;
       ic_req_ctrl=2'b00;
       dc_req_ctrl=2'b00;
       mem_req_ctrl=2'b00;
       log_file=$fopen("log_arbiter_for_OUT_req.txt");
     end
     
     `define clk_step #14;
     
     always #7 clk=~clk;
     
     //////////////////////////////////////////////////////////
     ///////////initial actural test : arbiter_for_OUT_req ////
     
     initial begin
       
       `clk_step
       
       $display("TEST BEGIN.......");
        $fdisplay(log_file,"TEST BEGIN.......");
        rst=1'b0;
        
        `clk_step
        
        ///////////////////////////////////////////////////////////////
        //First case: v_ic_req ,v_dc_req and v_mem_req are all valid///
        $display("First case: v_ic_req ,v_dc_req and v_mem_req are all valid");
        $fdisplay(log_file,"First case: v_ic_req ,v_dc_req and v_mem_req are all valid");
        $display("First try");
        $fdisplay(log_file,"First try");
        OUT_req_rdy=1'b0;
        v_ic_req=1'b1;
        v_dc_req=1'b1;
        v_mem_req=1'b1;
        ic_req_ctrl=2'b01;
        dc_req_ctrl=2'b01;
        mem_req_ctrl=2'b01;
        cmp_outputs(1'b0,  //exp_ack_OUT_req;
                    1'b0,  //exp_ack_ic_req;
                    1'b0,  //exp_ack_dc_req;
                    1'b0,  //exp_ack_mem_req;
                    3'b000  //exp_select;
                    );
        `clk_step
                    
        $display("2nd try : ic should win! ");
        $fdisplay(log_file,"2nd try : ic should win!");
        OUT_req_rdy=1'b1;
        v_ic_req=1'b1;
        v_dc_req=1'b1;
        v_mem_req=1'b1;
        ic_req_ctrl=2'b01;
        dc_req_ctrl=2'b01;
        mem_req_ctrl=2'b01;
        cmp_outputs(1'b1,  //exp_ack_OUT_req;
                    1'b1,  //exp_ack_ic_req;
                    1'b0,  //exp_ack_dc_req;
                    1'b0,  //exp_ack_mem_req;
                    3'b100  //exp_select;
                    );
                    
        `clk_step
                    
        $display("3rd try : ic should win! ");
        $fdisplay(log_file,"3rd try : ic should win!");
        OUT_req_rdy=1'b1;
        v_ic_req=1'b1;
        v_dc_req=1'b1;
        v_mem_req=1'b1;
        ic_req_ctrl=2'b10;
        dc_req_ctrl=2'b01;
        mem_req_ctrl=2'b01;
        cmp_outputs(1'b1,  //exp_ack_OUT_req;
                    1'b1,  //exp_ack_ic_req;
                    1'b0,  //exp_ack_dc_req;
                    1'b0,  //exp_ack_mem_req;
                    3'b100  //exp_select;
                    );
        
        `clk_step
                    
        $display("last try : ic should finish ! ");
        $fdisplay(log_file,"last try : ic should finish !");
        OUT_req_rdy=1'b1;
        v_ic_req=1'b1;
        v_dc_req=1'b1;
        v_mem_req=1'b1;
        ic_req_ctrl=2'b11;
        dc_req_ctrl=2'b01;
        mem_req_ctrl=2'b01;
        cmp_outputs(1'b1,  //exp_ack_OUT_req;
                    1'b1,  //exp_ack_ic_req;
                    1'b0,  //exp_ack_dc_req;
                    1'b0,  //exp_ack_mem_req;
                    3'b100  //exp_select;
                    );
                    
   /*     `clk_step
                    
        $display("last try :just test if ic has finish and mem win ! ");
        $fdisplay(log_file,"last try : if ic has finish and mem win !");
        OUT_req_rdy=1'b1;
        v_ic_req=1'b0;
        v_dc_req=1'b1;
        v_mem_req=1'b1;
        ic_req_ctrl=2'b00;
        dc_req_ctrl=2'b01;
        mem_req_ctrl=2'b01;
        cmp_outputs(1'b1,  //exp_ack_OUT_req;
                    1'b0,  //exp_ack_ic_req;
                    1'b0,  //exp_ack_dc_req;
                    1'b1,  //exp_ack_mem_req;
                    3'b001  //exp_select;
                    );
    */               
        /////////////////////////////////////////////////////////////////
        ///////2nd case :both mem and dc are valid! and mem will win!////
        /////////////////////////////////////////////////////////////////
        rst=1'b1;
        #7;
        rst=1'b0;
        #7;
        //clk_step
        
        $display("2nd case: v_dc_req and v_mem_req are  valid");
        $fdisplay(log_file,"2nd case: v_dc_req and v_mem_req are  valid");
        $display("First try");
        $fdisplay(log_file,"First try");
        OUT_req_rdy=1'b1;
        v_ic_req=1'b0;
        v_dc_req=1'b1;
        v_mem_req=1'b1;
        ic_req_ctrl=2'b00;
        dc_req_ctrl=2'b01;
        mem_req_ctrl=2'b01;
        cmp_outputs(1'b1,  //exp_ack_OUT_req;
                    1'b0,  //exp_ack_ic_req;
                    1'b0,  //exp_ack_dc_req;
                    1'b1,  //exp_ack_mem_req;
                    3'b001  //exp_select;
                    );
                    
        `clk_step
        
        $display("2nd try");
        $fdisplay(log_file,"2nd try");
        OUT_req_rdy=1'b1;
        v_ic_req=1'b0;
        v_dc_req=1'b1;
        v_mem_req=1'b1;
        ic_req_ctrl=2'b00;
        dc_req_ctrl=2'b01;
        mem_req_ctrl=2'b10;
        cmp_outputs(1'b1,  //exp_ack_OUT_req;
                    1'b0,  //exp_ack_ic_req;
                    1'b0,  //exp_ack_dc_req;
                    1'b1,  //exp_ack_mem_req;
                    3'b001  //exp_select;
                    );
        
        `clk_step
        
        $display("3rd try");
        $fdisplay(log_file,"3rd try");
        OUT_req_rdy=1'b1;
        v_ic_req=1'b0;
        v_dc_req=1'b1;
        v_mem_req=1'b1;
        ic_req_ctrl=2'b00;
        dc_req_ctrl=2'b01;
        mem_req_ctrl=2'b10;
        cmp_outputs(1'b1,  //exp_ack_OUT_req;
                    1'b0,  //exp_ack_ic_req;
                    1'b0,  //exp_ack_dc_req;
                    1'b1,  //exp_ack_mem_req;
                    3'b001  //exp_select;
                    );
        
        `clk_step
        
        $display("last try");
        $fdisplay(log_file,"last try");
        OUT_req_rdy=1'b1;
        v_ic_req=1'b0;
        v_dc_req=1'b1;
        v_mem_req=1'b1;
        ic_req_ctrl=2'b00;
        dc_req_ctrl=2'b01;
        mem_req_ctrl=2'b11;
        cmp_outputs(1'b1,  //exp_ack_OUT_req;
                    1'b0,  //exp_ack_ic_req;
                    1'b0,  //exp_ack_dc_req;
                    1'b1,  //exp_ack_mem_req;
                    3'b001  //exp_select;
                    );
        
        
        /////////////////////////////////////////////////////////////////////////////
        ////3rd case: both mem and dc are valid but it's dc's turn to transfer msg///
        `clk_step
        
        $display("3rd case: both mem and dc are valid but it's dc's turn to transfer msg\n also test for last try error");
        $fdisplay(log_file,"3rd case: both mem and dc are valid but it's dc's turn to transfer msg\n also test for last try error");
        $display("First try");
        $fdisplay(log_file,"First try");
        OUT_req_rdy=1'b1;
        v_ic_req=1'b0;
        v_dc_req=1'b1;
        v_mem_req=1'b1;
        ic_req_ctrl=2'b00;
        dc_req_ctrl=2'b01;
        mem_req_ctrl=2'b01;
        cmp_outputs(1'b1,  //exp_ack_OUT_req;
                    1'b0,  //exp_ack_ic_req;
                    1'b1,  //exp_ack_dc_req;
                    1'b0,  //exp_ack_mem_req;
                    3'b010  //exp_select;
                    ); 
                    
                    
        `clk_step
        
        $display("2nd try");
        $fdisplay(log_file,"2nd try");
        OUT_req_rdy=1'b1;
        v_ic_req=1'b0;
        v_dc_req=1'b1;
        v_mem_req=1'b1;
        ic_req_ctrl=2'b00;
        dc_req_ctrl=2'b10;
        mem_req_ctrl=2'b01;
        cmp_outputs(1'b1,  //exp_ack_OUT_req;
                    1'b0,  //exp_ack_ic_req;
                    1'b1,  //exp_ack_dc_req;
                    1'b0,  //exp_ack_mem_req;
                    3'b010  //exp_select;
                    ); 
        
        `clk_step
        
        $display("3rd try");
        $fdisplay(log_file,"3rd try");
        OUT_req_rdy=1'b1;
        v_ic_req=1'b0;
        v_dc_req=1'b1;
        v_mem_req=1'b1;
        ic_req_ctrl=2'b00;
        dc_req_ctrl=2'b10;
        mem_req_ctrl=2'b01;
        cmp_outputs(1'b1,  //exp_ack_OUT_req;
                    1'b0,  //exp_ack_ic_req;
                    1'b1,  //exp_ack_dc_req;
                    1'b0,  //exp_ack_mem_req;
                    3'b010  //exp_select;
                    );       
        
        // req fifo is not ready
        `clk_step
        
        $display("last try");
        $fdisplay(log_file,"last try");
        OUT_req_rdy=1'b0;
        v_ic_req=1'b0;
        v_dc_req=1'b1;
        v_mem_req=1'b1;
        ic_req_ctrl=2'b00;
        dc_req_ctrl=2'b11;
        mem_req_ctrl=2'b01;
        cmp_outputs(1'b0,  //exp_ack_OUT_req;
                    1'b0,  //exp_ack_ic_req;
                    1'b0,  //exp_ack_dc_req;
                    1'b0,  //exp_ack_mem_req;
                    3'b000  //exp_select;
                    );
        `clk_step
        
        $display("last try");
        $fdisplay(log_file,"last try");
        OUT_req_rdy=1'b1;
        v_ic_req=1'b0;
        v_dc_req=1'b1;
        v_mem_req=1'b1;
        ic_req_ctrl=2'b00;
        dc_req_ctrl=2'b11;
        mem_req_ctrl=2'b01;
        cmp_outputs(1'b1,  //exp_ack_OUT_req;
                    1'b0,  //exp_ack_ic_req;
                    1'b1,  //exp_ack_dc_req;
                    1'b0,  //exp_ack_mem_req;
                    3'b010  //exp_select;
                    );   
                    
        ///////////////////////////////////////////////////////////////
        ////4th case : only dc is valid!                          /////
        `clk_step
        
        $display("4th case : only dc is valid!\n also test for last try error");
        $fdisplay(log_file,"4th case : only dc is valid!\n also test for last try error");
        $display("First try");
        $fdisplay(log_file,"First try");
        OUT_req_rdy=1'b1;
        v_ic_req=1'b0;
        v_dc_req=1'b1;
        v_mem_req=1'b0;
        ic_req_ctrl=2'b00;
        dc_req_ctrl=2'b01;
        mem_req_ctrl=2'b00;
        cmp_outputs(1'b1,  //exp_ack_OUT_req;
                    1'b0,  //exp_ack_ic_req;
                    1'b1,  //exp_ack_dc_req;
                    1'b0,  //exp_ack_mem_req;
                    3'b010  //exp_select;
                    );
        
        `clk_step
        
        $display("2nd try");
        $fdisplay(log_file,"2nd try");
        OUT_req_rdy=1'b1;
        v_ic_req=1'b0;
        v_dc_req=1'b1;
        v_mem_req=1'b0;
        ic_req_ctrl=2'b00;
        dc_req_ctrl=2'b10;
        mem_req_ctrl=2'b01;
        cmp_outputs(1'b1,  //exp_ack_OUT_req;
                    1'b0,  //exp_ack_ic_req;
                    1'b1,  //exp_ack_dc_req;
                    1'b0,  //exp_ack_mem_req;
                    3'b010  //exp_select;
                    );
        
        //req fifo is not ready 
        `clk_step
        
        $display("2nd try");
        $fdisplay(log_file,"2nd try");
        OUT_req_rdy=1'b0;
        v_ic_req=1'b0;
        v_dc_req=1'b1;
        v_mem_req=1'b0;
        ic_req_ctrl=2'b00;
        dc_req_ctrl=2'b10;
        mem_req_ctrl=2'b01;
        cmp_outputs(1'b0,  //exp_ack_OUT_req;
                    1'b0,  //exp_ack_ic_req;
                    1'b0,  //exp_ack_dc_req;
                    1'b0,  //exp_ack_mem_req;
                    3'b000  //exp_select;
                    );       
        
        `clk_step
        
        $display("last try");
        $fdisplay(log_file,"last try");
        OUT_req_rdy=1'b1;
        v_ic_req=1'b0;
        v_dc_req=1'b1;
        v_mem_req=1'b0;
        ic_req_ctrl=2'b00;
        dc_req_ctrl=2'b11;
        mem_req_ctrl=2'b01;
        cmp_outputs(1'b1,  //exp_ack_OUT_req;
                    1'b0,  //exp_ack_ic_req;
                    1'b1,  //exp_ack_dc_req;
                    1'b0,  //exp_ack_mem_req;
                    3'b010  //exp_select;
                    );
                    
        ////////////////////////////////////////////////////////////
        ////5th case: only mem is valid !///////////////////////////
        
        `clk_step
        
        $display("1st try");
        $fdisplay(log_file,"1st try");
        OUT_req_rdy=1'b1; //doesn't matter
        v_ic_req=1'b0;
        v_dc_req=1'b0;
        v_mem_req=1'b1;
        ic_req_ctrl=2'b01;
        dc_req_ctrl=2'b01;
        mem_req_ctrl=2'b01;
        cmp_outputs(1'b1,  //exp_ack_OUT_req;
                    1'b0,  //exp_ack_ic_req;
                    1'b0,  //exp_ack_dc_req;
                    1'b1,  //exp_ack_mem_req;
                    3'b001  //exp_select;
                    );
        `clk_step
        
        $display("2nd try");
        $fdisplay(log_file,"2nd try");
        OUT_req_rdy=1'b1; //doesn't matter
        v_ic_req=1'b0;
        v_dc_req=1'b0;
        v_mem_req=1'b1;
        ic_req_ctrl=2'b01;
        dc_req_ctrl=2'b01;
        mem_req_ctrl=2'b10;
        cmp_outputs(1'b1,  //exp_ack_OUT_req;
                    1'b0,  //exp_ack_ic_req;
                    1'b0,  //exp_ack_dc_req;
                    1'b1,  //exp_ack_mem_req;
                    3'b001  //exp_select;
                    );
        /// req fifo is not ready!
        `clk_step
        
        $display("2nd try");
        $fdisplay(log_file,"2nd try");
        OUT_req_rdy=1'b0; //doesn't matter
        v_ic_req=1'b0;
        v_dc_req=1'b0;
        v_mem_req=1'b1;
        ic_req_ctrl=2'b01;
        dc_req_ctrl=2'b01;
        mem_req_ctrl=2'b10;
        cmp_outputs(1'b0,  //exp_ack_OUT_req;
                    1'b0,  //exp_ack_ic_req;
                    1'b0,  //exp_ack_dc_req;
                    1'b0,  //exp_ack_mem_req;
                    3'b000  //exp_select;
                    );
                    
        `clk_step
        
        $display("3rd try");
        $fdisplay(log_file,"3rd try");
        OUT_req_rdy=1'b1; //doesn't matter
        v_ic_req=1'b0;
        v_dc_req=1'b0;
        v_mem_req=1'b1;
        ic_req_ctrl=2'b01;
        dc_req_ctrl=2'b01;
        mem_req_ctrl=2'b11;
        cmp_outputs(1'b1,  //exp_ack_OUT_req;
                    1'b0,  //exp_ack_ic_req;
                    1'b0,  //exp_ack_dc_req;
                    1'b1,  //exp_ack_mem_req;
                    3'b001  //exp_select;
                    );
                    
       /////////////////////////////////////////////////
       ////both mem and ic are valid ///////////////////
       `clk_step
        
        $display("1st try");
        $fdisplay(log_file,"1st try");
        OUT_req_rdy=1'b1; //doesn't matter
        v_ic_req=1'b1;
        v_dc_req=1'b0;
        v_mem_req=1'b1;
        ic_req_ctrl=2'b01;
        dc_req_ctrl=2'b01;
        mem_req_ctrl=2'b01;
        cmp_outputs(1'b1,  //exp_ack_OUT_req;
                    1'b1,  //exp_ack_ic_req;
                    1'b0,  //exp_ack_dc_req;
                    1'b0,  //exp_ack_mem_req;
                    3'b100  //exp_select;
                    );
        `clk_step
        
        $display("2nd try");
        $fdisplay(log_file,"2nd try");
        OUT_req_rdy=1'b1; //doesn't matter
        v_ic_req=1'b1;
        v_dc_req=1'b0;
        v_mem_req=1'b1;
        ic_req_ctrl=2'b10;
        dc_req_ctrl=2'b01;
        mem_req_ctrl=2'b01;
        cmp_outputs(1'b1,  //exp_ack_OUT_req;
                    1'b1,  //exp_ack_ic_req;
                    1'b0,  //exp_ack_dc_req;
                    1'b0,  //exp_ack_mem_req;
                    3'b100  //exp_select;
                    );
        /// req fifo is not ready!
        `clk_step
        
        $display("2nd try");
        $fdisplay(log_file,"2nd try");
        OUT_req_rdy=1'b0; //doesn't matter
        v_ic_req=1'b1;
        v_dc_req=1'b0;
        v_mem_req=1'b1;
        ic_req_ctrl=2'b10;
        dc_req_ctrl=2'b01;
        mem_req_ctrl=2'b01;
        cmp_outputs(1'b0,  //exp_ack_OUT_req;
                    1'b0,  //exp_ack_ic_req;
                    1'b0,  //exp_ack_dc_req;
                    1'b0,  //exp_ack_mem_req;
                    3'b000  //exp_select;
                    );
                    
        `clk_step
        
        $display("3rd try");
        $fdisplay(log_file,"3rd try");
        OUT_req_rdy=1'b1; //doesn't matter
        v_ic_req=1'b1;
        v_dc_req=1'b0;
        v_mem_req=1'b1;
        ic_req_ctrl=2'b11;
        dc_req_ctrl=2'b01;
        mem_req_ctrl=2'b01;
        cmp_outputs(1'b1,  //exp_ack_OUT_req;
                    1'b1,  //exp_ack_ic_req;
                    1'b0,  //exp_ack_dc_req;
                    1'b0,  //exp_ack_mem_req;
                    3'b100  //exp_select;
                    );
        `clk_step
        $display("FINISH TEST!");
        $fdisplay(log_file,"FINISH TEST!");
        $stop;
      end 
    endmodule
    