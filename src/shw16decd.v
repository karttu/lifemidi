
/* shw16decd:  by karttu, Dec 9 2004.
              When the input signal NEWNUM goes high,
              grab the 16-bit binary number specified in NUM
              (divide it to digits), and then show those
              decimal digits in the 7-segment display.
              This "d-version" also shows extra four bits
              of information in the decimal points.
 */
module show16withdps(
         input CLK,
         input NEWNUM,
         input [15:0] NUM,
         input DP3,
         input DP2,
         input DP1,
         input DP0,
         output [7:0] SEG_OUT,
         output [3:0] DIGIT_OUT);

function [6:0] HEX2LED;
  input [3:0] HEX;

  begin
     case (HEX)
	4'b0001 : HEX2LED = 7'b1111001;	//1
	4'b0010 : HEX2LED = 7'b0100100;	//2
	4'b0011 : HEX2LED = 7'b0110000;	//3
	4'b0100 : HEX2LED = 7'b0011001;	//4
	4'b0101 : HEX2LED = 7'b0010010;	//5
	4'b0110 : HEX2LED = 7'b0000010;	//6
	4'b0111 : HEX2LED = 7'b1111000;	//7
	4'b1000 : HEX2LED = 7'b0000000;	//8
	4'b1001 : HEX2LED = 7'b0010000;	//9
	4'b1010 : HEX2LED = 7'b0001000;	//A
	4'b1011 : HEX2LED = 7'b0000011;	//b
	4'b1100 : HEX2LED = 7'b1000110;	//C
	4'b1101 : HEX2LED = 7'b0100001;	//d
	4'b1110 : HEX2LED = 7'b0000110;	//E
	4'b1111 : HEX2LED = 7'b0001110;	//F
	default : HEX2LED = 7'b1000000;	//0
     endcase
  end
endfunction

parameter [1:0] ST_DIVISION_START  = 2'b00;
parameter [1:0] ST_DIVIDING        = 2'b01;
parameter [1:0] ST_DIVISION_READY  = 2'b10;
parameter [1:0] ST_N_DIGITS_READY  = 2'b11;

reg [1:0] state = ST_DIVISION_START;

parameter MAXDIGITS = 4;

reg [15:0] n = 0; // Copied from NUM or new_n
wire [15:0] new_n; // Returned by digitgenerator when division is ready.
wire [3:0] digout; // Ditto.
reg [3:0] digits [MAXDIGITS-1:0]; // digits[j] is copied from digout.

// integer i; // A "compile-time" index to digits. (for the for loop).
reg [2:0] j = 0; // A "run-time" index to digits.
reg [2:0] n_digs_minus1 = 0;

wire [1:0] d = j[1:0]; // Index to the currently shown digit.

wire sig_division_ready;

parameter msb = 12;
reg [msb:0] delay_counter = 0;

// assign SEG_OUT[7] = 1'b1; // Don't light the dp.
assign SEG_OUT[7] = ~(0 == d ? DP0 : 1 == d ? DP1 : 2 == d ? DP2 : DP3);
assign SEG_OUT[6:0] = HEX2LED((2'b00 == d) ? digits[0] :
                              (2'b01 == d) ? digits[1] :
                              (2'b10 == d) ? digits[2] : digits[3]);

assign DIGIT_OUT =
 ((ST_N_DIGITS_READY == state) ? ((2'b00 == d) ? 4'b1110 :
                                  (2'b01 == d) ? 4'b1101 :
                                  (2'b10 == d) ? 4'b1011 : 4'b0111)
                               : 4'b1111); // Show nothing.

div16by10 DIGITGENERATOR(CLK,(ST_DIVIDING != state),
                         n,new_n,digout,sig_division_ready);


always @(posedge CLK or posedge NEWNUM)
  begin
    if(NEWNUM)
     begin
      n <= NUM;
      state <= ST_DIVISION_START;
      n_digs_minus1 <= 0;
      j <= 0;
     end
    else // It is the clock ticking.
     begin
      case(state)
        ST_DIVISION_START: // We stay one clock cycle here, thus giving
          state <= ST_DIVIDING; // the digitgenerator time to initialize.
        ST_DIVIDING:
          if(sig_division_ready)
           begin
            state <= ST_DIVISION_READY;
            n <= new_n;
// What I would like to synthesized here is a 2-to-4 line demultiplexer,
// so that 4-bits in digout are copied to one of the four digits
// depending on the value of j (00,01,10,11):
//          for(i=0; i<MAXDIGITS; i=i+1)
//           if(j == i) digits[i] <= digout; // Save the remainder.
            digits[d] <= digout;
           end
          else
            state <= ST_DIVIDING;
        ST_DIVISION_READY:
          if(0 == n) // No more digits?
           begin
            state <= ST_N_DIGITS_READY;
//          delay_counter <= 0; // Unnecessary.
            n_digs_minus1 <= j;
           end
          else // More digits to come.
           begin
            state <= ST_DIVISION_START;
            j <= j+1;
           end

        ST_N_DIGITS_READY: // Show them...
         begin
          if(~|(delay_counter)) // Time to show the next digit?
           j <= ((0 == j) ? n_digs_minus1 : j-1);
          delay_counter <= delay_counter+1; // Wraps around, eventually.
         end
      endcase
     end

  end

endmodule
