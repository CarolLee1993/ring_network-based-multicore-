//date:2016/3/20
//engineer:ZhaiShaoMin
//module name: PHT :Pattern History Table
module  core_PHT(//input
                   clk,
                   rst,
                   if_pc,  // pc[10:5]
                   id_pc,  // pc[10:5]
                   update_BP,
                   pred_right,
                   taken,
                   BHR_in,
                   //delayed PHT_out from previous stage , useful to avoid reading PHT when update PHT
                   delayed_PHT,
                   //output
                   pred_out,
                   BHR_rd,
                   PHT_out
                   );
//input
input               clk;
input               rst;
input               update_BP;
input               pred_right;
input               taken;
input     [5:0]     if_pc;  //part of pc
input     [5:0]     id_pc;  // part of pc
input     [3:0]     BHR_in;          
input     [1:0]     delayed_PHT;
//output
output              pred_out; 
output              BHR_rd;
output              PHT_out;

wire  [1:0]   PHT_out;
wire  [2:0]   BHR_rd;
reg           en_update_PHT;
reg   [1:0]   PHT_in;
//reg of BHT
reg   [3:0]  BHT [7:0];
reg   [1:0]  PHT [127:0];
//index for update PHT
wire  [6:0]  index_PHT_id;
//index for look PHT
wire  [6:0]  index_PHT_if;
assign   index_PHT_if={BHR_rd,if_pc[4:2]};
assign   index_PHT_id={BHR_in,id_pc[4:2]};

//index for look BHT
wire    [2:0]   index_BHT_if;
wire    [2:0]   index_BHT_id;
//hash process for short index!
assign   index_BHT_if={if_pc[5]^if_pc[4],if_pc[3]^if_pc[2],if_pc[1]^if_pc[0]};
assign   index_BHT_id={id_pc[5]^id_pc[4],id_pc[3]^id_pc[2],id_pc[1]^id_pc[0]};
// update BHT
always@(posedge clk)
begin
  if(rst)   
    begin :resetBHT
      integer i;
      for(i=0;i<8;i=i+1)
      begin
        BHT[i]<=4'b0000;
      end
    end
  else if(update_BP)
    begin
      if(taken)
          BHT[index_BHT_id]<={BHR_in[2:0],1'b1};
      else
          BHT[index_BHT_id]<={BHR_in[2:0],1'b1};
    end
end

//update PHT
always@(posedge clk)
begin
  if(rst)
    begin:resetPHT
      integer j;
      for(j=0;j<128;j=j+1)
      begin
        PHT[j]<=2'b00;
      end
    end
  else if(en_update_PHT)
    begin
      PHT[index_PHT_id]<=PHT_in;
    end
end

// figure out whether updating PHT or not
always@(*)
begin
  en_update_PHT=1'b0;
  PHT_in=2'b00;
  if(update_BP)
    begin
      if(delayed_PHT[1]&&pred_right)
        begin
          if(delayed_PHT[0]==1'b0)
            begin
              en_update_PHT=1'b1;
              PHT_in=2'b11;
            end
        end
      else if((!delayed_PHT[1])&&pred_right)
        begin
          en_update_PHT=1'b1;
          PHT_in=2'b10;
        end
      else if(delayed_PHT[1]&&(!pred_right))
        begin
          en_update_PHT=1'b1;
          PHT_in=2'b01;
        end
      else if((!delayed_PHT[1])&&(!pred_right))
        begin
          en_update_PHT=1'b1;
          PHT_in=2'b00;
        end
    end
end

//read BHT
assign  BHR_rd=BHT[index_BHT_if];
//read PHT
assign  PHT_out=PHT[index_PHT_if];
assign  pred_out=PHT_out[1];
endmodule