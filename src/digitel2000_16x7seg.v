
/* 16 oktaalidigitin näyttö johonkin User Extension-porttiin liitetylle
 * 16 digitin "Digitel 2000"-näytölle. By karttu 2012-08-17 - 2012-10-08.
 * Lisäparametrilla show_only_these voi mielivaltaisesti joidenkin digittien
 * näyttämisen estää kokonaan.
 * Kutsuva moduli antaa kellon, sekä erillisen refresh-signaalin, jonka
 * tilan vaihtuessa multipleksoidaan seuraava digitti.
 */

module digitel2000_16x7seg(input CLK,
                           output [7:0] extseg_out,
                           output [15:0] extdigit_out,
                           input refresh,
                           input [2:0] dig0,
                           input [2:0] dig1,
                           input [2:0] dig2,
                           input [2:0] dig3,
                           input [2:0] dig4,
                           input [2:0] dig5,
                           input [2:0] dig6,
                           input [2:0] dig7,
                           input [2:0] dig8,
                           input [2:0] dig9,
                           input [2:0] dig10,
                           input [2:0] dig11,
                           input [2:0] dig12,
                           input [2:0] dig13,
                           input [2:0] dig14,
                           input [2:0] dig15,
                           input [15:0] decimal_points,
                           input [15:0] show_only_these);



wire [3:0] nybble [15:0];

assign nybble[0] = dig0;
assign nybble[1] = dig1;
assign nybble[2] = dig2;
assign nybble[3] = dig3;
assign nybble[4] = dig4;
assign nybble[5] = dig5;
assign nybble[6] = dig6;
assign nybble[7] = dig7;
assign nybble[8] = dig8;
assign nybble[9] = dig9;
assign nybble[10] = dig10;
assign nybble[11] = dig11;
assign nybble[12] = dig12;
assign nybble[13] = dig13;
assign nybble[14] = dig14;
assign nybble[15] = dig15;


function [6:0] HEX2LED;
  input [3:0] HEX;

  begin
     case (HEX)
	4'b0001 : HEX2LED = 7'b0000110;	//1
	4'b0010 : HEX2LED = 7'b1011011;	//2
	4'b0011 : HEX2LED = 7'b1001111;	//3
	4'b0100 : HEX2LED = 7'b1100110;	//4
	4'b0101 : HEX2LED = 7'b1101101;	//5
	4'b0110 : HEX2LED = 7'b1111101;	//6
	4'b0111 : HEX2LED = 7'b0000111;	//7
	4'b1000 : HEX2LED = 7'b1111111;	//8
	4'b1001 : HEX2LED = 7'b1101111;	//9
	4'b1010 : HEX2LED = 7'b1110111;	//A
	4'b1011 : HEX2LED = 7'b1111100;	//b
	4'b1100 : HEX2LED = 7'b0111001;	//C
	4'b1101 : HEX2LED = 7'b1011110;	//d
	4'b1110 : HEX2LED = 7'b1111001;	//E
	4'b1111 : HEX2LED = 7'b1110001;	//F
	default : HEX2LED = 7'b0111111;	//0
     endcase
  end
endfunction


function [15:0] NYBBLE2HOTCODE;
  input [3:0] NYBBLE;

  begin
     case (NYBBLE)
	4'b0001  : NYBBLE2HOTCODE = 16'b0000000000000010;	//1
	4'b0010  : NYBBLE2HOTCODE = 16'b0000000000000100;	//2
	4'b0011  : NYBBLE2HOTCODE = 16'b0000000000001000;	//3
	4'b0100  : NYBBLE2HOTCODE = 16'b0000000000010000;	//4
	4'b0101  : NYBBLE2HOTCODE = 16'b0000000000100000;	//5
	4'b0110  : NYBBLE2HOTCODE = 16'b0000000001000000;	//6
	4'b0111  : NYBBLE2HOTCODE = 16'b0000000010000000;	//7
        4'b1000  : NYBBLE2HOTCODE = 16'b0000000100000000;       //8
        4'b1001  : NYBBLE2HOTCODE = 16'b0000001000000000;       //9
        4'b1010  : NYBBLE2HOTCODE = 16'b0000010000000000;	//10
        4'b1011  : NYBBLE2HOTCODE = 16'b0000100000000000;	//11
        4'b1100  : NYBBLE2HOTCODE = 16'b0001000000000000;       //12
        4'b1101  : NYBBLE2HOTCODE = 16'b0010000000000000;       //13
        4'b1110  : NYBBLE2HOTCODE = 16'b0100000000000000;       //14
        4'b1111  : NYBBLE2HOTCODE = 16'b1000000000000000;       //15
	default  : NYBBLE2HOTCODE = 16'b0000000000000001;	//0
     endcase
  end
endfunction

// 65536 / 50000000 = 0.00131072 sec. (1.3 ms)

reg old_refresh = 1'b0;
reg [3:0] which_digit = 4'b0000;

// reg [7:0] buffered_segments = 8'b0;
// assign extseg_out[7:0] = buffered_segments[7:0];

assign extseg_out = {decimal_points[which_digit],HEX2LED(nybble[which_digit])};

assign extdigit_out = (show_only_these[which_digit]
                           ? ~NYBBLE2HOTCODE(which_digit)
                           : 16'b1111111111111111); // Show nothing!


always @(posedge CLK)
  begin
    if(refresh != old_refresh)
      begin
         old_refresh <= refresh;
         which_digit <= which_digit+1;
      end
  end
  

endmodule
