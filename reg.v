/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

                     University of Illinois/NCSA
                         Open Source License

         Copyright(C) 2004, The Board of Trustees of the
          University of Illinois.  All rights reserved

                              IVM 1.0
                          Developed by:
                  Advanced Computing Systems Group
        Center for Reliable and High-Performance Computing
            University of Illinois at Urbana-Champaign

                   http://www.crhc.uiuc.edu/ACS

                      -- with support from --     
             Center for Circuits and Systems Solutions (C2S2)

Permission is hereby granted, free of charge, to any person obtaining a copy 
of this software and associated documentation files (the Software), to 
deal with the Software without restriction, including without limitation the 
rights to use, copy, modify, merge, publish, distribute, sublicense, and/or 
sell copies of the Software, and to permit persons to whom the Software is 
furnished to do so, subject to the following conditions:

Redistributions of source code must retain the above copyright notice, this 
list of conditions and the following disclaimers.

Redistributions in binary, gate-level, layout-level, or physical form must
reproduce the above copyright notice, this list of conditions and the
following disclaimers in the documentation and/or other materials provided
with the distribution.

Neither the names of Advanced Computing Systems Group, Center for Reliable
and High-Performance Computing, Center for Circuits and Systems Solution
(C2S2), University of Illinois at Urbana-Champaign, nor the names of its
contributors may be used to endorse or promote products derived from this
Software without specific prior written permission.

THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE 
CONTRIBUTORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS 
WITH THE SOFTWARE.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/


/*******************************************************************************

  File: REGn.v

  Description: This file contains the definition of a n-bit register

******************************************************************************/

`timescale 1ns/100ps


/*
 * FUNC_NAME: REGn
 *
 * DESCRIPTION: 
 *	Definition for a n-bit register, asynch. reset
 *
 * INPUT:
 *	reg_in - the value to be stored in the register on the next clock edge
 *	clk - the system clock
 *
 * OUTPUT:
 *	reg_out - the current value of the register
 *
 * ASSUMPTIONS:
 *
 * AUTHOR:
 *	Justin Quek
 * DATE:
 *	17-Apr-03
 * LAST MODIFICATION:
 *	Created modules
 */
module REGn(reg_out, clk, reset, reg_in);

  parameter RegLen = 63;

  // outputs
  output [RegLen:0] reg_out;
  // inouts
  // special inputs
  input clk;
  input reset;
  // inputs
  input [RegLen:0] reg_in;

  // internal vars
  reg [RegLen:0] reg_val;

  // assign vars

  // assign outputs
  assign reg_out = reg_val;

  // instantiate other modules

  // change the value of the register on every rising clock edge
  always @(posedge clk)
  begin
    reg_val <= reg_in;
  end

  // async. reset
  always @(posedge reset)
  begin
    reg_val = 'b0;
  end

endmodule // REGn

/*
 * FUNC_NAME: REGfn
 *
 * DESCRIPTION: 
 *	Definition for a n-bit register, with synchronous AND asynchronous reset signal
 *
 * INPUT:
 *	reg_in - the value to be stored in the register on the next clock edge
 *	clk - the system clock
 *      flush - synchronous reset
 *
 * OUTPUT:
 *	reg_out - the current value of the register
 *
 * ASSUMPTIONS:
 *
 * AUTHOR:
 *	Justin Quek
 * DATE:
 *	19-Apr-03
 * LAST MODIFICATION:
 *	Created modules
 */
module REGfn(reg_out, clk, reset, flush, reg_in);

  parameter RegLen = 63;

  // outputs
  output [RegLen:0] reg_out;
  // inouts
  // special inputs
  input clk;
  input reset;
  input flush;
  // inputs
  input [RegLen:0] reg_in;

  // internal vars
  reg [RegLen:0] reg_val;

  // assign vars

  // assign outputs
  assign reg_out = reg_val;

  // instantiate other modules

  // change the value of the register on every rising clock edge if the flush signal is low
  always @(posedge clk)
  begin
    if (flush == 1'b1)
    begin
      reg_val <= 'b0;
    end
    else
    begin
      reg_val <= reg_in;
    end
  end

  // async. reset
  always @(posedge reset)
  begin
    reg_val = 'b0;
  end

endmodule // REGfn

/*
 * FUNC_NAME: REGln
 *
 * DESCRIPTION: 
 *	Definition for a n-bit register, with load signal and synchronous reset
 *
 * INPUT:
 *	reg_in - the value to be stored in the register on the next clock edge
 *	clk - the system clock
 *      load - if we should store on the next clock edge
 *
 * OUTPUT:
 *	reg_out - the current value of the register
 *
 * ASSUMPTIONS:
 *
 * AUTHOR:
 *	Justin Quek
 * DATE:
 *	10-Apr-03
 * LAST MODIFICATION:
 *	Created modules
 */
module REGln(reg_out, clk, load, reset, reg_in);

  parameter RegLen = 63;

  // outputs
  output [RegLen:0] reg_out;
  // inouts
  // special inputs
  input clk;
  input load;
  input reset;
  // inputs
  input [RegLen:0] reg_in;

  // internal vars
  reg [RegLen:0] reg_val;

  // assign vars

  // assign outputs
  assign reg_out = reg_val;

  // instantiate other modules

  // change the value of the register on every rising clock edge if the load signal is high
  always @(posedge clk)
  begin
    if (reset == 1'b1)
    begin
      reg_val <= 'b0;
    end
    else if (load == 1'b1)
    begin
      reg_val <= reg_in;
    end
  end

endmodule // REGln

/*
 * FUNC_NAME: REGan
 *
 * DESCRIPTION: 
 *	Definition for a n-bit register, with load signal and asynchronous reset
 *
 * INPUT:
 *	reg_in - the value to be stored in the register on the next clock edge
 *	clk - the system clock
 *      load - if we should store on the next clock edge
 *
 * OUTPUT:
 *	reg_out - the current value of the register
 *
 * ASSUMPTIONS:
 *
 * AUTHOR:
 *	Justin Quek
 * DATE:
 *	10-Apr-03
 * LAST MODIFICATION:
 *	Created modules
 */
module REGan(reg_out, clk, load, reset, reg_in);

  parameter RegLen = 63;

  // outputs
  output [RegLen:0] reg_out;
  // inouts
  // special inputs
  input clk;
  input load;
  input reset;
  // inputs
  input [RegLen:0] reg_in;

  // internal vars
  reg [RegLen:0] reg_val;

  // assign vars

  // assign outputs
  assign reg_out = reg_val;

  // instantiate other modules

  // change the value of the register on every rising clock edge if the load signal is high
  always @(posedge clk)
  begin
    if (load == 1'b1)
    begin
      reg_val <= reg_in;
    end
  end

  // async. reset
  always @(posedge reset)
  begin
    reg_val = 'b0;
  end

endmodule // REGan

