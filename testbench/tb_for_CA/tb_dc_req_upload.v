/************************************************************
date:2016/3/16
engineer:ZhaiShaoMin
module function: find out errors in the module
revision date:2016/3/31 
*************************************************************/
`timescale 1ns/1ps

module  tb_dc_req_upload();

//input
reg                         clk;
reg                         rst;
reg       [47:0]            dc_flits_req;
reg                         v_dc_flits_req;
reg                         req_fifo_rdy;
//output
wire      [15:0]            dc_flit_out;
wire                        v_dc_flit_out;
wire                        dc_req_upload_state;


//instantiate the uut
dc_req_upload      uut (//input
                          .clk(clk),
                          .rst(rst),
                          .dc_flits_req(dc_flits_req),
                          .v_dc_flits_req(v_dc_flits_req),
                          .req_fifo_rdy(req_fifo_rdy),
                          //output
                          .dc_flit_out(dc_flit_out),
                          .v_dc_flit_out(v_dc_flit_out),
                          .dc_req_upload_state(dc_req_upload_state)
                          );
                          
// store the simulation log into log_file
integer log_file;

// Initialize Inputs
        initial begin
            clk=1'b0;
            rst=1'b0;
            dc_flits_req=48'h000000000000;
            v_dc_flits_req=1'b0;
            req_fifo_rdy=1'b0;
            log_file=$fopen("log_tb_arbiter_req_upload");
        end
        
     always #20 clk=~clk;
        
    `define clk_step #40;
        
     initial begin
        
            /////// dc_req_upload test /////////
            
            // First reset all //            

            $display("(%t) Initializing...", $time);
            $fdisplay(log_file, "(%t) Initializing...", $time);
            
            rst=1;                       
            `clk_step
            rst=0;
            `clk_step
            
            ///////////////////////////////////////////////////////////////////////////////////////
            //////////////////////only need to test shreq or exreq both 3 flits long///////////////
            dc_flits_req=48'h123456789abc;
            v_dc_flits_req=1'b1;
            
            `clk_step
            
            //inter regs should have hold the flits
            req_fifo_rdy=1'b0;
            $display("(%t),the flit from dc_req_upload is %h and v_dc_flit_out is %b ",$time,dc_flit_out,v_dc_flit_out);
            $fdisplay(log_file,"(%t),the flit from dc_req_upload is %h and v_dc_flit_out is %b ",$time,dc_flit_out,v_dc_flit_out);
            
            `clk_step
            
            v_dc_flits_req=1'b0;
            //since last cycle req fifo rdy is not valid , v_dc_flit_out will be not valid
            req_fifo_rdy=1'b1;
            $display("(%t),the flit from dc_req_upload is %h and v_dc_flit_out is %b ",$time,dc_flit_out,v_dc_flit_out);
            $fdisplay(log_file,"(%t),the flit from dc_req_upload is %h and v_dc_flit_out is %b ",$time,dc_flit_out,v_dc_flit_out);
            
            
            `clk_step
            
            //since last cycle req fifo rdy is not valid , v_dc_flit_out will be valid
            req_fifo_rdy=1'b1;
            $display("(%t),the flit from dc_req_upload is %h and v_dc_flit_out is %b ",$time,dc_flit_out,v_dc_flit_out);
            $fdisplay(log_file,"(%t),the flit from dc_req_upload is %h and v_dc_flit_out is %b ",$time,dc_flit_out,v_dc_flit_out);
            
            
            `clk_step
            
            //since last cycle req fifo rdy is not valid , v_dc_flit_out will be valid
            dc_flits_req=48'h2016c0de0330;
            v_dc_flits_req=1'b1;
            req_fifo_rdy=1'b0;
            $display("(%t),the flit from dc_req_upload is %h and v_dc_flit_out is %b ",$time,dc_flit_out,v_dc_flit_out);
            $fdisplay(log_file,"(%t),the flit from dc_req_upload is %h and v_dc_flit_out is %b ",$time,dc_flit_out,v_dc_flit_out); 
                       
            `clk_step
            
            //since last cycle req fifo rdy is not valid , v_dc_flit_out will be not valid
            req_fifo_rdy=1'b1;
            $display("(%t),the flit from dc_req_upload is %h and v_dc_flit_out is %b ",$time,dc_flit_out,v_dc_flit_out);
            $fdisplay(log_file,"(%t),the flit from dc_req_upload is %h and v_dc_flit_out is %b ",$time,dc_flit_out,v_dc_flit_out);
            
            `clk_step
            
            //since last cycle req fifo rdy is not valid , v_dc_flit_out will be valid
            
            `clk_step
            
            //till now dc_req_upload has been empty,so flits will be push into ic_upload ,but it's not the to pop one flit to req fifo!
            req_fifo_rdy=1'b1;
            `clk_step
            
            //this cycle head flit will be poped to req fifo
            req_fifo_rdy=1'b1;
            `clk_step
            
            //due to not being valid ,second flit won't be poped to req fifo
            req_fifo_rdy=1'b0;
            `clk_step
            
            //this cycle second flit will be poped to req fifo
            req_fifo_rdy=1'b1;
            `clk_step
            
            //this cycle third flit will be poped to req fifo
            req_fifo_rdy=1'b1;
            `clk_step
            
            //this time upload_rs(=>upload_reserve station) should become empty!
            `clk_step
            $stop;
          end
        endmodule