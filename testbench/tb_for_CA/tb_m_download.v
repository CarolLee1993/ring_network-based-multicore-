//date:2016/3/16
//engineer: zhaishaomin
//module function :test whether mem_download  will behave as what i want it to do ,such as handling coming flit correctly 

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

module     tb_m_download();
 
//input
reg                    clk;
reg                    rst;
reg     [15:0]         IN_flit_mem;
reg                    v_IN_flit_mem;
reg     [1:0]          In_flit_ctrl;
reg                    mem_done_access;

//output
wire                    v_m_download;
wire    [175:0]         m_donwload_flits;
wire    [1:0]           m_download_state;



//instantiate the uut
 m_download(//input
                    .clk(clk),
                    .rst(rst),
                    .IN_flit_mem(IN_flit_mem),
                    .v_IN_flit_mem(v_IN_flit_mem),
                    .In_flit_ctrl(In_flit_ctrl),
                    .mem_done_access(mem_done_access),
                    //output
                    .v_m_download(v_m_download),
                    .m_donwload_flits(m_donwload_flits),
                    .m_download_state(m_download_state)
                    );

// store the simulation log into log_file
integer logfile;


// Initialize Inputs
        initial begin
            clk=1'b0;
            rst=1'b1;
            IN_flit_mem=16'h0000;
            v_IN_flit_mem=1'b0;
            In_flit_ctrl=2'b00;
            mem_done_access=1'b0;
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
            /////////////FIRST TEST 11 FLITS LONG MSG 
            //first flit 
            IN_flit_mem=16'h1234;
            v_IN_flit_mem=1'b1;
            In_flit_ctrl=2'b01; 
            
            
            `step
            // second flit comes and is usefull for dc_download
            IN_flit_mem=16'h1234;
            v_IN_flit_mem=1'b1;
            In_flit_ctrl=2'b10;
            
            `step
            // 3rd flit comes and is usefull for dc_download
            IN_flit_mem=16'h1234;
            v_IN_flit_mem=1'b1;
            In_flit_ctrl=2'b10;
            
            `step
            // 4th flit comes and is usefull for dc_download
            IN_flit_mem=16'h1234;
            v_IN_flit_mem=1'b1;
            In_flit_ctrl=2'b10;
            
            //  JUST a test that whether ic_download only output inst word to inst cache when it has receiverd all flits taht required!
            $display("(%t)TEST ERROR msg to mem is :%h,and is vallid :%b ,and mem_download_state is:%b ",$time,m_donwload_flits,v_m_download,m_download_state);
            $fdisplay(logfile,"(%t) TEST ERROR msg to mem is :%h,and is vallid :%b ,and mem_download_state is:%b ",$time,m_donwload_flits,v_m_download,m_download_state);
            
            `step
            // 5th flit comes and is usefull for dc_download
            IN_flit_mem=16'h1234;
            v_IN_flit_mem=1'b1;
            In_flit_ctrl=2'b10;
            
            `step
            // 6th flit comes and is usefull for dc_download
            IN_flit_mem=16'h1234;
            v_IN_flit_mem=1'b1;
            In_flit_ctrl=2'b10;
            
            //here assume IN_fifo not ready
            `step
            //7th invalid
            IN_flit_mem=16'h1234;
            v_IN_flit_mem=1'b0;
            In_flit_ctrl=2'b10;
            
            `step
            // 7th flit comes and is usefull for dc_download
            IN_flit_mem=16'h1234;
            v_IN_flit_mem=1'b1;
            In_flit_ctrl=2'b10;
            
            `step
            // 8th flit comes and is usefull for dc_download
            IN_flit_mem=16'h1234;
            v_IN_flit_mem=1'b1;
            In_flit_ctrl=2'b10;
            
            
            //here assume IN_fifo not ready
            `step
            //9th invalid
            IN_flit_mem=16'h1234;
            v_IN_flit_mem=1'b0;
            In_flit_ctrl=2'b10;
            
            `step
            // 9th flit comes and is usefull for dc_download
            IN_flit_mem=16'h1234;
            v_IN_flit_mem=1'b1;
            In_flit_ctrl=2'b10;
            
            `step
            // 10th flit comes and is usefull for dc_download
            IN_flit_mem=16'h1234;
            v_IN_flit_mem=1'b1;
            In_flit_ctrl=2'b10;
            
            `step
            // 11th flit comes and is usefull for dc_download
            IN_flit_mem=16'h1234;
            v_IN_flit_mem=1'b1;
            In_flit_ctrl=2'b11;
            
            `step
            //at this time, inst cache is ready to receive inst word and all inst words have been recceived by ic_download   
            $display("(%t) msg to mem is :%h,and is vallid :%b ,and mem_download_state is:%b ",$time,m_donwload_flits,v_m_download,m_download_state);
            $fdisplay(logfile,"(%t) msg to mem is :%h,and is vallid :%b ,and mem_download_state is:%b ",$time,m_donwload_flits,v_m_download,m_download_state);
            mem_done_access=1'b1;

            /////////////////////////////////////////////////////////////
            /////////////FIRST TEST 9 FLITS LONG MSG 
            //first flit 
            IN_flit_mem=16'h1234;
            v_IN_flit_mem=1'b1;
            In_flit_ctrl=2'b01; 
            
            //note :the 2nd to  9th are the flits which includes actual inst word betys  
            `step
            // second flit comes and is usefull for ic_download
            IN_flit_mem=16'h1234;
            v_IN_flit_mem=1'b1;
            In_flit_ctrl=2'b10;
            
            `step
            // 3rd flit comes and is usefull for ic_download
            IN_flit_mem=16'h1234;
            v_IN_flit_mem=1'b1;
            In_flit_ctrl=2'b10;
            
            `step
            // 4th flit comes and is usefull for ic_download
            IN_flit_mem=16'h1234;
            v_IN_flit_mem=1'b1;
            In_flit_ctrl=2'b10;
            
            //  JUST a test that whether ic_download only output inst word to inst cache when it has receiverd all flits taht required!
            $display("(%t)TEST ERROR msg to mem is :%h,and is vallid :%b ,and mem_download_state is:%b ",$time,m_donwload_flits,v_m_download,m_download_state);
            $fdisplay(logfile,"(%t) TEST ERROR msg to mem is :%h,and is vallid :%b ,and mem_download_state is:%b ",$time,m_donwload_flits,v_m_download,m_download_state);
            
            `step
            // 5th flit comes and is usefull for ic_download
            IN_flit_mem=16'h1234;
            v_IN_flit_mem=1'b1;
            In_flit_ctrl=2'b10;
            
            //here assume IN_fifo not ready
            `step
            //6th invalid
            IN_flit_mem=16'h1234;
            v_IN_flit_mem=1'b0;
            In_flit_ctrl=2'b10;
            
            `step
            // 6th flit comes and is usefull for ic_download
            IN_flit_mem=16'h1234;
            v_IN_flit_mem=1'b1;
            In_flit_ctrl=2'b10;
            
            // just test that whether ic_download only output inst word to inst cache when it has receiverd all flits taht required!
            `step
            // 7th flit comes and is usefull for ic_download
            IN_flit_mem=16'h1234;
            v_IN_flit_mem=1'b1;
            In_flit_ctrl=2'b10;
            
            `step
            // 8th flit comes and is usefull for ic_download
            IN_flit_mem=16'h1234;
            v_IN_flit_mem=1'b1;
            In_flit_ctrl=2'b10;
            
            `step
            // 9th flit comes and is usefull for ic_download
            IN_flit_mem=16'h1234;
            v_IN_flit_mem=1'b1;
            In_flit_ctrl=2'b11;
            
            `step
            //at this time, inst cache is ready to receive inst word and all inst words have been recceived by ic_download   
            $display("(%t) msg to mem is :%h,and is vallid :%b ,and mem_download_state is:%b ",$time,m_donwload_flits,v_m_download,m_download_state);
            $fdisplay(logfile,"(%t) msg to mem is :%h,and is vallid :%b ,and mem_download_state is:%b ",$time,m_donwload_flits,v_m_download,m_download_state);
            `step
            `step
            `step
            mem_done_access=1'b1;
            
            /////////////////////////////////////////////////////////////
            /////////////FIRST TEST 3 FLITS LONG MSG 
            //first flit 
            IN_flit_mem=16'h1234;
            v_IN_flit_mem=1'b1;
            In_flit_ctrl=2'b01; 
            
            //here assume IN_fifo not ready
            `step
            //2th invalid
            IN_flit_mem=16'h1234;
            v_IN_flit_mem=1'b0;
            In_flit_ctrl=2'b10;
            
            `step
            // second flit comes and is usefull for ic_download
            IN_flit_mem=16'h1234;
            v_IN_flit_mem=1'b1;
            In_flit_ctrl=2'b10;
            
            // JUST a test that whether ic_download only output inst word to inst cache when it has receiverd all flits taht required!
            $display("(%t)TEST ERROR msg to mem is :%h,and is vallid :%b ,and mem_download_state is:%b ",$time,m_donwload_flits,v_m_download,m_download_state);
            $fdisplay(logfile,"(%t) TEST ERROR msg to mem is :%h,and is vallid :%b ,and mem_download_state is:%b ",$time,m_donwload_flits,v_m_download,m_download_state);
            `step
            // 3rd flit comes and is usefull for ic_download
            IN_flit_mem=16'h1234;
            v_IN_flit_mem=1'b1;
            In_flit_ctrl=2'b11;
            
            `step
            //at this time, inst cache is ready to receive inst word and all inst words have been recceived by ic_download   
            $display("(%t) msg to mem is :%h,and is vallid :%b ,and mem_download_state is:%b ",$time,m_donwload_flits,v_m_download,m_download_state);
            $fdisplay(logfile,"(%t) msg to mem is :%h,and is vallid :%b ,and mem_download_state is:%b ",$time,m_donwload_flits,v_m_download,m_download_state);
            `step
            mem_done_access=1'b1;
            
            
            /////////////////////////////////////////////////////////////
            /////////////FIRST TEST 1 FLITS LONG MSG 
            //first flit 
            IN_flit_mem=16'h1234;
            v_IN_flit_mem=1'b1;
            In_flit_ctrl=2'b01;
            
            `step
        
            $display("(%t) msg to mem is :%h,and is vallid :%b ,and mem_download_state is:%b ",$time,m_donwload_flits,v_m_download,m_download_state);
            $fdisplay(logfile,"(%t) msg to mem is :%h,and is vallid :%b ,and mem_download_state is:%b ",$time,m_donwload_flits,v_m_download,m_download_state);
            `step
            `step
            `step
            
            `step
            mem_done_access=1'b1;
            
            `step
            $display("(%t) msg to mem is :%h,and is vallid :%b ,and mem_download_state is:%b ",$time,m_donwload_flits,v_m_download,m_download_state);
            $fdisplay(logfile,"(%t) msg to mem is :%h,and is vallid :%b ,and mem_download_state is:%b ",$time,m_donwload_flits,v_m_download,m_download_state);
          $stop;      
        end
      endmodule
