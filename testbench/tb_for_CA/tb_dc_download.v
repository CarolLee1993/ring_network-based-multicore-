//date:2016/3/16
//engineer: zhaishaomin
//module function :test whether dc_download  will behave as what i want it to do ,such as handling coming flit correctly 

/*
// test examples 
//wbrep       11 flits long
flits_d_m_areg={flits_in[140:139],1'b1,local_id,1'b0,wbrep_cmd,5'b00000,seled_addr,data_read};
//ATflurep   11 flits long 
flits_d_m_areg={state_tag_out[3:2],1'b0,local_id,1'b1,ATflurep_cmd,5'b00000,
                   seled_addr[31:13],delayed_state_tag,seled_addr[8:0],data_read};
                   
//shrep    9 flits long
msg={temp_rep_head_flit,data_read,32'h00000000};
//SHexrep   9 flits long
msg={temp_rep_head_flit,data_read,32'h00000000};
//exrep    9 flits long
msg={temp_rep_head_flit,data_read,32'h00000000};


//wbreq    3 flits long
msg={temp_rep_head_flit,seled_addr,128'h0000};
//flushreq  3 flits long
msg={temp_req_head_flit,seled_addr,128'h0000};
//SCinvreq or invreq  3 flits long
msg={temp_req_head_flit,seled_addr,128'h0000};
//shreq     3 flits long
flits_d_m_areg={seled_addr[12:11],1'b0,local_id,1'b1,shreq_cmd,5'b00000,seled_addr,128'hzzzz};
//exreq     3 flits long
flits_d_m_areg={state_tag_out[3:2],1'b0,local_id,1'b1,exreq_cmd,5'b00000,seled_addr,128'hzzzz};
//C2Hinvrep  3 flits long
flits_d_m_areg={state_tag_out[3:2],1'b0,local_id,1'b1,C2Hinvrep_cmd,5'b00000,
                     seled_addr[31:13],delayed_state_tag,seled_addr[8:0],128'hzzzz};
//flushrep     3 flits long
flits_d_m_areg={flits_in[140:139],1'b1,local_id,1'b0,flushrep_cmd,5'b00000,seled_addr,128'h0000};

//flushfail_rep     3 flits long
flits_d_m_areg={flits_in[140:139],1'b1,flits_in[132:131],1'b0,flushfail_rep_cmd,5'b00000,seled_addr,128'h0000};
//wbfail_rep       3 flits long
flits_d_m_areg={flits_in[140:139],1'b1,flits_in[132:131],1'b0,wbfail_rep_cmd,5'b00000,seled_addr,128'h0000};
                     
//nackrep  1 flit long
msg={temp_rep_head_flit,data_read,32'h00000000};
//C2Cinvrep   1 flit long
flits_d_m_areg={state_tag_out[3:2],1'b0,local_id,1'b1,C2Hinvrep_cmd,5'b00000,
                     seled_addr[31:13],delayed_state_tag,seled_addr[8:0],128'hzzzz};
//SCflushrep  1 flit long
msg={temp_rep_head_flit,data_read,32'h00000000};                                             
*/

`timescale 1ns/1ps

module     tb_dc_download();
 
//inputs
reg            clk;
reg            rst;
reg    [15:0]  IN_flit_dc;
reg            v_IN_flit_dc;
reg    [1:0]   In_flit_ctrl_dc;
reg            dc_done_access;

//output
wire          v_dc_download;
wire   [1:0]  dc_downlaod_state;
wire   [143:0]dc_download_flits;


//instantiate the uut
dc_download     uut(//input
                    .clk(clk),
                    .rst(rst),
                    .IN_flit_dc(IN_flit_dc),
                    .v_IN_flit_dc(v_IN_flit_dc),
                    .In_flit_ctrl_dc(In_flit_ctrl_dc),
                    .dc_done_access(dc_done_access),
                    //output
                    .v_dc_download(v_dc_download),
                    .dc_download_flits(dc_download_flits),
                    .dc_download_state(dc_download_state)
                   );

// store the simulation log into log_file
integer logfile;


// Initialize Inputs
        initial begin
            clk = 1'b0;
            rst = 1'b0;
            IN_flit_dc=16'h1234;
            v_IN_flit_dc=1'b0;
            In_flit_ctrl_dc=2'b00;
            dc_done_access=1'b0;
        end
        
     always #20 clk=~clk;
        
    `define step #40;
        
     initial begin
        
            /////// mem_download test /////////
            
            // First reset all //            

            $display("(%t) Initializing...", $time);
            $fdisplay(log_file, "(%t) Initializing...", $time);
            
            rst=1;                       
            `step
            rst=0;
            `step
            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            ////////////////////////REP MSG FROM IN_REP_FIFO//////////////////////////////////////////////////////////////////////
            //after a few cycles ,a rep msg from IN_local_rep fifo come and dc_download should be ready to receive the flits
            // note :here are three kinds of reps and reqs  totally,
            // including :9 flits long msg : exrep , shrep, sh->exrep
            //            3 flits long msg : invreq, wbreq, flushreq, scflushreq,
            //            1 flit long msg  : C2Cinvrep  so far. 
            
            
            
            /////////////////////////////////////////////////////////////
            /////////////FIRST TEST 9 FLITS LONG MSG 
            //first flit 
            IN_flit_dc=16'h1234;
            v_IN_flit_dc=1'b1;
            In_flit_ctrl_dc=2'b01; 
            
             
            `step
            // second flit comes and is usefull for dc_download
            IN_flit_dc=16'h1234;
            v_IN_flit_dc=1'b1;
            In_flit_ctrl_dc=2'b10;
            
            `step
            // 3rd flit comes and is usefull for dc_download
            IN_flit_dc=16'h1234;
            v_IN_flit_dc=1'b1;
            In_flit_ctrl_dc=2'b10;
            
            `step
            // 4th flit comes and is usefull for dc_download
            IN_flit_dc=16'h1234;
            v_IN_flit_dc=1'b1;
            In_flit_ctrl_dc=2'b10;
            
            //  JUST a test that whether ic_download only output inst word to inst cache when it has receiverd all flits taht required!
            $display("(%t)TEST ERROR msg to data cache is :%h,and is vallid :%b ,and dc_download_state is:%b ",$time,dc_download_flits,v_dc_download,dc_download_state);
            $fdisplay(logfile,"(%t) TEST ERROR msg to data cache is :%h,and is vallid :%b ,and dc_download_state is:%b ",$time,dc_download_flits,v_dc_download,dc_download_state);
            
            `step
            // 5th flit comes and is usefull for dc_download
            IN_flit_dc=16'h1234;
            v_IN_flit_dc=1'b1;
            In_flit_ctrl_dc=2'b10;
            
            `step
            // 6th flit comes and is usefull for dc_download
            IN_flit_dc=16'h1234;
            v_IN_flit_dc=1'b1;
            In_flit_ctrl_dc=2'b10;
            
            // just test that whether ic_download only output inst word to inst cache when it has receiverd all flits taht required!
            `step
            // 7th flit comes and is usefull for dc_download
            IN_flit_dc=16'h1234;
            v_IN_flit_dc=1'b1;
            In_flit_ctrl_dc=2'b10;
            
            `step
            // 8th flit comes and is usefull for dc_download
            IN_flit_dc=16'h1234;
            v_IN_flit_dc=1'b1;
            In_flit_ctrl_dc=2'b10;
            
            `step
            // 9th flit comes and is usefull for dc_download
            IN_flit_dc=16'h1234;
            v_IN_flit_dc=1'b1;
            In_flit_ctrl_dc=2'b11;
            
            `step
            //at this time, inst cache is ready to receive inst word and all inst words have been recceived by ic_download   
            $display("(%t) msg to data cache is :%h,and is vallid :%b ,and dc_download_state is:%b ",$time,dc_download_flits,v_dc_download,dc_download_state);
            $fdisplay(logfile,"(%t) msg todata cache is :%h,and is vallid :%b ,and dc_download_state is:%b ",$time,dc_download_flits,v_dc_download,dc_download_state);
            
            
            /////////////////////////////////////////////////////////////
            /////////////FIRST TEST 3 FLITS LONG MSG 
            //first flit 
            IN_flit_dc=16'h1234;
            v_IN_flit_dc=1'b1;
            In_flit_ctrl_dc=2'b01; 
            
              
            `step
            // second flit comes and is usefull for dc_download
            IN_flit_dc=16'h1234;
            v_IN_flit_dc=1'b1;
            In_flit_ctrl_dc=2'b10;
            
            // JUST a test that whether ic_download only output inst word to inst cache when it has receiverd all flits taht required!
            $display("(%t)TEST ERROR msg to data cache is :%h,and is vallid :%b ,and dc_download_state is:%b ",$time,dc_download_flits,v_dc_download,dc_download_state);
            $fdisplay(logfile,"(%t) TEST ERROR msg to data cache is :%h,and is vallid :%b ,and dc_download_state is:%b ",$time,dc_download_flits,v_dc_download,dc_download_state);
            `step
            // 3rd flit comes and is usefull for dc_download
            IN_flit_dc=16'h1234;
            v_IN_flit_dc=1'b1;
            In_flit_ctrl_dc=2'b11;
            
            `step
            //at this time, inst cache is ready to receive inst word and all inst words have been recceived by ic_download   
            $display("(%t) msg to data cache is :%h,and is vallid :%b ,and dc_download_state is:%b ",$time,dc_download_flits,v_dc_download,dc_download_state);
            $fdisplay(logfile,"(%t) msg to data cache is :%h,and is vallid :%b ,and dc_download_state is:%b ",$time,dc_download_flits,v_dc_download,dc_download_state);
         
            
            
            /////////////////////////////////////////////////////////////
            /////////////FIRST TEST 1 FLITS LONG MSG 
            //first flit     
            IN_flit_dc=16'h1234;  // condition: IN_flit_dc[9:5]==nackrep_cmd||IN_flit_dc[9:5]==SCflurep_cmd||IN_flit_dc[9:5]==C2Cinvrep_cmd
            v_IN_flit_dc=1'b1;
            In_flit_ctrl_dc=2'b01;
            
            `step
            //at this time, inst cache is ready to receive inst word and all inst words have been recceived by ic_download   
            $display("(%t) msg to data cache is :%h,and is vallid :%b ,and dc_download_state is:%b ",$time,dc_download_flits,v_dc_download,dc_download_state);
            $fdisplay(logfile,"(%t) msg to data cache is :%h,and is vallid :%b ,and dc_download_state is:%b ",$time,dc_download_flits,v_dc_download,dc_download_state);

          $stop;      
        end
      endmodule