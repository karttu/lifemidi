


module mefi8x8a(input CLK,
                input [7:0] BCOL_IN,
                output [7:0] BCOL_OUT,
                output [7:0] BROW,
                input [7:0] LEDS2LIT0,
                input [7:0] LEDS2LIT1,
                input [7:0] LEDS2LIT2,
                input [7:0] LEDS2LIT3,
                input [7:0] LEDS2LIT4,
                input [7:0] LEDS2LIT5,
                input [7:0] LEDS2LIT6,
                input [7:0] LEDS2LIT7,
                output [7:0] PIECES0,
                output [7:0] PIECES1,
                output [7:0] PIECES2,
                output [7:0] PIECES3,
                output [7:0] PIECES4,
                output [7:0] PIECES5,
                output [7:0] PIECES6,
                output [7:0] PIECES7
               );

reg [7:0] R_PIECES0 = 8'b10000010;
reg [7:0] R_PIECES1 = 8'b10001010;
reg [7:0] R_PIECES2 = 8'b10010010;
reg [7:0] R_PIECES3 = 8'b10011010;
reg [7:0] R_PIECES4 = 8'b10100010;
reg [7:0] R_PIECES5 = 8'b10101010;
reg [7:0] R_PIECES6 = 8'b10110010;
reg [7:0] R_PIECES7 = 8'b10111010;

assign PIECES0 = R_PIECES0;
assign PIECES1 = R_PIECES1;
assign PIECES2 = R_PIECES2;
assign PIECES3 = R_PIECES3;
assign PIECES4 = R_PIECES4;
assign PIECES5 = R_PIECES5;
assign PIECES6 = R_PIECES6;
assign PIECES7 = R_PIECES7;

reg [7:0] BCOL_IN_S = 8'b0;

// Note that sel_row and row_ind should be "in sync".

// The multiplexed row, one-hot in 8-bit shift register:
reg [7:0] sel_row = 8'b10000000;

// 50 MHz/50Hz = 1 million ~= 2^20
parameter msb = 15; // Use 26; for a little over second.
reg [msb+3:0] whole_cycle = 0;
parameter kuuw = 3;
wire [kuuw:0] kuu = whole_cycle[msb:msb-kuuw];
wire [2:0] row_ind = whole_cycle[msb+3:msb+1];

wire [msb:0] row_period = whole_cycle[msb:0];

// We turn the 1/8th time the row signals completely off
// (after switch from one row to next), so that we don't
// get dim, but superfluous "pre-" and "afterglows" below and
// on the top of each LED that should glow.
// (This because the slowness of the optoisolators
//  in the interface module).

assign BROW = (((~|kuu) || &kuu) ? 8'b00000000 : sel_row);

assign BCOL_OUT = (0 == row_ind ? LEDS2LIT0 :
                   1 == row_ind ? LEDS2LIT1 :
                   2 == row_ind ? LEDS2LIT2 :
                   3 == row_ind ? LEDS2LIT3 :
                   4 == row_ind ? LEDS2LIT4 :
                   5 == row_ind ? LEDS2LIT5 :
                   6 == row_ind ? LEDS2LIT6 : LEDS2LIT7);

always @(posedge CLK)
  begin
   whole_cycle <= whole_cycle+1; // Wraps around, eventually.
   if(0 == row_period) // Time to switch to the next row?
     sel_row <= {sel_row[6],sel_row[5],sel_row[4],sel_row[3],sel_row[2],sel_row[1],sel_row[0],sel_row[7]};

   BCOL_IN_S  <= BCOL_IN; // Synchronized input.
   if(0 != kuu)
    begin
     R_PIECES0 <= ((0 == row_ind) ? ~BCOL_IN_S : R_PIECES0);
     R_PIECES1 <= ((1 == row_ind) ? ~BCOL_IN_S : R_PIECES1);
     R_PIECES2 <= ((2 == row_ind) ? ~BCOL_IN_S : R_PIECES2);
     R_PIECES3 <= ((3 == row_ind) ? ~BCOL_IN_S : R_PIECES3);
     R_PIECES4 <= ((4 == row_ind) ? ~BCOL_IN_S : R_PIECES4);
     R_PIECES5 <= ((5 == row_ind) ? ~BCOL_IN_S : R_PIECES5);
     R_PIECES6 <= ((6 == row_ind) ? ~BCOL_IN_S : R_PIECES6);
     R_PIECES7 <= ((7 == row_ind) ? ~BCOL_IN_S : R_PIECES7);

//     case (row_ind)
//	3'b000  : R_PIECES0 <= ~BCOL_IN_S;
//	3'b001  : R_PIECES1 <= ~BCOL_IN_S;
//	3'b010  : R_PIECES2 <= ~BCOL_IN_S;
//	3'b011  : R_PIECES3 <= ~BCOL_IN_S;
//	3'b100  : R_PIECES4 <= ~BCOL_IN_S;
//	3'b101  : R_PIECES5 <= ~BCOL_IN_S;
//	3'b110  : R_PIECES6 <= ~BCOL_IN_S;
//	default : R_PIECES7 <= ~BCOL_IN_S;
//     endcase

    end

  end

endmodule
