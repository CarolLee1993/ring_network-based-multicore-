//date: 2016/3/13
//engineer :ZhaiShaoMin
//module name :ring_node 
//module function: It includes network_interface , commu_assist ,core ,inst cache ,data cache and memory.
module   ring_node(//input
                     clk,
                     rst,
                     ctrl_in, //[1:0] for guiding flit flowing ; 00:nothing, 01:head flit, 10:body flit, 11:tail flit
                     flit_in, 
                     dest_fifo_in,
                     en_local_req_in,
                     en_local_rep_in,
                     en_pass_req_in,
                     en_pass_rep_in,
                     used_slots_pass_req_in,
                     used_slots_pass_rep_in,
                     //output
                     en_local_req,    // to previous node  refer to below notes  
                     en_local_rep,    
                     en_pass_req,     // from next node  //local_in_req fifo in next node says that it can receive
                     en_pass_rep,     // refer to notes below
                     used_slots_pass_req,
                     used_slots_pass_rep,               
                     flit_out,
                     ctrl_out,
                     dest_fifo_out
                     );
//input
input                     clk;
input                     rst;
input    [1:0]            ctrl_in;      //[1:0] for guiding flit flowing ; 00:nothing, 01:head flit, 10:body flit, 11:tail flit
input    [15:0]           flit_in;  
input    [1:0]            dest_fifo_in;
input                     en_local_req_in;
input                     en_local_rep_in;
input                     en_pass_req_in;
input                     en_pass_rep_in;
input    [3:0]            used_slots_pass_req_in;
input    [3:0]            used_slots_pass_rep_in;
//output
output                     en_local_req;    // to previous node  refer to below notes  
output                     en_local_rep;    
output                     en_pass_req;    // from next node  //local_in_req fifo in next node says that it can receive
output                     en_pass_rep;     // refer to notes below
output   [3:0]             used_slots_pass_req;
output   [3:0]             used_slots_pass_rep;               
output   [15:0]            flit_out;
output   [1:0]             ctrl_out;
output   [1:0]             dest_fifo_out;
// top- down 
// network interface  output
wire      [17:0]             deq_req_data;                  //[17:0]cache or memory dequeue a flit from  IN_local req fifo
wire      [17:0]             deq_rep_data;                  //[17:0]cache or memory dequeue a flit from  IN_local rep fifo
wire                         en_local_req;    // to previous node  refer to below notes  
wire                         en_local_rep;    
wire                         en_pass_req;    // from next node  //local_in_req fifo in next node says that it can receive
wire                         en_pass_rep;     // refer to notes below
wire      [3:0]              used_slots_pass_req;
wire      [3:0]              used_slots_pass_rep;               
wire      [15:0]             flit_out;
wire      [1:0]              ctrl_out;
wire      [1:0]              dest_fifo_out;

//commu assist output
                         // output
 wire                          ack_rep;   //  arbiter tell IN rep fifo that it's ready to receive flit,
                                      //  as well as been used by IN rep fifo as a deq rdy signal
 wire                          ack_req;   //req_rep and req_req are better!
                           // output
 wire        [1:0]             OUT_req_ctrl; // used to tell the frame of msg. 00 means nothing 01 means head flit,
                                         // 10 means body flit,11 means tail flit, exception is invrep which has only one flit.
 wire        [15:0]            OUT_req_flit; // flit outputed to OUT req fifo
 wire                          OUT_req_ack;  // same as rdy signal saying now I'm a valid flit, also a enq signal for OUT req fifo 
 wire        [1:0]             OUT_rep_ctrl; // similar function as above 
 wire        [15:0]            OUT_rep_flit;
 wire                          OUT_rep_ack;  
 wire                          v_inst_rep; // saying that is a valid rep data back to pipeline
 wire        [31:0]            inst_data;  // rep data (inst word) back to pipeline.
 wire        [143:0]           flits_dcache;    // arbiter select a flits to dcache
 wire                          v_flits_dcache;   // means it's a valid flits to dcache
                           // output 
 wire                          v_m_download;       // valic flits from m_download to mem
 wire        [175:0]           m_donwload;         //flits from m_download to mem
 wire                          v_d_m_areg;         // valid flits from d_m_areg to mem
 wire        [175:0]           d_m_areg;           // flits from d_m_areg to mem
 wire                          v_i_m_areg;
 wire        [31:0]            i_m_areg;
                           
 wire        [1:0]             ic_download_fsm_state;  //here are some fsm state indicating whether some state elements is idle or busy
 wire                          m_d_areg_fsm_state;     // which is useful to decide whether or not to output flits from mem to these elements
 wire                          m_rep_fsm_state;
 wire                          m_req_fsm_state;
 wire        [1:0]             d_m_areg_fsm_state;    // fsm state outputed from commu_assist intended to tell dcache if it's able 
                                                   // to send flits to these units
 wire        [1:0]             dc_req_fsm_state;
 wire        [1:0]             dc_rep_fsm_state;  
 
 //dcache_cpu_network_ctrler output
                        //output to cpu access regs saying that data cache doesn't need cpu_addr anymore!
wire                         done_access_cpu_addr;
                      //output to tell arbiter that data cache has been accessed!
wire                         dcache_done_access;
                      //output to d_m_areg when the generated msg is a local msg
wire    [175:0]              flits_d_m_areg;   // at most 11 flits 
wire                         v_flits_d_m_areg;
                      //output to dc_upload_req regs
wire    [47:0]               flits_dc_upload_req; // always 3 flits
wire                         v_flits_dc_upload_req;
wire                         en_flit_max_req_d;
wire    [1:0]                flit_max_req_d;
                      //output to dc_upload_rep regs
wire    [175:0]              flits_dc_upload_rep; // at most 11 flits
wire                         v_flits_dc_upload_rep;
wire                         en_flit_max_rep_d;
wire    [3:0]                flit_max_rep_d;
                       // output to cpu tell whether cpu access has done
wire    [31:0]               data_cpu;
wire                         v_rep_cpu;

//inst cache output
wire                    v_ic_req;
wire                    local_or_OUT; //1:local  ,0:OUT_req
wire    [47:0]          req_msg;
wire                    v_inst;
wire    [31:0]          inst;

//memory output 

                  // output to local d cache
wire                    v_req_d;
wire                    v_rep_d;
wire     [15:0]         head_out_local_d;
wire     [31:0]         addr_out_local_d;
wire     [127:0]        data_out_local_d;
                    // output to local i cahce
wire                    v_rep_i;
wire     [127:0]        data_out_local_i;
                    // output to OUT req fifo
wire                    en_inv_ids;
wire     [3:0]          inv_ids_in;
wire     [1:0]          flit_max_req_m;
wire                    en_flit_max_req_m;               
wire                    v_req_out;
wire     [15:0]         head_out_req_out;
wire     [31:0]         addr_out_req_out;
wire     [127:0]        data_out_req_out;
                    // output to OUT rep fifo
wire     [3:0]          flit_max_rep_m;
wire                    en_flit_max_rep_m; 
wire                    v_rep_out;
wire     [15:0]         head_out_rep_out;
wire     [31:0]         addr_out_rep_out;
wire     [127:0]        data_out_rep_out;

// core output

             //output
wire     [31:0]     pc;
wire                v_pc;
wire                v_mem;
wire     [3:0]      mem_head;
wire     [31:0]     mem_addr;
wire     [31:0]     mem_data; 
network_interface     NI (
                      //input    
                         .clk(clk),                           //global clock
                         .rst(rst),                           //global reset
                         .ctrl_in(ctrl_in),                          //[2:0] for guiding flit flowing ; 00:nothing, 01:head flit, 10:body flit, 11:tail flit
                                                        //ctrl[2]  1:next_node; 0:not_next_node;
                         .flit_in(flit_in),  
                         .dest_fifo_in(dest_fifo_in),                    
                         .en_IN_req_deq(ack_req),    // from arbiter_for_IN_node in commu_assist             
                         .en_IN_rep_deq(ack_rep),                 
                         .enq_req_data({OUT_req_ctrl,OUT_req_flit}),    // from arbiter_for_OUT_req fifo in commu_assist     (include ctrl)          
                         .enq_rep_data({OUT_rep_ctrl,OUT_rep_flit}),     // from arbiter_for_OUT_rep fifo in commu_assist     (include ctrl)
                         .en_OUT_req_enq(OUT_req_ack),     // from arbiter_for_OUT_req fifo in commu_assist             
                         .en_OUT_rep_enq(OUT_rep_ack),     // from arbiter_for_OUT_rep fifo in commu_assist            
                         .en_local_req_in(en_local_req_in),
                         .en_local_rep_in(en_local_rep_in),
                         .en_pass_req_in(en_pass_req_in),
                         .en_pass_rep_in(en_pass_rep_in),
                         .used_slots_pass_req_in(used_slots_pass_req_in),
                         .used_slots_pass_rep_in(used_slots_pass_rep_in),            //the pass req fifo of next node says it can receive a flit
                      //output   
                         .deq_req_data(deq_req_data),                  //[17:0]cache or memory dequeue a flit from  IN_local req fifo
                         .deq_rep_data(deq_rep_data),                  //[17:0]cache or memory dequeue a flit from  IN_local rep fifo
                         .req_rdy(req_rdy),
                         .rep_rdy(rep_rdy),
                         .en_local_req(en_local_req),    // to previous node  refer to below notes  
                         .en_local_rep(en_local_rep),    
                         .en_pass_req(en_pass_req),     // from next node  //local_in_req fifo in next node says that it can receive
                         .en_pass_rep(en_pass_rep),     // refer to notes below
                         .used_slots_pass_req(used_slots_pass_req),
                         .used_slots_pass_rep(used_slots_pass_rep),               
                         .flit_out(flit_out),
                         .ctrl_out(ctrl_out),
                         .dest_fifo_out(dest_fifo_out),
                         .OUT_req_rdy(OUT_req_rdy),
                         .OUT_rep_rdy(OUT_rep_rdy)
                         );
                         

commu_assist            CA(//input
                           .clk(clk),
                           .rst(rst),
                           // I/O between arbiter and IN fifos
                           // input
                           .req_flit_in(deq_req_data[15:0]),  //flit from IN req fifo
                           .req_rdy(req_rdy),      // it's ready for arbiter_IN_node to dequeue flit from In req fifo
                           .req_ctrl_in(deq_req_data[17:16]), //control signals from In fifo indicate what kind of flit under transfering
                           .rep_flit_in(deq_rep_data[15:0]),  
                           .rep_rdy(rep_rdy),    
                           .rep_ctrl_in(deq_rep_data[17:16]),
                           // output
                           .ack_rep(ack_rep),   //  arbiter tell IN rep fifo that it's ready to receive flit,
                                      //  as well as been used by IN rep fifo as a deq rdy signal
                           .ack_req(ack_req),   //req_rep and req_req are better!
                           
                           /// I/O about OUT_req/rep fifo
                           //input
                           .OUT_req_rdy(OUT_req_rdy), // arbiter_OUT_req tell OUT req fifo to be ready to receive flit from commu_assist 
                           .OUT_rep_rdy(OUT_rep_rdy), // arbiter_OUT_rep ......
                           // output
                           .OUT_req_ctrl(OUT_req_ctrl), // used to tell the frame of msg. 00 means nothing 01 means head flit,
                                         // 10 means body flit,11 means tail flit, exception is invrep which has only one flit.
                           .OUT_req_flit(OUT_req_flit), // flit outputed to OUT req fifo
                           .OUT_req_ack(OUT_req_ack),  // same as rdy signal saying now I'm a valid flit, also a enq signal for OUT req fifo 
                           .OUT_rep_ctrl(OUT_rep_ctrl), // similar function as above 
                           .OUT_rep_flit(OUT_rep_flit),
                           .OUT_rep_ack(OUT_rep_ack),
                           
                           /// I/O about inst cache
                           // input 
                       //    .v_req_inst(),     // indicate that's a valid inst request from pc
                       //    .pc_addr(),     // addr of pc used to look up inst cache to find intended inst 
                           // to OUT_req
                           .v_flits_2_ic_req(local_or_OUT), // saying I'm a valid req flits to OUT req fifo
                           .flits_2_ic_req(req_msg),   //  req flits output to OUT req fifo
                           // to local mem
                           .v_req_2_i_m_areg(!local_or_OUT),  // saying I'm a valid req flits to local home(memory)
                           .req_i_m_areg(req_msg[31:0]),     //  req flits output to local home
                           // output
                           .v_inst_rep(v_inst_rep), // saying that is a valid rep data back to pipeline
                           .inst_data(inst_data),  // rep data (inst word) back to inst cahe.
                           
                           /// I/O about data cache
                           // input
                           .dcache_done_access(dcache_done_access), // data cache tell arbiter_for_dcache previous access had done via this signal
                           // output 
                           .flits_dcache(flits_dcache),    // arbiter select a flits to dcache
                           .v_flits_dcache(v_flits_dcache),   // means it's a valid flits to dcache
                           
                           /// I/O about cpu_req_cache about ll/ld/st/sc
                           // input
                           .v_cpu_access(v_mem), // means it's a valid access from pipeline
                           .cpu_head(mem_head),    // this part include access ctrl info such as ll or ld ,sc or st ,wr or rd
                           .cpu_addr(mem_addr),   //addr of mem ops 
                           .cpu_data(mem_data),   // data of store or store-condition
                           
                           /// I/O about memory
                           // input 
                           .ack_m_donwload(v_m_download),      // response to m_download saying i'm now reading flits
                           .ack_d_m_donwload(v_d_m_areg),    // similar as above
                           .ack_i_m_donwload(v_i_m_areg),    //similar as above  
                           .mem_access_done(mem_access_done),
                           
                           .mem_ic_donwload(data_out_local_i),     // flits from mem to ic_download
                           .v_mem_ic_download(v_rep_i),   //  flit above is valid 
                           .mem_m_d_areg({head_out_local_d,addr_out_local_d,data_out_local_d}),        // flits from mem to m_d_areg
                           .v_mem_m_d_areg(v_req_d||v_rep_d),      // it's a valid flits to m_d_areg 
                           .mem_m_req({head_out_rep_out,addr_out_rep_out}),          // similar as above 
                           .v_mem_m_req(v_req_out),
                           .mem_m_rep({head_out_rep_out,addr_out_rep_out,data_out_rep_out}),
                           .v_mem_m_rep(v_rep_out),        //similar as above
                           .en_m_flits_max_rep(en_flit_max_rep_m),
                           .m_flits_max_rep(flit_max_rep_m),
                           .en_m_flits_max_req(en_flit_max_req_m),
                           .m_flits_max_req(flit_max_req_m),
                           .en_inv_ids(en_inv_ids),
                           .inv_ids_in(inv_ids_in),
                           // output 
                           .v_m_download(v_m_download),       // valic flits from m_download to mem
                           .m_donwload(m_donwload),         //flits from m_download to mem
                           .v_d_m_areg(v_d_m_areg),         // valid flits from d_m_areg to mem
                           .d_m_areg(d_m_areg),           // flits from d_m_areg to mem
                           .v_i_m_areg(v_i_m_areg),
                           .i_m_areg(i_m_areg),
                           
                           .ic_download_fsm_state(ic_download_fsm_state),  //here are some fsm state indicating whether some state elements is idle or busy
                           .m_d_areg_fsm_state(m_d_areg_fsm_state),     // which is useful to decide whether or not to output flits from mem to these elements
                           .m_rep_fsm_state(m_rep_fsm_state),
                           .m_req_fsm_state(m_req_fsm_state),
                           
                           /// I/O about data cache
                           //input 
                           .dcache_d_m_areg(flits_d_m_areg),      //access via flits from data cache to local mem  
                           .v_dcache_d_m_areg(v_flits_d_m_areg),     // means it's avalid access
                           .dcache_dc_req(flits_dc_upload_req),        // access via flits to OUT_req_upload corresponding to dcache
                           .v_dcache_dc_req(v_flits_dc_upload_req),      // means it's avalid access
                           .dcache_dc_rep(flits_dc_upload_rep),        
                           .v_dcache_dc_rep(v_flits_dc_upload_rep),
                           .en_dc_flits_max_rep(en_flit_max_rep_d),
                           .dc_flits_max_rep(flit_max_rep_d),
                           /// output
                           
                           .d_m_areg_fsm_state(d_m_areg_fsm_state),    // fsm state outputed from commu_assist intended to tell dcache if it's able 
                                                   // to send flits to these units
                           .dc_req_fsm_state(dc_req_fsm_state),
                           .dc_rep_fsm_state(dc_rep_fsm_state)
                           );


                           
dcache_cpu_network_ctrler       
                    DCNC( //global ctrl signals
                         .clk(clk),
                         .rst(rst),
                      //input from arbiter_for_dcache
                         .flits_in(flits_dcache),
                         .v_flits_in(v_flits_dcache),
                         .v_cpu_req(v_mem),
                      // input from cpu access regs used for cpu_side wait state:shrep or exrep or SH_exrep or invrep
                         .cpu_addr_for_wait(mem_addr),
                         .v_cpu_addr_for_wait(v_mem),
                         .cpu_access_head(mem_head),
                      //input from dc_upload_req regs :  fsm_state to tell dcache whether it's idle
                         .d_req_state(dc_req_fsm_state),
                      //input from dc_upload_rep regs  : fsm state to tell dcache whether it's idle
                         .d_rep_state(dc_rep_fsm_state),
                      // input from d_m_areg(=>data cache to mem access regs) :fsm state. used to tell dcache whether it's idle
                         .m_fsm_state(d_m_areg_fsm_state),
                      //output to cpu access regs saying that data cache doesn't need cpu_addr anymore!
                         .done_access_cpu_addr(done_access_cpu_addr),
                      //output to tell arbiter that data cache has been accessed!
                         .dcache_done_access(dcache_done_access),
                      //output to d_m_areg when the generated msg is a local msg
                         .flits_d_m_areg(flits_d_m_areg),   // at most 11 flits 
                         .v_flits_d_m_areg(v_flits_d_m_areg),
                      //output to dc_upload_req regs
                         .flits_dc_upload_req(flits_dc_upload_req), // always 3 flits
                         .v_flits_dc_upload_req(v_flits_dc_upload_req),
                         .en_flit_max_req(en_flit_max_req_d),
                         .flit_max_req(flit_max_req_d),
                      //output to dc_upload_rep regs
                         .flits_dc_upload_rep(flits_dc_upload_rep), // at most 11 flits
                         .v_flits_dc_upload_rep(v_flits_dc_upload_rep),
                         .en_flit_max_rep(en_flit_max_rep_d),
                         .flit_max_rep(flit_max_rep_d),
                       // output to cpu tell whether cpu access has done
                         .data_cpu(data_cpu),
                         .v_rep_cpu(v_rep_cpu)  
                        );
                        
//wire    [47:0]          req_msg_local;
//wire    [47:0]          req_msg_OUT;
//assign   req_msg_local=local_or_OUT?48'hzzzz:req_msg;
//assign   req_msg_OUT=local_or_OUT?req_msg:48'hzzzz;   
// here   should be inst cache ,but by now i haven't written it
inst_cache      IC(//input
                    .clk(clk),
                    .rst(rst),
                    // from pc
                    .v_pc(v_pc),
                    .pc(pc),
                    //from ic_download
                    .inst_4word(inst_data),
                    .v_inst_4word(v_inst_rep),
                    
                    //output
                    // to local mem or OUT_req upload
                    .v_ic_req(v_ic_req),
                    .local_or_OUT(local_or_OUT), //1:local  ,0:OUT_req
                    .req_msg(req_msg),
                    .v_inst(v_inst),
                    .inst(inst)
                    );


                    
                    
  memory          (//input
                    .clk(clk),
                    .rst(rst),
                    //fsm state of rep paralle-serial port corresponding to mem 
                    .m_rep_fsm_state(m_rep_fsm_state),
                    //fsm state of req paralle-serial port corresponding to mem
                    .m_req_fsm_state(m_req_fsm_state),
                    // fsm state of req paralle-serial port corresponding to data cache
                    .d_fsm_state(m_d_areg_fsm_state),
                    // input from local d cache
                    .v_d_req(v_flits_d_m_areg),
                    .v_d_rep(v_flits_d_m_areg), 
                    .local_d_head_in(flits_d_m_areg[175:160]),
                    .local_d_addr_in(flits_d_m_areg[159:128]),
                    .local_d_data_in(flits_d_m_areg[127:0]),
                    // input from local i cache
                    .v_i_rep(!local_or_OUT),
                    //  local_i_head,  // no need for local i cache miss
                    .local_i_addr_in(req_msg[31:0]),
                    // input form INfifos 
                    .v_INfifos(v_m_download),
                    .infifos_head_in(m_donwload[175:160]),
                    .infifos_addr_in(m_donwload[159:128]),
                    .infifos_data_in(m_donwload[127:0]),
                    // output to local d cache
                    .v_req_d(v_req_d),
                    .v_rep_d(v_rep_d),
                    .head_out_local_d(head_out_local_d),
                    .addr_out_local_d(addr_out_local_d),
                    .data_out_local_d(data_out_local_d),
                    // output to local i cahce
                    .v_rep_i(v_rep_i),
                    .data_out_local_i(data_out_local_i),
                    // output to OUT req fifo
                    .en_inv_ids(en_inv_ids),
                    .inv_ids_in(inv_ids_in),
                    .flit_max_req(flit_max_req_m),
                    .en_flit_max_req(en_flit_max_req_m),
                    .v_req_out(v_req_out),
                    .head_out_req_out(head_out_req_out),
                    .addr_out_req_out(addr_out_req_out),
                    .data_out_req_out(data_out_req_out),
                    // output to OUT rep fifo
                    .flit_max_rep(flit_max_rep_m),
                    .en_flit_max_rep(en_flit_max_rep_m),
                    .v_rep_out(v_rep_out),
                    .head_out_rep_out(head_out_rep_out),
                    .addr_out_rep_out(addr_out_rep_out),
                    .data_out_rep_out(data_out_rep_out),
                    //
                    .mem_access_done(mem_access_done)
                    );

                  
core           (//input
                .clk(clk),
                .rst(rst),
                .v_inst(v_inst),
                .inst(inst),
                .v_data(v_rep_cpu),
                .data(data_cpu),
                //output
                .pc(pc),
                .v_pc(v_pc),
                .v_mem(v_mem),
                .mem_head(mem_head),
                .mem_addr(mem_addr),
                .mem_data(mem_data)
                );     
endmodule                                  