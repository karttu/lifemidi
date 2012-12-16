module syncinp(CLK,sigIn,sigOut);

input CLK;
input sigIn;

output sigOut;
reg intSig = 0;
reg sigOut = 0;

always @(posedge CLK)
 begin
  intSig <= sigIn;
  sigOut <= intSig;
end

endmodule

