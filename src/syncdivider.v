`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Helsinki Hacklab
// Engineer: karttu
// 
// Create Date:    11:32:59 03/26/2010 
// Design Name: 
// Module Name:    syncdivider 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: Divides the incoming sync_in signal with user-settable
//              divider (either 1, 2, 4 or 8), and allows the user
//              also set the offset (from 0 to 8, used modulo divider).
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
//
// Revision 0.02 - (2012-10-20): Added invert_sync_in possibility. Also available as an output-wire.
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module syncdivider(
    input CLK,
    input sync_in,   // Input sync signal, should stay up exactly one cycle.
    output sync_out, // Divided output sync signal, will stay up exactly one cycle.
    input pb_divby, // Preferably debounced, staying up exactly one FPGA-cycle.
    input pb_offset, // As well.
    output [3:0] divby, // For displaying on 7-SEG display.
    output [3:0] sel_offset, // As well.
    output invert_sync_in
    );

function [7:0] rol8bits;
  input [7:0] b;
  rol8bits = {b[6],b[5],b[4],b[3],b[2],b[1],b[0]};
endfunction

function [2:0] choose_n_lsbs;
  input [2:0] b;
  input [1:0] n;
  begin
   case(n)
    2'b00: choose_n_lsbs = {3'b000};
    2'b01: choose_n_lsbs = {2'b00,b[0]};
    2'b10: choose_n_lsbs = {1'b0,b[1:0]};
    2'b11: choose_n_lsbs = b[2:0];
   endcase
  end
endfunction

// if everynth = 00 --> take every sync
//             = 01 --> take every 2nd sync
//             = 10 --> take every 4th sync
//             = 11 --> take every 8th sync


reg [1:0] everynth = 2'b00;
reg [2:0] isyncs_since_last_osync = 3'b000;

reg [3:0] offset_and_invert_flag = 4'b0000;

assign invert_sync_in = offset_and_invert_flag[0];
wire [2:0] offset = offset_and_invert_flag[3:1];

wire sync_now = sync_in; // (sync_in ^ invert_sync_in);

assign divby = (1 << everynth);
assign sel_offset = offset;
// Too hard for Verilog:
// assign sync_out = (sync_now & ~|isyncs_since_last_osync[everynth:0]);

assign sync_out = (sync_now & (~|choose_n_lsbs(isyncs_since_last_osync,everynth)));

always @(posedge CLK)
  begin
   if(sync_now) isyncs_since_last_osync <= isyncs_since_last_osync+1;

   if(pb_divby)  everynth <= everynth+1; // Toggle frequency from 1/1 to 1/8.
   if(pb_offset) // Toggle invert_sync_in and increase offset circularly from 0 to 7.
    begin
     offset_and_invert_flag <= offset_and_invert_flag+1;
     if(invert_sync_in) isyncs_since_last_osync <= isyncs_since_last_osync-1;
    end
  end

endmodule
