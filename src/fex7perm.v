/*

Created with (works for example in MIT/GNU Scheme, Version 9):
  (load "gen_fexperm.scm")
  (load-option 'format) ;; Needed in MIT/GNU Scheme.
  (create-fexperm-module 7 "fex7perm.v" #f)

Copyright (C) 2010-2012 Antti Karttunen, subject to the terms of the GPL v2.

 */
module fex7perm(input f1,
                 input [1:0] f2,
                 input [1:0] f3,
                 input [2:0] f4,
                 input [2:0] f5,
                 input [2:0] f6,
                 input [2:0] f7,
                 output [2:0] d0,
                 output [2:0] d1,
                 output [2:0] d2,
                 output [2:0] d3,
                 output [2:0] d4,
                 output [2:0] d5,
                 output [2:0] d6,
                 output [2:0] d7);

parameter w = 2;

parameter [w:0] lev0_0 = 0;
parameter [w:0] lev0_1 = 1;
parameter [w:0] lev0_2 = 2;
parameter [w:0] lev0_3 = 3;
parameter [w:0] lev0_4 = 4;
parameter [w:0] lev0_5 = 5;
parameter [w:0] lev0_6 = 6;
parameter [w:0] lev0_7 = 7;


wire [w:0] lev1_0 = (1 == f1 ? lev0_1 : lev0_0);
wire [w:0] lev1_1 = (1 == f1 ? lev0_0 : lev0_1);

wire [w:0] lev2_0 = (2 == f2 ? lev0_2 : lev1_0);
wire [w:0] lev2_1 = (1 == f2 ? lev0_2 : lev1_1);
wire [w:0] lev2_2 = (2 == f2 ? lev1_0 : (1 == f2 ? lev1_1 : lev0_2));

wire [w:0] lev3_0 = (3 == f3 ? lev0_3 : lev2_0);
wire [w:0] lev3_1 = (2 == f3 ? lev0_3 : lev2_1);
wire [w:0] lev3_2 = (1 == f3 ? lev0_3 : lev2_2);
wire [w:0] lev3_3 = (3 == f3 ? lev2_0 : (2 == f3 ? lev2_1 : (1 == f3 ? lev2_2 : lev0_3)));

wire [w:0] lev4_0 = (4 == f4 ? lev0_4 : lev3_0);
wire [w:0] lev4_1 = (3 == f4 ? lev0_4 : lev3_1);
wire [w:0] lev4_2 = (2 == f4 ? lev0_4 : lev3_2);
wire [w:0] lev4_3 = (1 == f4 ? lev0_4 : lev3_3);
wire [w:0] lev4_4 = (4 == f4 ? lev3_0 : (3 == f4 ? lev3_1 : (2 == f4 ? lev3_2 : (1 == f4 ? lev3_3 : lev0_4))));

wire [w:0] lev5_0 = (5 == f5 ? lev0_5 : lev4_0);
wire [w:0] lev5_1 = (4 == f5 ? lev0_5 : lev4_1);
wire [w:0] lev5_2 = (3 == f5 ? lev0_5 : lev4_2);
wire [w:0] lev5_3 = (2 == f5 ? lev0_5 : lev4_3);
wire [w:0] lev5_4 = (1 == f5 ? lev0_5 : lev4_4);
wire [w:0] lev5_5 = (5 == f5 ? lev4_0 : (4 == f5 ? lev4_1 : (3 == f5 ? lev4_2 : (2 == f5 ? lev4_3 : (1 == f5 ? lev4_4 : lev0_5)))));

wire [w:0] lev6_0 = (6 == f6 ? lev0_6 : lev5_0);
wire [w:0] lev6_1 = (5 == f6 ? lev0_6 : lev5_1);
wire [w:0] lev6_2 = (4 == f6 ? lev0_6 : lev5_2);
wire [w:0] lev6_3 = (3 == f6 ? lev0_6 : lev5_3);
wire [w:0] lev6_4 = (2 == f6 ? lev0_6 : lev5_4);
wire [w:0] lev6_5 = (1 == f6 ? lev0_6 : lev5_5);
wire [w:0] lev6_6 = (6 == f6 ? lev5_0 : (5 == f6 ? lev5_1 : (4 == f6 ? lev5_2 : (3 == f6 ? lev5_3 : (2 == f6 ? lev5_4 : (1 == f6 ? lev5_5 : lev0_6))))));

wire [w:0] lev7_0 = (7 == f7 ? lev0_7 : lev6_0);
wire [w:0] lev7_1 = (6 == f7 ? lev0_7 : lev6_1);
wire [w:0] lev7_2 = (5 == f7 ? lev0_7 : lev6_2);
wire [w:0] lev7_3 = (4 == f7 ? lev0_7 : lev6_3);
wire [w:0] lev7_4 = (3 == f7 ? lev0_7 : lev6_4);
wire [w:0] lev7_5 = (2 == f7 ? lev0_7 : lev6_5);
wire [w:0] lev7_6 = (1 == f7 ? lev0_7 : lev6_6);
wire [w:0] lev7_7 = (7 == f7 ? lev6_0 : (6 == f7 ? lev6_1 : (5 == f7 ? lev6_2 : (4 == f7 ? lev6_3 : (3 == f7 ? lev6_4 : (2 == f7 ? lev6_5 : (1 == f7 ? lev6_6 : lev0_7)))))));


assign d0 = lev7_0;
assign d1 = lev7_1;
assign d2 = lev7_2;
assign d3 = lev7_3;
assign d4 = lev7_4;
assign d5 = lev7_5;
assign d6 = lev7_6;
assign d7 = lev7_7;

endmodule
