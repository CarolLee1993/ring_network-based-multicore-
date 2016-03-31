// date:2016/3/16
// engineer:ZhaiShaoMin
// project:multicore ring based project
// module function: testbench for ic_download
`timescale 1ns/1ps

//`include "constants.v"

module     tb_ic_download();
  
  
//inputs
reg                 clk;
reg                 rst;
reg    [15:0]       rep_flit_ic;
reg                 v_rep_flit_ic;
reg    [1:0]        rep_ctrl_ic;
reg    [127:0]      mem_flits_ic;
reg                 v_mem_flits_ic;


//outputs
wire                ic_download_state;
wire                inst_word_ic;
wire                v_inst_word;

  
  
//instantiate the uut
  ic_download    uut(//input
                    .clk(clk),
                    .rst(rst),
                    .rep_flit_ic(rep_flit_ic),
                    .v_rep_flit_ic(v_rep_flit_ic),
                    .rep_ctrl_ic(rep_ctrl_ic),
                    .mem_flits_ic(mem_flits_ic),
                    .v_mem_flits_ic(v_mem_flits_ic),
                    //output
                    .ic_download_state(ic_download_state),
                    .inst_word_ic(inst_word_ic),
                    .v_inst_word(v_inst_word)
                    );
integer i,j;
integer log_file;

// Initialize Inputs
        initial begin
            clk = 0;
            rst = 0;
            rep_flit_ic=16'h1234;
            v_rep_flit_ic=1'b0;
            rep_ctrl_ic=2'b00;
            mem_flits_ic=128'h12345678123456781234567812345678;
            v_mem_flits_ic=1'b0;
        end
        
    always #20 clk=~clk;
    
    `define  step #40;
    
    initial begin
        
            /////// ic_download test /////////
            
            // First reset all //            

            $display("(%t) Initializing...", $time);
            $fdisplay(log_file, "(%t) Initializing...", $time);
            
            rst=1;                       
            `step
            rst=0;
            
            //////////////////////////////////////////////////////////////////////////////////////////////////////////////
            ///////////////////////////REP MSG FROM LOCAL MEM/////////////////////////////////////////////////////////////
            //here we assume that m_i_areg send a rep msg  to test datapath from mem to inst cache
            mem_flits_ic=128'h12345678123456781234567812345678;
            v_mem_flits_ic=1'b1;
            `step
            $display("(%t)inst word sent to inst cache is valid:%d inst:%h and ic_download_state is :%b",$time,v_inst_word_ic,inst_word_ic,ic_download_state);
            $fdisplay(logfile,"(%t) inst word sent to inst cache is :%h and ic_download_state is :%b",$time,v_inst_word_ic,inst_word_ic,ic_download_state);
            
            `step
            `step
            
            
            //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
            ////////////////////////REP MSG FROM IN_REP_FIFO//////////////////////////////////////////////////////////////////////
            //after a few cycles ,another rep msg from IN_local_rep fifo come and ic_download should be ready to receive the flits
            // note : because head flit of inst_rep is useless for inst cache ,first flit will be droped by ic_download
            //first flit 
            rep_flit_ic=16'h1234;
            v_rep_flit_ic=1'b1;
            rep_ctrl_ic=2'b01; 
            
            //note :the 2nd to  9th are the flits which includes actual inst word betys  
            `step
            // second flit comes and is usefull for ic_download
            rep_flit_ic=16'h1234;
            v_rep_flit_ic=1'b1;
            rep_ctrl_ic=2'b10;
            
            `step
            // 3rd flit comes and is usefull for ic_download
            rep_flit_ic=16'h1234;
            v_rep_flit_ic=1'b1;
            rep_ctrl_ic=2'b10;
            
            `step
            // 4th flit comes and is usefull for ic_download
            rep_flit_ic=16'h1234;
            v_rep_flit_ic=1'b1;
            rep_ctrl_ic=2'b10;
            
            //  JUST a test that whether ic_download only output inst word to inst cache when it has receiverd all flits taht required!
            $display("(%t)just test ERROR:inst word sent to inst cache is valid:%d inst:%h and ic_download_state is :%b",$time,v_inst_word_ic,inst_word_ic,ic_download_state);
            $fdisplay(logfile,"(%t)just test ERROR: inst word sent to inst cache is :%h and ic_download_state is :%b",$time,v_inst_word_ic,inst_word_ic,ic_download_state);
            
            `step
            // 5th flit comes and is usefull for ic_download
            rep_flit_ic=16'h1234;
            v_rep_flit_ic=1'b1;
            rep_ctrl_ic=2'b10;
            
            `step
            // 6th flit comes and is usefull for ic_download
            rep_flit_ic=16'h1234;
            v_rep_flit_ic=1'b1;
            rep_ctrl_ic=2'b10;
            
            // just test that whether ic_download only output inst word to inst cache when it has receiverd all flits taht required!
            `step
            // 7th flit comes and is usefull for ic_download
            rep_flit_ic=16'h1234;
            v_rep_flit_ic=1'b1;
            rep_ctrl_ic=2'b10;
            
            `step
            // 8th flit comes and is usefull for ic_download
            rep_flit_ic=16'h1234;
            v_rep_flit_ic=1'b1;
            rep_ctrl_ic=2'b10;
            
            `step
            // 9th flit comes and is usefull for ic_download
            rep_flit_ic=16'h1234;
            v_rep_flit_ic=1'b1;
            rep_ctrl_ic=2'b11;
            
            `step
            //at this time, inst cache is ready to receive inst word and all inst words have been recceived by ic_download   
            $display("(%t)inst word sent to inst cache is valid:%d inst:%h and ic_download_state is :%b",$time,v_inst_word_ic,inst_word_ic,ic_download_state);
            $fdisplay(logfile,"(%t) inst word sent to inst cache is :%h and ic_download_state is :%b",$time,v_inst_word_ic,inst_word_ic,ic_download_state);
            
          $stop;  
       end
endmodule   