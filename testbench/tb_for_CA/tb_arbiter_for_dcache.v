/*******************************************************************
date:2016/3/30
designer:ZhaiShaoMin
module name :tb_arbiter_for_dcache
moduel function : check errors in arbiter_for_dcache
********************************************************************/

`timescale 1ns/1ps

module tb_arbiter_for_dcache();
  
//input
reg                         clk;
reg                         rst;
reg                         dcache_done_access;
reg                         v_dc_download;
reg     [143:0]             dc_download_flits;
reg                         v_cpu;
reg     [67:0]              cpu_access_flits;
reg                         v_m_d_areg;
reg     [143:0]             m_d_areg_flits;
//output
wire    [143:0]             flits_dc;
wire                        v_flits_dc;
wire                        re_dc_download_flits;
wire                        re_cpu_access_flits;
wire                        re_m_d_areg_flits;
wire                        cpu_done_access;
wire                        dc_download_done_access;
wire                        m_d_areg_done_access; 

//instante design

arbiter_for_dcache(//input
                              .clk(clk),
                              .rst(rst),
                              .dcache_done_access(dcache_done_access),
                              .v_dc_download(v_dc_download),
                              .dc_download_flits(dc_download_flits),
                              .v_cpu(v_cpu),
                              .cpu_access_flits(cpu_access_flits),
                              .v_m_d_areg(v_m_d_areg),
                              .m_d_areg_flits(m_d_areg_flits),
                              //output
                              .flits_dc(flits_dc),
                              .v_flits_dc(v_flits_dc),
                              .re_dc_download_flits(re_dc_download_flits),
                              .re_cpu_access_flits(re_cpu_access_flits),
                              .re_m_d_areg_flits(re_m_d_areg_flits),
                              .cpu_done_access(cpu_done_access),
                              .dc_download_done_access(dc_download_done_access),
                              .m_d_areg_done_access(m_d_areg_done_access)
                              );
                              
          integer     log_file;
          
          //initial inputs
          initial 
            begin
              clk=1'b0;
              rst=1'b1;
              dcache_done_access=1'b0;
              v_dc_download=1'b0;
              dc_download_flits=144'hc0de_1234_c1de_5678_c2de_1234_c3de_5678_c4de;
              v_cpu=1'b0;
              cpu_access_flits=68'h01234c0de5678c0de;
              v_m_d_areg=1'b0;
              m_d_areg_flits=144'h1234_c0de_5678_c1de_1234_c2de_5678_c3de_1234;
              log_file=$fopen("log_arbiter_for_dcache");
            end
            
            `define clk_step #14;
            
            always #7 clk=~clk;
            
            //////////////////////////////////////////////////////////////
            ////////////////BEGIN TEST!///////////////////////////////////
            
            initial   begin
              
              `clk_step
              $display("begin test!");
              $fdisplay("begin test!");
                
                rst=1'b1;
                
                /////////////////////////////////////////////////
                ///////////////first case: all valid  ///////////
                
                //// m_d_flits win,due to priority3 was reset to 3'b001!
                `clk_step
                
                dcache_done_access=1'b0;
                v_dc_download=1'b1;
                dc_download_flits=144'hc0de_1234_c1de_5678_c2de_1234_c3de_5678_c4de;
                v_cpu=1'b1;
                cpu_access_flits=68'h01234c0de5678c0de;
                v_m_d_areg=1'b1;
                m_d_areg_flits=144'h1234_c0de_5678_c1de_1234_c2de_5678_c3de_1234;
                
                `clk_step
                dcache_done_access=1'b0;
                v_dc_download=1'b1;
                dc_download_flits=144'hc0de_1234_c1de_5678_c2de_1234_c3de_5678_c4de;
                v_cpu=1'b1;
                cpu_access_flits=68'h01234c0de5678c0de;
                v_m_d_areg=1'b1;
                m_d_areg_flits=144'h1234_c0de_5678_c1de_1234_c2de_5678_c3de_1234;
                
                `clk_step
                dcache_done_access=1'b0;
                v_dc_download=1'b1;
                dc_download_flits=144'hc0de_1234_c1de_5678_c2de_1234_c3de_5678_c4de;
                v_cpu=1'b1;
                cpu_access_flits=68'h01234c0de5678c0de;
                v_m_d_areg=1'b1;
                m_d_areg_flits=144'h1234_c0de_5678_c1de_1234_c2de_5678_c3de_1234;
                
                ///dcache has processed m_d_flits ,due to RR it will be turn of  cpu access
                `clk_step
                dcache_done_access=1'b1;
                v_dc_download=1'b1;
                dc_download_flits=144'hc0de_1234_c1de_5678_c2de_1234_c3de_5678_c4de;
                v_cpu=1'b1;
                cpu_access_flits=68'h01234c0de5678c0de;
                v_m_d_areg=1'b1;
                m_d_areg_flits=144'h1234_c0de_5678_c1de_1234_c2de_5678_c3de_1234;         
                  
                `clk_step
                dcache_done_access=1'b0;
                v_dc_download=1'b1;
                dc_download_flits=144'hc0de_1234_c1de_5678_c2de_1234_c3de_5678_c4de;
                v_cpu=1'b1;
                cpu_access_flits=68'h01234c0de5678c0de;
                v_m_d_areg=1'b1;
                m_d_areg_flits=144'h1234_c0de_5678_c1de_1234_c2de_5678_c3de_1234;  
                
                
                `clk_step
                dcache_done_access=1'b0;
                v_dc_download=1'b1;
                dc_download_flits=144'hc0de_1234_c1de_5678_c2de_1234_c3de_5678_c4de;
                v_cpu=1'b1;
                cpu_access_flits=68'h01234c0de5678c0de;
                v_m_d_areg=1'b1;
                m_d_areg_flits=144'h1234_c0de_5678_c1de_1234_c2de_5678_c3de_1234;
                
                //dcache has processed dc_download flits, due to RR now it's turn of dc_download
                `clk_step
                dcache_done_access=1'b1;
                v_dc_download=1'b1;
                dc_download_flits=144'hc0de_1234_c1de_5678_c2de_1234_c3de_5678_c4de;
                v_cpu=1'b1;
                cpu_access_flits=68'h01234c0de5678c0de;
                v_m_d_areg=1'b1;
                m_d_areg_flits=144'h1234_c0de_5678_c1de_1234_c2de_5678_c3de_1234;
                
                `clk_step
                dcache_done_access=1'b0;
                v_dc_download=1'b1;
                dc_download_flits=144'hc0de_1234_c1de_5678_c2de_1234_c3de_5678_c4de;
                v_cpu=1'b1;
                cpu_access_flits=68'h01234c0de5678c0de;
                v_m_d_areg=1'b1;
                m_d_areg_flits=144'h1234_c0de_5678_c1de_1234_c2de_5678_c3de_1234;
                
                `clk_step
                dcache_done_access=1'b0;
                v_dc_download=1'b1;
                dc_download_flits=144'hc0de_1234_c1de_5678_c2de_1234_c3de_5678_c4de;
                v_cpu=1'b1;
                cpu_access_flits=68'h01234c0de5678c0de;
                v_m_d_areg=1'b1;
                m_d_areg_flits=144'h1234_c0de_5678_c1de_1234_c2de_5678_c3de_1234;
                
                `clk_step
                dcache_done_access=1'b1;
                v_dc_download=1'b1;
                dc_download_flits=144'hc0de_1234_c1de_5678_c2de_1234_c3de_5678_c4de;
                v_cpu=1'b1;
                cpu_access_flits=68'h01234c0de5678c0de;
                v_m_d_areg=1'b1;
                m_d_areg_flits=144'h1234_c0de_5678_c1de_1234_c2de_5678_c3de_1234;
                
                //////////////////////////////////////////////////////////////////////
                ///////////2nd case:both cpu access and dc_download flit are valid////
               
                ///////turn of cpu due to RR 
                `clk_step
                dcache_done_access=1'b0;
                v_dc_download=1'b1;
                dc_download_flits=144'hc0de_1234_c1de_5678_c2de_1234_c3de_5678_c4de;
                v_cpu=1'b1;
                cpu_access_flits=68'h01234c0de5678c0de;
                v_m_d_areg=1'b0;
                m_d_areg_flits=144'h1234_c0de_5678_c1de_1234_c2de_5678_c3de_1234;
                
                `clk_step
                dcache_done_access=1'b0;
                v_dc_download=1'b1;
                dc_download_flits=144'hc0de_1234_c1de_5678_c2de_1234_c3de_5678_c4de;
                v_cpu=1'b1;
                cpu_access_flits=68'h01234c0de5678c0de;
                v_m_d_areg=1'b0;
                m_d_areg_flits=144'h1234_c0de_5678_c1de_1234_c2de_5678_c3de_1234;
                
                `clk_step
                dcache_done_access=1'b1;
                v_dc_download=1'b1;
                dc_download_flits=144'hc0de_1234_c1de_5678_c2de_1234_c3de_5678_c4de;
                v_cpu=1'b1;
                cpu_access_flits=68'h01234c0de5678c0de;
                v_m_d_areg=1'b0;
                m_d_areg_flits=144'h1234_c0de_5678_c1de_1234_c2de_5678_c3de_1234;
                
                ///turn of dc access
                `clk_step
                dcache_done_access=1'b0;
                v_dc_download=1'b1;
                dc_download_flits=144'hc0de_1234_c1de_5678_c2de_1234_c3de_5678_c4de;
                v_cpu=1'b1;
                cpu_access_flits=68'h01234c0de5678c0de;
                v_m_d_areg=1'b0;
                m_d_areg_flits=144'h1234_c0de_5678_c1de_1234_c2de_5678_c3de_1234;
                
                `clk_step
                dcache_done_access=1'b0;
                v_dc_download=1'b1;
                dc_download_flits=144'hc0de_1234_c1de_5678_c2de_1234_c3de_5678_c4de;
                v_cpu=1'b1;
                cpu_access_flits=68'h01234c0de5678c0de;
                v_m_d_areg=1'b0;
                m_d_areg_flits=144'h1234_c0de_5678_c1de_1234_c2de_5678_c3de_1234;
                
                `clk_step
                dcache_done_access=1'b1;
                v_dc_download=1'b1;
                dc_download_flits=144'hc0de_1234_c1de_5678_c2de_1234_c3de_5678_c4de;
                v_cpu=1'b1;
                cpu_access_flits=68'h01234c0de5678c0de;
                v_m_d_areg=1'b0;
                m_d_areg_flits=144'h1234_c0de_5678_c1de_1234_c2de_5678_c3de_1234;
                
                
                //////////////////////////////////////////////////////////////////
                ////////3rd case: cpu and mem valid///////////////////////////////
                
                ///////turn of mem due to RR 
                `clk_step
                dcache_done_access=1'b0;
                v_dc_download=1'b0;
                dc_download_flits=144'hc0de_1234_c1de_5678_c2de_1234_c3de_5678_c4de;
                v_cpu=1'b1;
                cpu_access_flits=68'h01234c0de5678c0de;
                v_m_d_areg=1'b1;
                m_d_areg_flits=144'h1234_c0de_5678_c1de_1234_c2de_5678_c3de_1234;
                
                `clk_step
                dcache_done_access=1'b0;
                v_dc_download=1'b0;
                dc_download_flits=144'hc0de_1234_c1de_5678_c2de_1234_c3de_5678_c4de;
                v_cpu=1'b1;
                cpu_access_flits=68'h01234c0de5678c0de;
                v_m_d_areg=1'b1;
                m_d_areg_flits=144'h1234_c0de_5678_c1de_1234_c2de_5678_c3de_1234;
                
                `clk_step
                dcache_done_access=1'b1;
                v_dc_download=1'b0;
                dc_download_flits=144'hc0de_1234_c1de_5678_c2de_1234_c3de_5678_c4de;
                v_cpu=1'b1;
                cpu_access_flits=68'h01234c0de5678c0de;
                v_m_d_areg=1'b1;
                m_d_areg_flits=144'h1234_c0de_5678_c1de_1234_c2de_5678_c3de_1234;
                
                ///turn of cpu access
                `clk_step
                dcache_done_access=1'b0;
                v_dc_download=1'b1;
                dc_download_flits=144'hc0de_1234_c1de_5678_c2de_1234_c3de_5678_c4de;
                v_cpu=1'b1;
                cpu_access_flits=68'h01234c0de5678c0de;
                v_m_d_areg=1'b0;
                m_d_areg_flits=144'h1234_c0de_5678_c1de_1234_c2de_5678_c3de_1234;
                
                `clk_step
                dcache_done_access=1'b0;
                v_dc_download=1'b1;
                dc_download_flits=144'hc0de_1234_c1de_5678_c2de_1234_c3de_5678_c4de;
                v_cpu=1'b1;
                cpu_access_flits=68'h01234c0de5678c0de;
                v_m_d_areg=1'b0;
                m_d_areg_flits=144'h1234_c0de_5678_c1de_1234_c2de_5678_c3de_1234;
                
                `clk_step
                dcache_done_access=1'b1;
                v_dc_download=1'b1;
                dc_download_flits=144'hc0de_1234_c1de_5678_c2de_1234_c3de_5678_c4de;
                v_cpu=1'b1;
                cpu_access_flits=68'h01234c0de5678c0de;
                v_m_d_areg=1'b0;
                m_d_areg_flits=144'h1234_c0de_5678_c1de_1234_c2de_5678_c3de_1234;
                
                /////////////////////////////////////////////////////////////////
                ///////// 4th case: dc and mem are valid/////////////////////////
                
                /// turn of mem 
                `clk_step
                dcache_done_access=1'b0;
                v_dc_download=1'b1;
                dc_download_flits=144'hc0de_1234_c1de_5678_c2de_1234_c3de_5678_c4de;
                v_cpu=1'b0;
                cpu_access_flits=68'h01234c0de5678c0de;
                v_m_d_areg=1'b1;
                m_d_areg_flits=144'h1234_c0de_5678_c1de_1234_c2de_5678_c3de_1234;
                
                `clk_step
                dcache_done_access=1'b0;
                v_dc_download=1'b1;
                dc_download_flits=144'hc0de_1234_c1de_5678_c2de_1234_c3de_5678_c4de;
                v_cpu=1'b0;
                cpu_access_flits=68'h01234c0de5678c0de;
                v_m_d_areg=1'b1;
                m_d_areg_flits=144'h1234_c0de_5678_c1de_1234_c2de_5678_c3de_1234;
                
                `clk_step
                dcache_done_access=1'b1;
                v_dc_download=1'b1;
                dc_download_flits=144'hc0de_1234_c1de_5678_c2de_1234_c3de_5678_c4de;
                v_cpu=1'b0;
                cpu_access_flits=68'h01234c0de5678c0de;
                v_m_d_areg=1'b1;
                m_d_areg_flits=144'h1234_c0de_5678_c1de_1234_c2de_5678_c3de_1234;
                
                ///turn of dc access
                `clk_step
                dcache_done_access=1'b0;
                v_dc_download=1'b1;
                dc_download_flits=144'hc0de_1234_c1de_5678_c2de_1234_c3de_5678_c4de;
                v_cpu=1'b0;
                cpu_access_flits=68'h01234c0de5678c0de;
                v_m_d_areg=1'b1;
                m_d_areg_flits=144'h1234_c0de_5678_c1de_1234_c2de_5678_c3de_1234;
                
                `clk_step
                dcache_done_access=1'b0;
                v_dc_download=1'b1;
                dc_download_flits=144'hc0de_1234_c1de_5678_c2de_1234_c3de_5678_c4de;
                v_cpu=1'b0;
                cpu_access_flits=68'h01234c0de5678c0de;
                v_m_d_areg=1'b1;
                m_d_areg_flits=144'h1234_c0de_5678_c1de_1234_c2de_5678_c3de_1234;
                
                `clk_step
                dcache_done_access=1'b1;
                v_dc_download=1'b1;
                dc_download_flits=144'hc0de_1234_c1de_5678_c2de_1234_c3de_5678_c4de;
                v_cpu=1'b0;
                cpu_access_flits=68'h01234c0de5678c0de;
                v_m_d_areg=1'b1;
                m_d_areg_flits=144'h1234_c0de_5678_c1de_1234_c2de_5678_c3de_1234;
                
                //////////////////////////////////////////////////////////////////
                /////////5th case :only dc valid//////////////////////////////////
                
                ///turn of dc access
                `clk_step
                dcache_done_access=1'b0;
                v_dc_download=1'b1;
                dc_download_flits=144'hc0de_1234_c1de_5678_c2de_1234_c3de_5678_c4de;
                v_cpu=1'b0;
                cpu_access_flits=68'h01234c0de5678c0de;
                v_m_d_areg=1'b0;
                m_d_areg_flits=144'h1234_c0de_5678_c1de_1234_c2de_5678_c3de_1234;
                
                `clk_step
                dcache_done_access=1'b0;
                v_dc_download=1'b1;
                dc_download_flits=144'hc0de_1234_c1de_5678_c2de_1234_c3de_5678_c4de;
                v_cpu=1'b0;
                cpu_access_flits=68'h01234c0de5678c0de;
                v_m_d_areg=1'b0;
                m_d_areg_flits=144'h1234_c0de_5678_c1de_1234_c2de_5678_c3de_1234;
                
                `clk_step
                dcache_done_access=1'b1;
                v_dc_download=1'b1;
                dc_download_flits=144'hc0de_1234_c1de_5678_c2de_1234_c3de_5678_c4de;
                v_cpu=1'b0;
                cpu_access_flits=68'h01234c0de5678c0de;
                v_m_d_areg=1'b0;
                m_d_areg_flits=144'h1234_c0de_5678_c1de_1234_c2de_5678_c3de_1234;
                
                /////////////////////////////////////////////////////////////////
                /////////6th case: only cpu valid////////////////////////////////
                
                ///turn of dc access
                `clk_step
                dcache_done_access=1'b0;
                v_dc_download=1'b0;
                dc_download_flits=144'hc0de_1234_c1de_5678_c2de_1234_c3de_5678_c4de;
                v_cpu=1'b1;
                cpu_access_flits=68'h01234c0de5678c0de;
                v_m_d_areg=1'b0;
                m_d_areg_flits=144'h1234_c0de_5678_c1de_1234_c2de_5678_c3de_1234;
                
                `clk_step
                dcache_done_access=1'b0;
                v_dc_download=1'b0;
                dc_download_flits=144'hc0de_1234_c1de_5678_c2de_1234_c3de_5678_c4de;
                v_cpu=1'b1;
                cpu_access_flits=68'h01234c0de5678c0de;
                v_m_d_areg=1'b0;
                m_d_areg_flits=144'h1234_c0de_5678_c1de_1234_c2de_5678_c3de_1234;
                
                `clk_step
                dcache_done_access=1'b1;
                v_dc_download=1'b0;
                dc_download_flits=144'hc0de_1234_c1de_5678_c2de_1234_c3de_5678_c4de;
                v_cpu=1'b1;
                cpu_access_flits=68'h01234c0de5678c0de;
                v_m_d_areg=1'b0;
                m_d_areg_flits=144'h1234_c0de_5678_c1de_1234_c2de_5678_c3de_1234;
                
                /////////////////////////////////////////////////////////
                ///////////////////7th case :only mem valid//////////////
                
                ///turn of dc access
                `clk_step
                dcache_done_access=1'b0;
                v_dc_download=1'b0;
                dc_download_flits=144'hc0de_1234_c1de_5678_c2de_1234_c3de_5678_c4de;
                v_cpu=1'b0;
                cpu_access_flits=68'h01234c0de5678c0de;
                v_m_d_areg=1'b1;
                m_d_areg_flits=144'h1234_c0de_5678_c1de_1234_c2de_5678_c3de_1234;
                
                `clk_step
                dcache_done_access=1'b0;
                v_dc_download=1'b0;
                dc_download_flits=144'hc0de_1234_c1de_5678_c2de_1234_c3de_5678_c4de;
                v_cpu=1'b0;
                cpu_access_flits=68'h01234c0de5678c0de;
                v_m_d_areg=1'b1;
                m_d_areg_flits=144'h1234_c0de_5678_c1de_1234_c2de_5678_c3de_1234;
                
                `clk_step
                dcache_done_access=1'b1;
                v_dc_download=1'b0;
                dc_download_flits=144'hc0de_1234_c1de_5678_c2de_1234_c3de_5678_c4de;
                v_cpu=1'b0;
                cpu_access_flits=68'h01234c0de5678c0de;
                v_m_d_areg=1'b1;
                m_d_areg_flits=144'h1234_c0de_5678_c1de_1234_c2de_5678_c3de_1234;
                
                ////////////////////////////////////////////////////////////
                //////////////8th case: nothing comes //////////////////////
                
                ///turn of dc access
                `clk_step
                dcache_done_access=1'b0;
                v_dc_download=1'b0;
                dc_download_flits=144'hc0de_1234_c1de_5678_c2de_1234_c3de_5678_c4de;
                v_cpu=1'b0;
                cpu_access_flits=68'h01234c0de5678c0de;
                v_m_d_areg=1'b0;
                m_d_areg_flits=144'h1234_c0de_5678_c1de_1234_c2de_5678_c3de_1234;
                
                `clk_step
                dcache_done_access=1'b0;
                v_dc_download=1'b0;
                dc_download_flits=144'hc0de_1234_c1de_5678_c2de_1234_c3de_5678_c4de;
                v_cpu=1'b0;
                cpu_access_flits=68'h01234c0de5678c0de;
                v_m_d_areg=1'b0;
                m_d_areg_flits=144'h1234_c0de_5678_c1de_1234_c2de_5678_c3de_1234;
                
                `clk_step
                dcache_done_access=1'b1;
                v_dc_download=1'b0;
                dc_download_flits=144'hc0de_1234_c1de_5678_c2de_1234_c3de_5678_c4de;
                v_cpu=1'b0;
                cpu_access_flits=68'h01234c0de5678c0de;
                v_m_d_areg=1'b0;
                m_d_areg_flits=144'h1234_c0de_5678_c1de_1234_c2de_5678_c3de_1234;
                
                `clk_step
                
                $display("FINISH TEST!");
                $fdisplay(log_file,"FINISH TEST!");
            end  
          endmodule
