/// date :2016/3/4
/// engineer :ZhaiShaoMin
/// module name :memory_state_data_ram
/// module function : here is placed the ram of state and data
///                   because of design division
/// note:  state[3:0] is directory
///        state[5:4] is home directory state .00 :R(dir),01 :W(id),10 TR(dir),11 TW(id). 
/// every home memeory has 2KB
module  memory_state_data_ram(// input
                                  clk,
                                  state_we_in,
                                  state_re_in,
                                  addr_in,
                                  state_in,
                                  data_we_in,
                                  data_re_in,
                                  data_in,
                                // output
                                  state_out,
                                  data_out);
             
input                                  clk;
input                                  state_we_in;
input                                  state_re_in;
input       [31:0]                     addr_in;
input       [5:0]                      state_in;
input                                  data_we_in;
input                                  data_re_in;
input       [127:0]                    data_in;
input       [5:0]                      state_out;
input       [127:0]                    data_out;
                               

/*wire       [31:0]  seled_addr;
wire       [5:0]   m_state_out;
wire       [127:0] seled_data;
wire       [127:0] data_read; */
           /////////////////////////////////////////////////////////////////////////
           ////////////// directory_ram   and  data_ram////////////////////////////////////
           ////////////////////////////////////////////////////////////////////////
           SP_BRAM_SRd  #(128,6,7)  tag_ram(.clk(clk), .we(state_we_in), .re(state_re_in), .a(addr_in[10:4]), .di(state_in), .do(state_out));
           SP_BRAM_SRd  #(128,128,7) data_ram(.clk(clk), .we(data_we_in), .re(data_re_in), .a(addr_in[10:4]), .di(data_out), .do(data_read));
endmodule

