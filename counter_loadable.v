///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////LOADABLE COUNTER////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Generic n-bit incrementable loadable counter
module counter_loadable     (CLK,        //input         assert posedge to increment/decrement counter                                                                          
                             EN,         //input         enable signal (assert to allow counter to count)
                             RST,        //input         assert to set counter               
                             DIN,        //input         data to set counter to
                             DONE,       //output        asserted if count is reached                             
                             COUNT);     //output [n:0]  current count
    
    //////////MODULE PARAMETERS//////////
                
    parameter      n=4,         //width of counter                   
                   start=0,     //This value doesn't matter.. dummy var to make parameters the same
                   final=8,     //ending value of counter
                   step=1;  //step to increment by (set to -1 for decrementing)
                   

    //////////SIGNALS ///////////////////
    
    input          CLK;
    input          RST;
    input          EN;
    input  [n-1:0] DIN;
    output         DONE;
    output [n-1:0] COUNT; 


    ///////////IMPLEMENTATION//////////////////////
    reg [n-1:0] COUNT;

    always @ (posedge CLK or posedge RST)
    begin
        if (RST)
            #5 COUNT = DIN;
        else if (EN)
            #5 COUNT = COUNT + step;        
    end                

    assign DONE = (COUNT == final);
        
endmodule
