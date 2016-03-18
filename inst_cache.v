// date:2016/3/15
//engineer: zhaishaomin
// module function: output inst_word according to coming pc ,
//    if missed , it will stall the pipeline and gen a msg to find the requested cache block 
//     including the origal inst_word 
module  inst_cache (//input
                    clk,
                    rst,
                    // from pc
                    v_pc,
                    pc,
                    //from ic_download
                    inst_4word,
                    v_inst_4word,
                    
                    //output
                    // to local mem or OUT_req upload
                    v_ic_req,
                    local_or_OUT, //1:local  ,0:OUT_req
                    req_msg,
                    v_inst,
                    inst
                    );
//input
input                    clk;
input                    rst;
                    // from pc
input                    v_pc;
input     [31:0]         pc;
                    //from ic_download
input     [127:0]        inst_4word;
input                    v_inst_4word;                    
                    //output
                    // to local mem or OUT_req upload
output                    v_ic_req;
output                    local_or_OUT; //1:local  ,0:OUT_req
output    [47:0]          req_msg;
output                    v_inst;
output    [31:0]          inst;

/////////////////////////////////////////////////////////////////////
////////////////inst cache data and tag//////////////////////////////
reg          tag_we;
reg          tag_re;
reg          data_we;
reg          data_re;
reg   [5:0]  state_tag_in;
wire  [5:0]  state_tag_out;
reg   [31:0] seled_addr;
reg   [127:0]data_write;
wire  [127:0]data_read;
reg   [31:0] inst1;
reg   [31:0] inst2;
reg          v_inst;
reg          local_or_OUT;
reg   [47:0] req_msg;
reg          inst1_inst2;

           SP_BRAM_SRd  #(32,6,5)  tag_ram(.clk(clk), .we(tag_we), .re(tag_re), .a(seled_addr[8:4]), .di(state_tag_in), .do(state_tag_out));
           SP_BRAM_SRd  #(32,128,5) data_ram(.clk(clk), .we(data_we), .re(data_re), .a(seled_addr[8:4]), .di(data_write), .do(data_read));   
           
           
           
                                          
/////////////////////////////////////////////////////////////////////
/////////////////inst cache fsm//////////////////////////////////////

//paramter 
parameter    inst_idle=2'b00;
parameter    inst_comp_tag=2'b01;
parameter    inst_gen_req=2'b10;
parameter    inst_wait_rep=2'b11;
parameter    local_id=2'b00;
parameter    instreq_cmd=5'b00110;


reg   [1:0]  inst_cstate;
reg   [1:0]  inst_nstate;

always@(posedge clk)
begin
  if(rst)
    inst_cstate<=2'b00;
  else 
    inst_cstate<=inst_nstate;
end

//fsm always block
always@(*)
begin
  //default values
    tag_we=1'b0;
    tag_re=1'b0;
    data_we=1'b0;
    data_re=1'b0;
    state_tag_in=5'b00000;
    seled_addr=32'h0000;
    data_write=128'h0000;
    local_or_OUT=1'b0;
    req_msg=48'h0000;
    inst_nstate=inst_cstate;
    inst1 = data_read[31:0];
    inst2 = inst_4word[31:0];
    inst1_inst2=1'b0;
    /////////////////////////////////////////////////
   /*read out correct word(32-bit) from cache (to if_id)*/
    case(pc[3:2])
    2'b00:inst1 = data_read[31:0];
    2'b01:inst1 = data_read[63:32];
    2'b10:inst1 = data_read[95:64];
    2'b11:inst1 = data_read[127:96];
    endcase
    
    /////////////////////////////////////////////////
    /* read inst_word directly from inst_4word (to if_id) */
    case(pc[3:2])
    2'b00:inst2 = inst_4word[31:0];
    2'b01:inst2 = inst_4word[63:32];
    2'b10:inst2 = inst_4word[95:64];
    2'b11:inst2 = inst_4word[127:96];
    endcase
    case(inst_cstate)
      inst_idle:
        begin
          if(v_pc)
            inst_nstate=inst_comp_tag;
        end
      inst_comp_tag:
        begin
          tag_re=1'b1;
          data_re=1'b1;
        if(pc[12:9]==state_tag_out[3:0])
        // tag equals 
          begin    // [5:4]  00 inv, 01 wait inst rep , 10 valid
            if(state_tag_out[5:4]==2'b10)//read hit  
              begin
            //gen read hit ctrl signals
              v_inst=1'b1;
              inst1_inst2=1'b0;
              inst_nstate=inst_idle;
              end
       /*     else if(state_tag_out[5:4]==2'b01) // state is inv ,so read miss   
                 //  NOTE:the core only allow one outstanding cache access,
                 //       so there won't be a case that cpu aceesses see apending state!   
              begin
                if(pc[12:11]==local_id)
                  begin
                    req_local_remote=1'b0;
                  end      // local 0 ;remote 1; default :remote ? 
              nstate=inst_gen_req;
         //     oneORmore=1'b0;
              end     */
          end    
      else// tag miss
          begin
            // gen new tag to tag ram
              tag_we=1'b1;
              /*new tag*/
              state_tag_in = {2'b01,pc[12:9]};
              inst_nstate=inst_gen_req;
          end
      end
      inst_gen_req:
        begin
          if(pc[12:11]==local_id)
              begin
                local_or_OUT=1'b0;
              end      // local 0 ;remote 1; default :remote ? 
          req_msg={pc[12:11],1'b1,local_id,1'b0,instreq_cmd,5'b00000,pc};
          inst_nstate=inst_wait_rep;
        end
      inst_wait_rep:
        begin
          if(v_inst_4word)
            begin
              tag_re=1'b1;
              data_write=inst_4word;
              data_we=1'b1;
              inst1_inst2=1'b1;
              v_inst=1'b1;
              // gen new tag to tag ram
              tag_we=1'b1;
              /*new tag*/
              state_tag_in = {2'b10,pc[12:9]};  // 10 means valid
            end
        end
        endcase
end

assign  inst=inst1_inst2?inst2:inst1;
endmodule