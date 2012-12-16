/*

Created with (works for example in MIT/GNU Scheme, Version 9):
  (load "gen_incfex.scm")
  (load-option 'format)
  (create-incfex-module 7 "inc7fex.v")

Copyright (C) 2010-2012 Antti Karttunen, subject to the terms of the GPL v2.

 */

module inc7fex(input in_f1,
                input [1:0] in_f2,
                input [1:0] in_f3,
                input [2:0] in_f4,
                input [2:0] in_f5,
                input [2:0] in_f6,
                input [2:0] in_f7,
                output out_f1,
                output [1:0] out_f2,
                output [1:0] out_f3,
                output [2:0] out_f4,
                output [2:0] out_f5,
                output [2:0] out_f6,
                output [2:0] out_f7);

wire wrap1 = in_f1;
wire wrap2 = (wrap1 && (2 == in_f2));
wire wrap3 = (wrap2 && (3 == in_f3));
wire wrap4 = (wrap3 && (4 == in_f4));
wire wrap5 = (wrap4 && (5 == in_f5));
wire wrap6 = (wrap5 && (6 == in_f6));


assign out_f1 = ~in_f1;
assign out_f2 = (wrap1 ? (wrap2 ? 0 : in_f2+1) : in_f2);
assign out_f3 = (wrap2 ? in_f3+1 : in_f3);
assign out_f4 = (wrap3 ? (wrap4 ? 0 : in_f4+1) : in_f4);
assign out_f5 = (wrap4 ? (wrap5 ? 0 : in_f5+1) : in_f5);
assign out_f6 = (wrap5 ? (wrap6 ? 0 : in_f6+1) : in_f6);
assign out_f7 = (wrap6 ? in_f7+1 : in_f7);

endmodule
