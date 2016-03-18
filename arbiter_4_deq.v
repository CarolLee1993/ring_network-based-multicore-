/// date: 2016/2/19 11:00-17:50
/// engineer: ZhaiShaoMin
/// module name: arbiter_4_deq
/// module function: decide which fifo among pass fifos and OUT_local fifos can really deq flit,ctrl and next_node infos;

module arbiter_4_deq ( 
             //input
                       clk,
                       rst,
                       pass_req_empty,
                       pass_rep_empty,
                       OUT_local_req_empty,
                       OUT_local_rep_empty,
                       
                       OUT_rep_length_code,
                       en_local_req,
                       en_local_rep,
                       en_pass_req,
                       en_pass_rep,
                       used_slots_pass_req,
                       used_slots_pass_rep,
                       next_pass_req,
                       next_pass_rep,
                       next_local_req,
                       next_local_rep,
             //output
                       select
                       );
  
  //input
input       clk;
input       rst;
input       pass_req_empty;                 //local node: pass req fifo is empty     
input       pass_rep_empty;                 //local node: pass rep fifo is empty
input       OUT_local_req_empty;            //local node: OUT_local req fifo is empty
input       OUT_local_rep_empty;            //local node: OUT_local rep fifo is empty
input       en_local_req;                   //IN_local_req_fifo of next node says I can receive a flit 
input       en_local_rep;                   //IN_local_rep_fifo of next node says I can receive a flit
input       en_pass_req;                    //pass req fifo of next node says i can receive a flit now
input       en_pass_rep;                    //pass rep fifo of next node says i can receive a flit now
input [3:0] used_slots_pass_req;          //pass req fifo of next node says how many slots I have used ,avoiding deadlock
input [3:0] used_slots_pass_rep;          //pass rep fifo of next node says how many slots I have used ,avoiding deadlock

input       next_pass_req;                  //local node: flit in the head of pass req fifo says I am a flit to next node if it's 1;
input       next_pass_rep;                  //local node: flit in the head of pass rep fifo says I am a flit to next node if it's 1;
input       next_local_req;                 //local node: flit in the head of OUT_local req fifo says I am a flit to next node if it's 1;
input       next_local_rep;                 //local node: flit in the head of OUT_local rep fifo says I am a flit to next node if it's 1;
input [1:0] OUT_rep_length_code;


 //output 
 output [3:0]   select;                      // one-hot encode select  4'b0001 : pass_rep
 reg    [3:0]   select;                      //                        4'b0010 : local_rep
                                             //                        4'b0100 ? pass_req
                                             //                        4'b1000 ? local_req
                                              
 //local fifos busy flag 
 reg           local_pass_req_busy;
 reg           local_pass_rep_busy;
 reg           OUT_req_busy;
 reg           OUT_rep_busy;
 
 reg           set_local_pass_req_busy;
 reg           set_local_pass_rep_busy;
 reg           set_OUT_req_busy;
 reg           set_OUT_rep_busy;
 
 // set pass_req_busy
 always@(posedge clk)
 begin
 if(rst==1'b0)
   local_pass_req_busy<=1'b0;
 else if(set_local_pass_req_busy==1'b1)
   local_pass_req_busy<=1'b1;
 
 end
 
 // set pass_rep_busy
 always@(posedge clk)
 begin
 if(rst==1'b0)
   local_pass_rep_busy<=1'b0;
 else if(set_local_pass_rep_busy==1'b1)
   local_pass_rep_busy<=1'b1;

 end 
 
  // set OUT_req_busy
 always@(posedge clk)
 begin
 if(rst==1'b0)
   OUT_req_busy<=1'b0;
 else if(set_OUT_req_busy==1'b1)
   OUT_req_busy<=1'b1;
 
 end
 
 // set OUT_rep_busy
 always@(posedge clk)
 begin
 if(rst==1'b0)
   OUT_rep_busy<=1'b0;
 else if(set_OUT_rep_busy==1'b1)
   OUT_rep_busy<=1'b1;
 
 end
 
 // temp dest fifo id of local fifos
 reg       [1:0]    pass_req_temp_dest_id;
 reg       [1:0]    pass_rep_temp_dest_id;
 reg       [1:0]    OUT_req_temp_dest_id;
 reg       [1:0]    OUT_rep_temp_dest_id; 
 
reg         [1:0]  set_OUT_rep_dest_id_in;
reg         [1:0]  set_OUT_req_dest_id_in;
reg         [1:0]  set_pass_rep_dest_id_in;
reg         [1:0]  set_pass_req_dest_id_in;

reg                set_OUT_rep_dest_id;
reg                set_OUT_req_dest_id;
reg                set_pass_rep_dest_id;
reg                set_pass_req_dest_id;
 // set_pass_req_dest_id
 always@(posedge clk)
 begin
   if(rst)
     pass_req_temp_dest_id<=2'b00;
   else if(set_pass_req_dest_id)
     pass_req_temp_dest_id<=set_pass_req_dest_id_in;
  
 end 
 //   set_pass_rep_dest_id
always@(posedge clk)
 begin
   if(rst)
     pass_rep_temp_dest_id<=2'b00;
   else if(set_pass_rep_dest_id)
     pass_rep_temp_dest_id<=set_pass_rep_dest_id_in;
  
end
//  set_OUT_req_dest_id
always@(posedge clk)
 begin
   if(rst)
     OUT_req_temp_dest_id<=2'b00;
   else if(set_OUT_req_dest_id)
     OUT_req_temp_dest_id<=set_OUT_req_dest_id_in;
   
end
//   set_OUT_rep_dest_id
always@(posedge clk)
 begin
   if(rst)
     OUT_rep_temp_dest_id<=2'b00;
   else if(set_OUT_rep_dest_id)
     OUT_rep_temp_dest_id<=set_OUT_rep_dest_id_in;
    
 end
 
 wire    local_pass_req_dest_seled_rdy;
 wire    local_pass_rep_dest_seled_rdy;
 wire    OUT_req_dest_seled_rdy;
 wire    OUT_rep_dest_seled_rdy;
 
 ///////////////////////////////////////////////////////////////////////////////////////////////////////////
 /////select every src fifo's  ready signal of dest fifo to avoiding overflow in the fifos of next node ////
MUXn_4_1 #(0) local_pass_req_dest_seled_rdy_dut(.mux_in0(en_local_req),
                                                .mux_in1(en_local_rep),
                                                .mux_in2(en_pass_req),
                                                .mux_in3(en_pass_rep),
                                                .mux_sel(pass_req_temp_dest_id),
                                                .mux_out(local_pass_req_dest_seled_rdy));
                                                
MUXn_4_1 #(0) local_pass_rep_dest_seled_rdy_dut(.mux_in0(en_local_req),
                                                .mux_in1(en_local_rep),
                                                .mux_in2(en_pass_req),
                                                .mux_in3(en_pass_rep),
                                                .mux_sel(pass_red_temp_dest_id),
                                                .mux_out(local_pass_rep_dest_seled_rdy));
                                                
   MUXn_4_1 #(0) OUT_req_dest_seled_rdy_dut    (.mux_in0(en_local_req),
                                                .mux_in1(en_local_rep),
                                                .mux_in2(en_pass_req),
                                                .mux_in3(en_pass_rep),
                                                .mux_sel(OUT_req_temp_dest_id),
                                                .mux_out(OUT_req_dest_seled_rdy));
  
   MUXn_4_1 #(0) OUT_rep_dest_seled_rdy_dut    (.mux_in0(en_local_req),
                                                .mux_in1(en_local_rep),
                                                .mux_in2(en_pass_req),
                                                .mux_in3(en_pass_rep),
                                                .mux_sel(OUT_rep_temp_dest_id),
                                                .mux_out(OUT_rep_dest_seled_rdy));
       
 // busy flag of next node
 reg           next_pass_req_busy;
 reg           next_pass_rep_busy;
 reg           next_in_req_busy;
 reg           next_in_rep_busy;
 
 reg           set_next_pass_req_busy;
 reg           set_next_pass_rep_busy;
 reg           set_next_in_req_busy;
 reg           set_next_in_rep_busy;
 
 // set next_pass_req_busy
 always@(posedge clk)
 begin
 if(rst==1'b0)
   next_pass_req_busy<=1'b0;
 else if(set_next_pass_req_busy==1'b1)
   next_pass_req_busy<=1'b1;
 
 end
 
 // set next_pass_rep_busy
 always@(posedge clk)
 begin
 if(rst==1'b0)
   next_pass_rep_busy<=1'b0;
 else if(set_next_pass_rep_busy==1'b1)
   next_pass_rep_busy<=1'b1;
 
 end 
 
  // set next_in_req_busy
 always@(posedge clk)
 begin
 if(rst==1'b0)
   next_in_req_busy<=1'b0;
 else if(set_next_in_req_busy==1'b1)
   next_in_req_busy<=1'b1;
 
 end
 
 // set next_in_rep_busy
 always@(posedge clk)
 begin
 if(rst==1'b0)
   next_in_rep_busy<=1'b0;
 else if(set_next_in_rep_busy==1'b1)
   next_in_rep_busy<=1'b1;
 
 end
 
 
 reg            pass_rep_go;
 reg            local_rep_go;
 reg            pass_req_go;
 reg            local_req_go;
 
 //priority reg
 reg  [3:0] priority_1;
 reg  [2:0] priority_2;
 reg  [1:0] priority_3;
 
 // fake en_priority
 reg   en_priority_1;
 reg   en_priority_2;
 reg   en_priority_3;
 reg   en_priority_4;
 
 
 wire  [3:0] en;
 //assign 
    
wire  [3:0]   temp_priority_1;
wire  [2:0]   temp_priority_2;
wire  [1:0]   temp_priority_3;
 
 //assign 
assign temp_priority_1=priority_1;
assign temp_priority_2=priority_2;
assign temp_priority_3=priority_3;



//////////////////////////////////////////////////////////////////////////////////
///// here need some revision/////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////
 // from unused to used 
 
 always@( * )
  begin
    if(next_local_rep==1'b0&&~next_pass_rep_busy&&~OUT_rep_busy&&(!OUT_local_rep_empty))
      begin
        if(used_slots_pass_rep<=4'b0100&&OUT_rep_length_code==2'b11)
          //  out local rep not empty, unused slots in pass rep of next node more than 11
          local_rep_go=1'b1;
        if(used_slots_pass_rep<=4'b0110&&OUT_rep_length_code==2'b10)
          //  out local rep not empty, unused slots in pass rep of next node more than 9
          local_rep_go=1'b1;
        if(used_slots_pass_rep<=4'b1100&&OUT_rep_length_code==2'b01)
          //  out local rep not empty, unused slots in pass rep of next node more than 3
          local_rep_go=1'b1;
        if(used_slots_pass_rep<=4'b1110&&OUT_rep_length_code==2'b00)
          //  out local rep not empty, unused slots in pass rep of next node more than 1
          local_rep_go=1'b1;
      end
    if(!OUT_local_rep_empty&&next_local_rep&&~next_in_rep_busy&&~OUT_rep_busy)
      local_rep_go=1'b1;
    if(!OUT_local_req_empty&&~next_local_req&&~next_pass_req_busy&&~OUT_req_busy)
      //
      //
      // i'm afraid of some revision here i made causing problems
      //
      //
      local_req_go=1'b1;
    if(!OUT_local_req_empty&&next_local_req&&~next_in_req_busy&&~OUT_req_busy)
      local_req_go=1'b1;
    if(!pass_rep_empty&&~next_pass_rep&&~next_pass_rep_busy&&~local_pass_rep_busy)
      pass_rep_go=1'b1;
    if(!pass_rep_empty&&next_pass_rep&&~next_in_rep_busy&&~local_pass_rep_busy)
      pass_rep_go=1'b1;
    if(!pass_req_empty&&~next_pass_req&&~next_pass_req_busy&&~local_pass_req_busy)
      pass_req_go=1'b1;
    if(!pass_req_empty&&~next_pass_req&&~next_in_req_busy&&~local_pass_req_busy)  
      pass_req_go=1'b1;
   end  

// arbitrate dest fifos for ready and safe source fifos


reg   priority_arbiter1;
reg   priority_arbiter2;

reg   update_arbiter1;
reg   update_arbiter2;
always@(posedge clk)
begin
  if(rst)
    priority_arbiter1<=1'b0;
 else if(update_arbiter1)
    priority_arbiter1<=~priority_arbiter1;
 
end

always@(posedge clk)
begin
  if(rst)
    priority_arbiter2<=1'b0;
 else if(update_arbiter2)
    priority_arbiter2<=~priority_arbiter2;
  
end

///  arbitrate local rep fifo and pass rep fifo
always@(local_rep_go or pass_rep_go or next_local_rep or  next_pass_rep)
begin
  /////////////////////////////////////////////////////////////////////////////////
  ///////NOTE: the  order if block looks like 4 bits                   ////////////
  //////      {local_rep_go,pass_rep_go,next_local_rep,next_pass_rep}   ///////////
  //////       order 0000,0001,0010...                                   //////////
  /////////////////////////////////////////////////////////////////////////////////
   //                 if (00xx)                        // 4 case
  // if local rep  can't go anywhere ,then pass can go anywhere it want! 
  if(~local_rep_go&&pass_rep_go&&~next_pass_rep)  // 2 case 01x0
    begin
      set_next_pass_rep_busy=1'b1;
      set_local_pass_rep_busy=1'b1;
      set_pass_rep_dest_id_in=2'b11;
      set_pass_rep_dest_id=1'b1;
    end
    
  // if local rep  can't go anywhere ,then pass can go anywhere it want!
  if(~local_rep_go&&pass_rep_go&&next_pass_rep)   // 2 case  01x1
    begin
      set_next_in_rep_busy=1'b1;
      set_local_pass_rep_busy=1'b1;
      set_pass_rep_dest_id_in=2'b01;
      set_pass_rep_dest_id=1'b1;
    end
    
  // if local rep want and can go to next pass rep fifo,then he will be allowed to go on.
  if(local_rep_go&&~pass_rep_go&&~next_local_rep) //2 case  100x
    begin
      set_next_pass_rep_busy=1'b1;
      set_OUT_rep_busy=1'b1;
      set_OUT_rep_dest_id_in=2'b11;
      set_OUT_rep_dest_id=1'b1;
    end
  
  // if local rep want and can go to next local rep fifo,then he will be allowed to go on.
  if(local_rep_go&&~pass_rep_go&&next_local_rep) //2 case  101x
    begin
      set_next_in_rep_busy=1'b1;
      set_OUT_rep_busy=1'b1;
      set_OUT_rep_dest_id_in=2'b01;
      set_OUT_rep_dest_id=1'b1;
    end
    
 // if local rep want to go to pass rep of next,it will go
  if(local_rep_go&&pass_rep_go&&~next_local_rep) //2 case  110x
    begin
      set_next_pass_rep_busy=1'b1;
      set_OUT_rep_busy=1'b1;
      set_OUT_rep_dest_id_in=2'b11;
      set_OUT_rep_dest_id=1'b1;
    end
  
  // if local rep and pass rep want go to differrent fifo of next node, they both succeed go on.
  if(local_rep_go&&pass_rep_go&&next_local_rep&&~next_pass_rep)  //1 case  1110
    begin
      set_next_in_rep_busy=1'b1;
      set_OUT_rep_busy=1'b1;
      set_OUT_rep_dest_id_in=2'b01;
      set_OUT_rep_dest_id=1'b1;
      set_next_pass_rep_busy=1'b1;
      set_local_pass_rep_busy=1'b1;
      set_pass_rep_dest_id_in=2'b11;
      set_pass_rep_dest_id=1'b1;
    end
  // if local rep and pass rep both want to go to local rep of next node ,priority_arbiter1 will decide who win!
   if(local_rep_go&&pass_rep_go&&next_local_rep&&next_pass_rep)  // 1 case 1111
     begin
       update_arbiter1=1'b1;
       if(priority_arbiter1)
         begin
          set_next_in_rep_busy=1'b1;
          set_OUT_rep_busy=1'b1;
          set_OUT_rep_dest_id_in=2'b01;
          set_OUT_rep_dest_id=1'b1;
         end
       else
         begin
          set_next_in_rep_busy=1'b1;
          set_local_pass_rep_busy=1'b1;
          set_pass_rep_dest_id_in=2'b01;
          set_pass_rep_dest_id=1'b1; 
         end 
    end
end

 
 
 //// arbitrate local req fifo and pass req fifo
always@(local_req_go or pass_req_go or next_local_req or  next_pass_req)
begin
  /////////////////////////////////////////////////////////////////////////////////
  ///////NOTE: the  order if block looks like 4 bits                   ////////////
  //////      {local_req_go,pass_req_go,next_local_req,next_pass_req}   ///////////
  //////       order 0000,0001,0010...                                   //////////
  /////////////////////////////////////////////////////////////////////////////////
   //                 if (00xx)                        // 4 case
  // if local req  can't go anywhere ,then pass can go anywhere it want! 
  if(~local_req_go&&pass_req_go&&~next_pass_req)  // 2 case 01x0
    begin
      set_next_pass_req_busy=1'b1;
      set_local_pass_req_busy=1'b1;
      set_pass_req_dest_id_in=2'b10;
      set_pass_req_dest_id=1'b1;
    end
    
  // if local req  can't go anywhere ,then pass can go anywhere it want!
  if(~local_req_go&&pass_req_go&&next_pass_req)   // 2 case  01x1
    begin
      set_next_in_req_busy=1'b1;
      set_local_pass_req_busy=1'b1;
      set_pass_req_dest_id_in=2'b00;
      set_pass_req_dest_id=1'b1;
    end
    
  // if local req want and can go to next pass req fifo,then he will be allowed to go on.
  if(local_req_go&&~pass_req_go&&~next_local_req) //2 case  100x
    begin
      set_next_pass_req_busy=1'b1;
      set_OUT_req_busy=1'b1;
      set_OUT_req_dest_id_in=2'b10;
      set_OUT_req_dest_id=1'b1;
    end
  
  // if local req want and can go to next local req fifo,then he will be allowed to go on.
  if(local_req_go&&~pass_req_go&&next_local_req) //2 case  101x
    begin
      set_next_in_req_busy=1'b1;
      set_OUT_req_busy=1'b1;
      set_OUT_req_dest_id_in=2'b00;
      set_OUT_req_dest_id=1'b1;
    end
    
 // if local req want to go to pass req of next,it will go
  if(local_req_go&&pass_req_go&&~next_local_req) //2 case  110x
    begin
      set_next_pass_req_busy=1'b1;
      set_OUT_req_busy=1'b1;
      set_OUT_req_dest_id_in=2'b10;
      set_OUT_req_dest_id=1'b1;
    end
  
  // if local req and pass req want go to differrent fifo of next node, they both succeed go on.
  if(local_req_go&&pass_req_go&&next_local_req&&~next_pass_req)  //1 case  1110
    begin
      set_next_in_req_busy=1'b1;
      set_OUT_req_busy=1'b1;
      set_OUT_req_dest_id_in=2'b00;
      set_OUT_req_dest_id=1'b1;
      set_next_pass_req_busy=1'b1;
      set_local_pass_req_busy=1'b1;
      set_pass_req_dest_id_in=2'b10;
      set_pass_req_dest_id=1'b1;
    end
  // if local req and pass req both want to go to local req of next node ,priority_arbiter1 will decide who win!
   if(local_req_go&&pass_req_go&&next_local_req&&next_pass_req)  // 1 case 1111
     begin
       update_arbiter2=1'b1;
       if(priority_arbiter2)
         begin
           set_next_in_req_busy=1'b1;
           set_OUT_req_busy=1'b1;
           set_OUT_req_dest_id_in=2'b00;
           set_OUT_req_dest_id=1'b1;
         end
       else
         begin
           set_next_in_req_busy=1'b1;
           set_local_pass_req_busy=1'b1;
           set_pass_req_dest_id_in=2'b00;
           set_pass_req_dest_id=1'b1; 
         end 
    end
end



     
   assign en[3:0]={OUT_req_busy&&OUT_req_dest_seled_rdy,local_pass_req_busy&&local_pass_req_dest_seled_rdy,
                   OUT_rep_busy&&OUT_rep_dest_seled_rdy,local_pass_rep_busy&&local_pass_rep_dest_seled_rdy}; 

 always@(en[3:0] or temp_priority_1 or temp_priority_2 or temp_priority_3)
 begin
   //init
   en_priority_1=0;
   en_priority_2=0;
   en_priority_3=0;
   en_priority_4=0;
   select=4'b0000;
   //behave logic judgement
   if(en[3:0]==4'b1111)
     begin
     select=temp_priority_1;
     en_priority_1=1;
     end
   else if(en[3:0]==4'b1110)
     begin
     select={temp_priority_2,1'b0};
     en_priority_2=1;
     end
   else if(en[3:0]==4'b1101)
     begin
     select={temp_priority_2[1:0],1'b0,temp_priority_2[2]};
     en_priority_2=1;
     end
   else if(en[3:0]==4'b1011)
     begin
     select={temp_priority_2[0],1'b0,temp_priority_2[2:1]};
     en_priority_2=1;
     end
   else if(en[3:0]==4'b0111)
     begin
     select={1'b0,temp_priority_2};
     en_priority_2=1;
     end
   else if(en[3:0]==4'b1100)
     begin
     select={temp_priority_3,1'b0,1'b0};
     en_priority_3=1;
     end
   else if(en[3:0]==4'b1001)
     begin
     select={temp_priority_3[0],1'b0,1'b0,temp_priority_3[1]};
     en_priority_3=1;
     end
   else if(en[3:0]==4'b0011)
     begin
     select={1'b0,1'b0,temp_priority_3};
     en_priority_3=1;
     end
   else if(en[3:0]==4'b0110)
     begin
     select={1'b0,temp_priority_3,1'b0};
     en_priority_3=1;
     end
   else if(en[3:0]==4'b1010)
     begin
     select={temp_priority_3[1],1'b0,temp_priority_3[0],1'b0};
     en_priority_3=1;
     end
   else if(en[3:0]==4'b0101)
     begin
     select={1'b0,temp_priority_3[1],1'b0,temp_priority_3[0]};
     en_priority_3=1;
     end
   else
    begin
     select=en;
    end
 end

//priority_1 reg   
always@(posedge clk or posedge rst)
begin
 if(rst)
   priority_1=0001;
else if(en_priority_1)
   priority_1={priority_1[2:0],priority_1[3]};
end
   
   
//priority_2 reg
always@(posedge clk or posedge rst)
begin
 if(rst)
   priority_2=3'b001;
else if(en_priority_2)
   priority_2={priority_2[1:0],priority_2[2]};
end

//priority_3 reg  
always@(posedge clk or posedge rst)
begin
 if(rst)
   priority_3=2'b01;
else if(en_priority_3)
   priority_3={priority_3[0],priority_3[1]};
end
  

endmodule
    
                       
                       