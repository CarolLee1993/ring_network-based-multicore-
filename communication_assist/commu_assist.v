/// date:2016/3/9
/// engineer :ZhaiShaoMin
/// module name: communication assist
/// module function: put many components,such as arbiter and download_flit_fsm and 
/// upload_flit_fsm,together, then we can get a bigger module which named communication assist.
/// this module is responsible for handling flits from IN fifos and flits to OUT fifos ,as well as 
/// providing  firendly interfaces to inst cache ,data cache and memory
////////////////////////////////////////////////////////////////////////////////
/// submoddules:  arbiter_IN_node,    // guiding flits from IN_fifos to the right places with high efficiency
///               arbiter_for_dc,     // select source flits from cpu_access,IN_fifos msg and local memory access
///               arbiter_for_mem,    // select source flits from local inst cache or local data cache or IN_fifos
///               arbiter_for_OUT_rep,// select src flit from dc_rep_upload and m_rep_upload
///               arbiter_for_OUT_req,// select flit from ic_req_upload or dc_req_upload or m_req_upload
///               ic_download,        // receive rep from IN_rep or local mem
///               dc_download,        // receive rep from IN_rep or req from IN_req
///               m_download,         // receive rep from IN_rep or req from IN_req
///               m_d_areg,           // receive rep or req from local mem
///               d_m_areg,           // receive req or rep fromlocal data cache
///               i_m_areg,           // receive req from local inst cache
///               ic_req_upload,      //upload flits from ic(inst cache) to OUT_req
///               dc_rep_upload,      //upload flits from dc to OUT_req
///               m_rep_upload,       //upload flits from mem to OUT_req
///               dc_req_upload,      //upload flits from dc to OUT_rep
///               m_req_upload        //upload flits from mem to OUT_req
////////////////////////////////////////////////////////////////////////////////
module        commu_assist(//input
                           clk,
                           rst,
                           // I/O between arbiter and IN fifos
                           // input
                           req_flit_in,  //flit from IN req fifo
                           req_rdy,    // it's ready for arbiter_IN_node to dequeue flit from In req fifo
                           req_ctrl_in, //control signals from In fifo indicate what kind of flit under transfering
                           rep_flit_in,  
                           rep_rdy,    
                           rep_ctrl_in,
                           // output
                           ack_rep,   //  arbiter tell IN rep fifo that it's ready to receive flit,
                                      //  as well as been used by IN rep fifo as a deq rdy signal
                           ack_req,   //req_rep and req_req are better!
                           
                           /// I/O about OUT_req/rep fifo
                           //input
                           OUT_req_rdy, // arbiter_OUT_req tell OUT req fifo to be ready to receive flit from commu_assist 
                           OUT_rep_rdy, // arbiter_OUT_rep ......
                           // output
                           OUT_req_ctrl, // used to tell the frame of msg. 00 means nothing 01 means head flit,
                                         // 10 means body flit,11 means tail flit, exception is invrep which has only one flit.
                           OUT_req_flit, // flit outputed to OUT req fifo
                           OUT_req_ack,  // same as rdy signal saying now I'm a valid flit, also a enq signal for OUT req fifo 
                           OUT_rep_ctrl, // similar function as above 
                           OUT_rep_flit,
                           OUT_rep_ack,
                           
                           /// I/O about inst cache
                           // input 
                      //     v_req_inst,     // indicate that's a valid inst request from pc
                      //     pc_addr,     // addr of pc used to look up inst cache to find intended inst 
                           // to OUT_req
                           v_flits_2_ic_req, // saying I'm a valid req flits to OUT req fifo
                           flits_2_ic_req,   //  req flits output to OUT req fifo
                           // to local mem
                           v_req_i_m_areg,  // saying I'm a valid req flits to local home(memory)
                           req_i_m_areg,     //  req flits output to local home
                           // output
                           v_inst_rep, // saying that is a valid rep data back to pipeline
                           inst_data,  // rep data (inst word) back to inst cache.
                           
                           /// I/O about data cache
                           // input
                           dcache_done_access, // data cache tell arbiter_for_dcache previous access had done via this signal
                           // output 
                           flits_dcache,    // arbiter select a flits to dcache
                           v_flits_dcache,   // means it's a valid flits to dcache
                           
                           /// I/O about cpu_req_cache about ll/ld/st/sc
                           // input
                           v_cpu_access, // means it's a valid access from pipeline
                           cpu_head,    // this part include access ctrl info such as ll or ld ,sc or st ,wr or rd
                           cpu_addr,   //addr of mem ops 
                           cpu_data,   // data of store or store-condition
                           
                           /// I/O about memory
                           // input 
                           ack_m_donwload,      // response to m_download saying i'm now reading flits
                           ack_d_m_donwload,    // similar as above
                           ack_i_m_donwload,    //similar as above  
                           mem_access_done,
                           
                           mem_ic_download,     // flits from mem to ic_download
                           v_mem_ic_download,   //  flit above is valid 
                           mem_m_d_areg,        // flits from mem to m_d_areg
                           v_mem_m_d_areg,      // it's a valid flits to m_d_areg 
                           mem_m_req,          // similar as above 
                           v_mem_m_req,
                           mem_m_rep,
                           v_mem_m_rep,        //similar as above
                           en_m_flits_max_rep,
                           m_flits_max_rep,
                           en_m_flits_max_req,
                           m_flits_max_req,
                           en_inv_ids,
                           inv_ids_in,
                           // output 
                           v_m_download,       // valic flits from m_download to mem
                           m_donwload,         //flits from m_download to mem
                           v_d_m_areg,         // valid flits from d_m_areg to mem
                           d_m_areg,           // flits from d_m_areg to mem
                           v_i_m_areg,
                           i_m_areg,
                           
                           ic_download_fsm_state,  //here are some fsm state indicating whether some state elements is idle or busy
                           m_d_areg_fsm_state,     // which is useful to decide whether or not to output flits from mem to these elements
                           m_rep_fsm_state,
                           m_req_fsm_state,
                           
                           /// I/O about data cache
                           //input 
                           dcache_d_m_areg,      //access via flits from data cache to local mem  
                           v_dcache_d_m_areg,     // means it's avalid access
                           dcache_dc_req,        // access via flits to OUT_req_upload corresponding to dcache
                           v_dcache_dc_req,      // means it's avalid access
                           dcache_dc_rep,        
                           v_dcache_dc_rep,
                           en_dc_flits_max_rep,
                           dc_flits_max_rep,
                           /// output
                           
                           d_m_areg_fsm_state,    // fsm state outputed from commu_assist intended to tell dcache if it's able 
                                                   // to send flits to these units
                           dc_req_fsm_state,
                           dc_rep_fsm_state
                           ); 
          
                                      // I/O between arbiter and IN fifos
                                      // input
          input                       clk;
          input                       rst;
          input      [15:0]           req_flit_in;  
          input                       req_rdy;  
          input      [1:0]            req_ctrl_in; 
          input      [15:0]           rep_flit_in;  
          input                       rep_rdy;
          input      [1:0]            rep_ctrl_in;
                                      // output
          output                      ack_rep;
          output                      ack_req; 
  
          input                       OUT_req_rdy; 
          input                       OUT_rep_rdy;
                                      // output
          output    [1:0]             OUT_req_ctrl;                               
          output    [15:0]            OUT_req_flit; 
          output                      OUT_req_ack; 
          output    [1:0]             OUT_rep_ctrl; 
          output    [15:0]            OUT_rep_flit;
          output                      OUT_rep_ack;
                           
                          
                                      // input 
       //   input                       v_req_inst;   
       //   input     [31:0]            pc_addr;                       
          input                       v_flits_2_ic_req; 
          input     [47:0]            flits_2_ic_req; 
                                      // to local mem
          input                       v_req_i_m_areg; 
          input     [31:0]            req_i_m_areg;
                                      // output
          output                      v_inst_rep; 
          output    [127:0]            inst_data; 
                           
                                      /// I/O about data cache
                                      // input
          input                       dcache_done_access; 
                                      // output 
          output    [143:0]           flits_dcache;
          output                      v_flits_dcache;  
                           
                                      /// I/O about cpu_req_cache about ll/ld/st/sc
                                      // input
          input                       v_cpu_access;
          input     [3:0]             cpu_head;  
          input     [31:0]            cpu_addr;   
          input     [31:0]            cpu_data;   
                           
                                      /// I/O about memory
                                      // input 
          input                       ack_m_donwload;    
          input                       ack_d_m_donwload;    
          input                       ack_i_m_donwload; 
          input                       mem_access_done;  
          input     [127:0]           mem_ic_download;     
          input                       v_mem_ic_download;  
          input     [143:0]           mem_m_d_areg;       
          input                       v_mem_m_d_areg;      
          input     [47:0]            mem_m_req;        
          input                       v_mem_m_req;
          input     [143:0]           mem_m_rep;
          input                       v_mem_m_rep;  
          input                       en_m_flits_max_rep;
          input     [3:0]             m_flits_max_rep;
          input                       en_m_flits_max_req;
          input     [1:0]             m_flits_max_req; 
          input                       en_inv_ids;               //from mem
          input                       inv_ids_in;
                                      // output 
           output                     v_m_download;       
           output    [175:0]          m_donwload;         
           output                     v_d_m_areg;         
           output    [175:0]          d_m_areg;         
           output                     v_i_m_areg;
           output    [47:0]           i_m_areg;
                           
           output    [1:0]            ic_download_fsm_state; 
           output                     m_d_areg_fsm_state; 
           output                     m_rep_fsm_state;
           output    [1:0]            m_req_fsm_state;
                           
                                      /// I/O about data cache
                                      //input 
           input     [175:0]          dcache_d_m_areg;       
           input                      v_dcache_d_m_areg;    
           input     [47:0]           dcache_dc_req;       
           input                      v_dcache_dc_req;      
           input     [175:0]          dcache_dc_rep;        
           input                      v_dcache_dc_rep;
           input                      en_dc_flits_max_rep;
           input     [3:0]            dc_flits_max_rep;
                                      /// output
           output                d_m_areg_fsm_state;    
                                                  
           output                dc_req_fsm_state;
           output                dc_rep_fsm_state;

///////////////////////////////////////////////
///////////// submodules//////////////////////
//////////////////////////////////////////////

//output of arbiter_IN_node 
wire         ack_req;
wire         ack_rep;
wire         v_ic_net;
wire [15:0]  flit_ic_net;
wire [1:0]   ctrl_ic_net;
wire         v_dc_net;
wire [15:0]  flit_dc_net;
wire [1:0]   ctrl_dc_net;
wire         v_mem_net;
wire [15:0]  flit_mem_net;
wire [1:0]   ctrl_mem_net;

//output of  arbiter_for_dcache
wire [143:0] flits_dcache_abter;
wire         v_flits_dcache_abter;
wire         re_dc_download_flits;
wire         re_cpu_access_flits;
wire         re_m_d_areg_flits;
wire         cpu_done_access;
wire         dc_download_done_access;
wire         m_d_areg_done_access;

// output of  arbiter_for_mem
wire  ack_m_download_net;
wire  ack_d_m_areg_net;
wire  ack_i_m_areg_net;
wire  v_m_download_m_net;
wire  v_d_m_areg_m_net;
wire  v_i_m_areg_m_net; 

 //output of arbiter_for_OUT_rep
wire       OUT_rep_ack;
wire       ack_dc_rep_net;
wire       ack_mem_rep_net;
wire [1:0] select2_net;

//output of  arbiter_for_OUT_req 
wire       OUT_req_ack;
wire       ack_ic_req_net;
wire       ack_dc_req_net;
wire       ack_mem_req_net;
wire [1:0] select3_net  ;

//output of ic_download
wire [1:0]   ic_download_state_net;
//wire [127:0] inst_data;
wire         v_inst_rep;

//output of dc_download
wire         v_flits_dcache;
wire [143:0] flits_dcache;
wire [1:0]   dc_download_state_net;

//output of m_download
wire         v_m_download;
wire [175:0] m_donwload;
wire [1:0]   mem_download_state_net;
  
//output of m_d_areg
wire [143:0] m_d_areg_flits_net;
wire         v_m_d_areg_flits_net;
wire         m_d_areg_fsm_state;

 //ooutput of d_m_areg
wire [175:0] d_m_areg;
wire         v_d_m_areg;
wire         d_m_areg_fsm_state;

 //output of  i_m_areg 
wire [47:0] i_m_areg;
wire        v_i_m_areg;

 //output of m_rep_upload
wire  [15:0]  m_rep_flit_net;
wire          v_m_rep_flit_net;
wire          m_rep_fsm_state;
wire [1:0]    m_rep_ctrl_net;

 //output of dc_rep_upload
wire [15:0] dc_rep_flit_net;
wire        v_dc_rep_flit_net;
wire        dc_rep_fsm_state;
wire [1:0]  dc_rep_ctrl_net;

//output of ic_req_upload
wire [15:0] ic_req_flit_net;
wire        v_ic_req_flit_net;                       
wire [1:0]  ic_download_fsm_state;
wire [1:0]  ic_req_ctrl_net;
              
 //output of   m_req_upload
wire [1:0]  m_req_ctrl_net;
wire [15:0] m_req_flit_net;
wire [1:0]  m_req_fsm_state;
wire        v_m_req_flit_net;
 
 //output of dc_req_upload
wire  [15:0] dc_req_flit_net;
wire         v_dc_req_flit_net;
wire         dc_req_fsm_state;
wire  [1:0]  dc_req_ctrl_net;  


reg  [15:0]  OUT_req_flit;
reg  [1:0]   OUT_req_ctrl;

//mux OUT_req_ctrl and OUT_req_flit 
always@(*)
begin
  case(select3_net)
  3'b001:
     begin
	  OUT_req_ctrl=m_req_ctrl_net;
	  OUT_req_flit=m_req_flit_net;
	  end
  3'b010:
     begin
	  OUT_req_ctrl=dc_req_ctrl_net;
     OUT_req_flit=dc_req_flit_net;
	  end
  3'b100:
     begin
	  OUT_req_ctrl=ic_req_ctrl_net;
     OUT_req_flit=ic_req_flit_net;
	  end
	default:
     begin
	  OUT_req_ctrl=2'b00;
     OUT_req_flit=ic_req_ctrl_net;
	  end
	endcase
end

reg  [15:0]  OUT_rep_flit;
reg  [1:0]   OUT_rep_ctrl;
//mux OUT_req_ctrl and OUT_req_flit 
always@(*)
begin
  case(select2_net)
  2'b01:
     begin
	  OUT_rep_ctrl=dc_rep_ctrl_net;
     OUT_rep_flit=dc_rep_flit_net;
	  end
  2'b10:
     begin
	  OUT_rep_ctrl=m_rep_ctrl_net;
     OUT_rep_flit=m_rep_flit_net;
	  end
	default:
     begin
	  OUT_rep_ctrl=2'b00;
     OUT_rep_flit=m_rep_flit_net;
	  end
	endcase
end
  arbiter_IN_node    arbiter_IN_node_dut(
  
                           //input
                           .clk(clk),
                           .rst(rst),
                           .in_req_rdy(req_rdy),
                           .in_rep_rdy(rep_rdy),
                           .req_ctrl_in(req_ctrl_in),
                           .rep_ctrl_in(rep_ctrl_in),
                           .req_flit_in(req_flit_in),
                           .rep_flit_in(rep_flit_in),
                           .ic_download_state_in(ic_download_state_net),  // (net)from ic_downlaod
                           .dc_download_state_in(dc_download_state_net),  // from dc_download
                           .mem_download_state_in(mem_download_state_net), // from mem_downlaod
                           //output
                           .ack_req(ack_req),    // to IN_req fifo
                           .ack_rep(ack_rep),    // to IN_rep fifo
                           .v_ic(v_ic_net),      // to ic_download
                           .flit_ic(flit_ic_net), 
                           .ctrl_ic(ctrl_ic_net),
                           .v_dc(v_dc_net),       // to dc_download
                           .flit_dc(flit_dc_net),
                           .ctrl_dc(ctrl_dc_net),
                           .v_mem(v_mem_net),      // to mem_download
                           .flit_mem(flit_mem_net),
                           .ctrl_mem(ctrl_mem_net)
                           );    // guiding flits from IN_fifos to the right places with high efficiency
 
arbiter_for_dcache      arbiter_for_dcache_dut (
                              //input
                              .clk(clk),
                              .rst(rst),
                              .dcache_done_access(dcache_done_access),  // from data cache
                              .v_dc_download(v_flits_dcache),       // from dc_downlaod
                              .dc_download_flits(flits_dcache),
                              .v_cpu(v_cpu_access),                    // from cpu mem stage
                              .cpu_access_flits({cpu_head,cpu_addr,cpu_data}),
                              .v_m_d_areg(v_m_d_areg_flits_net),             // from local mem
                              .m_d_areg_flits(m_d_areg_flits_net),
                              //output
                              .flits_dc(flits_dcache_abter),                  // selected flits to data cache
                              .v_flits_dc(v_flits_dcache_abter),
                              .re_dc_download_flits(re_dc_download_flits),  // to dc_donwlaod
                              .re_cpu_access_flits(re_cpu_access_flits),    // to cpu mem stage
                              .re_m_d_areg_flits(re_m_d_areg_flits),        // to local mem
                              .cpu_done_access(cpu_done_access),            
                              .dc_download_done_access(dc_download_done_access),
                              .m_d_areg_done_access(m_d_areg_done_access)
                              );     // select source flits from cpu_access,IN_fifos msg and local memory access
 
  arbiter_for_mem    arbiter_for_mem_dut(
                             //input
                            .clk(clk),
                            .rst(rst),
                            .v_mem_download(v_m_download),  // from mem_downlaod
                            .v_d_m_areg(v_d_m_areg),          // from local data cache
                            .v_i_m_areg(v_i_m_areg),          // from local inst cache
                            .mem_access_done(mem_access_done),    // from local mem
                            //output
                            .ack_m_download(ack_m_download_net),  // to m_download
                            .ack_d_m_areg(ack_d_m_areg_net),      // to data cache via d_m_areg
                            .ack_i_m_areg(ack_i_m_areg_net), 
                            .v_m_download_m(v_m_download_m_net),   // to mem syaing these flits is valid
                            .v_d_m_areg_m(v_d_m_areg_m_net),
                            .v_i_m_areg_m(v_i_m_areg_m_net)
                            );    // select source flits from local inst cache or local data cache or IN_fifos
									 


 arbiter_for_OUT_rep   arbiter_for_OUT_rep_dut(
                               //input
                               .clk(clk),
                               .rst(rst),
                               .OUT_rep_rdy(OUT_rep_rdy),    // from OUT_rep fifo 
                               .v_dc_rep(v_dc_rep_flit_net),  // from dc_upload 
                               .v_mem_rep(v_m_rep_flit_net),  // from mem_upload
                               .dc_rep_flit(dc_rep_flit_net), 
                               .mem_rep_flit(m_rep_flit_net),
                               .dc_rep_ctrl(dc_rep_ctrl_net),
                               .mem_rep_ctrl(m_rep_ctrl_net),
                               //output
                               .ack_OUT_rep(OUT_rep_ack),     // to OUT_rep fifo
                               .ack_dc_rep(ack_dc_rep_net),   // to dc_upload
                               .ack_mem_rep(ack_mem_rep_net),  //to mem_upload
                               .select(select2_net)  // select 1/2
                               );// select src flit from dc_rep_upload and m_rep_upload


                
arbiter_for_OUT_req   arbiter_for_OUT_req_dut(
                               //input
                               .clk(clk),
                               .rst(rst),
                               .OUT_req_rdy(OUT_req_rdy),       // from  OUT_req fifo
                               .v_ic_req(v_ic_req_flit_net),    // from ic_upload_req
                               .v_dc_req(v_dc_req_flit_net),    // from dc_upload_req
                               .v_mem_req(v_m_req_flit_net),    // from mem_upload_req
                               .ic_req_ctrl(ic_req_ctrl_net),
                               .dc_req_ctrl(dc_req_ctrl_net),
                               .mem_req_ctrl(m_req_ctrl_net),
                               //output
                               .ack_OUT_req(OUT_req_ack),       // to OUT_req
                               .ack_ic_req(ack_ic_req_net),     // to ic_upload_req
                               .ack_dc_req(ack_dc_req_net),     // to dc_
                               .ack_mem_req(ack_mem_req_net),   // to mem_
                               .select(select3_net)// select one from three
                               );// select flit from ic_req_upload or dc_req_upload or m_req_upload
                               
 


 ic_download      ic_download_dut(
                    //input
                    .clk(clk),
                    .rst(rst),
                    .rep_flit_ic(flit_ic_net),           //from arbiter_for_IN_node
                    .v_rep_flit_ic(v_ic_net),
                    .rep_ctrl_ic(ctrl_ic_net),
                    .mem_flits_ic(mem_ic_download),      // from  local mem
                    .v_mem_flits_ic(v_mem_ic_download),
                    //output
                    .ic_download_state(ic_download_state_net), // to local mem and arbiter_IN_node
                    .inst_word_ic(inst_data),                  // to front of cpu
                    .v_inst_word(v_inst_rep)                   
                    );        // receive rep from IN_rep or local mem  
                
						  
 dc_download   dc_download_dut(
                    //input
                    .clk(clk),
                    .rst(rst),
                    .IN_flit_dc(flit_dc_net),    // from arrbiter_IN_node
                    .v_IN_flit_dc(v_dc_net),    
                    .In_flit_ctrl_dc(ctrl_dc_net),
                    .dc_done_access(dcache_done_access), // from data cache
                    //output
                    .v_dc_download(v_flits_dcache),      // to data cache
                    .dc_download_flits(flits_dcache),
                    .dc_download_state(dc_download_state_net) // to arbiter_IN_node
                   );        // receive rep from IN_rep or req from IN_req
 m_download      m_download_dut(
                    //input
                    .clk(clk),
                    .rst(rst),
                    .IN_flit_mem(flit_mem_net),  // from arrbiter_IN_node
                    .v_IN_flit_mem(v_mem_net),
                    .In_flit_ctrl(ctrl_mem_net),
                    .mem_done_access(mem_access_done),  // from mem
                    //output
                    .v_m_download(v_m_download),    // to arbiter_for_mem
                    .m_download_flits(m_donwload),
                    .m_download_state(mem_download_state_net) // to arbiter_IN_node
                    );         // receive rep from IN_rep or req from IN_req

  m_d_areg       m_d_areg_dut(
                   //input
                   .clk(clk),
                   .rst(rst),
                   .m_flits_d(mem_m_d_areg),  // from local mem
                   .v_m_flits_d(v_mem_m_d_areg),
                   .dc_done_access(dcache_done_access), // from data cache
                   //output
                   .m_d_areg_flits(m_d_areg_flits_net),  // to data cache
                   .v_m_d_areg_flits(v_m_d_areg_flits_net),
                   .m_d_areg_state( m_d_areg_fsm_state)  // to local mem
                   );           // receive rep or req from local mem
 

 d_m_areg      d_m_areg_dut(
                    //input
                   .clk(clk),               ////////////////////////////note :here  local mem or data cache   equals   mem or data cache
                   .rst(rst),
                   .d_flits_m(dcache_d_m_areg),    // from data cache
                   .v_d_flits_m(v_dcache_d_m_areg), 
                   .mem_done_access(mem_access_done), // from local mem
                   ///output 
                   .d_m_areg_flits(d_m_areg),      // to local mem
                   .v_d_m_areg_flits(v_d_m_areg),
                   .d_m_areg_state(d_m_areg_fsm_state)  // to data cache
                   );           // receive req or rep fromlocal data cache
 

 i_m_areg       i_m_areg_dut(
                   //input
                   .clk(clk),
                   .rst(rst),
                   .i_flits_m(req_i_m_areg),  // from inst cache
                   .v_i_flits_m(v_req_i_m_areg),
                   .mem_done_access(mem_access_done), // from mem
                   //output
                   .i_m_areg_flits(i_m_areg),   // to mem
                   .v_i_areg_m_flits(v_i_m_areg)
                   );           // receive req from local inst cache

 //note : here we need  a ctrl output 
  m_rep_upload     m_rep_upload_dut (
                        //input
                        .clk(clk),
                        .rst(rst),
                        .m_flits_rep(mem_m_rep),  // from mem
                        .v_m_flits_rep(v_mem_m_rep),
                        .flits_max(m_flits_max_rep),
                        .en_flits_max(en_m_flits_max_rep),
                        .rep_fifo_rdy(ack_mem_rep_net),  // from OUT_rep fifo
                        //output
                        .m_flit_out(m_rep_flit_net),   // to arbiter_OUT_rep
                        .v_m_flit_out(v_m_rep_flit_net),
								.m_ctrl_out(m_rep_ctrl_net),
                        .m_rep_upload_state(m_rep_fsm_state) // to mem
                        );       //upload flits from mem to OUT_req
								
 //note : here we need  a ctrl output 
 dc_rep_upload        dc_rep_upload_dut(
                          //input
                          .clk(clk),
                          .rst(rst),
                          .dc_flits_rep(dcache_dc_rep), // from dc
                          .v_dc_flits_rep(v_dcache_dc_rep),
                          .flits_max(dc_flits_max_rep),
                          .en_flits_max(en_dc_flits_max_rep),
                          .rep_fifo_rdy(ack_dc_rep_net),  // from OUT_rep fifo
                          //output
                          .dc_flit_out(dc_rep_flit_net),  // to arbiter_OUT_rep
                          .v_dc_flit_out(v_dc_rep_flit_net),
								  .dc_ctrl_out(dc_rep_ctrl_net),
                          .dc_rep_upload_state(dc_rep_fsm_state) //to dc
                          );      //upload flits from dc to OUT_req
                          
//note : here we need  a ctrl output                              
 ic_req_upload     ic_req_upload_dut(
                         //input
                         .clk(clk),
                         .rst(rst),
                         .ic_flits_req(flits_2_ic_req),// from ic
                         .v_ic_flits_req(v_flits_2_ic_req),
 //here need a ctrl                        .req_fifo_rdy(ack_ic_req_net),
                         //output
                         .ic_flit_out(ic_req_flit_net),  // to arbiter_OUT_req
                         .v_ic_flit_out(v_ic_req_flit_net),
								 .ic_ctrl_out(ic_req_ctrl_net),
                         .ic_req_upload_state(ic_download_fsm_state) // to inst cache
                         );      //upload flits from ic(inst cache) to OUT_req

 //note : here we need  a ctrl output 
 m_req_upload      m_req_upload_dut(
                             //input
                             .clk(clk),
                             .rst(rst),
                             .v_flits_in(v_mem_m_req), // from mem
                             .out_req_fifo_rdy_in(ack_mem_req_net), //from OUT_req_fifo
                             .en_inv_ids(en_inv_ids),               //from mem
                             .inv_ids_in(inv_ids_in),
                             .flits_max_in(m_flits_max_req),
                             .head_flit(mem_m_req[47:32]),
                             .addrhi(mem_m_req[31:16]),
                             .addrlo(mem_m_req[15:0]),
                             //output
                             .ctrl_out(m_req_ctrl_net),     // to  OUT_req_fifo
                             .flit_out(m_req_flit_net),
                             .fsm_state(m_req_fsm_state),     // to mem
                             .v_flit_to_req_fifo(v_m_req_flit_net)  
                             );       //upload flits from mem to OUT_req

 
//note : here we need  a ctrl output  
dc_req_upload      dc_req_upload_dut(
                          //input
                          .clk(clk),
                          .rst(rst),
                          .dc_flits_req(dcache_dc_req),  // from dc
                          .v_dc_flits_req(v_dcache_dc_req),
                          .req_fifo_rdy(ack_dc_req_net),  // from OUT_req_fifo
                          //output
                          .dc_flit_out(dc_req_flit_net),  // to  OUT_req_fifo
                          .v_dc_flit_out(v_dc_req_flit_net),
								  .dc_ctrl_out(dc_req_ctrl_net),
                          .dc_req_upload_state(dc_req_fsm_state)   // to dc
                          );      //upload flits from dc to OUT_rep
              
endmodule