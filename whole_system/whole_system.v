//date:2016/3/14
//engineer :ZhaiShaoMin
// module function :unite all four ring_node together
module    whole_system(//input
                        clk,
                        rst
                        );
input     clk;
input     rst;
                     
wire                     en_local_req_1;    // to previous node  refer to below notes  
wire                     en_local_rep_1;    
wire                     en_pass_req_1;    // from next node  //local_in_req fifo in next node says that it can receive
wire                     en_pass_rep_1;     // refer to notes below
wire     [3:0]           used_slots_pass_req_1;
wire     [3:0]           used_slots_pass_rep_1;               
wire     [15:0]          flit_out_1;
wire     [1:0]           ctrl_out_1;
wire     [1:0]           dest_fifo_out_1;
                     
wire                     en_local_req_2;   // to previous node  refer to below notes  
wire                     en_local_rep_2;    
wire                     en_pass_req_2;    // from next node  //local_in_req fifo in next node says that it can receive
wire                     en_pass_rep_2;     // refer to notes below
wire    [3:0]            used_slots_pass_req_2;
wire    [3:0]            used_slots_pass_rep_2;               
wire    [15:0]           flit_out_2;
wire    [1:0]            ctrl_out_2;
wire    [1:0]            dest_fifo_out_2;
                     
wire                     en_local_req_3;   // to previous node  refer to below notes  
wire                     en_local_rep_3;    
wire                     en_pass_req_3;    // from next node  //local_in_req fifo in next node says that it can receive
wire                     en_pass_rep_3;     // refer to notes below
wire    [3:0]            used_slots_pass_req_3;
wire    [3:0]            used_slots_pass_rep_3;               
wire    [15:0]           flit_out_3;
wire    [1:0]            ctrl_out_3;
wire    [1:0]            dest_fifo_out_3;
                     
wire                     en_local_req_4;   // to previous node  refer to below notes  
wire                     en_local_rep_4;    
wire                     en_pass_req_4;    // from next node  //local_in_req fifo in next node says that it can receive
wire                     en_pass_rep_4;     // refer to notes below
wire    [3:0]            used_slots_pass_req_4;
wire    [3:0]            used_slots_pass_rep_4;               
wire    [15:0]           flit_out_4;
wire    [1:0]            ctrl_out_4;
wire    [1:0]            dest_fifo_out_4;
// instance of node1
ring_node     node1(//input
                     .clk(clk),
                     .rst(rst),
                     .ctrl_in(ctrl_out_4),                          //[1:0] for guiding flit flowing ; 00:nothing, 01:head flit, 10:body flit, 11:tail flit
                     .flit_in(flit_out_4),  
                     .dest_fifo_in(dest_fifo_out_4),
                     .en_local_req_in(en_local_req_4),
                     .en_local_rep_in(en_local_rep_4),
                     .en_pass_req_in(en_pass_req_4),
                     .en_pass_rep_in(en_pass_rep_4),
                     .used_slots_pass_req_in(used_slots_pass_req_4),
                     .used_slots_pass_rep_in(used_slots_pass_rep_4),
                     //output
                     .en_local_req(en_local_req_1),    // to previous node  refer to below notes  
                     .en_local_rep(en_local_rep_1),    
                     .en_pass_req(en_pass_req_1),     // from next node  //local_in_req fifo in next node says that it can receive
                     .en_pass_rep(en_pass_rep_1),     // refer to notes below
                     .used_slots_pass_req(used_slots_pass_req_1),
                     .used_slots_pass_rep(used_slots_pass_rep_1),               
                     .flit_out(flit_out_1),
                     .ctrl_out(ctrl_out_1),
                     .dest_fifo_out(dest_fifo_out_1)
                     );  

// instance of node2
ring_node     node2(//input
                     .clk(clk),
                     .rst(rst),
                     .ctrl_in(ctrl_out_1),                          //[1:0] for guiding flit flowing ; 00:nothing, 01:head flit, 10:body flit, 11:tail flit
                     .flit_in(flit_out_1),  
                     .dest_fifo_in(dest_fifo_out_1),
                     .en_local_req_in(en_local_req_1),
                     .en_local_rep_in(en_local_rep_1),
                     .en_pass_req_in(en_pass_req_1),
                     .en_pass_rep_in(en_pass_rep_1),
                     .used_slots_pass_req_in(used_slots_pass_req_1),
                     .used_slots_pass_rep_in(used_slots_pass_rep_1),
                     //output
                     .en_local_req(en_local_req_2),    // to previous node  refer to below notes  
                     .en_local_rep(en_local_rep_2),    
                     .en_pass_req(en_pass_req_2),     // from next node  //local_in_req fifo in next node says that it can receive
                     .en_pass_rep(en_pass_rep_2),     // refer to notes below
                     .used_slots_pass_req(used_slots_pass_req_2),
                     .used_slots_pass_rep(used_slots_pass_rep_2),               
                     .flit_out(flit_out_2),
                     .ctrl_out(ctrl_out_2),
                     .dest_fifo_out(dest_fifo_out_2)
                     );
                     
// instance of node3
ring_node     node3(//input
                     .clk(clk),
                     .rst(rst),
                     .ctrl_in(ctrl_out_2),                          //[1:0] for guiding flit flowing ; 00:nothing, 01:head flit, 10:body flit, 11:tail flit
                     .flit_in(flit_out_2),  
                     .dest_fifo_in(dest_fifo_out_2),
                     .en_local_req_in(en_local_req_2),
                     .en_local_rep_in(en_local_rep_2),
                     .en_pass_req_in(en_pass_req_2),
                     .en_pass_rep_in(en_pass_rep_2),
                     .used_slots_pass_req_in(used_slots_pass_req_2),
                     .used_slots_pass_rep_in(used_slots_pass_rep_2),
                     //output
                     .en_local_req(en_local_req_3),    // to previous node  refer to below notes  
                     .en_local_rep(en_local_rep_3),    
                     .en_pass_req(en_pass_req_3),     // from next node  //local_in_req fifo in next node says that it can receive
                     .en_pass_rep(en_pass_rep_3),     // refer to notes below
                     .used_slots_pass_req(used_slots_pass_req_3),
                     .used_slots_pass_rep(used_slots_pass_rep_3),               
                     .flit_out(flit_out_3),
                     .ctrl_out(ctrl_out_3),
                     .dest_fifo_out(dest_fifo_out_3)
                     );
              
// instance of node4
ring_node     node4(//input
                     .clk(clk),
                     .rst(rst),
                     .ctrl_in(ctrl_out_3),                          //[1:0] for guiding flit flowing ; 00:nothing, 01:head flit, 10:body flit, 11:tail flit
                     .flit_in(flit_out_3),  
                     .dest_fifo_in(dest_fifo_out_3),
                     .en_local_req_in(en_local_req_3),
                     .en_local_rep_in(en_local_rep_3),
                     .en_pass_req_in(en_pass_req_3),
                     .en_pass_rep_in(en_pass_rep_3),
                     .used_slots_pass_req_in(used_slots_pass_req_3),
                     .used_slots_pass_rep_in(used_slots_pass_rep_3),
                     //output
                     .en_local_req(en_local_req_4),    // to previous node  refer to below notes  
                     .en_local_rep(en_local_rep_4),    
                     .en_pass_req(en_pass_req_4),     // from next node  //local_in_req fifo in next node says that it can receive
                     .en_pass_rep(en_pass_rep_4),     // refer to notes below
                     .used_slots_pass_req(used_slots_pass_req_4),
                     .used_slots_pass_rep(used_slots_pass_rep_4),               
                     .flit_out(flit_out_4),
                     .ctrl_out(ctrl_out_4),
                     .dest_fifo_out(dest_fifo_out_4)
                     );
endmodule