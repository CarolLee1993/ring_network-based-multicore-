////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// network_interface include:  pass fifo, which is used to pass non_local messages to next node ///////////
///                             IN_local req fifo and rep fifo,which is used to buffers msgs to local node//
///                             OUT_local req fifo and rep fifo ,which is used to buffers msgs leave local//
///                             and some other FSMs to help manage  these fifos!                    ////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

module network_interface(
                     //input    
                         clk,                           //global clock
                         rst,                           //global reset
                         ctrl_in,                          //[2:0] for guiding flit flowing ; 00:nothing, 01:head flit, 10:body flit, 11:tail flit
                                                        //ctrl[2]  1:next_node; 0:not_next_node;
                         flit_in,  
                         dest_fifo_in,                    
                         en_IN_req_deq,    // from arbiter_for_IN_node in commu_assist             
                         en_IN_rep_deq,                
                         enq_req_data,    // from arbiter_for_OUT_req fifo in commu_assist     (include ctrl)          
                         enq_rep_data,     // from arbiter_for_OUT_rep fifo in commu_assist     (include ctrl)
                         en_OUT_req_enq,     // from arbiter_for_OUT_req fifo in commu_assist             
                         en_OUT_rep_enq,     // from arbiter_for_OUT_rep fifo in commu_assist            
                         en_local_req_in,
                         en_local_rep_in,
                         en_pass_req_in,
                         en_pass_rep_in,
                         used_slots_pass_req_in,
                         used_slots_pass_rep_in,            //the pass req fifo of next node says it can receive a flit
                      //output   
                         deq_req_data,                  //[17:0]cache or memory dequeue a flit from  IN_local req fifo
                         deq_rep_data,                  //[17:0]cache or memory dequeue a flit from  IN_local rep fifo
                         req_rdy,
                         rep_rdy,
                         en_local_req,    // to previous node  refer to below notes  
                         en_local_rep,    
                         en_pass_req,     // from next node  //local_in_req fifo in next node says that it can receive
                         en_pass_rep,     // refer to notes below
                         used_slots_pass_req,
                         used_slots_pass_rep,               
                         flit_out,
                         ctrl_out,
                         dest_fifo_out,
                         OUT_req_rdy,
                         OUT_rep_rdy
                         );
                         
/////// parameter  for reply cmd
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

                       
    //input          
      input                   clk;                          
      input                   rst;                          
      input      [2:0]        ctrl_in;                          
      input      [15:0]       flit_in; 
      input      [1:0]        dest_fifo_in;                      
      input                   en_IN_req_deq;    // from arbiter_for_IN_node in commu_assist             
      input                   en_IN_rep_deq;                 
      input      [17:0]       enq_req_data;     // from arbiter_for_OUT_req fifo in commu_assist     (include ctrl)          
      input      [17:0]       enq_rep_data;     // from arbiter_for_OUT_rep fifo in commu_assist     (include ctrl)
      input                   en_OUT_req_enq;     // from arbiter_for_OUT_req fifo in commu_assist             
      input                   en_OUT_rep_enq;     // from arbiter_for_OUT_rep fifo in commu_assist            
      input                   en_local_req_in;    // from next node  //local_in_req fifo in next node says that it can receive
      input                   en_local_rep_in;                       //local_in_req fifo in next node says that it can receive
      input                   en_pass_req_in;                        //pass_req fifo in next node says that it can receive
      input                   en_pass_rep_in;                        //pass_req fifo in next node says that it can receive
      input      [3:0]        used_slots_pass_req_in;              //pass_req fifo in next node says how many used slots
      input      [3:0]        used_slots_pass_rep_in;              //pass_req fifo in next node says how many used slots
    //output   
      output     [2:0]         ctrl_out;
      output     [15:0]        flit_out;
      output     [1:0]         dest_fifo_out;  // used for arbiter_enq to select which fifo to write in
      
      output                   OUT_req_rdy;   // it's ready for ic_req_upload,dc_req_upload or mem_req_upload to enq their req flit
      output                   OUT_rep_rdy;   // it's ready for dc_rep_upload or mem_rep_upload to enq their rep flit
      
      output     [17:0]        deq_req_data;    // from IN_req fifo          (include ctrl) 
      output     [17:0]        deq_rep_data;    // from IN_rep fifo          (include ctrl)  
      
      output                   req_rdy;    // it's ready for arbiter_IN_node to dequeue flit from In req fifo
      output                   rep_rdy;   // it's ready for arbiter_IN_node to dequeue flit from In rep fifo
      
      output                   en_local_req;    // to previous node  refer to above notes 
      output                   en_local_rep;    
      output                   en_pass_req;
      output                   en_pass_rep;
      output     [3:0]         used_slots_pass_req;
      output     [3:0]         used_slots_pass_rep;  
// output from  pass fifos and OUT_local fifos
wire        [17:0]     pass_rep_dout;
wire        [17:0]     out_local_rep_dout;
wire        [17:0]     pass_req_dout;
wire        [17:0]     out_local_req_dout;
                 
//full state of fifos
wire                    pass_req_full;
wire                    pass_rep_full;
wire                    in_req_full;
wire                    in_rep_full;
wire                    out_req_full;
wire                    out_rep_full;

//empty state of fifos
wire                    pass_req_empty;
wire                    pass_rep_empty;
wire                    IN_local_req_empty;
wire                    IN_local_rep_empty;                   
wire                    OUT_local_req_empty;
wire                    OUT_local_rep_empty;


//// mux 4 kinds of flits to output to next node
reg        [17:0]    temp_flit_out;

// arbietr for deq
wire   [3:0]            select;  


//arbiter for enq
wire           [15:0]  flit2pass_req;   // seled flit output to pass req 
wire           [1:0]   ctrl2pass_req;   // seled ctrl output to pass req
wire           [15:0]  flit2pass_rep;   // seled flit output to pass req 
wire           [1:0]   ctrl2pass_rep;   // seled ctrl output to pass req
wire           [15:0]  flit2local_in_req;   // seled flit output to pass req 
wire           [1:0]   ctrl2local_in_req;   // seled ctrl output to pass req
wire           [15:0]  flit2local_in_rep;   // seled flit output to pass req 
wire           [1:0]   ctrl2local_in_rep;   // seled ctrl output to pass req

wire                   en_pass_req;  //  enable for pass req fifo to write data to tail
wire                   en_pass_rep;  //  enable for pass rep fifo to write data to tail 
wire                   en_local_in_req; // enable for local in req fifo to write data to tail
wire                   en_local_in_rep; // enable for local in rep fifo to write data to tail   

// output to uploads saying it's ready for them to receive flits from uploads
assign                  OUT_req_rdy=!out_req_full;
assign                  OUT_rep_rdy=!out_rep_full;

// to previous node  refer to below notes
assign          en_local_req=!in_req_full;      
assign          en_local_rep=!in_rep_full;   
assign          en_pass_req=!pass_req_full;     // from next node  //local_in_req fifo in next node says that it can receive
assign          en_pass_req=!pass_req_full;     // refer to notes below   

// output to arbiter_IN_node to tell it it's ready for them to deq flit from IN_local fifos
assign                   req_rdy=!IN_local_req_empty;
assign                   rep_rdy=!IN_local_rep_empty;

//wires just for convenience      
assign flit_out=temp_flit_out[15:0];
assign ctrl_out=temp_flit_out[18:16];

// figure out which fifo output its flit to next node
always@(*)
begin
   case(select)
   4'b0001:temp_flit_out=pass_rep_dout;
   4'b0010:temp_flit_out=out_local_rep_dout;
   4'b0100:temp_flit_out=pass_req_dout;
   4'b1000:temp_flit_out=out_local_req_dout;
   default:temp_flit_out=pass_rep_dout;                    
 endcase
end           

reg   [1:0]    OUT_rep_length_code;

// use hesd flit of every msg at the head of OUT_local_rep fifo 
// to produce OUT_rep_length_code ,which is usefull to avoid deadlock
always@(*)
begin
   if(out_local_rep_dout[17:16]==2'b01&&(out_local_rep_dout[9:5]==ATflurep_cmd||out_local_rep_dout[9:5]==wbrep_cmd))
     OUT_rep_length_code=2'b11;//msg has 11 flits
 else if(out_local_rep_dout[17:16]==2'b01&&(out_local_rep_dout[9:5]==exrep_cmd||out_local_rep_dout[9:5]==shrep_cmd||out_local_rep_dout[9:5]==instrep_cmd||out_local_rep_dout[9:5]==SH_exrep_cmd))
   OUT_rep_length_code=2'b10;  //msg has 9 flits
 else if(out_local_rep_dout[17:16]==2'b01&&(out_local_rep_dout[9:5]==nackrep_cmd||out_local_rep_dout[9:5]==flushrep_cmd||out_local_rep_dout[9:5]==C2Hinvrep_cmd||out_local_rep_dout[9:5]==flushfail_rep_cmd||out_local_rep_dout[9:5]==wbfail_rep_cmd)) 
   OUT_rep_length_code=2'b01;  //msg has 3 flits
 else if(out_local_rep_dout[17:16]==2'b01&&(out_local_rep_dout[9:5]==C2Cinvrep_cmd||out_local_rep_dout[9:5]==nackrep_cmd))
   OUT_rep_length_code=2'b00;  // msg has only 1 flit
 else  //default valus
   OUT_rep_length_code=2'b00;  // msg has only 1 flit
end
my_scfifo     pass_req_fifo(
	                      .aclr(rst),
	                      .clock(clk),
	                      .data({ctrl2pass_req,flit2pass_req}),
	                      .rdreq(select[2]),
	                      .wrreq(en_pass_req),
	                      .empty(pass_req_empty),
	                      .full(pass_req_full),
	                      .q(pass_req_dout),
	                      .usedw(used_slots_pass_req)
	                      );
                         
my_scfifo     pass_rep_fifo(
	                      .aclr(rst),
	                      .clock(clk),
	                      .data({ctrl2pass_rep,flit2pass_rep}),
	                      .rdreq(select[0]),
	                      .wrreq(en_pass_rep),
	                      .empty(pass_rep_empty),
	                      .full(pass_rep_full),
	                      .q(pass_rep_dout),
	                      .usedw(used_slots_pass_rep)
	                      );
                         
my_scfifo    IN_req_fifo(
	                      .aclr(rst),
	                      .clock(clk),
	                      .data({ctrl2local_in_req,flit2local_in_req}),
	                      .rdreq(en_IN_req_deq),
	                      .wrreq(en_local_in_req),
	                      .empty(IN_local_req_empty),
	                      .full(in_req_full),
	                      .q({deq_req_data}),
	                      .usedw()
	                      );
                         
my_scfifo    IN_rep_fifo(
	                      .aclr(rst),
	                      .clock(clk),
	                      .data({ctrl2local_in_rep,flit2local_in_rep}),
	                      .rdreq(en_IN_rep_deq),
	                      .wrreq(en_local_in_rep),
	                      .empty(IN_local_rep_empty),
	                      .full(in_rep_full),
	                      .q({deq_rep_data}),
	                      .usedw()
	                      );
	                      
my_scfifo    OUT_req_fifo(
	                      .aclr(rst),
	                      .clock(clk),
	                      .data({enq_req_data}),
	                      .rdreq(select[3]),
	                      .wrreq(en_OUT_req_enq),
	                      .empty(OUT_local_req_empty),
	                      .full(out_req_full),
	                      .q(out_local_req_dout),
	                      .usedw()
	                      );
	                      
my_scfifo   OUT_rep_fifo(
	                      .aclr(rst),
	                      .clock(clk),
	                      .data({enq_rep_data}),
	                      .rdreq(select[1]),
	                      .wrreq(en_OUT_rep_enq),
	                      .empty(OUT_local_rep_empty),
	                      .full(out_rep_full),
	                      .q(out_local_rep_dout),
	                      .usedw()
	                      );

   
    ///////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////Here need a arbiter to decide which flit to select to send out/////////
    ////////////////////from pass rep/req fifo, OUT_local rep/req fifo         ////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////
                 
     
arbiter_4_deq ( 
             //input
                       .clk(clk),
                       .rst(rst),
                       .pass_req_empty(pass_req_empty),
                       .pass_rep_empty(pass_rep_empty),
                       .OUT_local_req_empty(OUT_local_req_empty),
                       .OUT_local_rep_empty(OUT_local_rep_empty),
                       
                       .OUT_rep_length_code(OUT_rep_length_code),
                       .en_local_req(en_local_req_in),
                       .en_local_rep(en_local_rep_in),
                       .en_pass_req(en_pass_req_in),
                       .en_pass_rep(en_pass_rep_in),
                       .used_slots_pass_req(used_slots_pass_req_in),
                       .used_slots_pass_rep(used_slots_pass_rep_in),
                       .next_pass_req(next_pass_req),
                       .next_pass_rep(next_pass_rep),
                       .next_local_req(next_local_req),
                       .next_local_rep(next_local_rep),
             //output
                       .select(select)
                       );
                 
                 
                 
         
                 
                 
    ///////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////Here need a arbiter to decide which fifo to select to write flit in////
    ////////////////////write to pass rep/req fifo ,IN_local rep/req fifo       ///////////////
    /////////////////////////////////////////////////////////////////////////////////////////// 
   
arbiter_4_enq ( // input 
                       .flit(flit_in),
                       .ctrl(ctrl_in),
                       .en_dest_fifo(|ctrl_in),
                       .dest_fifo(dest_fifo_in),
                // output
                       .flit2pass_req(flit2pass_req),   // seled flit output to pass req 
                       .ctrl2pass_req(ctrl2pass_req),   // seled ctrl output to pass req
                       .flit2pass_rep(flit2pass_rep),   // seled flit output to pass rep
                       .ctrl2pass_rep(ctrl2pass_rep),   // seled ctrl output to pass rep
                       .flit2local_in_req(flit2local_in_req),   // seled flit output to local in req   
                       .ctrl2local_in_req(ctrl2local_in_req),   // seled ctrl output to local in req
                       .flit2local_in_rep(flit2local_in_rep),   // seled flit output to local in rep 
                       .ctrl2local_in_rep(ctrl2local_in_rep),   // seled ctrl output to local in rep
                       .en_pass_req(en_pass_req),
                       .en_pass_rep(en_pass_rep),
                       .en_local_in_req(en_local_in_req),
                       .en_local_in_rep(en_local_in_rep)
                      );
endmodule   
      
    ///////////////////////////////////////////////////////////////////////////////////////////
    ////////////here we process cache request or memory request for dequeuing IN_local fifo////
    ///////////////////////////////////////////////////////////////////////////////////////////
   
  
    
  
    
    
    
    
    
    ////////////////////////////////////////////////////////////////////////////////////////////
    ////////////here we process cache reply or memory reply for  dequeuing OUT_local fifo///////
    ////////////////////////////////////////////////////////////////////////////////////////////            
                    
                    