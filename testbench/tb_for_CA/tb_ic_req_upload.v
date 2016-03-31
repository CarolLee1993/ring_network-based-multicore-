/****************************************************************************************
date:2016/3/28
designer:ZhaiShaoMin
module name:tb_ic_req_upload
project:ring network multicore 
module function: test the behavior of ic_req_upload
****************************************************************************************/
`timescale 1ns/100ps

module tb_ic_req_upload();
  
  //inputs
reg                         clk;
reg                         rst;
reg       [47:0]            ic_flits_req;
reg                         v_ic_flits_req;
reg                         req_fifo_rdy;
//output
wire      [15:0]             ic_flit_out;
wire                         v_ic_flit_out;
wire      [1:0]              ic_ctrl_out;
wire                         ic_req_upload_state;
  
  ic_req_upload    uut (//input
                         .clk(clk),
                         .rst(rst),
                         .ic_flits_req(ic_flits_req),
                         .v_ic_flits_req(v_ic_flits_req),
                         .req_fifo_rdy(req_fifo_rdy),
                         //output
                         .ic_flit_out(ic_flit_out),
                         .v_ic_flit_out(v_ic_flit_out),
								         .ic_ctrl_out(ic_ctrl_out),
                         .ic_req_upload_state(ic_req_upload_state)
                         );

integer log_file;

//define task  for cmp actual output and expected outputs

task cmp_outputs;
  
 input  [15:0] exp_ic_flit_out;
 input         exp_v_ic_flit_out;
 input  [1:0]  exp_ic_ctrl_out;
 input         exp_ic_req_upload_state;
 
  begin
    
     $display ("Time: %t", $time);
     $fdisplay (log_file, "Time: %t", $time);
     
     if (ic_flit_out != exp_ic_flit_out)
        begin
          $display("ERROR: Invalid ic_flit_out\n \t Expected: 0x%x \n \t Acutal: 0x%x", exp_ic_flit_out,ic_flit_out);
          $fdisplay(log_file,"ERROR: Invalid ic_flit_out\n \t Expected: 0x%x \n \t Acutal: 0x%x", exp_ic_flit_out,ic_flit_out);
        end
        
     if (v_ic_flit_out != exp_v_ic_flit_out)
        begin
          $display("ERROR: Invalid v_ic_flit_out\n \t Expected: 0x%x \n \t Acutal: 0x%x", exp_v_ic_flit_out,v_ic_flit_out);
          $fdisplay(log_file,"ERROR: Invalid v_ic_flit_out\n \t Expected: 0x%x \n \t Acutal: 0x%x", exp_v_ic_flit_out,v_ic_flit_out);
        end   
    
     if (ic_ctrl_out != exp_ic_ctrl_out)
        begin
          $display("ERROR: Invalid ic_ctrl_out\n \t Expected: 0x%x \n \t Acutal: 0x%x", exp_ic_ctrl_out,ic_ctrl_out);
          $fdisplay(log_file,"ERROR: Invalid ic_ctrl_out\n \t Expected: 0x%x \n \t Acutal: 0x%x", exp_ic_ctrl_out,ic_ctrl_out);
        end
        
     if (ic_req_upload_state != exp_ic_req_upload_state)
        begin
          $display("ERROR: Invalid ic_req_upload_state\n \t Expected: 0x%x \n \t Acutal: 0x%x",exp_ic_req_upload_state,ic_req_upload_state);
          $fdisplay(log_file,"ERROR: Invalid ic_req_upload_state\n \t Expected: 0x%x \n \t Acutal: 0x%x", exp_ic_req_upload_state,ic_req_upload_state);
        end
     if((ic_flit_out == exp_ic_flit_out)&&
        (v_ic_flit_out == exp_v_ic_flit_out)&&
        (ic_ctrl_out == exp_ic_ctrl_out)&&
        (ic_req_upload_state == exp_ic_req_upload_state))
       begin
         $display("passed,test");
         $fdisplay(log_file,"passed,test");
       end
  end
endtask
//initial inputs
initial begin
    clk=1'b0;
    rst=1'b1;
    v_ic_flits_req=1'b0;
    req_fifo_rdy=1'b0;
    ic_flits_req=48'h000000000000;
    log_file=$fopen("log_IC_REQ_UPLOAD.txt");
  end
  
`define clk_step #14;

always #7 clk=~clk;

initial 
  begin
    
    // IC_REQ_UPLOAD TEST//
    
    `clk_step
    
    $display("TEST BEGIN.......");
    $fdisplay(log_file,"TEST BEGIN.......");
    rst=1'b0;
    
    `clk_step
    
    $display("1st try \n no valid flit from ic_req_upload,assuming that req_fifo is not full");
    $fdisplay(log_file,"1st try \n no valid flit from ic_req_upload,assuming that req_fifo is not full");
    v_ic_flits_req=1'b0;
    req_fifo_rdy=1'b1;
    ic_flits_req=48'h12345678abcd;
    //Now,let's test whether ic_req_up work well,note: there should be passed,test!
    cmp_outputs(16'h0000,/*ic_flit_out*/
                1'b0,    /*v_ic_flit_out*/
                2'b01,   /*ic_ctrl_out*/
                1'b0     /*ic_req_upload_state */
                );
                
    `clk_step
    
    // till now, ic_req_upload has nothing valid
    $display("2nd try\n no valid flit from ic_req_upload,assuming that req_fifo is not full");
    $fdisplay(log_file,"2nd try\n no valid flit from ic_req_upload,assuming that req_fifo is not full");
    v_ic_flits_req=1'b1;
    req_fifo_rdy=1'b1;
    ic_flits_req=48'h12345678abcd;
    //a valid flits comes in !
     //Now,let's test whether ic_req_up work well,note: there should be passed,test!
    cmp_outputs(16'h0000,/*ic_flit_out*/
                1'b0,    /*v_ic_flit_out*/
                2'b01,   /*ic_ctrl_out*/
                1'b0     /*ic_req_upload_state */
                );
                
    `clk_step
    
    $display("3rd try\n 1st valid flit from ic_req_upload,assuming that req_fifo is not full");
    $fdisplay(log_file,"3rd try\n 1st valid flit from ic_req_upload,assuming that req_fifo is not full");
    v_ic_flits_req=1'b0;
    req_fifo_rdy=1'b1;
    ic_flits_req=48'h12345678abcd;
    //Now,let's test whether ic_req_up work well,note: there should be passed,test!
    // this is a case where coming flits and req_fifo_rdy both are valid
    cmp_outputs(16'h1234,/*ic_flit_out*/
                1'b1,    /*v_ic_flit_out*/
                2'b01,   /*ic_ctrl_out*/
                1'b1     /*ic_req_upload_state */
                );
    //  cpm above should be right ,since there was a valid req fifo rdy!
                
    `clk_step
    
    $display("4th try\n no valid flit from ic_req_upload,assuming that req_fifo is  full");
    $fdisplay(log_file,"4th try\n no valid flit from ic_req_upload,assuming that req_fifo is  full");
    v_ic_flits_req=1'b0;
    req_fifo_rdy=1'b0;
    ic_flits_req=48'h12345678abcd;  
   //Now,let's test whether ic_req_up work well,note: there should be passed,test!
    cmp_outputs(16'h5678,/*ic_flit_out*/
                1'b0,    /*v_ic_flit_out*/
                2'b10,   /*ic_ctrl_out*/
                1'b1     /*ic_req_upload_state */
                );
                
   `clk_step
   
    $display("5th try\n 2nd valid flit from ic_req_upload,assuming that req_fifo is not full");
    $fdisplay(log_file,"5th try\n 2nd valid flit from ic_req_upload,assuming that req_fifo is not full");
    // second flit will get out of ic_req_upload           
    v_ic_flits_req=1'b0;
    req_fifo_rdy=1'b1;
    ic_flits_req=48'h12345678abcd;   
    cmp_outputs(16'h5678,/*ic_flit_out*/
                1'b1,    /*v_ic_flit_out*/
                2'b10,   /*ic_ctrl_out*/
                1'b1     /*ic_req_upload_state */
                );
                
    `clk_step
    
    //third flit get out of ic_req_upload  
    $display("6th try\n 3rd valid flit from ic_req_upload,assuming that req_fifo is not full");
    $fdisplay(log_file,"6th try\n 3rd valid flit from ic_req_upload,assuming that req_fifo is not full");          
    v_ic_flits_req=1'b0;
    req_fifo_rdy=1'b1;
    ic_flits_req=48'h12345678abcd; 
    cmp_outputs(16'habcd,/*ic_flit_out*/
                1'b1,    /*v_ic_flit_out*/
                2'b11,   /*ic_ctrl_out*/
                1'b1     /*ic_req_upload_state */
                );
                
    `clk_step    
            
    // now let's try a case where coming flits is valid but req_fifo_rdy is invalid
    $display("7th try \n now let's try a case where coming flits is valid but req_fifo_rdy is invalid\n a valid flits comes in");
    $fdisplay(log_file,"7th try \n now let's try a case where coming flits is valid but req_fifo_rdy is invalid\n a valid flits comes in");
    v_ic_flits_req=1'b1;
    req_fifo_rdy=1'b0;
    ic_flits_req=48'hc0de2016c0de;
    //this time v_ic_flit_out should be invalid because req_fifo_rdy==1'b0
    cmp_outputs(16'h0000,/*ic_flit_out*/
                1'b0,    /*v_ic_flit_out*/
                2'b01,   /*ic_ctrl_out*/
                1'b0     /*ic_req_upload_state */
                );
    
    `clk_step
    
    $display("8th try \n 1st flit from ic_req_upload,assuming that req_fifo is not full");
    $fdisplay(log_file,"8th try \n 1st flit from ic_req_upload,assuming that req_fifo is not full");
    v_ic_flits_req=1'b0;
    req_fifo_rdy=1'b1;
    ic_flits_req=48'hc0de2016c0de;
    cmp_outputs(16'hc0de,/*ic_flit_out*/
                1'b1,    /*v_ic_flit_out*/
                2'b01,   /*ic_ctrl_out*/
                1'b1     /*ic_req_upload_state */
                );
    
    `clk_step
    
    //assuming that req_fifo is full
    $display("9th try \n 2nd flit from ic_req_upload,assuming that req_fifo is  full");
    $fdisplay(log_file,"9th try \n 2nd flit from ic_req_upload,assuming that req_fifo is  full");
    v_ic_flits_req=1'b0;
    req_fifo_rdy=1'b0;
    ic_flits_req=48'hc0de2016c0de;
    //this time v_ic_flit_out should be invalid because req_fifo_rdy==1'b0
    cmp_outputs(16'h2016,/*ic_flit_out*/
                1'b0,    /*v_ic_flit_out*/
                2'b10,   /*ic_ctrl_out*/
                1'b1     /*ic_req_upload_state */
                );
                
    `clk_step
    
    //2th flit from ic_req_upload
    //assuming that req_fifo is not full
    $display("10th try \n 2th flit from ic_req_upload,assuming that req_fifo is not full");
    $fdisplay(log_file,"10th try \n 2th flit from ic_req_upload,assuming that req_fifo is not full");
    v_ic_flits_req=1'b0;
    req_fifo_rdy=1'b1;
    ic_flits_req=48'hc0de2016c0de;
    //this time v_ic_flit_out should be invalid because req_fifo_rdy==1'b0
    cmp_outputs(16'h2016,/*ic_flit_out*/
                1'b1,    /*v_ic_flit_out*/
                2'b10,   /*ic_ctrl_out*/
                1'b1     /*ic_req_upload_state */
                );
   
   `clk_step
    
    //3rd flit from ic_req_upload
    //assuming that req_fifo is  full
    $display("11th try \n 3rd flit from ic_req_upload,assuming that req_fifo is not full");
    $fdisplay(log_file,"11th try \n 3rd flit from ic_req_upload,assuming that req_fifo is full");
    v_ic_flits_req=1'b0;
    req_fifo_rdy=1'b1;
    ic_flits_req=48'hc0de2016c0de;
    //this time v_ic_flit_out should be invalid because req_fifo_rdy==1'b0
    cmp_outputs(16'hc0de,/*ic_flit_out*/
                1'b0,    /*v_ic_flit_out*/
                2'b11,   /*ic_ctrl_out*/
                1'b1     /*ic_req_upload_state */
                );  
                
    `clk_step
    
    //3rd flit from ic_req_upload
    //assuming that req_fifo is not full
    $display("12th try \n 3rd flit from ic_req_upload,assuming that req_fifo is not full");
    $fdisplay(log_file,"12th try \n  3rd flit from ic_req_upload,assuming that req_fifo is not full");
    v_ic_flits_req=1'b0;
    req_fifo_rdy=1'b1;
    ic_flits_req=48'hc0de2016c0de;
    //this time v_ic_flit_out should be invalid because req_fifo_rdy==1'b0
    cmp_outputs(16'hc0de,/*ic_flit_out*/
                1'b1,    /*v_ic_flit_out*/
                2'b11,   /*ic_ctrl_out*/
                1'b1     /*ic_req_upload_state */
                );   
                
    $display("FINISH test of ic_req_upload !");
    $fdisplay(log_file,"FINISH test of ic_req_upload !");
    $stop;
 end
endmodule