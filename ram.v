//            Block RAM initialization 
//
//
module BLOCK_RAM_INIT (data_out, ADDR, data_in, CLK, WE);
output[3:0] data_out;
input [2:0] ADDR;
input [3:0] data_in;
input CLK, WE;
reg [3:0] mem [7:0];
reg [3:0] read_addr;
initial
begin
$readmemb("data.dat", mem);       //?data.dat? contains initial RAM
                                  //contents, it gets put into the bitfile
end                               //and loaded at configuration time.
                                  //(Remake bits to change contents)

always@(posedge CLK)
read_addr <= ADDR;
assign data_out = mem[read_addr];
always @(posedge CLK)
if (WE) mem[ADDR] = data_in;
endmodule
