/// date :2016/2/27
/// engineer
/// module name mem controler
/// module function : include direcotory ram and data ram
 module memory_fsm(// global signals
               clk,
               rst,
               //fsm state of rep paralle-serial port corresponding to mem 
               m_rep_fsm_state,
               //fsm state of req paralle-serial port corresponding to mem
               m_req_fsm_state,
               // fsm state of req/rep regs to data cache
               d_fsm_state,
               // fsm state of input reg to inst cache
               i_fsm_state,
               // input from mem_ram
               mem_state_out,
               mem_data_in,
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
               
               //output to mem_ram
               data_out_mem_ram,
               state_out_mem_ram,
               addr_out_mem_ram,
               //output to mem_ram
               state_we_out,
               state_re_out,
               data_we_out,
               data_re_out,
               // output to local d cache
               v_req_d,
               v_rep_d,
               head_out_local_d,
               addr_out_local_d,
               data_out_local_d,
               // output to local i cahce
               v_rep_Icache,
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
// parameters of msg type used for temp reg 

parameter           shrep_type=4'b0001;
parameter           wbreq_type=4'b0010;
parameter           exrep_type=4'b0011;
parameter           SHexrep_type=4'b0100;
parameter           invreq_type=4'b0101;
parameter           SCinvreq_type=4'b0110;
parameter           flushreq_type=4'b0111;
parameter           SCflurep_type=4'b1000;
parameter           instrep_type=4'b1001;
parameter           nackrep_type=4'b1010;
parameter           local_id=2'b00;

/// parameter   of msg cmd 
/////// request cmd
parameter        shreq_cmd=5'b00000;
parameter        exreq_cmd=5'b00001;
parameter        SCexreq_cmd=5'b00010;
parameter        instreq_cmd=5'b00110;
parameter        wbreq_cmd=5'b00011;
parameter        invreq_cmd=5'b00100;
parameter        flushreq_cmd=5'b00101;
parameter        SCinvreq_cmd=5'b00110;
/////// reply cmd
parameter        wbrep_cmd=5'b10000;
parameter        C2Hinvrep_cmd=5'b10001;
parameter        flushrep_cmd=5'b10010;
parameter        ATflurep_cmd=5'b10011;
parameter        shrep_cmd=5'b11000;
parameter        exrep_cmd=5'b11001;
parameter        SH_exrep_cmd=5'b11010;
parameter        SCflurep_cmd=5'b11100;
parameter        instrep_cmd=5'b10100;
parameter        C2Cinvrep_cmd=5'b11011;
parameter        nackrep_cmd=5'b10101;
parameter        flushfail_rep_cmd=5'b10110;
parameter        wbfail_rep_cmd=5'b10111;

///
parameter       i_idle=2'b00;
parameter       d_idle=1'b0;
parameter       m_rep_idle=1'b0;
parameter       m_req_idle=1'b0;
 input                    clk;
 input                    rst;
 input      [1:0]         i_fsm_state;
 input                    d_fsm_state;
 input                    m_rep_fsm_state;
 input                    m_req_fsm_state;
                        // input from mem_ram
 input      [5:0]         mem_state_out;
 input      [127:0]       mem_data_in;
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
                          
                          // output to mem_ram
 output     [127:0]       data_out_mem_ram;
 output     [5:0]         state_out_mem_ram;
 output     [31:0]        addr_out_mem_ram;
                         //output to mem_ram
 output                   state_we_out;
 output                   state_re_out;
 output                   data_we_out;
 output                   data_re_out;
                         // output to local d cache
 output                    v_req_d;
 output                    v_rep_d;
 output     [15:0]         head_out_local_d;
 output     [31:0]         addr_out_local_d;
 output     [127:0]        data_out_local_d;
                           // output to local i cahce
 output                    v_rep_Icache;
 output     [127:0]        data_out_local_i;
                           // output to OUT req fifo
 output                    en_inv_ids;
 output     [3:0]          inv_ids_in;
 output     [3:0]          flit_max_req;
 output                    en_flit_max_req;          
 output                    v_req_out;
 output     [15:0]         head_out_req_out;
 output     [31:0]         addr_out_req_out;
// output     [127:0]        data_out_req_out;
                           // output to OUT rep fifo
 output     [3:0]          flit_max_rep;
 output                    en_flit_max_rep;
 output                    v_rep_out;
 output     [15:0]         head_out_rep_out;
 output     [31:0]         addr_out_rep_out;
 output     [127:0]        data_out_rep_out;
 output                    mem_access_done;
 
 

           

wire       [5:0]     m_state_out;


assign   m_state_out=mem_state_out;


reg  [15:0]   temp_req_head_flit;
reg  [15:0]   temp_rep_head_flit;
wire   [15:0]  temp_req_head_flit_in1;
wire   [15:0]  temp_rep_head_flit_in1; 

           
           ///////////////////////////////////////////////////////////////////////////
           //////////////////////MEMORY FSM///////////////////////////////////////////

reg           state_re_out;
reg           mem_access_done;
reg           data_re_out;
reg  [1:0]    addr_sel;
reg  [1:0]    data_sel;

reg           req_done;
reg           rep_done;
reg           has_only_id;
reg  [5:0]    m_state_in;
reg           en_rep_type;
reg  [3:0]    rep_type;
reg  [3:0]    rep_type_reg;
reg           en_req_type;
reg  [3:0]    req_type;
reg  [3:0]    req_type_reg;
reg           en_m_state_in;
reg           oneORmore;
reg           en_inv_ids;
reg  [3:0]    inv_ids_in;
reg  [3:0]    src_id_dir;
reg  [3:0]    requester_id_dir;
reg           en_m_data_in;
reg  [175:0]  msg;
reg           v_rep_d;
reg           v_rep_out;
reg           v_req_d;
reg           v_req_out;
reg           v_rep_Icache;
//reg  [4:0]    thead;    
/////////////   I have forget what function it is ,soI think I should take enough notes to some strange things
reg           en_temp_rep_head_flit;
reg  [15:0]   temp_rep_head_flit_in;
reg           en_temp_req_head_flit;
reg  [15:0]   temp_req_head_flit_in; 
//reg  [3:0]    flit_max;
//reg           en_flit_max; 
reg  [3:0]    flit_max_rep;
reg           en_flit_max_rep; 
reg  [3:0]    flit_max_req;
reg           en_flit_max_req;  
reg           t_req_head_sel;
reg           t_rep_head_sel;
reg           id_sel_out;
reg           rep_local_remote;
reg           req_local_remote;
reg  [4:0]    cmd_type;
reg           set_req_done;
reg           set_rep_done;
reg           rst_rep_type;
reg           rst_req_type;
////////fsm
parameter     m_idle=2'b00;
parameter     m_compare_tag=2'b01;
parameter     m_gen_shrep=2'b10;
parameter     m_gen_exrep=2'b11;

reg   [1:0]    nstate;
reg   [1:0]    rstate;

wire  [15:0]   seled_head;
wire  [31:0]   seled_addr;
wire  [127:0]  seled_data;
wire  [127:0]  data_read;

assign data_read=mem_data_in;
assign seled_head=addr_sel?infifos_head_in:local_d_head_in;
assign seled_addr=addr_sel?infifos_addr_in:local_d_addr_in;

assign addr_out_mem_ram=seled_addr;
always@(*)
begin
  // default signal values
 //   en_temp_head_flit=1'b0;
    mem_access_done=1'b0;
    state_re_out=1'b0;
    data_re_out=1'b0;
    cmd_type=5'b00000;
    rep_local_remote=1'b0;
    req_local_remote=1'b0;
    addr_sel=1'b0;
    data_sel=1'b0;
    nstate=rstate;
    has_only_id=1'b0;
    m_state_in=6'b000000;
    en_rep_type=1'b0;
    rep_type=4'b0000;
    en_req_type=1'b0;
    req_type=4'b0000;
    en_m_state_in=1'b0;
    oneORmore=1'b0;
    en_inv_ids=1'b0;
    inv_ids_in=4'b0000;
    src_id_dir=4'b0000;
    requester_id_dir=4'b0000;
    en_m_data_in=1'b0;
    msg=176'h0000;
    v_rep_d=1'b0;
    v_rep_out=1'b0;
    v_req_d=1'b0;
    v_req_out=1'b0;
    v_rep_Icache=1'b0;
 //   thead=5'b00000;
    t_req_head_sel=1'b0;
    t_rep_head_sel=1'b0;
    en_temp_rep_head_flit=1'b0;
    temp_rep_head_flit_in =16'h0000;
    en_temp_req_head_flit=1'b0;
    temp_req_head_flit_in=16'h0000; 
  //  flit_max=4'b0000;
  //  en_flit_max=1'b0;  
    flit_max_req=4'b0000;
    en_flit_max_req=1'b0;
	 flit_max_rep=4'b0000;
    en_flit_max_rep=1'b0;
    id_sel_out=1'b0;
    set_req_done=1'b0;
    set_rep_done=1'b0;
	 rst_rep_type=1'b0;
	 rst_req_type=1'b0;
  case(rstate)
    m_idle:
    begin
      if(v_d_req==1'b1||v_d_rep==1'b1)
        begin
          addr_sel=1'b0;
          data_sel=1'b0;
          nstate=m_compare_tag;
         // en_temp_head_flit=1'b1;
          t_req_head_sel=1'b0;
          t_rep_head_sel=1'b0;
          en_temp_rep_head_flit=1'b1;
          en_temp_req_head_flit=1'b1;
        end
     else  if(v_INfifos==1'b1)
        begin
          addr_sel=1'b1;
          data_sel=1'b1;
          nstate=m_compare_tag;
       //   en_temp_head_flit=1'b1;
          t_req_head_sel=1'b0;
          t_rep_head_sel=1'b0;
          en_temp_rep_head_flit=1'b1;
          en_temp_req_head_flit=1'b1;
        end
    end
    
    m_compare_tag:
    begin
      state_re_out=1'b1;
      // has_only_id function
      case(seled_head[12:11])
        2'b00:has_only_id=m_state_out[3:0]==4'b0001;
        2'b01:has_only_id=m_state_out[3:0]==4'b0010;
        2'b10:has_only_id=m_state_out[3:0]==4'b0100;
        2'b11:has_only_id=m_state_out[3:0]==4'b1000;
      //  default:has_only_id=m_state_out[3:0]==4'b0001;
      endcase
      
      //id_sel_out
      case(seled_head[12:11])
        2'b00:id_sel_out=m_state_out[0];
        2'b01:id_sel_out=m_state_out[1]; 
        2'b10:id_sel_out=m_state_out[2];
        2'b11:id_sel_out=m_state_out[3];
      endcase
      //  default:id_sel_out=m_state_out[0];
      //////////////////////////////////
      // check req /rep type////////////
      //////////////////////////////////
      
      
      //////////////////////////////////
      // fsm will gen shreps
      if((seled_head[9:5]==shreq_cmd||seled_head[9:5]==wbfail_rep_cmd)&&m_state_out[5:4]==2'b00&&id_sel_out==1'b0)
        begin
          if(seled_addr[12:11]==local_id)
            rep_local_remote=1'b0;
          else
            rep_local_remote=1'b1;
          en_m_state_in=1'b1;
          case(seled_head[12:11])
            2'b00:m_state_in={m_state_out[5:1],1'b0};
            2'b01:m_state_in={m_state_out[5:2],1'b0,m_state_out[0]};
            2'b10:m_state_in={m_state_out[5:3],1'b0,m_state_out[1:0]};
            2'b11:m_state_in={m_state_out[5:4],1'b0,m_state_out[2:0]};
            default:m_state_in=m_state_out;
          endcase
          rep_type=shrep_type;
          en_rep_type=1'b1;
     //     oneORmore=1'b0;
          nstate=m_gen_shrep;
       //   t_req_head_sel=1'b0;
          t_rep_head_sel=1'b1;
          en_temp_rep_head_flit=1'b1;
          temp_rep_head_flit_in={temp_rep_head_flit[12:11],1'b0,temp_rep_head_flit[15:14],1'b1,shrep_cmd,5'b00000};
        end
        
        ////////////////////////////////////
        // fsm will gen NACKreply
      if(seled_head[9:5]==shreq_cmd&&m_state_out[5]==1'b1)
        begin
          if(seled_addr[12:11]==local_id)
            rep_local_remote=1'b0;
          else
            rep_local_remote=1'b1;
            /// since the addr being accessed is busy doing other thing,home should just NACK this request ,
            /// (via sending back a simple reply tell the requester the addr now is busy ,please retry again(here just for simplicity)) 
            /// and no need to do something to m_state! 
          rep_type=nackrep_type;
          en_rep_type=1'b1; 
            
     /*     en_m_state_in=1'b1;
          case(seled_head[12:11])
            2'b00:m_state_in={m_state_out[5:1],1'b0};
            2'b01:m_state_in={m_state_out[5:2],1'b0,m_state_out[0]};
            2'b01:m_state_in={m_state_out[5:3],1'b0,m_state_out[1:0]};
            2'b01:m_state_in={m_state_out[5:4],1'b0,m_state_out[2:0]};
            default:m_state_in=m_state_out;
          endcase   */
          
     //     oneORmore=1'b0;
          nstate=m_gen_shrep;
       //   t_req_head_sel=1'b0;
          t_rep_head_sel=1'b1;
          en_temp_rep_head_flit=1'b1;
          temp_rep_head_flit_in={temp_rep_head_flit[12:11],1'b0,temp_rep_head_flit[15:14],1'b1,nackrep_cmd,5'b00000};
        end
        
        
        //////////////////////
        // fsm will gen wbreq
      if(seled_head[9:5]==shreq_cmd&&m_state_out[5:4]==2'b01&&id_sel_out==1'b0)
        begin
          if(seled_addr[12:11]==local_id)
            req_local_remote=1'b0;
          else
            req_local_remote=1'b1;
          en_m_state_in=1'b1;
          m_state_in={2'b11,m_state_out[3:0]};
          en_req_type=1'b1;
          req_type=wbreq_type;
     //     oneORmore=1'b0;
          t_req_head_sel=1'b1;
      //    t_rep_head_sel=1'b0;
          nstate=m_gen_shrep;
          en_temp_req_head_flit=1'b1;
          temp_req_head_flit_in={2'b00,1'b0,temp_req_head_flit[15:14],1'b1,wbreq_cmd,temp_req_head_flit[12:11],3'b000};
        end
        
        ////////////////////////
        // fsm will gen exrep 
      if((seled_head[9:5]==exreq_cmd||seled_head[9:5]==flushfail_rep_cmd||seled_head[9:5]==SCexreq_cmd)&&m_state_out[5:4]==2'b00&&(|m_state_out[3:0]==1'b0||has_only_id))
        begin
          if(seled_addr[12:11]==local_id)
            rep_local_remote=1'b0;
          else
            rep_local_remote=1'b1;
          en_m_state_in=1'b1;
          case(seled_head[12:11])
            2'b00:m_state_in=6'b100001;
            2'b01:m_state_in=6'b100010;
            2'b10:m_state_in=6'b100100;
            2'b11:m_state_in=6'b101000;
            default:m_state_in=6'b100001;
          endcase
          rep_type=exrep_type;
          en_rep_type=1'b1;
          oneORmore=1'b0;
          nstate=m_gen_exrep;
      //    t_req_head_sel=1'b0;
          t_rep_head_sel=1'b1;
          en_temp_rep_head_flit=1'b1;
          temp_rep_head_flit_in={temp_rep_head_flit[12:11],1'b0,temp_rep_head_flit[15:14],1'b1,exrep_cmd,5'b00000};
        end
        
        ////////////////////////
        // fsm will gen NACKrep 
      if((seled_head[9:5]==exreq_cmd||seled_head[9:5]==SCexreq_cmd)&&m_state_out[5]==1'b1)
        begin
          if(seled_addr[12:11]==local_id)
            rep_local_remote=1'b0;
          else
            rep_local_remote=1'b1;
            /// since the addr being accessed is busy doing other thing,home should just NACK this request ,
            /// (via sending back a simple reply tell the requester the addr now is busy ,please retry again(here just for simplicity)) 
            /// and no need to do something to m_state! 
          rep_type=nackrep_type;
          en_rep_type=1'b1;
          oneORmore=1'b0;
     /*     en_m_state_in=1'b1;
          case(seled_head[12:11])
            2'b00:m_state_in=6'b100001;
            2'b01:m_state_in=6'b100010;
            2'b01:m_state_in=6'b100100;
            2'b01:m_state_in=6'b101000;
            default:m_state_in=6'b100001;
          endcase    */
          
          nstate=m_gen_exrep;
      //    t_req_head_sel=1'b0;
          t_rep_head_sel=1'b1;
          en_temp_rep_head_flit=1'b1;
          temp_rep_head_flit_in={temp_rep_head_flit[12:11],1'b0,temp_rep_head_flit[15:14],1'b1,nackrep_cmd,5'b00000};
        end
        
       //////////////////////////////////
      //// fsm will gen invreq /SCinvreq
      if((seled_head[9:5]==exreq_cmd||seled_head[9:5]==SCexreq_cmd)&&m_state_out[5:4]==2'b00&&!(|m_state_out[3:0]==1'b0||has_only_id))
        begin
          
          // check whether the original dir include src_id 
          if(id_sel_out==1'b1)
            begin
              case(seled_head[12:11])
                2'b00:m_state_in={2'b10,m_state_out[3:1],1'b0};
                2'b01:m_state_in={2'b10,m_state_out[3:2],1'b0,m_state_out[0]};
                2'b10:m_state_in={2'b10,m_state_out[3],1'b0,m_state_out[1:0]};
                2'b11:m_state_in={2'b10,1'b0,m_state_out[2:0]};
                default:m_state_in={2'b10,m_state_out[3:1],1'b0};
              endcase
            end
          else
            begin
              m_state_in={2'b10,m_state_out[3:0]};
            end
          //check whether invreq or SCinvreq
          if(seled_head[9:5]==exreq_cmd)
            begin
              req_type=invreq_type;
              cmd_type=invreq_cmd;
            end
          else
            begin
              req_type=SCinvreq_type;
              cmd_type=SCinvreq_cmd;
            end
          if(seled_addr[12:11]==local_id)
            req_local_remote=1'b0;
          else
            req_local_remote=1'b1;
          // commen signals
          en_m_state_in=1'b1;
          en_req_type=1'b1;
          oneORmore=1'b1;
          rep_type=SHexrep_type;
          en_rep_type=1'b1;
          // reg the invreq vectors! 
          en_inv_ids=1'b1;
          inv_ids_in=m_state_out[3:0];
          nstate=m_gen_exrep;
          t_req_head_sel=1'b1;
          t_rep_head_sel=1'b1;
          en_temp_rep_head_flit=1'b1;
          temp_rep_head_flit_in={temp_rep_head_flit[12:11],1'b0,temp_rep_head_flit[15:14],1'b1,exrep_cmd,1'b0,m_state_out[3:0]};
          en_temp_req_head_flit=1'b1;
          temp_req_head_flit_in={2'b00,1'b0,temp_rep_head_flit[15:14],1'b1,cmd_type,temp_rep_head_flit[12:11],3'b000};
        end
        
        //////////////////
        //  gen flushreq
      if(seled_head[9:5]==exreq_cmd&&m_state_out[5:4]==2'b10&&id_sel_out==1'b0)
        begin
          if(seled_addr[12:11]==local_id)
            req_local_remote=1'b0;
          else
            req_local_remote=1'b1;
          oneORmore=1'b0;
          en_m_state_in=1'b1;
          m_state_in={2'b11,m_state_out[3:0]};
          en_req_type=1'b1;
          req_type=flushreq_type;
          nstate=m_gen_exrep;
          t_req_head_sel=1'b1;
      //    t_rep_head_sel=1'b0;
          en_temp_req_head_flit=1'b1;
          temp_req_head_flit_in={2'b00,1'b0,temp_req_head_flit[15:14],1'b1,flushreq_cmd,temp_req_head_flit[12:11],3'b000};
        end
        
        /////////////////
        // gen SCflushrep
      if(seled_head[9:5]==SCexreq_cmd&&m_state_out[5:4]==2'b10&&id_sel_out==1'b0)
        begin
          if(seled_addr[12:11]==local_id)
            rep_local_remote=1'b0;
          else
            rep_local_remote=1'b1;
          oneORmore=1'b0;
          en_rep_type=1'b1;
          rep_type=SCflurep_type;
       //   t_req_head_sel=1'b0;
          nstate=m_gen_exrep;
          t_rep_head_sel=1'b1;
          en_temp_rep_head_flit=1'b1;
          temp_rep_head_flit_in={temp_rep_head_flit[12:11],1'b0,temp_rep_head_flit[15:14],1'b1,SCflurep_cmd,5'b00000};
        end
        
        /////////////////
        /// gen instrep!
      if(seled_head[9:5]==instreq_cmd)
        begin
          if(seled_addr[12:11]==local_id)
            rep_local_remote=1'b0;
          else
            rep_local_remote=1'b1;
          en_rep_type=1'b1;
          rep_type=instrep_type;
   //       oneORmore=1'b0;
          nstate=m_gen_shrep;
    //      t_req_head_sel=1'b0;
          t_rep_head_sel=1'b1;
          en_temp_rep_head_flit=1'b1;
          temp_rep_head_flit_in={temp_rep_head_flit[12:11],1'b0,temp_rep_head_flit[15:14],1'b1,instrep_cmd,5'b00000};
        end
        
        /////////////////////////////////////////////////////////////////////////
        /////////////////////////////////////////////////////////////////////////
        ///////////fsm will process the rep from network or local D$ or I$///////
     
     //process invreps
      if(seled_head[9:5]==C2Cinvrep_cmd&&(m_state_out[5:4]==2'b10))
        begin
		    rst_rep_type=1'b1;
			 rst_req_type=1'b1;
          nstate=m_idle;
          mem_access_done=1'b1;
          // some invreps haven't come  
          if(m_state_out[3:0]!=src_id_dir)
            begin
              en_m_state_in=1'b1;
              case(seled_head[12:11])
                2'b00:m_state_in={2'b10,m_state_out[3:1],1'b0};
                2'b01:m_state_in={2'b10,m_state_out[3:2],1'b0,m_state_out[0]};
                2'b10:m_state_in={2'b10,m_state_out[3],1'b0,m_state_out[1:0]};
                2'b11:m_state_in={2'b10,1'b0,m_state_out[2:0]};
                default:m_state_in={2'b10,m_state_out[3:1],1'b0};
              endcase
            end
           // all the necessary invreps have come 
          else
            begin
              m_state_in={2'b01,requester_id_dir};
              en_m_state_in=1'b1;
            end
            
          //src_id_dir :convert src_id to dir style
          case(seled_head[12:11])
            2'b00:src_id_dir=4'b0001;
            2'b01:src_id_dir=4'b0010;
            2'b10:src_id_dir=4'b0100;
            2'b11:src_id_dir=4'b1000;
            default:src_id_dir=4'b0001;
          endcase
          //requester_id_dir: convert requester id into dir stylr
          case(seled_head[4:3])
            2'b00:requester_id_dir=4'b0001;
            2'b01:requester_id_dir=4'b0010;
            2'b10:requester_id_dir=4'b0100;
            2'b11:requester_id_dir=4'b1000;
            default:requester_id_dir=4'b0001;
          endcase
        end
        
        ////////////////////////////////////
        /// process (auto)invreps
      if(seled_head[9:5]==C2Hinvrep_cmd&&(m_state_out[5:4]==2'b00))
        begin
		    rst_rep_type=1'b1;
			 rst_req_type=1'b1;
          nstate=m_idle;
          mem_access_done=1'b1;
          en_m_state_in=1'b1;
          case(seled_head[12:11])
              2'b00:m_state_in={2'b00,m_state_out[3:1],1'b0};
              2'b01:m_state_in={2'b00,m_state_out[3:2],1'b0,m_state_out[0]};
              2'b10:m_state_in={2'b00,m_state_out[3],1'b0,m_state_out[1:0]};
              2'b11:m_state_in={2'b00,1'b0,m_state_out[2:0]};
            default:m_state_in={2'b00,m_state_out[3:1],1'b0};
          endcase
        end
        
        //////////////////////////////////////
        /// process wbrep
      if(seled_head[9:5]==wbrep_cmd&&(m_state_out[5:4]==2'b11))
        begin
		    rst_rep_type=1'b1;
			 rst_req_type=1'b1;
          nstate=m_idle;
          mem_access_done=1'b1;
          en_m_state_in=1'b1;
          en_m_data_in=1'b1;
          case(seled_head[12:11])
              2'b00:m_state_in={2'b00,m_state_out[3:1],1'b1};
              2'b01:m_state_in={2'b00,m_state_out[3:2],1'b1,m_state_out[0]};
              2'b10:m_state_in={2'b00,m_state_out[3],1'b1,m_state_out[1:0]};
              2'b11:m_state_in={2'b00,1'b1,m_state_out[2:0]};
            default:m_state_in={2'b00,m_state_out[3:1],1'b1};
          endcase
        end
        
        /////////////////////////////////////////
        /// process AUTOflushrep
      if(seled_head[9:5]==ATflurep_cmd&&(m_state_out[5:4]==2'b01))
        begin
		    rst_rep_type=1'b1;
			 rst_req_type=1'b1;
          nstate=m_idle;
          mem_access_done=1'b1;
          en_m_state_in=1'b1;
          en_m_data_in=1'b1;
          m_state_in=6'b000000;
        end
          
        /////////////////////////////////////////
        /// process flushrep  
      if(seled_head[9:5]==flushrep_cmd&&(m_state_out[5:4]==2'b11))
        begin
		    rst_rep_type=1'b1;
			 rst_req_type=1'b1;
          nstate=m_idle;
          mem_access_done=1'b1;
          en_m_state_in=1'b1;
          case(seled_head[4:3])
            2'b00:m_state_in=6'b010001;
            2'b01:m_state_in=6'b010010;
            2'b10:m_state_in=6'b010100;
            2'b11:m_state_in=6'b011000;
           default:m_state_in=6'b010001;
          endcase
        end
    end 
    m_gen_shrep:
      begin
        data_re_out=1'b1;
        /////////////////////////////////////
        /// gen shrep
        if(rep_type_reg==shrep_type&&~rep_local_remote&&d_fsm_state==d_idle)
          begin
            v_rep_d=1'b1;
          //  flit_max_rep=4'b1000;
          //  en_flit_max_rep=1'b1;
            msg={temp_rep_head_flit,data_read,32'h00000000};
            nstate=m_idle;
            mem_access_done=1'b1;
				rst_rep_type=1'b1;
				rst_req_type=1'b1;
          end
        if(rep_type_reg==shrep_type&&rep_local_remote&&m_rep_fsm_state==m_rep_idle)
          begin
            v_rep_out=1'b1;
            flit_max_rep=4'b1000;
            en_flit_max_rep=1'b1;
            msg={temp_rep_head_flit,data_read,32'h00000000};
            nstate=m_idle;
            mem_access_done=1'b1;
				rst_rep_type=1'b1;
				rst_req_type=1'b1;
          end
          
        /////////////////////////////////////
        /// gen nackrep
        if(rep_type_reg==nackrep_type&&~rep_local_remote&&d_fsm_state==d_idle)
          begin
            v_rep_d=1'b1;
         //   flit_max_rep=4'b0000;
         //   en_flit_max_rep=1'b1;
            msg={temp_rep_head_flit,data_read,32'h00000000};
            nstate=m_idle;
            mem_access_done=1'b1;
				rst_rep_type=1'b1;
				rst_req_type=1'b1;
          end
        if(rep_type_reg==nackrep_type&&rep_local_remote&&m_rep_fsm_state==m_rep_idle)
          begin
            v_rep_out=1'b1;
            flit_max_rep=4'b0000;
            en_flit_max_rep=1'b1;
            msg={temp_rep_head_flit,data_read,32'h00000000};
            nstate=m_idle;
            mem_access_done=1'b1;
		      rst_rep_type=1'b1;
				rst_req_type=1'b1;
          end
          
        //////////////////////////////////////
        /// gen wbreq
        if(req_type_reg==wbreq_type&&~req_local_remote&&d_fsm_state==d_idle)
          begin
            v_req_d=1'b1;
          //  flit_max_req=4'b0010;
          //  en_flit_max_req=1'b1;
            msg={temp_rep_head_flit,seled_addr,128'h0000};
            nstate=m_idle;
            mem_access_done=1'b1;
				rst_rep_type=1'b1;
				rst_req_type=1'b1;
          end
        if(req_type_reg==wbreq_type&&req_local_remote&&m_req_fsm_state==m_req_idle)
          begin
            v_req_out=1'b1;
            flit_max_req=4'b0010;
            en_flit_max_req=1'b1;
            msg={temp_req_head_flit,seled_addr,128'h0000};
            nstate=m_idle;
            mem_access_done=1'b1;
				rst_rep_type=1'b1;
				rst_req_type=1'b1;
          end
        
        ///////////////////////////////////////
        /// gen instrep
        if(rep_type_reg==instrep_type&&~rep_local_remote&&i_fsm_state==i_idle)
          begin
            v_rep_Icache=1'b1;
        //    flit_max_rep=4'b1000;
        //    en_flit_max_rep=1'b1;
            msg={temp_rep_head_flit,data_read,32'h00000000};
            nstate=m_idle;
            mem_access_done=1'b1;
				rst_rep_type=1'b1;
				rst_req_type=1'b1;
          end
        if(rep_type_reg==instrep_type&&rep_local_remote&&m_rep_fsm_state==m_rep_idle)
          begin
            v_rep_out=1'b1;
            flit_max_rep=4'b1000;
            en_flit_max_rep=1'b1;
            msg={temp_rep_head_flit,data_read,32'h00000000};
            nstate=m_idle;
            mem_access_done=1'b1;
				rst_rep_type=1'b1;
			   rst_req_type=1'b1;
          end
      end
    
    m_gen_exrep:
      begin
        //////////////////////////////////////////
        //// gen exrep
        if(oneORmore==1'b0)
          begin
            if(rep_type_reg==exrep_type&&~rep_local_remote&&d_fsm_state==d_idle)
              begin
                v_rep_d=1'b1;
          //      flit_max_rep=4'b1000;
          //      en_flit_max_rep=1'b1;
                msg={temp_rep_head_flit,data_read,32'h00000000};
                nstate=m_idle;
                mem_access_done=1'b1;
					 rst_rep_type=1'b1;
					 rst_req_type=1'b1;
              end
            if(rep_type_reg==exrep_type&&rep_local_remote&&m_rep_fsm_state==m_rep_idle)
              begin
                v_rep_out=1'b1;
                flit_max_rep=4'b1000;
                en_flit_max_rep=1'b1;
                msg={temp_rep_head_flit,data_read,32'h00000000};
                nstate=m_idle;
                mem_access_done=1'b1;
					 rst_rep_type=1'b1;
					 rst_req_type=1'b1;
              end
          
          
        /////////////////////////////////////
        /// gen nackrep
        if(rep_type_reg==nackrep_type&&~rep_local_remote&&d_fsm_state==d_idle)
          begin
            v_rep_d=1'b1;
       //     flit_max_rep=4'b0000;
       //     en_flit_max_rep=1'b1;
            msg={temp_rep_head_flit,data_read,32'h00000000};
            nstate=m_idle;
            mem_access_done=1'b1;
				rst_rep_type=1'b1;
			   rst_req_type=1'b1;
          end
        if(rep_type_reg==nackrep_type&&rep_local_remote&&m_rep_fsm_state==m_rep_idle)
          begin
            v_rep_out=1'b1;
            flit_max_rep=4'b0000;
            en_flit_max_rep=1'b1;
            msg={temp_rep_head_flit,data_read,32'h00000000};
            nstate=m_idle;
            mem_access_done=1'b1;
				rst_rep_type=1'b1;
				rst_req_type=1'b1;
          end
          
          
            ////////////////////////////////////////////////
            /// gen flushreq
            if(req_type_reg==flushreq_type&&~req_local_remote&&d_fsm_state==d_idle)
              begin
                v_req_d=1'b1;
         //       flit_max_req=4'b0010;
         //       en_flit_max_req=1'b1;
                msg={temp_req_head_flit,seled_addr,128'h0000};
                nstate=m_idle;
                mem_access_done=1'b1;
					 rst_rep_type=1'b1;
					 rst_req_type=1'b1;
              end
            if(req_type_reg==flushreq_type&&req_local_remote&&m_req_fsm_state==m_req_idle)
              begin
                v_req_out=1'b1;
                flit_max_req=4'b0010;
                en_flit_max_req=1'b1;
                msg={temp_req_head_flit,seled_addr,128'h0000};
                nstate=m_idle;
                mem_access_done=1'b1;
					 rst_rep_type=1'b1;
					 rst_req_type=1'b1;
              end  
          
            //////////////////////////////////////////////////
            /// gen SCflushrep
            if(rep_type_reg==SCflurep_type&&~rep_local_remote&&d_fsm_state==d_idle)
              begin
                v_rep_d=1'b1;
          //      flit_max_rep=4'b0000;
          //      en_flit_max_rep=1'b1;
                msg={temp_rep_head_flit,data_read,32'h00000000};
                nstate=m_idle;
                mem_access_done=1'b1;
					 rst_rep_type=1'b1;
					 rst_req_type=1'b1;
                end
            if(rep_type_reg==SCflurep_type&&rep_local_remote&&m_rep_fsm_state==m_rep_idle)
              begin
                v_rep_out=1'b1;
                flit_max_rep=4'b0000;
                en_flit_max_rep=1'b1;
                msg={temp_rep_head_flit,data_read,32'h00000000};
                nstate=m_idle;
                mem_access_done=1'b1;
					 rst_rep_type=1'b1;
					 rst_req_type=1'b1;
              end
          end
        if(oneORmore==1'b1)
          begin
            //////////////////////////////////////////////////
            /// gen SHexrep
            if(rep_type_reg==SHexrep_type&&~rep_local_remote&&d_fsm_state==d_idle)
              begin
                v_rep_d=1'b1;
          //      flit_max_rep=4'b1000;
          //      en_flit_max_rep=1'b1;
                msg={temp_rep_head_flit,data_read,32'h00000000};
                set_rep_done=1'b1;
                end
            if(rep_type_reg==SHexrep_type&&rep_local_remote&&m_rep_fsm_state==m_rep_idle)
              begin
                v_rep_out=1'b1;
                flit_max_rep=4'b1000;
                en_flit_max_rep=1'b1;
                msg={temp_rep_head_flit,data_read,32'h00000000};
                set_rep_done=1'b1;
              end
              
            ////////////////////////////////////////////////////
            /// gen SCinvreq or invreq
            if((req_type_reg==invreq_type||req_type_reg==SCinvreq_type)&&~req_local_remote&&d_fsm_state==d_idle)
              begin
        /*        if(req_type==invreq_type)
                  thead[4:0]=invreq_cmd;
                else
                  thead[4:0]=SCinvreq_cmd;
          */      ///
         //       flit_max=4'b0010;
         //       en_flit_max=1'b1;
                v_req_d=1'b1;
                msg={temp_req_head_flit,seled_addr,128'h0000};
                set_req_done=1'b1;
                end
            if((req_type_reg==invreq_type||req_type_reg==SCinvreq_type)&&req_local_remote&&m_req_fsm_state==m_req_idle)
              begin
           /*     if(req_type==invreq_type)
                  thead[4:0]=invreq_cmd;
                else
                  thead[4:0]=SCinvreq_cmd;
             */   ///
                flit_max_req=4'b0010;
                en_flit_max_req=1'b1;
                v_req_out=1'b1;
                msg={temp_req_head_flit,seled_addr,128'h0000};
                set_req_done=1'b1;
              end
            if(rep_done&&req_done||set_rep_done&&req_done||rep_done&&set_req_done)
              begin
                nstate=m_idle;
                mem_access_done=1'b1;
					 rst_rep_type=1'b1;
					 rst_req_type=1'b1;
              end
          end 
      end
  endcase
  end
  
  
// fsm_memory_ctrl
always@(posedge clk)
begin
 if(rst)
   rstate<=m_idle;
 else
	rstate<=nstate;
end
always@(posedge clk)
begin
  if(rst)
    req_done<=1'b0;
  else if(set_req_done)
    req_done<=1'b1;
end
    
always@(posedge clk)
begin
  if(rst)
    rep_done<=1'b0;
  else if(set_rep_done)
    rep_done<=1'b1;
end

always@(posedge clk)
begin
  if(rst||rst_rep_type)
    rep_type_reg<=4'b0000;
  else if(en_rep_type)
    rep_type_reg<=rep_type;
end

always@(posedge clk)
begin
  if(rst||rst_req_type)
    req_type_reg<=4'b0000;
  else if(en_req_type)
    req_type_reg<=req_type;
end

assign  temp_req_head_flit_in1=t_req_head_sel?temp_req_head_flit_in:seled_head;
assign  temp_rep_head_flit_in1=t_rep_head_sel?temp_rep_head_flit_in:seled_head;
always@(posedge clk)
begin
  if(rst)
    temp_req_head_flit<=16'h0000;
  else if(en_temp_req_head_flit)
    temp_req_head_flit<=temp_req_head_flit_in1;
end
    

always@(posedge clk)
begin
  if(rst)
    temp_rep_head_flit<=16'h0000;
  else if(en_temp_rep_head_flit)
    temp_rep_head_flit<=temp_rep_head_flit_in1;
end

assign seled_data=data_sel?infifos_data_in:local_d_data_in;

wire    [127:0]    data_out_mem_ram;
wire    [5:0]      state_out_mem_ram;

assign   state_we_out=en_m_state_in;
assign   data_we_out=en_m_data_in;
assign   state_out_mem_ram=m_state_in;
assign   data_out_mem_ram=seled_data;
// assign output to local inst cache or local data cache or mem_rep_out fifo or mem_rep_out fifo
//  output to local data cache
assign   {head_out_local_d,addr_out_local_d,data_out_local_d}=msg;
// output to local inst cache
assign   data_out_local_i=msg[159:32];
// output to mem_OUT rep fifo
assign   {head_out_rep_out,addr_out_rep_out,data_out_rep_out}=msg;
// output to mem_OUT req fifo
assign   {head_out_req_out,addr_out_req_out}=msg[175:128]; // msg[127:0] is useless for req msg
endmodule
             

                                