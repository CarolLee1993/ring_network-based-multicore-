/// date:2016/3/9
/// engineer: ZhaiShaoMin
/// module name ic_download
/// module function: receiving rep flits from local memory or IN_rep fifo
module  ic_download(//input
                    clk,
                    rst,
                    rep_flit_ic,
                    v_rep_flit_ic,
                    rep_ctrl_ic,
                    mem_flits_ic,
                    v_mem_flits_ic,
                    //output
                    ic_download_state,
                    inst_word_ic,
                    v_inst_word
                    );
//input
input                    clk;
input                    rst;
input      [15:0]        rep_flit_ic;
input                    v_rep_flit_ic;
input      [1:0]         rep_ctrl_ic;
input      [127:0]        mem_flits_ic;
input                    v_mem_flits_ic;
//output
output     [1:0]         ic_download_state;
output     [127:0]       inst_word_ic;
output                   v_inst_word;

//reg  for inst word
reg [127:0]  inst_word ;
reg [1:0]    ic_download_nstate;
reg [1:0]    ic_download_cstate;
parameter    ic_download_idle=2'b00;
parameter    ic_download_busy=2'b01;
parameter    ic_download_rdy=2'b10;

assign ic_download_state=ic_download_cstate;
assign inst_word_ic=inst_word;

//assign inst_word_ic={inst_word[127:112],inst_word[111:96],inst_word[95:80],inst_word[79:64],inst_word[63:48],inst_word[47:32],inst_word[31:16],inst_word[15:0]};

reg             v_inst_word;
reg             en_mem_flits_ic;
reg             en_rep_flit_ic;
reg             inc_cnt;
reg             fsm_rst;
reg   [127:0]   inst_word_in;
/// fsm of ic_download
always@(*)
begin
  //default values
  ic_download_nstate=ic_download_cstate;
  v_inst_word=1'b0;
  en_mem_flits_ic=1'b0;
  en_rep_flit_ic=1'b0;
  inc_cnt=1'b0;
  fsm_rst=1'b0;
  inst_word_in=128'h0000;
  case(ic_download_cstate)
    ic_download_idle:
      begin
        if(v_mem_flits_ic)
          begin
            ic_download_nstate=ic_download_rdy;
            inst_word_in=mem_flits_ic;
            en_mem_flits_ic=1'b1;
          end
      else if(v_rep_flit_ic)
          begin
            ic_download_nstate=ic_download_busy;
            en_rep_flit_ic=1'b1;
          end
      end
    ic_download_busy:
      begin
        if(rep_ctrl_ic==2'b11)
           begin
             en_rep_flit_ic=1'b1;
            // inc_cnt=1'b1;
             ic_download_nstate=ic_download_rdy;
           end
        else if(rep_ctrl_ic==2'b10)
          begin
            en_rep_flit_ic=1'b1;
            inc_cnt=1'b1;
          end
      end
    ic_download_rdy:
      begin
        v_inst_word=1'b1;
        ic_download_nstate=ic_download_idle;
        fsm_rst=1'b1;
      end
    endcase
end

reg [2:0] cnt;
reg  [7:0]  en_instword;
// select right inst_word_in 
always@(*)
begin
  case(cnt)
    3'b000:en_instword=8'b00000001;
    3'b001:en_instword=8'b00000010;
    3'b010:en_instword=8'b00000100;
    3'b011:en_instword=8'b00001000;
    3'b100:en_instword=8'b00010000;
    3'b101:en_instword=8'b00100001;
    3'b110:en_instword=8'b01000001;
    3'b111:en_instword=8'b10000001;
    default:en_instword=8'b00000000;
  endcase
 end
// 1th flit
always@(posedge clk)
begin
  if(rst||fsm_rst)
    begin
      inst_word[15:0]<=16'h0000;
    end
  else if(en_mem_flits_ic)
      inst_word[15:0]<=inst_word_in[15:0];
  else if(en_rep_flit_ic&&en_instword[0])
      inst_word[15:0]<=inst_word_in[15:0];
end

// 2ed flit
always@(posedge clk)
begin
  if(rst||fsm_rst)
    begin
      inst_word[31:16]<=16'h0000;
    end
  else if(en_mem_flits_ic)
      inst_word[31:16]<=inst_word_in[31:16];
  else if(en_rep_flit_ic&&en_instword[1])
      inst_word[31:16]<=inst_word_in[31:16];
end

//3rd flit
always@(posedge clk)
begin
  if(rst||fsm_rst)
    begin
      inst_word[47:32]<=16'h0000;
    end
  else if(en_mem_flits_ic)
      inst_word[47:32]<=inst_word_in[47:32];
  else if(en_rep_flit_ic&&en_instword[2])
      inst_word[47:32]<=inst_word_in[47:32];
end

//4th flit
always@(posedge clk)
begin
  if(rst||fsm_rst)
    begin
      inst_word[63:48]<=16'h0000;
    end
  else if(en_mem_flits_ic)
      inst_word[63:48]<=inst_word_in[63:48];
  else if(en_rep_flit_ic&&en_instword[3])
      inst_word[63:48]<=inst_word_in[63:48];
end

// 5th flit
always@(posedge clk)
begin
  if(rst||fsm_rst)
    begin
      inst_word[79:64]<=16'h0000;
    end
  else if(en_mem_flits_ic)
      inst_word[79:64]<=inst_word_in[79:64];
  else if(en_rep_flit_ic&&en_instword[4])
      inst_word[79:64]<=inst_word_in[79:64];
end

//6th flit
always@(posedge clk)
begin
  if(rst||fsm_rst)
    begin
      inst_word[95:80]<=16'h0000;
    end
  else if(en_mem_flits_ic)
      inst_word[95:80]<=inst_word_in[95:80];
  else if(en_rep_flit_ic&&en_instword[5])
      inst_word[95:80]<=inst_word_in[95:80];
end

//7th flit
always@(posedge clk)
begin
  if(rst||fsm_rst)
    begin
      inst_word[111:96]<=16'h0000;
    end
  else if(en_mem_flits_ic)
      inst_word[111:96]<=inst_word_in[111:96];
  else if(en_rep_flit_ic&&en_instword[6])
      inst_word[111:96]<=inst_word_in[111:96];
end

//8th flit
always@(posedge clk)
begin
  if(rst||fsm_rst)
    begin
      inst_word[127:112]<=16'h0000;
    end
  else if(en_mem_flits_ic)
      inst_word[127:112]<=inst_word_in[127:112];
  else if(en_rep_flit_ic&&en_instword[7])
      inst_word[127:112]<=inst_word_in[127:112];
end

always@(posedge clk)
begin
  if(rst)
    ic_download_cstate<=2'b00;
  else
    ic_download_cstate<=ic_download_nstate;
end


always@(posedge clk)
begin
  if(rst||fsm_rst)
    cnt<=3'b000;
  else if(inc_cnt)
    cnt<=cnt+1;
end

endmodule

