/**********************************************************************
date:2016/3/26
designer:ZhaiShaoMin
project:ring network multicore
module name:tb_arbiter_OUT_rep
module function: figure out what's wrong with it
***********************************************************************/
`timescale 1ns/1ps

module tb_arbiter_for_OUT_rep();


//inputs
reg                               clk;
reg                               rst;
reg                               OUT_rep_rdy;
reg                               v_dc_rep;
reg                               v_mem_rep;
reg     [15:0]                    dc_rep_flit;
reg     [15:0]                    mem_rep_flit;
reg     [1:0]                     dc_rep_ctrl;
reg     [1:0]                     mem_rep_ctrl;

//output
wire                               ack_OUT_rep;
wire                               ack_dc_rep;
wire                               ack_mem_rep;
wire    [1:0]                      select; // select 1/2
parameter        SCflurep_cmd=5'b11100;
parameter        nackrep_cmd=5'b10101;
//instante design 
arbiter_for_OUT_rep       uut (//input
                               .clk(clk),
                               .rst(rst),
                               .OUT_rep_rdy(OUT_rep_rdy),
                               .v_dc_rep(v_dc_rep),
                               .v_mem_rep(v_mem_rep),
                               .dc_rep_flit(dc_rep_flit),
                               .mem_rep_flit(mem_rep_flit),
                               .dc_rep_ctrl(dc_rep_ctrl),
                               .mem_rep_ctrl(mem_rep_ctrl),
                               //output
                               .ack_OUT_rep(ack_OUT_rep),
                               .ack_dc_rep(ack_dc_rep),
                               .ack_mem_rep(ack_mem_rep),
                               .select(select)  // select 1/2
                               );
                               
   integer log_file;
                               
   //define task for cmp actual outputs and exp outputs
   task cmp_outputs;
     
     input      exp_ack_OUT_rep;
     input      exp_ack_dc_rep;
     input      exp_ack_mem_rep;
     input [1:0]exp_select;
     
     begin
       
       $display("Time:%t",$time);
       $fdisplay (log_file, "Time: %t", $time);
       
       if (ack_OUT_rep != exp_ack_OUT_rep)
        begin
          $display("ERROR: Invalid ack_OUT_rep\n \t Expected: 0x%x \n \t Acutal: 0x%x", exp_ack_OUT_rep,ack_OUT_rep);
          $fdisplay(log_file,"ERROR: Invalid ack_OUT_rep\n \t Expected: 0x%x \n \t Acutal: 0x%x", exp_ack_OUT_rep,ack_OUT_rep);
        end 

       if (ack_dc_rep != exp_ack_dc_rep)
        begin
          $display("ERROR: Invalid ack_dc_rep\n \t Expected: 0x%x \n \t Acutal: 0x%x", exp_ack_dc_rep,ack_dc_rep);
          $fdisplay(log_file,"ERROR: Invalid ack_dc_rep\n \t Expected: 0x%x \n \t Acutal: 0x%x", exp_ack_dc_rep,ack_dc_rep);
        end
       
       if (ack_mem_rep != exp_ack_mem_rep)
        begin
          $display("ERROR: Invalid ack_mem_rep\n \t Expected: 0x%x \n \t Acutal: 0x%x", exp_ack_mem_rep,ack_mem_rep);
          $fdisplay(log_file,"ERROR: Invalid ack_mem_rep\n \t Expected: 0x%x \n \t Acutal: 0x%x", exp_ack_mem_rep,ack_mem_rep);
        end
        
       if (select != exp_select)
        begin
          $display("ERROR: Invalid select\n \t Expected: 0x%x \n \t Acutal: 0x%x", exp_select,select);
          $fdisplay(log_file,"ERROR: Invalid select\n \t Expected: 0x%x \n \t Acutal: 0x%x", exp_select,select);
        end
        
       if((ack_OUT_rep == exp_ack_OUT_rep)&&
          (ack_dc_rep == exp_ack_dc_rep)&&
          (ack_mem_rep == exp_ack_mem_rep)&&
          (select == exp_select))
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
       OUT_rep_rdy=1'b0;
       v_dc_rep=1'b0;
       v_mem_rep=1'b0;
       dc_rep_flit=16'h0000;
       mem_rep_flit=16'h0000;
       dc_rep_ctrl=2'b00;
       mem_rep_ctrl=2'b00;
       log_file=$fopen("log_arbiter_for_OUT_rep.txt");
     end
     
     `define clk_step #14;
      
     always  #7 clk=~clk;
     
     initial begin
       // actural test  arbiter_for_OUT_rep TEST//
    
       `clk_step
    
        $display("TEST BEGIN.......");
        $fdisplay(log_file,"TEST BEGIN.......");
        rst=1'b0;
        
        `clk_step
        
        ////////////////////////////////////////////////////
        //First case both v_dc_rep and v_mem_rep are valid//
        $display("First case both v_dc_rep and v_mem_rep are valid");
        $fdisplay(log_file,"First case both v_dc_rep and v_mem_rep are valid");
        $display("First try");
        $fdisplay(log_file,"First try");
        //it also means that both flits are head flit
        OUT_rep_rdy=1'b0;//don't care 
        v_dc_rep=1'b1;   
        v_mem_rep=1'b1;
        dc_rep_flit=16'habcd;
        mem_rep_flit=16'h1234;
        dc_rep_ctrl=2'b01;
        mem_rep_ctrl=2'b01;
        cmp_outputs(1'b0,//ack_OUT_rep//
                    1'b0,//ack_dc_rep//
                    1'b0,//ack_mem_rep//
                    2'b00//select//
                    );
        
        `clk_step
        
        $display("2nd try  ");
        $fdisplay(log_file,"2nd try");
        //it also means that both flits are head flit
        OUT_rep_rdy=1'b1;
        v_dc_rep=1'b1;   
        v_mem_rep=1'b1;
        dc_rep_flit=16'habcd;
        mem_rep_flit=16'h1234;
        dc_rep_ctrl=2'b01;
        mem_rep_ctrl=2'b01;
        cmp_outputs(1'b1,//ack_OUT_rep//
                    1'b0,//ack_dc_rep//
                    1'b1,//ack_mem_rep//
                    2'b10//select//
                    );
                    
        `clk_step
        
        $display("3rd try  ");
        $fdisplay(log_file,"3rd try");
        //it also means that both flits are head flit
        OUT_rep_rdy=1'b1;
        v_dc_rep=1'b1;   
        v_mem_rep=1'b1;
        dc_rep_flit=16'habcd;
        mem_rep_flit=16'h5678;
        dc_rep_ctrl=2'b01;
        mem_rep_ctrl=2'b10;
        cmp_outputs(1'b1,//ack_OUT_rep//
                    1'b0,//ack_dc_rep//
                    1'b1,//ack_mem_rep//
                    2'b10//select//
                    );     
                    
        `clk_step
        
        $display("4th try  ");
        $fdisplay(log_file,"4th try");
        //it also means that both flits are head flit
        OUT_rep_rdy=1'b1;
        v_dc_rep=1'b1;   
        v_mem_rep=1'b1;
        dc_rep_flit=16'habcd;
        mem_rep_flit=16'h2016;
        dc_rep_ctrl=2'b01;
        mem_rep_ctrl=2'b10;
        cmp_outputs(1'b1,//ack_OUT_rep//
                    1'b0,//ack_dc_rep//
                    1'b1,//ack_mem_rep//
                    2'b10//select//
                    );      
        /*.....*/ 
        //assuming iit's time for tail flit of mem msg
        
        `clk_step
        
        $display("3rd try  ");
        $fdisplay(log_file,"3rd try");
        //it also means that both flits are head flit
        OUT_rep_rdy=1'b1;
        v_dc_rep=1'b1;   
        v_mem_rep=1'b1;
        dc_rep_flit=16'habcd;
        mem_rep_flit=16'h5678;
        dc_rep_ctrl=2'b01;
        mem_rep_ctrl=2'b11;
        cmp_outputs(1'b1,//ack_OUT_rep//
                    1'b0,//ack_dc_rep//
                    1'b1,//ack_mem_rep//
                    2'b10//select//
                    );
        
        `clk_step
        
        //////////////////////////////////////////////////
        //2nd case both v_dc_rep and v_mem_rep are valid
        $display("2nd case both v_dc_rep and v_mem_rep are valid ,but it's tme for dc");
        $fdisplay(log_file,"2nd case  both v_dc_rep and v_mem_rep are valid,but it's tme for dc");
        $display("First try");
        $fdisplay(log_file,"First try");
        //it also means that both flits are head flit
        OUT_rep_rdy=1'b0;//don't care 
        v_dc_rep=1'b1;   
        v_mem_rep=1'b1;
        dc_rep_flit=16'habcd;
        mem_rep_flit=16'h1234;
        dc_rep_ctrl=2'b01;
        mem_rep_ctrl=2'b01;
        cmp_outputs(1'b0,//ack_OUT_rep//
                    1'b0,//ack_dc_rep//
                    1'b0,//ack_mem_rep//
                    2'b00//select//
                    );
        
        `clk_step
        
        $display("2nd try  ");
        $fdisplay(log_file,"2nd try");
        //it also means that both flits are head flit
        OUT_rep_rdy=1'b1;
        v_dc_rep=1'b1;   
        v_mem_rep=1'b1;
        dc_rep_flit=16'habcd;
        mem_rep_flit=16'h1234;
        dc_rep_ctrl=2'b01;
        mem_rep_ctrl=2'b01;
        cmp_outputs(1'b1,//ack_OUT_rep//
                    1'b1,//ack_dc_rep//
                    1'b0,//ack_mem_rep//
                    2'b01//select//
                    );
                    
        `clk_step
        
        $display("3rd try  ");
        $fdisplay(log_file,"3rd try");
        //it also means that both flits are head flit
        OUT_rep_rdy=1'b1;
        v_dc_rep=1'b1;   
        v_mem_rep=1'b1;
        dc_rep_flit=16'h5678;
        mem_rep_flit=16'h5678;
        dc_rep_ctrl=2'b10;
        mem_rep_ctrl=2'b01;
        cmp_outputs(1'b1,//ack_OUT_rep//
                    1'b0,//ack_dc_rep//
                    1'b1,//ack_mem_rep//
                    2'b01//select//
                    );     
                    
        `clk_step
        
        $display("4th try  ");
        $fdisplay(log_file,"4th try");
        //it also means that both flits are head flit
        OUT_rep_rdy=1'b1;
        v_dc_rep=1'b1;   
        v_mem_rep=1'b1;
        dc_rep_flit=16'habcd;
        mem_rep_flit=16'h2016;
        dc_rep_ctrl=2'b10;
        mem_rep_ctrl=2'b01;
        cmp_outputs(1'b1,//ack_OUT_rep//
                    1'b1,//ack_dc_rep//
                    1'b0,//ack_mem_rep//
                    2'b01//select//
                    );      
        /*.....*/ 
        //assuming iit's time for tail flit of mem msg
        
        `clk_step
        
        $display("3rd try  ");
        $fdisplay(log_file,"3rd try");
        //it also means that both flits are head flit
        OUT_rep_rdy=1'b1;
        v_dc_rep=1'b1;   
        v_mem_rep=1'b1;
        dc_rep_flit=16'h2016;
        mem_rep_flit=16'h5678;
        dc_rep_ctrl=2'b11;
        mem_rep_ctrl=2'b01;
        cmp_outputs(1'b1,//ack_OUT_rep//
                    1'b1,//ack_dc_rep//
                    1'b0,//ack_mem_rep//
                    2'b01//select//
                    );   
                    
        
        `clk_step
        
        ////////////////////////////////////////////////
        /// 3rd case only v_dc_rep is valid
        $display("3rd case only v_dc_rep is valid");
        $fdisplay(log_file,"3rd case  only v_dc_rep is valid");
        $display("First try");
        $fdisplay(log_file,"First try");
        //it also means that both flits are head flit
        OUT_rep_rdy=1'b0;//don't care 
        v_dc_rep=1'b1;   
        v_mem_rep=1'b0;
        dc_rep_flit=16'h2016;
        mem_rep_flit=16'h1234;
        dc_rep_ctrl=2'b01;
        mem_rep_ctrl=2'b00;
        cmp_outputs(1'b0,//ack_OUT_rep//
                    1'b0,//ack_dc_rep//
                    1'b0,//ack_mem_rep//
                    2'b00//select//
                    );
                    
        `clk_step
        
        $display("2nd try");
        $fdisplay(log_file,"2nd try");
        //it also means that both flits are head flit
        OUT_rep_rdy=1'b1; 
        v_dc_rep=1'b1;   
        v_mem_rep=1'b0;
        // make it scflushrep which is only one flit long to test another path
        //no need to gen it ,because it imposible for dc
        dc_rep_flit=16'h2016; 
        mem_rep_flit=16'h1234;
        dc_rep_ctrl=2'b01;
        mem_rep_ctrl=2'b00;
        cmp_outputs(1'b1,//ack_OUT_rep//
                    1'b1,//ack_dc_rep//
                    1'b0,//ack_mem_rep//
                    2'b01//select//
                    );
       /*.....*/
       //let's  assum that there will be the tail flit of dc msg
        `clk_step
        
        $display("last try");
        $fdisplay(log_file,"last try");
        //it also means that both flits are head flit
        OUT_rep_rdy=1'b1; 
        v_dc_rep=1'b1;   
        v_mem_rep=1'b0;
        dc_rep_flit=16'h2016; 
        mem_rep_flit=16'h1234;
        dc_rep_ctrl=2'b11;
        mem_rep_ctrl=2'b00;
        cmp_outputs(1'b1,//ack_OUT_rep//
                    1'b1,//ack_dc_rep//
                    1'b0,//ack_mem_rep//
                    2'b01//select//
                    );           
                    
    /*    //just test whether state jump to idle
        `clk_step
        
        $display("last try");
        $fdisplay(log_file,"last try");
        //it also means that both flits are head flit
        OUT_rep_rdy=1'b1; 
        v_dc_rep=1'b1;   
        v_mem_rep=1'b0;
        dc_rep_flit=16'h2016; 
        mem_rep_flit=16'h1234;
        dc_rep_ctrl=2'b01;
        mem_rep_ctrl=2'b00;
        cmp_outputs(1'b0,//ack_OUT_rep//
                    1'b0,//ack_dc_rep//
                    1'b0,//ack_mem_rep//
                    2'b00//select//
                    );
        */
        /////////////////////////////////////////////
        ///4th case only v_mem_rep is valid
        `clk_step
        
        $display("3rd case only v_mem_rep is valid");
        $fdisplay(log_file,"3rd case  only v_mem_rep is valid");
        $display("First try");
        $fdisplay(log_file,"First try");
        //it also means that both flits are head flit
        OUT_rep_rdy=1'b1;//don't care 
        v_dc_rep=1'b0;   
        v_mem_rep=1'b1;
        dc_rep_flit=16'h2016;
        mem_rep_flit=16'h1234;
        dc_rep_ctrl=2'b01;
        mem_rep_ctrl=2'b01;
        cmp_outputs(1'b0,//ack_OUT_rep//
                    1'b0,//ack_dc_rep//
                    1'b0,//ack_mem_rep//
                    2'b00//select//
                    );
                    
        `clk_step
        
        $display("2nd try");
        $fdisplay(log_file,"2nd try");
        //it also means that both flits are head flit
        OUT_rep_rdy=1'b1; 
        v_dc_rep=1'b0;   
        v_mem_rep=1'b1;
        dc_rep_flit=16'h2016;
        mem_rep_flit=16'h1234;
        dc_rep_ctrl=2'b01;
        mem_rep_ctrl=2'b01;
        cmp_outputs(1'b1,//ack_OUT_rep//
                    1'b0,//ack_dc_rep//
                    1'b1,//ack_mem_rep//
                    2'b10//select//
                    );
                    
        `clk_step
        
        $display("3rd try");
        $fdisplay(log_file,"3rd try");
        //it also means that both flits are head flit
        OUT_rep_rdy=1'b1; 
        v_dc_rep=1'b0;   
        v_mem_rep=1'b1;
        dc_rep_flit=16'h0328;
        mem_rep_flit=16'h1234;
        dc_rep_ctrl=2'b01;
        mem_rep_ctrl=2'b10;
        cmp_outputs(1'b1,//ack_OUT_rep//
                    1'b0,//ack_dc_rep//
                    1'b1,//ack_mem_rep//
                    2'b10//select//
                    );
        `clk_step
        
        $display("last try");
        $fdisplay(log_file,"last try");
        //it also means that both flits are head flit
        OUT_rep_rdy=1'b1; 
        v_dc_rep=1'b0;   
        v_mem_rep=1'b1;
        dc_rep_flit=16'hc0de;
        mem_rep_flit=16'h1234;
        dc_rep_ctrl=2'b01;
        mem_rep_ctrl=2'b11;
        cmp_outputs(1'b1,//ack_OUT_rep//
                    1'b0,//ack_dc_rep//
                    1'b1,//ack_mem_rep//
                    2'b10//select//
                    );
        
 /*       `clk_step
        
        $display("last try,just a test for whether jump to idle");
        $fdisplay(log_file,"last try,just a test for whether jump to idle");
        //it also means that both flits are head flit
        OUT_rep_rdy=1'b1; 
        v_dc_rep=1'b0;   
        v_mem_rep=1'b1;
        dc_rep_flit=16'hc0de;
        mem_rep_flit=16'h1234;
        dc_rep_ctrl=2'b01;
        mem_rep_ctrl=2'b11;
        cmp_outputs(1'b1,//ack_OUT_rep//
                    1'b0,//ack_dc_rep//
                    1'b1,//ack_mem_rep//
                    2'b10//select//
                    );
        
                    */
        /////////////////////////////////////////////
        ///5th case only v_mem_rep is valid and is SCflushrep
        `clk_step
        
        $display("5th  case :only v_mem_rep is valid");
        $fdisplay(log_file,"5th  case  :only v_mem_rep is valid");
        $display("First try");
        $fdisplay(log_file,"First try");
        //it also means that both flits are head flit
        OUT_rep_rdy=1'b1;//don't care 
        v_dc_rep=1'b0;   
        v_mem_rep=1'b1;
        dc_rep_flit=16'h2016;
        mem_rep_flit={6'b110110,SCflurep_cmd,5'b00000};
        dc_rep_ctrl=2'b01;
        mem_rep_ctrl=2'b01;
        cmp_outputs(1'b0,//ack_OUT_rep//
                    1'b0,//ack_dc_rep//
                    1'b0,//ack_mem_rep//
                    2'b00//select//
                    );
                    
        `clk_step
        
        $display("2nd try");
        $fdisplay(log_file,"2nd try");
        //it also means that both flits are head flit
        OUT_rep_rdy=1'b1; 
        v_dc_rep=1'b0;   
        v_mem_rep=1'b1;
        dc_rep_flit=16'h2016;
        mem_rep_flit={6'b110110,SCflurep_cmd,5'b00000};
        dc_rep_ctrl=2'b01;
        mem_rep_ctrl=2'b01;
        cmp_outputs(1'b1,//ack_OUT_rep//
                    1'b0,//ack_dc_rep//
                    1'b1,//ack_mem_rep//
                    2'b10//select//
                    );
   /*     `clk_step
        
        $display("last try,just a test for whether jump to idle");
        $fdisplay(log_file,"last try,just a test for whether jump to idle");
        //it also means that both flits are head flit
        OUT_rep_rdy=1'b1; 
        v_dc_rep=1'b0;   
        v_mem_rep=1'b1;
        dc_rep_flit=16'h2016;
        mem_rep_flit={6'b110110,SCflurep_cmd,5'b00000};
        dc_rep_ctrl=2'b01;
        mem_rep_ctrl=2'b01;
        cmp_outputs(1'b1,//ack_OUT_rep//
                    1'b0,//ack_dc_rep//
                    1'b1,//ack_mem_rep//
                    2'b10//select//
                    );
        */
        /////////////////////////////////////////////
        ///6th case only v_mem_rep is valid and is nackrep
        `clk_step
        //nackrep_msg for test 
        $display("6th case :only v_mem_rep is valid");
        $fdisplay(log_file,"6th case  :only v_mem_rep is valid");
        $display("First try");
        $fdisplay(log_file,"First try");
        //it also means that both flits are head flit
        OUT_rep_rdy=1'b1;//don't care 
        v_dc_rep=1'b0;   
        v_mem_rep=1'b1;
        dc_rep_flit=16'h2016;
        mem_rep_flit={6'b110110,nackrep_cmd,5'b00000};
        dc_rep_ctrl=2'b01;
        mem_rep_ctrl=2'b01;
        cmp_outputs(1'b0,//ack_OUT_rep//
                    1'b0,//ack_dc_rep//
                    1'b0,//ack_mem_rep//
                    2'b00//select//
                    );
                    
        `clk_step
        
        $display("2nd try");
        $fdisplay(log_file,"2nd try");
        //it also means that both flits are head flit
        OUT_rep_rdy=1'b1; 
        v_dc_rep=1'b0;   
        v_mem_rep=1'b1;
        dc_rep_flit=16'h2016;
        mem_rep_flit={6'b110110,nackrep_cmd,5'b00000};
        dc_rep_ctrl=2'b01;
        mem_rep_ctrl=2'b01;
        cmp_outputs(1'b1,//ack_OUT_rep//
                    1'b0,//ack_dc_rep//
                    1'b1,//ack_mem_rep//
                    2'b10//select//
                    );
 /*       `clk_step
        
        $display("last try,just a test for whether jump to idle");
        $fdisplay(log_file,"last try,just a test for whether jump to idle");
        //it also means that both flits are head flit
        OUT_rep_rdy=1'b1; 
        v_dc_rep=1'b0;   
        v_mem_rep=1'b1;
        dc_rep_flit=16'h2016;
        mem_rep_flit={6'b110110,nackrep_cmd,5'b00000};
        dc_rep_ctrl=2'b01;
        mem_rep_ctrl=2'b01;
        cmp_outputs(1'b1,//ack_OUT_rep//
                    1'b0,//ack_dc_rep//
                    1'b1,//ack_mem_rep//
                    2'b10//select//
                    );  
                    */
        `clk_step
        $display("FINISH TEST!");
        $fdisplay(log_file,"FINISH TEST!");
        $stop;
      end
  endmodule
      