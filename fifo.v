////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////RAM BASED FIFO//////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module fifo (CLK,       //input         - clock to sample data in at. (e.g. DRAM_CLK)
             DIN,       //input  [18:0] - data to input into FIFO            width is 19 or some other  19=1( whether next_node is dest id)
             RST,       //input         - reset trigger for shift register                                 +2(ctrl 00:nothing 01:head 10:body 11:tail
             IN_EN,     //input         - input enable (allow shifting to start)                           +16(flit is 16 bits long)
             OUT_EN,     //input         - output enable (allow shifting to start)
             DOUT,      //output [18:0] - data to output from FIFO
             FULL,      //output        - indicate that fifo is full
             EMPTY      //output        - indicate that fifo is empty
            );   
  //  parameter            fifo_depth=16;
  //  parameter            fifo_width=19;            
    input                    CLK;
    input [18:0]   DIN;
    input                    RST;
    input                    IN_EN;
    input                    OUT_EN;
    output[18:0]   DOUT;
    output                   FULL;
    output                   EMPTY; 
    
    wire                 empty_en;
    wire                 full_en;
    
    reg [3:0]            cnthead;
    reg [3:0]            cnttail;
    reg                  full;
    reg                  empty;
    reg [18:0] fifo [0:15] ;
    reg [18:0] DOUT_temp;
    reg  [4:0] fcnt;
    
                
   
    
    //fifo counter
     always @(posedge CLK or posedge RST)
  begin
   if(RST)
          fcnt<=5'b0;
   else if((!OUT_EN&&IN_EN)||(OUT_EN&&!IN_EN))
      begin
       if(IN_EN)
          fcnt<=fcnt+1'b1;
       else           
          fcnt<=fcnt-1'b1;
      end
   else   fcnt<=fcnt;
  end
  
    //head counter
    always@(posedge CLK or posedge RST )
    if(RST)
      cnthead=4'b0000;
    else if(OUT_EN)
      cnthead=cnthead+1;
      
    //tail counter 
    always@(posedge CLK or posedge RST )
    if(RST)
      cnttail=4'b0000;
    else if(IN_EN)
      cnttail=cnttail+1;
      
      // reg full state
    always@(posedge CLK or posedge RST )
    if(RST)
      full=0;
    else if(full_en)
      full=1;
      
      //reg empty state
    always@(posedge CLK or posedge RST )
      if(RST)
        empty=0;
      else if(empty_en)
        empty=1;
        
    // write data into fifo
    always@(IN_EN )
    begin
       if(IN_EN)
         fifo[cnttail]=DIN;
    end
    
    // read data from fifo
   always@( OUT_EN)
   begin
       if(OUT_EN)
         DOUT_temp=fifo[cnthead];
       else
         DOUT_temp=19'h00000;
   end
   
   /// assign some signals!
   assign  full_en=((fcnt==5'b01111&&IN_EN))? 1:0;
   assign  empty_en=((fcnt==5'b00001&&OUT_EN))? 1:0;
   assign  DOUT=DOUT_temp;
   assign  FULL=full;
   assign  EMPTY=empty;
   
 endmodule
 