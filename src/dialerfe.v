
/* dialerfe.v - a module for reading digits of factorial expansion
                with Ericsson rotary dialer.
                By karttu, 2012-10-09 & 2012-10-10.

                Added debounced_pulses output-wire at 2012-10-20.
 */

module dialerfe(input CLK,
                input restart, // A kind of reset signal.
                input dialer_in_rest,
                input dialer_pulses, // Raw, bouncing!
                output all_digits_have_been_dialed,
                output [2:0] num_of_digits_dialed,
                output of1,
                output [1:0] of2,
                output [1:0] of3,
                output [2:0] of4,
                output [2:0] of5,
                output [2:0] of6,
                output [2:0] of7,
                output debounced_pulses);


reg [2:0] n_digits_dialed = 3'b000; // 0-7
assign num_of_digits_dialed = n_digits_dialed;

reg all_digits_dialed = 1'b1; // By default, we consider them all to have been.
// all_digits_dialed should in general stay up between dialings.

assign all_digits_have_been_dialed = all_digits_dialed;

reg deb_pulses = 1'b0;
assign debounced_pulses = deb_pulses;


parameter max_digits = 7;

parameter msb = 27;
// 2**27 x 20 ns  = 134217728 x 20 ns = 2.684 seconds.
// 2**28 x 20 ns  = 268435456 x 20 ns = 5.3687 seconds.

reg [msb:0] cycles_in_rest = 0;

// Something between 10 to 20 pulses per second. (from 50 to 100 ms).

// 2^21 x 20 ns = 2097152 x 20 ns = 41943040 ns = ~ 42 ms. (~ 1/24 s).
// 2^22 x 20 ns = 4194304 x 20 ns = 83886080 ns = ~ 84 ms. (~ 1/12 s).
parameter msb_pulses = 22;
parameter delay_between_pulses = 19;
reg [msb_pulses:0] cycles_since_last_pulse = 0;

// If some bits in the top bits of the counter have had time to set to ones,
// then it's probably a real pulse, not just bouncing:
wire is_real_pulse = |cycles_since_last_pulse[msb_pulses:delay_between_pulses];


// Registers for 7-digit factorial expansion, from 0000000 to 7654321

reg [2:0] fdigs [6:0];

assign of1 = fdigs[0][0];
assign of2 = fdigs[1][1:0];
assign of3 = fdigs[2][1:0];
assign of4 = fdigs[3];
assign of5 = fdigs[4];
assign of6 = fdigs[5];
assign of7 = fdigs[6];

reg prev_dialer_in_rest = 1'b1;

wire synced_pulses;

debounced_button DEB_RESTSIGNAL(CLK,dialer_in_rest,deb_dialer_in_rest);
syncinp SYNC_PULSES(CLK,dialer_pulses,synced_pulses);

integer i; // A "compile-time" index for the for loop.

always @(posedge CLK)
  begin
   prev_dialer_in_rest <= deb_dialer_in_rest;

   if(restart)
// This signal usually rises for one cycle when the user has stopped dialing.
     begin
      n_digits_dialed <= 0;
      for(i=0; i<max_digits; i=i+1) fdigs[i] <= 0;
     end
 
   if(deb_dialer_in_rest)
     begin
      if(~prev_dialer_in_rest) // When sets to the rest.
       begin
         n_digits_dialed <= n_digits_dialed+1;
         deb_pulses <= 0;
       end
     end
   else // dialer in use.
     begin
      if(prev_dialer_in_rest) // When user starts dialing.
       begin                  // the next digit.
         fdigs[n_digits_dialed] <= 0; // Start counting the pulses from zero.
         cycles_since_last_pulse <= 0; // And zero the debouncing ctr.
       end
     
      if(synced_pulses)
       begin
         cycles_since_last_pulse <= 0;
         if(is_real_pulse)
          begin
           deb_pulses <= 1;
// The nth factorial digit from right (here: n_digits_dialed is zero-based) may
// legally contain digits in range 0 - n_digits_dialed+1:
           if(fdigs[n_digits_dialed] > n_digits_dialed)
             fdigs[n_digits_dialed] <= 0;
           else
             fdigs[n_digits_dialed] <= fdigs[n_digits_dialed]+1;
          end
       end // if (synced_pulses)
      else
       begin // This starts incrementing when pulse first went low:
         deb_pulses <= 0;
         cycles_since_last_pulse <= cycles_since_last_pulse+1;
       end
     end
  end // always @ (posedge CLK)

// This is for rising the all_digits_dialed signal after a time-out:
// (Note the similarity with the debouncing code!)
always @(posedge CLK)
  begin
   if(~deb_dialer_in_rest)
    begin
     all_digits_dialed <= 0;
     cycles_in_rest <= 1;
    end
   else if(max_digits == n_digits_dialed)
    begin
     all_digits_dialed <= 1;
     cycles_in_rest <= 0;
    end
   else if(cycles_in_rest)
    begin
     all_digits_dialed <= 0;
     cycles_in_rest <= cycles_in_rest + 1;
    end
   else // cycles_in_rest has wrapped over,
    begin // so the time out has finished.
     all_digits_dialed <= 1;
    end
  end

endmodule
