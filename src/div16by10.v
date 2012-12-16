/*
   This is a piece of behavioral (???, yuk) Verilog-code that I found
   years ago from the net. I'm not sure about its copyright-status.

   That is, this is modified from streamlined_divider
   presented at http://www.ece.lsu.edu/ee3755/2002/l07.html
   Based on Patterson & Hennessy, "Computer Organization & Design",
   Figure 4.41
   (The division hardware presented here is slower than hardware used
   in real processors.)

   See also:
http://groups.google.com/groups?hl=en&lr=&selm=3CB5BCD0.8F40D227%40mail.com

   This is easily replaced with a Verilog-module compiled from
   an appropriate Bream-source. See e.g.:
   https://github.com/karttu/bream/tree/master/testprojects/t_intdec1/Compiled_for_ATLYS

 */

module div16by10(clk,start,dividend,
                 quotient,remainder,ready);
   input         clk, start;
   input [15:0]  dividend;
   output        quotient,remainder;
   output        ready;

   reg [31:0]    qr;
   reg [16:0]    diff;

   parameter divider = 16'd10; // Divider is always ten.

//
//              0000 1011
//  """"""""|
//     1011 |   0001 0110     <- qr reg
// -0011    |  -0011          <- divider (never changes)
//  """"""""|           
//     1011 |   0010 110o     <- qr reg
//  -0011   |  -0011
//  """"""""|
//     1011 |   0101 10oo     <- qr reg
//   -0011  |  -0011
//  """"""""|   0010 1000     <- qr reg before shift
//     0101 |   0101 0ooi     <- after shift
//    -0011 |  -0011
//  """"""""|   0010 ooii
//       10 |   
//
// Quotient, 3 (0011); remainder 2 (10).

   
// wire [15:0]   remainder = qr[31:16];
   wire [3:0]    remainder = qr[19:16]; // Max. 4-bit remainder.
   wire [15:0]   quotient = qr[15:0];

   reg [4:0]     bit = 0;
   wire          ready = ~|bit; // ready goes up when all five bits are 0

   always @( posedge clk ) 

     if( start ) // Was: ( ready && start )
      begin

        bit = 16;
        qr = {16'd0,dividend};

      end
     else
      begin

        diff = qr[31:15] - {1'b0,divider};

        if( diff[16] )
          qr = {qr[30:0],1'd0};
        else
          qr = {diff[15:0],qr[14:0],1'd1};
        
        bit = bit - 1;

      end

endmodule
