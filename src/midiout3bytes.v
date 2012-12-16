
// Module midiout3bytes by karttu, March 23 & 26 2010.
// Now copy the bytes to be sent to our local registers
// at the time module is raised with sendthem signal set to high.
// (Note that one should not raise it high again before at least four
// cycles has passed by.)

// Needs modules:
// raminfr.v, timescale.v, uart_defines.v, uart_tfifo.v and uart_transmitter.v
// from http://opencores.org/project,uart16550
//

module midiout3bytes(input CLK,
                     input RST,
                     input [7:0] ibyte1,
                     input [7:0] ibyte2,
                     input [7:0] ibyte3,
                     input sendthem,
                     output MIDIOUT
                    );

parameter ts_idle       = 2'b00;
parameter ts_send_byte1 = 2'b01;
parameter ts_send_byte2 = 2'b11;
parameter ts_send_byte3 = 2'b10;

reg [1:0] top_state = ts_idle;

reg [7:0] byte1 = 8'b00000000;
reg [7:0] byte2 = 8'b00000000;
reg [7:0] byte3 = 8'b00000000;

wire [7:0] outbyte = ((ts_send_byte1==top_state) ? byte1 : ((ts_send_byte2==top_state) ? byte2 : byte3));

wire send_byte_to_fifo = (top_state[0]|top_state[1]); // if top_state is not ts_idle

// Using open collector transistor at optoisolator card, needs to be inverted for MIDI:
wire inv_midiout;
assign MIDIOUT = ~inv_midiout;
reg enable_for_uart = 0;
wire tf_reset = RST;


// From http://en.wikipedia.org/wiki/MIDI_1.0

// It consists physically of a one-way (simplex) digital
// current loop serial communications electrical connection
// signaling at 31,250 bits per second.
// 8-N-1 format, i.e. one start bit (must be 0), eight data bits,
// no parity bit and one stop bit (must be 1), is used.


// We set UART_LC_DL, UART_LC_BC, UART_LC_SP, UART_LC_EP, UART_LC_PE and UART_LC_SB as zeros.
// We use 8 data bits, no parity, one stop bit. (8N1).
parameter UART_LCR_8N1 = 8'b00000011;

// FPGA is running at 50 MHz, 16 cycles per bit,
// so we divide it with 100, to get 31250 bps:
parameter dl = 12'b000001100100; // 100 * 16 * 31 250 = 50 000 000.

reg [11:0] dlc = 12'b000000000000;


uart_transmitter MIDISEND(.clk(CLK),
                           .wb_rst_i(RST),
                           .lcr(UART_LCR_8N1),
                           .tf_push(send_byte_to_fifo),
                           .wb_dat_i(outbyte),
                           .enable(enable_for_uart),
                           .stx_pad_o(inv_midiout),
                           .tstate(),   // This is an output signal.
                           .tf_count(), // As well. Neither is connected.
                           .tx_reset(tf_reset),
                           .lsr_mask(tf_reset)
                          );



always @(posedge CLK or posedge RST) 
begin
   if (RST)
     top_state  <= ts_idle;
   else
     case (top_state)

      ts_idle:
       begin
        top_state <= (sendthem ? ts_send_byte1 : ts_idle);
        if(sendthem)
         begin
// Make our own safe copies of the bytes to be sent:
          byte1 <= ibyte1;
          byte2 <= ibyte2;
          byte3 <= ibyte3;
         end
       end
      ts_send_byte1 : top_state <= ts_send_byte2;
      ts_send_byte2 : top_state <= ts_send_byte3;
      ts_send_byte3 : top_state <= ts_idle;

     endcase
end


// Frequency divider
always @(posedge CLK or posedge RST) 
begin
   if(RST)
    dlc <= dl - 1; // AK's addition.
   else if(~(|dlc))
    dlc <= #1 dl - 1; // preset counter
   else
    dlc <= #1 dlc - 1; // decrement counter
end

// Enable signal generation logic
always @(posedge CLK or posedge RST)
begin
   if(RST)
    enable_for_uart <= #1 1'b0;
   else if(|dl & ~(|dlc)) // dl>0 & dlc==0
    enable_for_uart <= #1 1'b1;
   else
    enable_for_uart <= #1 1'b0;
end

endmodule
