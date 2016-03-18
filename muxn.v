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

  File: MUXn_8_1.v

  Description: This file contains the definition of a n-bit 8-to-1 MUX

******************************************************************************/

`timescale 1ns/100ps

/*
 * FUNC_NAME: MUXn_2_1
 *
 * DESCRIPTION: 
 *	Definition for a n-bit 2-to-1 MUX
 *
 * INPUT:
 *	mux_in0 - the input to be output if mux_sel is 0
 * 	mux_in1 - the input to be output if mux_sel is 1
 * 	mux_sel - chooses between the inputs
 *
 * OUTPUT:
 *	mux_out - the output of the mux
 *
 * ASSUMPTIONS:
 *
 * AUTHOR:
 *	Justin Quek
 * DATE:
 *	25-apr-03
 * LAST MODIFICATION:
 *    <modifier's name>  <date modified>
 */
module MUXn_2_1(mux_in0, mux_in1, mux_sel, mux_out);

  parameter MuxLen = 63;

  // outputs
  output [MuxLen:0] mux_out;
  // inputs
  input [MuxLen:0] mux_in0;
  input [MuxLen:0] mux_in1;
  input mux_sel;

  // internal vars

  // assign vars

  // assing outputs
  reg [MuxLen:0] mux_out;

  // instantiate other modules

  // code
  always @(mux_in0 or mux_in1 or mux_sel)
  begin
    if (mux_sel == 1'b1)
      mux_out = mux_in1;
    else
      mux_out = mux_in0;
  end

endmodule // MUXn_2_1

/*
 * FUNC_NAME: MUXn_4_1
 *
 * DESCRIPTION: 
 *	Definition for a n-bit 4-to-1 MUX
 *
 * INPUT:
 *	mux_in0 - the input to be output if mux_sel is 00
 * 	mux_in1 - the input to be output if mux_sel is 01
 *	mux_in2 - the input to be output if mux_sel is 10
 *	mux_in3 - the input to be output if mux_sel is 11
 * 	mux_sel - chooses between the inputs
 *
 * OUTPUT:
 *	mux_out - the output of the mux
 *
 * ASSUMPTIONS:
 *
 * AUTHOR:
 *	Justin Quek
 * DATE:
 *	25-apr-03
 * LAST MODIFICATION:
 *    <modifier's name>  <date modified>
 */
module MUXn_4_1(mux_in0, mux_in1, mux_in2, mux_in3, mux_sel, mux_out);

  parameter MuxLen = 63;

  // outputs
  output [MuxLen:0] mux_out;
  // inputs
  input [MuxLen:0] mux_in0;
  input [MuxLen:0] mux_in1;
  input [MuxLen:0] mux_in2;
  input [MuxLen:0] mux_in3;
  input [1:0] mux_sel;

  // internal vars
  wire [MuxLen:0] mux_tmp0;
  wire [MuxLen:0] mux_tmp1;

  // assign vars

  // assing outputs

  // instantiate other modules
  MUXn_2_1 #(MuxLen) mux0(mux_in0, mux_in1, mux_sel[0], mux_tmp0);
  MUXn_2_1 #(MuxLen) mux1(mux_in2, mux_in3, mux_sel[0], mux_tmp1);
  MUXn_2_1 #(MuxLen) msel(mux_tmp0, mux_tmp1, mux_sel[1], mux_out);

  // code

endmodule // MUXn_4_1

/*
 * FUNC_NAME: MUXn_8_1
 *
 * DESCRIPTION: 
 *	Definition for a n-bit 8-to-1 MUX
 *
 * INPUT:
 *	mux_in0 - the input to be output if mux_sel is 000
 * mux_in1 - the input to be output if mux_sel is 001
 *	mux_in2 - the input to be output if mux_sel is 010
 *	mux_in3 - the input to be output if mux_sel is 011
 *	mux_in4 - the input to be output if mux_sel is 100
 *	mux_in5 - the input to be output if mux_sel is 101
 *	mux_in6 - the input to be output if mux_sel is 110
 *	mux_in7 - the input to be output if mux_sel is 111
 * 	mux_sel - chooses between the inputs
 *
 * OUTPUT:
 *	mux_out - the output of the mux
 *
 * ASSUMPTIONS:
 *
 * AUTHOR:
 *	Justin Quek
 * DATE:
 *	25-apr-03
 * LAST MODIFICATION:
 *    <modifier's name>  <date modified>
 */
module MUXn_8_1(mux_in0, mux_in1, mux_in2, mux_in3, mux_in4, mux_in5, mux_in6, mux_in7, mux_sel, mux_out);

  parameter MuxLen = 63;

  // outputs
  output [MuxLen:0] mux_out;
  // inputs
  input [MuxLen:0] mux_in0;
  input [MuxLen:0] mux_in1;
  input [MuxLen:0] mux_in2;
  input [MuxLen:0] mux_in3;
  input [MuxLen:0] mux_in4;
  input [MuxLen:0] mux_in5;
  input [MuxLen:0] mux_in6;
  input [MuxLen:0] mux_in7;
  input [2:0] mux_sel;

  // internal vars
  wire [MuxLen:0] mux_tmp0;
  wire [MuxLen:0] mux_tmp1;

  // assign vars

  // assing outputs

  // instantiate other modules
  MUXn_4_1 #(MuxLen) mux0(mux_in0, mux_in1, mux_in2, mux_in3, mux_sel[1:0], mux_tmp0);
  MUXn_4_1 #(MuxLen) mux1(mux_in4, mux_in5, mux_in6, mux_in7, mux_sel[1:0], mux_tmp1);
  MUXn_2_1 #(MuxLen) msel(mux_tmp0, mux_tmp1, mux_sel[2], mux_out);

  // code

endmodule // MUXn_8_1

