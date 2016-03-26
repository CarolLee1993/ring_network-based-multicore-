/// date:2016/3/4
/// engineer: ZhaiShaoMin
/// module function : just combine memory_fsm and memory_state_data_ram
module    memory (//input
                    clk,
                    rst,
                    //fsm state of rep paralle-serial port corresponding to mem 
                    m_rep_fsm_state,
                    //fsm state of req paralle-serial port corresponding to mem
                    m_req_fsm_state,
                    // fsm state of req paralle-serial port corresponding to data cache
                    d_fsm_state,
                    // input from local d cache
                    v_d_req,
                    v_d_rep, 
                    local_d_head_in,
                    local_d_addr_in,
                    local_d_data_in,
                    // input from local i cache
                    v_i_rep,
                    //  local_i_head,  // no need for local i cache miss
                    local_i_addr_in,
                    // input form INfifos 
                    v_INfifos,
                    infifos_head_in,
                    infifos_addr_in,
                    infifos_data_in,
                    // output to local d cache
                    v_req_d,
                    v_rep_d,
                    head_out_local_d,
                    addr_out_local_d,
                    data_out_local_d,
                    // output to local i cahce
                    v_rep_i,
                    data_out_local_i,
                    // output to OUT req fifo
                    en_inv_ids,
                    inv_ids_in,
                    flit_max_req,
                    en_flit_max_req,
                    v_req_out,
                    head_out_req_out,
                    addr_out_req_out,
                  //  data_out_req_out,
                    // output to OUT rep fifo
                    flit_max_rep,
                    en_flit_max_rep,
                    v_rep_out,
                    head_out_rep_out,
                    addr_out_rep_out,
                    data_out_rep_out,
                    mem_access_done
                    );
// input
 input                    clk;
 input                    rst;
                          //fsm state of rep paralle-serial port corresponding to mem 
 input       [1:0]        m_rep_fsm_state;
                          //fsm state of req paralle-serial port corresponding to mem
 input       [1:0]        m_req_fsm_state;
                          // fsm state of req paralle-serial port corresponding to data cache
 input       [1:0]        d_fsm_state;
                          // input from local d cache
 input                    v_d_req;
 input                    v_d_rep; 
 input      [15:0]        local_d_head_in;
 input      [31:0]        local_d_addr_in;
 input      [127:0]       local_d_data_in;
                          // input from local i cache
 input                    v_i_rep;
                          //  local_i_head,  // no need for local i cache miss
 input      [31:0]        local_i_addr_in;
                          // input form INfifos 
 input                    v_INfifos;
 input      [15:0]        infifos_head_in;
 input      [31:0]        infifos_addr_in;
 input      [127:0]       infifos_data_in;
 
 // output             
                         // output to local d cache
 output                    v_req_d;
 output                    v_rep_d;
 output     [15:0]         head_out_local_d;
 output     [31:0]         addr_out_local_d;
 output     [127:0]        data_out_local_d;
                           // output to local i cahce
 output                    v_rep_i;
 output     [127:0]        data_out_local_i;
                           // output to OUT req fifo
 output                    en_inv_ids;
 output     [3:0]          inv_ids_in;
 output     [1:0]          flit_max_req;
 output                    en_flit_max_req;
 output                    v_req_out;
 output     [15:0]         head_out_req_out;
 output     [31:0]         addr_out_req_out;
 //output     [127:0]        data_out_req_out;
                           // output to OUT rep fifo
 output     [3:0]          flit_max_rep;
 output                    en_flit_max_rep; 
 output                    v_rep_out;
 output     [15:0]         head_out_rep_out;
 output     [31:0]         addr_out_rep_out;
 output     [127:0]        data_out_rep_out;
 output                    mem_access_done;
 
 wire    state_we_net;
 wire    state_re_net;
 wire    data_we_net;
 wire    data_re_net;
 wire    [31:0] addr_net;
 wire    [127:0] data_in_net;
 wire    [127:0] data_out_net;
 wire    [5:0]   state_in_net;
 wire    [5:0]   state_out_net;
  memory_state_data_ram  mem_ram(// input
                            .clk(clk),
                            .state_we_in(state_we_net),
                            .state_re_in(state_re_net),
                            .addr_in(addr_net),
                            .state_in(state_in_net),
                            .data_we_in(data_we_net),
                            .data_re_in(data_re_net),
                            .data_in(data_in_net),
                          // output
                            .state_out(state_out_net),
                            .data_out(data_out_net));
  memory_fsm   mem_fsm(// global signals
               .clk(clk),
               .rst(rst),
               //fsm state of rep paralle-serial port corresponding to mem 
               .m_rep_fsm_state(m_rep_fsm_state),
               //fsm state of req paralle-serial port corresponding to mem
               .m_req_fsm_state(m_req_fsm_state),
               // fsm state of req paralle-serial port corresponding to data cache
               .d_fsm_state(d_fsm_state),
               // input from mem_ram
               .mem_state_out(state_out_net),
               .mem_data_in(data_out_net),
               // input from local d cache
               .v_d_req(v_d_req),
               .v_d_rep(v_d_rep), 
               .local_d_head_in(local_d_head_in),
               .local_d_addr_in(local_d_addr_in),
               .local_d_data_in(local_d_data_in),
               // input from local i cache
               .v_i_rep(v_i_rep),
             //  local_i_head,  // no need for local i cache miss
               .local_i_addr_in(),
               // input form INfifos 
               .v_INfifos(v_INfifos),
               .infifos_head_in(infifos_head_in),
               .infifos_addr_in(infifos_addr_in),
               .infifos_data_in(infifos_data_in),
               
               //output to mem_ram
               .data_out_mem_ram(data_in_net),
               .state_out_mem_ram(state_in_net),
               .addr_out_mem_ram(addr_net),
               .state_we_out(state_we_net),
               .state_re_out(state_re_net),
               .data_we_out(data_we_net),
               .data_re_out(data_re_net),
               // output to local d cache
               .v_req_d(v_req_d),
               .v_rep_d(v_rep_d),
               .head_out_local_d(head_out_local_d),
               .addr_out_local_d(addr_out_local_d),
               .data_out_local_d(data_out_local_d),
               // output to local i cahce
               .v_rep_Icache(v_rep_i),
               .data_out_local_i(data_out_local_i),
               // output to OUT req fifo
               .en_inv_ids(en_inv_ids),
               .inv_ids_in(inv_ids_in),
               .flit_max_req(flit_max_req),
               .en_flit_max_req(en_flit_max_req),
               .v_req_out(v_req_out),
               .head_out_req_out(head_out_req_out),
               .addr_out_req_out(addr_out_req_out),
               //.data_out_req_out(data_out_req_out),
               // output to OUT rep fifo
               .flit_max_rep(flit_max_rep),
               .en_flit_max_rep(en_flit_max_rep),
               .v_rep_out(v_rep_out),
               .head_out_rep_out(head_out_rep_out),
               .addr_out_rep_out(addr_out_rep_out),
               .data_out_rep_out(data_out_rep_out),
               .mem_access_done(mem_access_done)
               );
endmodule