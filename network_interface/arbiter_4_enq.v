// date:2016/2/19 11:00 done!
// engineer:ZhaiShaoMin
// module name:arbiter_4_enq
// module function:decide which fifo should receive coming flit according to the head flit of msg
// since arbiter dequeue has done most of the selction work , this part seems much easier!
module arbiter_4_enq ( // input 
                       flit,
                       ctrl,
                       en_dest_fifo,
                       dest_fifo,
                       // output
                       flit2pass_req,   // seled flit output to pass req 
                       ctrl2pass_req,   // seled ctrl output to pass req
                       flit2pass_rep,   // seled flit output to pass rep
                       ctrl2pass_rep,   // seled ctrl output to pass rep
                       flit2local_in_req,   // seled flit output to local in req   
                       ctrl2local_in_req,   // seled ctrl output to local in req
                       flit2local_in_rep,   // seled flit output to local in rep 
                       ctrl2local_in_rep,   // seled ctrl output to local in rep
                       en_pass_req,
                       en_pass_rep,
                       en_local_in_req,
                       en_local_in_rep
                      );
                      
//INPUT
input            [15:0]  flit;              
input            [1:0]   ctrl;
input                    en_dest_fifo; // enable selection between 4 fifos
input            [1:0]   dest_fifo;// used to decide write flit to pass fifos or In_local fifos
                                      // 00:write to pass req fifo;      01:write to pass rep fifo;
                                      // 10:write to IN_local req fifo;  11:write to IN_local rep fifo;

//output

//output           [1:0]   enq_select;  // 00:enq for pass fifo req;
                                      // 01:enq for pass fifo rep;  10:enq for local fifo req;
                                      // 11:enq for local fifo rep.
output           [15:0]  flit2pass_req;   // seled flit output to pass req 
output           [1:0]   ctrl2pass_req;   // seled ctrl output to pass req
output           [15:0]  flit2pass_rep;   // seled flit output to pass req 
output           [1:0]   ctrl2pass_rep;   // seled ctrl output to pass req
output           [15:0]  flit2local_in_req;   // seled flit output to pass req 
output           [1:0]   ctrl2local_in_req;   // seled ctrl output to pass req
output           [15:0]  flit2local_in_rep;   // seled flit output to pass req 
output           [1:0]   ctrl2local_in_rep;   // seled ctrl output to pass req

output                   en_pass_req;  //  enable for pass req fifo to write data to tail
output                   en_pass_rep;  //  enable for pass rep fifo to write data to tail 
output                   en_local_in_req; // enable for local in req fifo to write data to tail
output                   en_local_in_rep; // enable for local in rep fifo to write data to tail

reg           [15:0]  flit2pass_req;   // seled flit output to pass req 
reg           [1:0]   ctrl2pass_req;   // seled ctrl output to pass req
reg           [15:0]  flit2pass_rep;   // seled flit output to pass req 
reg           [1:0]   ctrl2pass_rep;   // seled ctrl output to pass req
reg           [15:0]  flit2local_in_req;   // seled flit output to pass req 
reg           [1:0]   ctrl2local_in_req;   // seled ctrl output to pass req
reg           [15:0]  flit2local_in_rep;   // seled flit output to pass req 
reg           [1:0]   ctrl2local_in_rep;   // seled ctrl output to pass req
reg                    en_pass_req;
reg                    en_pass_rep;
reg                    en_local_in_req;
reg                    en_local_in_rep;

always@(*)
begin
  {en_pass_req,flit2pass_req,ctrl2pass_req}={1'b0,flit,ctrl};
  {en_pass_rep,flit2pass_rep,ctrl2pass_rep}={1'b0,flit,ctrl};
  {en_local_in_req,flit2local_in_req,ctrl2local_in_req}={1'b0,flit,ctrl};
  {en_local_in_rep,flit2local_in_rep,ctrl2local_in_rep}={1'b0,flit,ctrl};
  if(en_dest_fifo)
    begin
      case(dest_fifo)
        2'b00:{en_pass_req,flit2pass_req,ctrl2pass_req}={1'b1,flit,ctrl};
        2'b01:{en_pass_rep,flit2pass_rep,ctrl2pass_rep}={1'b1,flit,ctrl};
        2'b10:{en_local_in_req,flit2local_in_req,ctrl2local_in_req}={1'b1,flit,ctrl};
        2'b11:{en_local_in_rep,flit2local_in_rep,ctrl2local_in_rep}={1'b1,flit,ctrl};
      //  default:{en_pass_req,flit2pass_req,ctrl2pass_req}={1'b1,flit,ctrl};
      endcase
    end
end
endmodule