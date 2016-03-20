/// data :2016/2/24
/// engineer :ZhaiShaoMin
/// module name :cache_controler_network_side 
/// module function :generate correct input data 
/// and ctrl signals for cache accesses!
module dcache_cpu_network_ctrler(
                      //global ctrl signals
                         clk,
                         rst,
                      //input from arbiter_for_dcache
                         flits_in,
                         v_flits_in,
                         v_cpu_req,
                      // input from cpu access regs used for cpu_side wait state:shrep or exrep or SH_exrep or invrep
                         cpu_addr_for_wait,
                         v_cpu_addr_for_wait,
                         cpu_access_head,
                      //input from dc_upload_req regs :  fsm_state to tell dcache whether it's idle
                         d_req_state,
                      //input from dc_upload_rep regs  : fsm state to tell dcache whether it's idle
                         d_rep_state,
                      // input from d_m_areg(=>data cache to mem access regs) :fsm state. used to tell dcache whether it's idle
                         m_fsm_state,
                      //output to cpu access regs saying that data cache doesn't need cpu_addr anymore!
                         done_access_cpu_addr,
                      //output to tell arbiter that data cache has been accessed!
                         dcache_done_access,
                      //output to d_m_areg when the generated msg is a local msg
                         flits_d_m_areg,   // at most 11 flits 
                         v_flits_d_m_areg,
                      //output to dc_upload_req regs
                         flits_dc_upload_req, // always 3 flits
                         v_flits_dc_upload_req,
                         en_flit_max_req,
                         flit_max_req,
                      //output to dc_upload_rep regs
                         flits_dc_upload_rep, // at most 11 flits
                         v_flits_dc_upload_rep,
                         en_flit_max_rep,
                         flit_max_rep,
                       // output to cpu tell whether cpu access has done
                         data_cpu,
                         v_rep_cpu  
                        );
/// msg type parameter

///////////request cmd
parameter        shreq_cmd=5'b00000;
parameter        exreq_cmd=5'b00001;
parameter        SCexreq_cmd=5'b00010;
parameter        instreq_cmd=5'b00110;
parameter        wbreq_cmd=5'b00011;
parameter        invreq_cmd=5'b00100;
parameter        flushreq_cmd=5'b00101;
parameter        SCinvreq_cmd=5'b00110;

//////////reply cmd
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
//para
parameter        local_id=2'b00;
                       //global ctrl signals
input                         clk;
input                         rst;
                      //input from arbiter_for_dcache
input     [143:0]             flits_in;
input                         v_flits_in;
input                         v_cpu_req;
                      // input from cpu access regs used for cpu_side wait state:shrep or exrep or SH_exrep or invrep
input     [31:0]              cpu_addr_for_wait;
input                         v_cpu_addr_for_wait;
input     [3:0]               cpu_access_head;
                      //input from dc_upload_req regs :  fsm_state to tell dcache whether it's idle
input                         d_req_state;
                      //input from dc_upload_rep regs  : fsm state to tell dcache whether it's idle
input                         d_rep_state;
                      // input from d_m_areg(=>data cache to mem access regs) :fsm state. used to tell dcache whether it's idle
input                         m_fsm_state;
                      //output to cpu access regs saying that data cache doesn't need cpu_addr anymore!
output                        done_access_cpu_addr;
                      //output to tell arbiter that data cache has been accessed!
output                        dcache_done_access;
                      //output to d_m_areg when the generated msg is a local msg
output    [175:0]             flits_d_m_areg;   // at most 11 flits
output                        v_flits_d_m_areg;
                      //output to dc_upload_req regs
output    [47:0]              flits_dc_upload_req; // always 3 flits
output                        v_flits_dc_upload_req;
output                        en_flit_max_req;
output    [1:0]               flit_max_req;
                      //output to dc_upload_rep regs
output    [175:0]             flits_dc_upload_rep; // at most 11 flits
output                        v_flits_dc_upload_rep;
output                        en_flit_max_rep;
output    [3:0]               flit_max_rep;

                      // output to cpu tell whether cpu access has done
output    [31:0]              data_cpu;
output                        v_rep_cpu;

// datapath of data cache
wire  [5:0]     state_tag_out;
reg   [5:0]     state_tag_in;  
reg             data_we;
reg             data_re;
reg             tag_we;
reg             tag_re;    
wire [127:0]    data_read;
reg  [127:0]    data_write; 
reg  [31:0]     seled_addr;                                                                                            
           /////////////////////////////////////////////////////////////////////////
           //////////////tag_ram   and  data_ram////////////////////////////////////
           ////////////////////////////////////////////////////////////////////////
           SP_BRAM_SRd  #(32,6,5)  tag_ram(.clk(clk), .we(tag_we), .re(tag_re), .a(seled_addr[8:4]), .di(state_tag_in), .do(state_tag_out));
           SP_BRAM_SRd  #(32,128,5) data_ram(.clk(clk), .we(data_we), .re(data_re), .a(seled_addr[8:4]), .di(data_write), .do(data_read));                                                                                                     
        

///////////////////////////////////////////////////////////
////////////////////////cpuside FSM////////////////////////
///////////////////////////////////////////////////////////
// fsm state constant!
parameter    cpu_idle=6'b000001;
parameter    cpu_compare_tag=6'b000010;
parameter    cpu_gen_shreq=6'b000100;
parameter    cpu_gen_exreq=6'b001000;
parameter    cpu_wait_shrep=6'b010000;
parameter    cpu_wait_exrep=6'b100000;
// msg  type
parameter    shreq_type=2'b00;
parameter    exreq_type=2'b01;

//parameter    Invrep_type=3'b000;
parameter    autoflushrep_type=3'b001;
parameter    wbreq_type=3'b010;
parameter    invrep_type=3'b011;
parameter    flushrep_type=3'b100;
parameter    wbfail_rep_type=3'b101;
//parameter    C2Cinvrep_type=3'b110;
parameter    flushfail_rep_type=3'b110;
parameter    wbrep_type=3'b111;

//parameter for outer fsm state
parameter    m_idle=1'b0; 
parameter    d_req_idle=1'b0;
parameter    d_rep_idle=1'b0;
// local_remote
reg  [31:0]     llsc_addr;
reg             llsc_flag;
reg             req_local_remote;
reg             rep_local_remote;
reg             rep_done;
reg             req_done;
reg  [2:0]      rep_type_reg;
reg  [3:0]      now_past;
reg  [3:0]      inv_vector_end_reg;
reg  [3:0]      inv_vector_working_reg;
reg  [2:0]      cstate;
reg  [2:0]      nstate;
reg  [127:0]    cpu_wr_data;
reg  [31:0]     data_cpu;
reg             addr_sel;
reg             data_sel;
reg  [127:0]    data_out;
reg             v_rep_cpu;
reg             en_delayed_state_tag;
reg  [3:0]      delayed_state_tag_in;
reg  [3:0]      delayed_state_tag;
reg             oneORmore;
reg             oneORmore_reg;
reg             v_flits_d_m_areg;
reg  [175:0]    flits_d_m_areg;
reg             set_req_done;
reg             v_flits_dc_upload_req;
reg  [47:0]     flits_dc_upload_req;
reg             set_rep_done;
reg             v_flits_dc_upload_rep;
reg  [175:0]    flits_dc_upload_rep;
reg  [4:0]      seled_exreq;
reg             rst_llsc_flag;
reg             en_inv_vector_end;
reg  [3:0]      inv_vector_end;
reg             en_inv_vector_working;
reg  [3:0]      inv_vector_working;
reg             rst_inv_vector;
reg  [2:0]      rep_type;
reg             en_rep_type;
reg             en_flit_max_rep;
reg  [3:0]      flit_max_rep;
reg             en_flit_max_req;
reg  [1:0]      flit_max_req;
reg  [31:0]     llsc_addr_in;
reg             set_llsc_addr_flag;
always@(*)
begin
  data_we=1'b0;
  data_re=1'b0;
  tag_re=1'b0;
  tag_we=1'b0;
  addr_sel=1'b1;
  nstate=cstate;
  v_rep_cpu=1'b0;
  req_local_remote=1'b1;
  rep_local_remote=1'b1;
  en_delayed_state_tag=1'b0;
  delayed_state_tag_in=4'b0000;
  data_cpu = data_read[31:0];
  state_tag_in=6'b000000;
  oneORmore=1'b0;
  v_flits_d_m_areg=1'b0;
  flits_d_m_areg=176'h0000;
  set_req_done=1'b0;
  v_flits_dc_upload_req=1'b0;
  flits_dc_upload_req=48'h0000;
  set_rep_done=1'b0;
  v_flits_dc_upload_rep=1'b0;
  flits_dc_upload_rep=176'h0000;
  seled_exreq=exreq_cmd;
  rst_llsc_flag=1'b0;
  en_inv_vector_end=1'b0;
  inv_vector_end=4'b0000;
  en_inv_vector_working=1'b0;
  inv_vector_working=4'b0000;
  rst_inv_vector=1'b0;
  rep_type=3'b000;
  en_rep_type=1'b0;
  en_flit_max_rep=1'b0;
  flit_max_rep=4'b0010;
  en_flit_max_req=1'b0;
  flit_max_req=2'b10;
  llsc_addr_in=seled_addr;
  set_llsc_addr_flag=1'b0;
  ////////////////////////////////////////////////////////////////////
  ////////////select addr to index tag_ram and data_ram///////////////
     case(addr_sel)
       1'b0:seled_addr=flits_in[127:96];
       1'b1:seled_addr=cpu_addr_for_wait;
       default:seled_addr=flits_in[127:96];
     endcase
  ////////////////////////////////////////////////////////////////////////////////////////////
  ///////////select correct data among readed data ,Infifos data and mem data to write////////
     case(data_sel)
       1'b0:data_write=flits_in[127:0];
       1'b1:data_write=cpu_wr_data;
       default:data_write=cpu_wr_data;
     endcase
  //////////////////////////////////////////////////
  /*modify correct word (32-bit) based on address*/
    cpu_wr_data = data_read;
    case(seled_addr[3:2])
    2'b00:cpu_wr_data[31:0] = flits_in[107:76];
    2'b01:cpu_wr_data[63:32] = flits_in[107:76];
    2'b10:cpu_wr_data[95:64] = flits_in[107:76];
    2'b11:cpu_wr_data[127:96] = flits_in[107:76];
    endcase
    
  /////////////////////////////////////////////////
  /*read out correct word(32-bit) from cache (to CPU)*/
    case(seled_addr[3:2])
    2'b00:data_cpu = data_read[31:0];
    2'b01:data_cpu = data_read[63:32];
    2'b10:data_cpu = data_read[95:64];
    2'b11:data_cpu = data_read[127:96];
    endcase
  case(cstate)
    cpu_idle:
      begin
        if(v_cpu_req)
          begin
            nstate=cpu_compare_tag;
          end
      end
    cpu_compare_tag:
      begin
         tag_re=1'b1;
         addr_sel=1'b1;
         data_re=1'b1;
        if(seled_addr[12:9]==state_tag_out[3:0]&&flits_in[143:142]==2'b01)
        // flits_in[143:140] 143:r/w,0/1; 142:v,1; 141: ll/ld,0/1;  140:sc/st,0/1. 
          begin
            if(state_tag_out[5]==1'b1)//read hit  //state_tag_out[5:4]: inv:00 , pending :01 , sh:10 , ex:11;
              begin
                if(flits_in[141]==1'b0) // 0 :link load ;1 normal load 
                   begin
                     set_llsc_addr_flag=1'b1;
                     llsc_addr_in=seled_addr;
                   end
              //gen read hit ctrl signals
              v_rep_cpu=1'b1;
              nstate=cpu_idle;
              end
            else // state is inv ,so read miss   
                 //  NOTE:the core only allow one outstanding cache access,
                 //       so there won't be a case that cpu aceesses see apending state!   
              begin
                if(seled_addr[12:11]==local_id)
                  begin
                    req_local_remote=1'b0;
                  end      // local 0 ;remote 1; default :remote ? 
              /*generate new tag*/
              tag_we=1'b1;
              /*new tag*/
              state_tag_in = {2'b01,seled_addr[12:9]};
              en_delayed_state_tag=1'b1;
              delayed_state_tag_in=state_tag_out[3:0];
 ////            need_gen_shreq=1'b1;
             // gen_msg_ld_wr=1'b0;    //// 0: read miss ; 1: write miss;
              nstate=cpu_gen_shreq;
         //     oneORmore=1'b0;
              end  
          end
        else if(seled_addr[12:9]!=state_tag_out[3:0]&&flits_in[143:142]==2'b01)
          // if needed ,evict the  data in the addr
          begin// read miss
               nstate=cpu_gen_shreq;
               /*generate new tag*/
               tag_we = 1'b1;
               /*new tag*/
               state_tag_in = {2'b01,seled_addr[12:9]};
               en_delayed_state_tag=1'b1;
               delayed_state_tag_in=state_tag_out[3:0];
             //  req_type=shreq_type;
             //  en_req_type=1'b1;
    //          need_gen_shreq=1'b1;
              // output to local or home 
              if(seled_addr[12:11]==local_id)
                begin
                    req_local_remote=1'b0;
                end      // local 0 ;remote 1; default :remote ?  
             
              if(state_tag_out[5:4]==2'b00)  //inv  : no need to gen rep!
                begin
                oneORmore=1'b0;
                end
              else if(state_tag_out[5:4]==2'b10) //sh  :need to be invalided  back to home!
                begin
                  en_rep_type=1'b1;
                  rep_type=invrep_type;
                  oneORmore=1'b1;
                end
              else if(state_tag_out[5:4]==2'b11) // ex  :need to be flushed back to home!
                 begin
                   en_rep_type=1'b1;
                   rep_type=autoflushrep_type;
               //    oneORmore=1'b1;
                 end
          end
          
        if(seled_addr[12:9]==state_tag_out[3:0]&&flits_in[143:142]==2'b11) //cpu_req 11:wt; 01:rd
          begin
            if(state_tag_out[5:4]==2'b11)
              begin
              //gen write hit ctrl signals
              v_rep_cpu=1'b1;
              data_sel=1'b1;
              data_we=1'b1;
              nstate=cpu_idle;
              end
            else if(state_tag_out[5:4]==2'b10||state_tag_out[5:4]==2'b01)
            // since we want to write and data now is shared ,we need to gen exrep
              begin
                if(seled_addr[12:11]==local_id)
                begin
                    req_local_remote=1'b0;
                end      // local 0 ;remote 1; default :remote ? 
              //  req_type=exreq_type;
              //  en_req_type=1'b1;
                nstate=cpu_gen_exreq;
              end
          end
        else if(seled_addr[12:9]!=state_tag_out[3:0]&&flits_in[143:142]==2'b11) 
          begin  // write miss
               nstate=cpu_gen_exreq;
               /*generate new tag*/
               tag_we = 1'b1;
               /*new tag*/
               state_tag_in = {2'b01,seled_addr[12:9]};
               en_delayed_state_tag=1'b1;
               delayed_state_tag_in=state_tag_out[3:0];
           //    req_type=exreq_type;
           //    en_req_type=1'b1;
    //          need_gen_shreq=1'b1;
              // req output to local or home 
              if(seled_addr[12:11]==local_id)
                begin
                    req_local_remote=1'b0;
                end      // local 0 ;remote 1; default :remote ? 
              // rep output to local or home  
              if(state_tag_out[3:2]==local_id)
                begin
                    rep_local_remote=1'b0;
                end      // local 0 ;remote 1; default :remote ? 
                  
            /*  if(state_tag_out[5:4]==2'b00)  //inv  : no need to gen rep!
                begin
                oneORmore=1'b0;
                end
       else*/ if(state_tag_out[5:4]==2'b10) //sh  :need to be invalided  back to home!
                begin
                  en_rep_type=1'b1;
                  rep_type=invrep_type;
                  oneORmore=1'b1;
                end
              else if(state_tag_out[5:4]==2'b11) // ex  :need to be flushed back to home!
                 begin
                   en_rep_type=1'b1;
                   rep_type=autoflushrep_type;
                   oneORmore=1'b1;
                 end  
          end // end of write miss 
      end  // end of compare_tag
    cpu_gen_shreq:
      begin// gen sh msg to home! 
      addr_sel=1'b1;
      if(oneORmore_reg==1'b1)
        begin
          if(req_local_remote==1'b0&&m_fsm_state==m_idle&&~req_done)
            begin
              v_flits_d_m_areg=1'b1;
              flits_d_m_areg={seled_addr[12:11],1'b0,local_id,1'b1,shreq_cmd,5'b00000,seled_addr,128'hzzzz};
              set_req_done=1'b1;
            end
          if(req_local_remote==1'b1&&d_req_state==d_req_idle&&~req_done)
             begin
               en_flit_max_req=1'b1;
               flit_max_req=2'b10;
               v_flits_dc_upload_req=1'b1;
               flits_dc_upload_req={seled_addr[12:11],1'b0,local_id,1'b1,shreq_cmd,5'b00000,seled_addr,128'hzzzz};
               set_req_done=1'b1;
             end
          if(rep_local_remote==1'b0&&m_fsm_state==m_idle&&~rep_done)
            begin
              if(rep_type_reg==invrep_type)
                flits_d_m_areg={state_tag_out[3:2],1'b0,local_id,1'b1,C2Hinvrep_cmd,5'b00000,
                     seled_addr[31:13],delayed_state_tag,seled_addr[8:0],128'hzzzz};  
                     //evicted addr ,so addr flits is {seled_addr[31:13],state_tag_out[12:9],seled_addr[8:0]}! 
              else if(rep_type_reg==autoflushrep_type)
                flits_d_m_areg={state_tag_out[3:2],1'b0,local_id,1'b1,ATflurep_cmd,5'b00000,
                     seled_addr[31:13],delayed_state_tag,seled_addr[8:0],data_read};
              ////////////////////////////////////////////////////////////////////////////       
              // note: if the evicted data is llsc data ,we need to reset the llsc flag!//
              ////////////////////////////////////////////////////////////////////////////
              if({seled_addr[31:13],state_tag_out[3:0],seled_addr[8:0]}==llsc_addr)
                rst_llsc_flag=1'b1;
              v_flits_d_m_areg=1'b1;
              set_rep_done=1'b1;
            end
          if(rep_local_remote==1'b1&&d_rep_state==d_rep_idle&&~rep_done)
            begin
              if(rep_type_reg==invrep_type)
                begin
                  en_flit_max_rep=1'b1;
                  flit_max_rep=4'b0010;
                  flits_dc_upload_rep={state_tag_out[3:2],1'b0,local_id,1'b1,C2Hinvrep_cmd,5'b00000,
                     seled_addr[31:13],state_tag_out[3:0],seled_addr[8:0],128'hzzzz};
                end
              else if(rep_type_reg==autoflushrep_type)
                begin
                  en_flit_max_rep=1'b1;
                  flit_max_rep=4'b1010;
                  flits_dc_upload_rep={state_tag_out[3:2],1'b0,local_id,1'b1,ATflurep_cmd,5'b00000,
                     seled_addr[31:13],state_tag_out[3:0],seled_addr[8:0],data_read};
                end
              ////////////////////////////////////////////////////////////////////////////       
              // note: if the evicted data is llsc data ,we need to reset the llsc flag!//       
              if({seled_addr[31:13],state_tag_out[3:0],seled_addr[8:0]}==llsc_addr)
                rst_llsc_flag=1'b1;
              ////////////////////////////////////////////////////////////////////////////  
              v_flits_dc_upload_rep=1'b1;
              set_rep_done=1'b1;
            end
          if(set_req_done&&set_rep_done||req_done&&set_rep_done||set_req_done&&rep_done)
            nstate=cpu_wait_shrep;
        end
      if(oneORmore_reg==1'b0)
        begin
          if(req_local_remote==1'b0&&m_fsm_state==m_idle&&~req_done)   
            begin
              v_flits_d_m_areg=1'b1;
              flits_d_m_areg={seled_addr[12:11],1'b0,local_id,1'b1,shreq_cmd,5'b00000,seled_addr,128'hzzzz};
              set_req_done=1'b1;
            end
          if(req_local_remote==1'b1&&d_req_state==d_req_state&&~req_done)
            begin
              en_flit_max_req=1'b1;
              flit_max_req=2'b10;
              v_flits_dc_upload_req=1'b1;
              flits_dc_upload_req={seled_addr[12:11],1'b0,local_id,1'b1,shreq_cmd,5'b00000,seled_addr,128'hzzzz}; 
              set_req_done=1'b1;
            end
          if(set_req_done)
            nstate=cpu_wait_shrep;
        end
      end
    cpu_gen_exreq:
      begin
        addr_sel=1'b1;
        if(oneORmore_reg==1'b1) //exreq and inv/flush rep   if SCexreq ,then scexe req
          begin
            if(flits_in[143:142]==2'b11&&flits_in[140]==1'b0)
                  seled_exreq=SCexreq_cmd;
            else
                  seled_exreq=exreq_cmd;
                  
            if(req_local_remote==1'b0&&m_fsm_state==m_idle&&~req_done)
              begin
                set_req_done=1'b1;
                v_flits_d_m_areg=1'b1;
                flits_d_m_areg={state_tag_out[3:2],1'b0,local_id,1'b1,seled_exreq,5'b00000,seled_addr,128'hzzzz};
              end
            if(req_local_remote==1'b1&&d_req_state==d_req_idle&&~req_done)
              begin
                en_flit_max_req=1'b1;
                flit_max_req=2'b10;
                set_req_done=1'b1;
                v_flits_dc_upload_req=1'b1;
                flits_dc_upload_req={state_tag_out[3:2],1'b0,local_id,1'b1,seled_exreq,5'b00000,seled_addr,128'hzzzz};
              end
            if(rep_local_remote==1'b0&&m_fsm_state==m_idle&&~rep_done)
              begin
                
              if(rep_type_reg==invrep_type)
                begin
                  flits_d_m_areg={state_tag_out[3:2],1'b0,local_id,1'b1,C2Hinvrep_cmd,5'b00000,
                     seled_addr[31:13],state_tag_out[3:0],seled_addr[8:0],128'hzzzz};  
                     //evicted addr ,so addr flits is {seled_addr[31:13],state_tag_out[12:9],seled_addr[8:0]}! 
                end
              else if(rep_type_reg==autoflushrep_type)
                begin
                  flits_d_m_areg={state_tag_out[3:2],1'b0,local_id,1'b1,ATflurep_cmd,5'b00000,
                     seled_addr[31:13],state_tag_out[3:0],seled_addr[8:0],data_read};
                end
              ////////////////////////////////////////////////////////////////////////////       
              // note: if the evicted data is llsc data ,we need to reset the llsc flag!//
              ////////////////////////////////////////////////////////////////////////////
              if({seled_addr[31:13],state_tag_out[3:0],seled_addr[8:0]}==llsc_addr)
                rst_llsc_flag=1'b1;
                
              v_flits_d_m_areg=1'b1;
              set_rep_done=1'b1;
              end
            if(rep_local_remote==1'b1&&d_rep_state==d_rep_idle&&~rep_done)
              begin
              if(rep_type_reg==invrep_type)
                begin
                  en_flit_max_rep=1'b1;
                  flit_max_rep=4'b0010;
                  v_flits_dc_upload_rep={state_tag_out[3:2],1'b0,local_id,1'b1,C2Hinvrep_cmd,5'b00000,
                     seled_addr[31:13],state_tag_out[3:0],seled_addr[8:0],128'hzzzz};
                end
              else if(rep_type_reg==autoflushrep_type)
                begin
                  en_flit_max_rep=1'b1;
                  flit_max_rep=4'b1010;
                  v_flits_dc_upload_rep={state_tag_out[3:2],1'b0,local_id,1'b1,ATflurep_cmd,5'b00000,
                     seled_addr[31:13],state_tag_out[3:0],seled_addr[8:0],data_read};
                end
              ////////////////////////////////////////////////////////////////////////////       
              // note: if the evicted data is llsc data ,we need to reset the llsc flag!//
              ////////////////////////////////////////////////////////////////////////////       
              if({seled_addr[31:13],state_tag_out[3:0],seled_addr[8:0]}==llsc_addr)
                rst_llsc_flag=1'b1; 
                 
              v_flits_dc_upload_rep=1'b1;
              set_rep_done=1'b1;
              end
            if(set_req_done&&set_rep_done||req_done&&set_rep_done||set_req_done&&rep_done)
              nstate=cpu_wait_exrep;
          end
        if(oneORmore_reg==1'b0)
          begin
            if(flits_in[143:142]==2'b11&&flits_in[140]==1'b0)
                  seled_exreq=SCexreq_cmd;
            else
                  seled_exreq=exreq_cmd;
                  
            if(req_local_remote==1'b0&&m_fsm_state==m_idle&&~req_done)
              begin
                set_req_done=1'b1;
                v_flits_d_m_areg=1'b1;
                flits_d_m_areg={state_tag_out[3:2],1'b0,local_id,1'b1,seled_exreq,5'b00000,seled_addr,128'hzzzz};
              end
            if(req_local_remote==1'b1&&d_req_state==d_req_idle&&~req_done)
              begin
                en_flit_max_req=1'b1;
                flit_max_req=2'b10;
                set_req_done=1'b1;
                v_flits_dc_upload_req=1'b1;
                v_flits_dc_upload_req={state_tag_out[3:2],1'b0,local_id,1'b1,seled_exreq,5'b00000,seled_addr,128'hzzzz};
              end
            if(set_req_done)
              nstate=cpu_wait_exrep;
            end 
        end 
    cpu_wait_shrep:
      begin //wait for shrep msgs from cache or home! 
          
          if(v_cpu_req==1'b0&&v_flits_in==1'b1&&flits_in[137:133]==shrep_cmd)
            begin
              tag_re=1'b1;
              tag_we=1'b1;
              addr_sel=1'b1;
              state_tag_in={2'b10,state_tag_out[3:0]};
              data_sel=1'b0;
              data_we=1'b1;
            end
      end
    cpu_wait_exrep:
      begin // wait for exreps from mem or cache 
            // or wait for sh->exrep and his invreps from the original sharers! 
          if(v_cpu_req==1'b0&&v_flits_in==1'b1)
            begin
            tag_re=1'b1;
            addr_sel=1'b1;
            //a case: when SH_exrep arrives , some of its necessary invreps hasn't arrived.
                   //  look up the cmd code ,you will know that
                   //  head[3:0] sometimes is inv_vector ,useful when handling sh-exrep and his invreps
            if(flits_in[137:133]==SH_exrep_cmd&&inv_vector_working_reg!=flits_in[131:128]) 
              begin
                inv_vector_end=flits_in[131:128];
                en_inv_vector_end=1'b1;
                state_tag_in={2'b01,state_tag_out[3:0]};
                tag_we=1'b1;
                data_we=1'b1;
                data_sel=1'b1;
              end
              
            //a case: when SH_exrep arrives , his necessary invreps already arrived before!
            if(flits_in[137:133]==SH_exrep_cmd&&inv_vector_working_reg==flits_in[131:128])
              begin
                rst_inv_vector=1'b1;
                state_tag_in={2'b11,state_tag_out[3:0]};
                tag_we=1'b1;
                data_we=1'b1;
                data_sel=1'b1;
                nstate=cpu_idle;
              end
            
            // a case: when a invrep arrives ,it will do sth according to the inv_vector_end 
            // and inv_vector_working . when after setting the inv_vector of this invrep ,
            // inv_vector_end==inv_vector_working,which means cpu can do the actual write,
            // because without all necessary invreps arrive ,cpu can't write the addr! 
            if(flits_in[137:133]==C2Cinvrep_cmd&&inv_vector_working!=inv_vector_end)
              begin 
                //current plus past invreps ,then cpu can write data
                if(now_past==inv_vector_end_reg)
                  begin
                    rst_inv_vector=1'b1;
                    state_tag_in={2'b11,state_tag_out[3:0]};
                  //  data_we=1'b1;
                    tag_we=1'b1;
                    nstate=cpu_idle;
                  end
                // current plus past invreps ,still unfinished   
                if(now_past!=inv_vector_end_reg)
                  begin
                   // set_now_inv_bit=1'b1;
                    en_inv_vector_working=1'b1;
                    inv_vector_working=now_past;
                  end
              end
            // a case :requester id is id . when the state of the addr in home is R(id),
            // then home sends exrep directly to requestrer  or W(id'),then the owner will
            // flushrep with data directly to requester ,and meanwhile flushrep without to home
            if(flits_in[137:133]==exrep_cmd)
              begin
                state_tag_in={2'b11,state_tag_out[3:0]};
                tag_we=1'b1;
                data_we=1'b1;
                data_sel=1'b1;
                nstate=cpu_idle;
              end
          
           end // end of if(v_cpu_req)
      end // end of cpu_wait_exrep
   endcase
end // end of always@(*)

// reg for inv_vector_in form shexrep's head flit
always@(posedge clk)
begin
 if(rst==1'b1||rst_inv_vector)
   inv_vector_end_reg<=4'b0000;
 else if(en_inv_vector_end)
   inv_vector_end_reg<=inv_vector_end;
 end

// reg for inv_vector_working to register which invrep had arrived.
always@(posedge clk)
begin
 if(rst==1'b1||rst_inv_vector)
   inv_vector_working_reg<=4'b0000;
 else if(en_inv_vector_working)
   inv_vector_working_reg<=inv_vector_working;
end

// reg for req_done /rep_done
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

///////////////////////////////////////////////
// figure out inv_vector_working and now_past//


// seled_head[12:11] stand for src_id 
always@(*)
begin
    // defalut singals value!
     now_past=inv_vector_working_reg;
  if(flits_in[137:133]==C2Cinvrep_cmd)
    begin
      case(flits_in[140:139])
        2'b00:now_past={inv_vector_working_reg[3:1],1'b1};
        2'b01:now_past={inv_vector_working_reg[3:2],1'b1,inv_vector_working_reg[0]};
        2'b10:now_past={inv_vector_working_reg[3],1'b1,inv_vector_working_reg[1:0]};
        2'b11:now_past={1'b1,inv_vector_working_reg[2:0]};
      endcase
    end 
end



/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////FSM OF Network side data cache //////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
///parameter for network side data cache
parameter network_d_idle=2'b00;
parameter network_d_process_msg=2'b01;
parameter network_d_gen_rep_msg=2'b10;

reg [1:0]      network_d_nstate;
reg [1:0]      network_d_state;
reg            rep_to_OUT_done;
reg            rep_to_home_done;
reg            set_rep_to_home_done;
reg            set_rep_to_OUT_done;
reg            fsm_rst_set_done;
always@(*)
begin
  //default values
  network_d_nstate=network_d_state;
  data_re=1'b0;
  tag_re=1'b0;
  tag_we=1'b0;
  addr_sel=1'b0;
  rep_local_remote=1'b1;
  en_rep_type=1'b0;
  rep_type=wbfail_rep_type; //just for convenience
  state_tag_in=6'b000000;
  rst_llsc_flag=1'b0;
  flits_d_m_areg={flits_in[140:139],1'b1,local_id,1'b0,C2Hinvrep_cmd,5'b00000,seled_addr,128'h0000};
  v_flits_d_m_areg=1'b0;
  set_rep_to_home_done=1'b0;
  en_flit_max_rep=1'b1;
  flit_max_rep=4'b0000;
  flits_dc_upload_rep={flits_in[140:139],1'b1,local_id,1'b0,C2Hinvrep_cmd,5'b00000,seled_addr,128'h0000};
  v_flits_dc_upload_rep=1'b0;
  set_rep_to_OUT_done=1'b0;
  fsm_rst_set_done=1'b0;
  
  case(network_d_state)
    network_d_idle:
      begin
        if(v_cpu_req==1'b0&&v_flits_in==1'b1&&(flits_in[137:133]==wbreq_cmd||flits_in[137:133]==invreq_cmd
            ||flits_in[137:133]==flushreq_cmd||flits_in[137:133]==SCinvreq_cmd))
            begin
              network_d_nstate=network_d_process_msg;
            end
      end
    network_d_process_msg:
      begin
        tag_re=1'b1;
        data_re=1'b1;
        //// wbreq///////
        if(flits_in[137:133]==wbreq_cmd&&state_tag_out[5:4]==2'b00)
          /// if this case happens ,that means the of the wbreqed data has been evicted out and back to home
          /// we need a wbfail_rep to tell home to do the shrep now, since that ,i need to revise some issues
          /// in memory fsm.oh my god!    
          begin
            if(flits_in[140:139]==local_id)
                begin
                    rep_local_remote=1'b0;
                end      // local 0 ;remote 1; default :remote ? 
            oneORmore=1'b0;      //we only need a msg.
            rep_type=wbfail_rep_type;
            en_rep_type=1'b1;
          end
        else if(flits_in[137:133]==wbreq_cmd&&state_tag_out[5:4]==2'b11)
          /// now we need to gen a wbrep to home and a shrep to requester.
          begin
            if(flits_in[140:139]==local_id)
                begin
                    rep_local_remote=1'b0;
                end      // local 0 ;remote 1; default :remote ? 
            oneORmore=1'b1;
            rep_type=wbrep_type;
       //     rep_type1=shrep_type;
        //    en_rep_type1=1'b1;
            en_rep_type=1'b1;
            tag_we=1'b1;
            state_tag_in={2'b10,state_tag_out[3:0]};
          end
          
          ////// invreq/////////
          if(flits_in[137:133]==invreq_cmd&&state_tag_out[5:4]==2'b10)
            begin
              if(flits_in[140:139]==local_id)
                begin
                    rep_local_remote=1'b0;
                end      // local 0 ;remote 1; default :remote ? 
              oneORmore=1'b1;
              rep_type=invrep_type;
       //       rep_type1=C2Cinvrep_type;
              en_rep_type=1'b1;
       //       en_rep_type1=1'b1;
              tag_we=1'b1;
              state_tag_in={2'b00,state_tag_out[3:0]};
            end
            
            ////////flushreq////////////
          if(flits_in[137:133]==flushreq_cmd&&state_tag_out[5:4]==2'b00)
            /// if this case happens, the data has been evicted out of cache and to home
            /// now we need to gen a msg named flushfail_rep to tell home to send a exrep 
            /// to the requester directly
            begin
              if(flits_in[140:139]==local_id)
                begin
                    rep_local_remote=1'b0;
                end      // local 0 ;remote 1; default :remote ? 
              oneORmore=1'b0;
              en_rep_type=1'b1;
              rep_type=flushfail_rep_type;
            end
          else if(flits_in[137:133]==flushreq_cmd&&state_tag_out[5:4]==2'b11)
            begin
              if(flits_in[140:139]==local_id)
                begin
                    rep_local_remote=1'b0;
                end      // local 0 ;remote 1; default :remote ? 
              oneORmore=1'b1;
              rep_type=flushrep_type;
         //     rep_type1=exrep_type;
              en_rep_type=1'b1;
         //     en_rep_type1=1'b1;
              
              tag_we=1'b1;
              state_tag_in={2'b00,state_tag_out[3:0]};
            end
          
          ///////////SCinvreq////////////
          if(flits_in[137:133]==SCinvreq_cmd&&state_tag_out[5:4]==2'b10)
            begin
              if(flits_in[140:139]==local_id)
                begin
                    rep_local_remote=1'b0;
                end      // local 0 ;remote 1; default :remote ? 
              oneORmore=1'b1;
              rep_type=invrep_type;
          //    rep_type1=C2Cinvrep_type;
              en_rep_type=1'b1;
          //    en_rep_type1=1'b1;
              rst_llsc_flag=1'b1;/////// reset flag in this cache  
            end
      end
    network_d_process_msg:
      begin
        if(rep_local_remote==1'b0)
          begin
            if(m_fsm_state==m_idle&&rep_to_home_done==1'b0)
              begin
                /// gen to_home msg according to rep_type
                if(rep_type_reg==invrep_type)
                 begin
                 //  en_flit_max_rep=1'b1; //to local msg don't need flit_max
                 //  flit_max_rep=4'b0010;
                  flits_d_m_areg={flits_in[140:139],1'b1,local_id,1'b0,C2Hinvrep_cmd,5'b00000,seled_addr,128'h0000};
                 end
              else if(rep_type_reg==flushrep_type)
                 begin
                  flits_d_m_areg={flits_in[140:139],1'b1,local_id,1'b0,flushrep_cmd,5'b00000,seled_addr,128'h0000};
                 end
              else if(rep_type_reg==wbrep_type)
                 begin
                  flits_d_m_areg={flits_in[140:139],1'b1,local_id,1'b0,wbrep_cmd,5'b00000,seled_addr,data_read};
                 end
              else if(rep_type_reg==flushfail_rep_type)
                 begin
                  flits_d_m_areg={flits_in[140:139],1'b1,flits_in[132:131],1'b0,flushfail_rep_cmd,5'b00000,seled_addr,128'h0000};
                 end
              else if(rep_type_reg==wbfail_rep_type)
                 begin
                  flits_d_m_areg={flits_in[140:139],1'b1,flits_in[132:131],1'b0,wbfail_rep_cmd,5'b00000,seled_addr,128'h0000};
                 end
                 
                v_flits_d_m_areg=1'b1;
                set_rep_to_home_done=1'b1;
              end
            if(d_rep_state==d_rep_idle&&rep_to_OUT_done==1'b0)
              begin
                //// gen to_cache msg according to rep_type
                if(rep_type_reg==invrep_type)
                 begin
                   en_flit_max_rep=1'b1;
                   flit_max_rep=4'b0000;
                  flits_dc_upload_rep={flits_in[132:131],1'b0,local_id,1'b0,C2Cinvrep_cmd,5'b00000,seled_addr,128'h0000};//only one flit
                 end
              else if(rep_type_reg==flushrep_type)
                 begin
                   en_flit_max_rep=1'b1;
                   flit_max_rep=4'b1000;
                  flits_dc_upload_rep={flits_in[132:131],1'b0,local_id,1'b0,exrep_cmd,5'b00000,data_read,32'h0000};  // 9flits
                 end
              else if(rep_type_reg==wbrep_type)
                 begin
                   en_flit_max_rep=1'b1;
                   flit_max_rep=4'b1000;
                  flits_dc_upload_rep={flits_in[132:131],1'b0,local_id,1'b0,shrep_cmd,5'b00000,data_read,32'h0000};  // 9flits
                 end
                 
                  v_flits_dc_upload_rep=1'b1;
                  set_rep_to_OUT_done=1'b1;
              end
            if(set_rep_to_home_done&&set_rep_to_OUT_done||rep_to_home_done&&set_rep_to_OUT_done||set_rep_to_home_done&&rep_to_OUT_done)
              begin
                fsm_rst_set_done=1'b1;
                network_d_nstate=network_d_idle;
              end
          end
        else   /// both reps will be sent to OUT rep fifo via dcache_upload_rep  ,so one by one.
          begin
            if(d_rep_state==d_rep_idle&&rep_to_OUT_done==1'b0)
              begin
                /// gen to_home msg according to rep_type
                if(rep_type_reg==invrep_type)
                 begin
                   en_flit_max_rep=1'b1;
                   flit_max_rep=4'b0010;
                  flits_dc_upload_rep={flits_in[140:139],1'b1,local_id,1'b0,C2Hinvrep_cmd,5'b00000,seled_addr,128'h0000};  // 3 flits
                 end
              else if(rep_type_reg==flushrep_type)
                 begin
                   en_flit_max_rep=1'b1;
                   flit_max_rep=4'b0010;
                  flits_dc_upload_rep={flits_in[140:139],1'b1,local_id,1'b0,flushrep_cmd,5'b00000,seled_addr,128'h0000};  // 3 flits
                 end
              else if(rep_type_reg==wbrep_type)
                 begin
                   en_flit_max_rep=1'b1;
                   flit_max_rep=4'b1010;
                  flits_dc_upload_rep={flits_in[140:139],1'b1,local_id,1'b0,wbrep_cmd,5'b00000,seled_addr,data_read};   //11 flits
                 end
              else if(rep_type_reg==flushfail_rep_type)
                 begin
                   en_flit_max_rep=1'b1;
                   flit_max_rep=4'b0010;
                  flits_dc_upload_rep={flits_in[140:139],1'b1,flits_in[132:131],1'b0,flushfail_rep_cmd,5'b00000,seled_addr,128'h0000};  // 3 flits
                  network_d_nstate=network_d_idle;
                 end
              else if(rep_type_reg==wbfail_rep_type)
                 begin
                   en_flit_max_rep=1'b1;
                   flit_max_rep=4'b0010;
                  flits_dc_upload_rep={flits_in[140:139],1'b1,flits_in[132:131],1'b0,wbfail_rep_cmd,5'b00000,seled_addr,128'h0000};  // 3 flits
                  network_d_nstate=network_d_idle;
                 end
                 v_flits_dc_upload_rep=1'b1;
                 set_rep_to_home_done=1'b1;
              end
            else if(d_rep_state==d_rep_idle)
              begin
                /// gen to_home msg according to rep_type
                if(rep_type_reg==invrep_type)
                 begin
                   en_flit_max_rep=1'b1;
                   flit_max_rep=4'b0000;
                  flits_dc_upload_rep={flits_in[132:131],1'b0,local_id,1'b0,C2Cinvrep_cmd,5'b00000,seled_addr,128'h0000};//only one flit
                 end
              else if(rep_type_reg==flushrep_type)
                 begin
                   en_flit_max_rep=1'b1;
                   flit_max_rep=4'b1000;
                  flits_dc_upload_rep={flits_in[132:131],1'b0,local_id,1'b0,exrep_cmd,5'b00000,data_read,32'h0000};  // 9 flits
                 end
              else if(rep_type_reg==wbrep_type)
                 begin
                  en_flit_max_rep=1'b1;
                  flit_max_rep=4'b1000;
                  flits_dc_upload_rep={flits_in[132:131],1'b0,local_id,1'b0,shrep_cmd,5'b00000,data_read,32'h0000};  // 9 flits
                 end
                 
                 network_d_nstate=network_d_idle;
                 v_flits_dc_upload_rep=1'b1;
                 
              end
          end
      end
    endcase
end



// reg for rep_to_OUT_done
always@(posedge clk)
begin
  if(rst||fsm_rst_set_done)
    rep_to_OUT_done<=1'b0;
  else if(set_rep_to_OUT_done)
    rep_to_OUT_done<=1'b1;
end
    
// reg for rep_to_home_done
always@(posedge clk)
begin
  if(rst||fsm_rst_set_done)
    rep_to_home_done<=1'b0;
  else if(set_rep_to_home_done)
    rep_to_home_done<=1'b1;
end 

// reg for rep_type
always@(posedge clk)
begin
  if(rst)
    rep_type_reg<=3'b000;
  else if(en_rep_type)
    rep_type_reg<=rep_type;
end

// oneORmore 
always@(posedge clk)
begin
  if(rst||~oneORmore)
    oneORmore_reg<=1'b0;
 else if(oneORmore)
    oneORmore_reg<=1'b1;
end

//used to gen auto reps
always@(posedge clk)
begin
  if(rst)
    delayed_state_tag<=4'b0000;
else if(en_delayed_state_tag)
    delayed_state_tag<=delayed_state_tag_in;
end
wire   rst_llsc_addr_flag;
assign  rst_llsc_addr_flag=rst_llsc_flag;
// reg for llsc addr and flag
always@(posedge clk)
begin
  if(rst||rst_llsc_addr_flag)
    begin
      llsc_addr<=32'h0000;
      llsc_flag<=1'b0;
    end
  else if(set_llsc_addr_flag)
    begin
      llsc_addr<=llsc_addr_in;
      llsc_flag<=1'b1;
    end
end

endmodule 
                 