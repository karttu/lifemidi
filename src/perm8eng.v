
/* Module perm8eng: Coded manually by Antti Karttunen, April 7 2010,
   based on the eralier perm17eng.v module coded October 1, 2007.
   This module combines the modules inc7fexb and fex7perm

   The synchronous input signal reset_fex_to_inputs has priority
   over the synchronous input signal nxt.
   With reset_fex_to_inputs=1, the internal registers containing
   the running factorial expansion are reset to values given
   in input signals if1-if7.
   The output permutation in op0-op7 will reflect this fact after
   one clock cycle.

   With reset_fex_to_inputs=0, but nxt=1, the factorial expansion
   contained in internal registers f1-f7 is incremented by one.
   The output permutation in op0-op7 will reflect this
   fact after one clock cycle.

   Change 2012-10-08: Added the output wires for the digits of fact expansion
                      so that we can print also that out.

   2012-12-16: Corrected the documentation above.
 */

module  perm8eng(input CLK,
                 input reset_fex_to_inputs,
                 input nxt,
                 input if1,
                 input [1:0] if2,
                 input [1:0] if3,
                 input [2:0] if4,
                 input [2:0] if5,
                 input [2:0] if6,
                 input [2:0] if7,
                 output of1,
                 output [1:0] of2,
                 output [1:0] of3,
                 output [2:0] of4,
                 output [2:0] of5,
                 output [2:0] of6,
                 output [2:0] of7,
                 output [2:0] op0,
                 output [2:0] op1,
                 output [2:0] op2,
                 output [2:0] op3,
                 output [2:0] op4,
                 output [2:0] op5,
                 output [2:0] op6,
                 output [2:0] op7);




// Registers for 7-digit factorial expansion, from 0000000 to 7654321

reg f1 = 0;         // 0-1
reg [1:0]  f2 = 0;  // 0-2
reg [1:0]  f3 = 0;  // 0-3
reg [2:0]  f4 = 0;  // 0-4
reg [2:0]  f5 = 0;  // 0-5
reg [2:0]  f6 = 0;  // 0-6
reg [2:0]  f7 = 0;  // 0-7

assign of1 = f1;
assign of2 = f2;
assign of3 = f3;
assign of4 = f4;
assign of5 = f5;
assign of6 = f6;
assign of7 = f7;

// Wires out of the factorial expansion incrementer:
wire g1;
wire [1:0]  g2;
wire [1:0]  g3;
wire [2:0]  g4;
wire [2:0]  g5;
wire [2:0]  g6;
wire [2:0]  g7;


inc7fex  INCFEX(f1,f2,f3,f4,f5,f6,f7,
                 g1,g2,g3,g4,g5,g6,g7);

fex7perm FEXPERM(f1,f2,f3,f4,f5,f6,f7,
                 op0,op1,op2,op3,op4,op5,op6,op7);


always @(posedge CLK)
  begin
   if(reset_fex_to_inputs) // Time to do some reseting.
    begin // Initialize the factorial expansion. Fex valid on the next cycle.
      f1 <= if1;
      f2 <= if2;
      f3 <= if3;
      f4 <= if4;
      f5 <= if5;
      f6 <= if6;
      f7 <= if7;
    end
   else if(nxt)
    begin // Transfer the incremented fex-digits back to f's:
      f1 <= g1;
      f2 <= g2;
      f3 <= g3;
      f4 <= g4;
      f5 <= g5;
      f6 <= g6;
      f7 <= g7;
    end
  end

endmodule

