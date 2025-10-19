`timescale 1ns / 1ps


module cordic_fixed_multiplier_tb();


 reg  signed  [31:0]  i_cordic_fixed_multiplier;
 wire signed  [63 :0]  o_cordic_fixed_multiplier;



cordic_fixed_multiplier#(
.WORD_LENGTH(32)) u_cordic_fixed_multiplier
(
.i_cordic_fixed_multiplier(i_cordic_fixed_multiplier),
.o_cordic_fixed_multiplier(o_cordic_fixed_multiplier)
    );


initial begin
i_cordic_fixed_multiplier = 'b00000101000001100111101100110110 ;
#10
$display("%b",o_cordic_fixed_multiplier);
end





endmodule
