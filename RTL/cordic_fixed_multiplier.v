`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Abdelrahman Khaled
// Create Date: 10/09/2025 05:42:22 AM
// Module Name: cordic_fixed_multiplier
// Description: Multiplying by a constant can be rewritten as additions and shifts.
//K = 32'b0_000000000_1001101101110100111011
//K ? 2?¹ + 2?? + 2?? + 2?? + 2?? + 2?¹? + 2?¹¹ + 2?¹³ + 2?¹? + 2?¹? + 2?¹? + 2?²¹
//////////////////////////////////////////////////////////////////////////////////


module cordic_fixed_multiplier#(
parameter WORD_LENGTH =32,
parameter OUT_LENGTH  =64
)(

input  signed  [WORD_LENGTH-1:0]  i_cordic_fixed_multiplier,
input  signed  [1:0]              i_signed,
output signed  [OUT_LENGTH-1 :0]  o_cordic_fixed_multiplier
    );
 
wire signed  [OUT_LENGTH-1 :0]  signal_cordic_fixed_multiplier;


wire signed [WORD_LENGTH-1    :0]      mul1  ;
wire signed [WORD_LENGTH      :0]      mul2  ;
wire signed [WORD_LENGTH-1+3  :0]      mul3  ;
wire signed [WORD_LENGTH-1+4  :0]      mul4  ;
wire signed [WORD_LENGTH-1+5  :0]      mul5  ;
wire signed [WORD_LENGTH-1+8  :0]      mul6  ;
wire signed [WORD_LENGTH-1+10 :0]      mul7  ;
wire signed [WORD_LENGTH-1+11 :0]      mul8  ;
wire signed [WORD_LENGTH-1+12 :0]      mul9  ;
wire signed [WORD_LENGTH-1+14 :0]      mul10 ;
wire signed [WORD_LENGTH-1+15 :0]      mul11 ;
wire signed [WORD_LENGTH-1+17 :0]      mul12 ;
wire signed [WORD_LENGTH-1+18 :0]      mul13 ;
wire signed [WORD_LENGTH-1+21 :0]      mul14 ;

assign mul1  = i_cordic_fixed_multiplier;
assign mul2  = i_cordic_fixed_multiplier <<< 'd1    ;
assign mul3  = i_cordic_fixed_multiplier <<< 'd3    ;
assign mul4  = i_cordic_fixed_multiplier <<< 'd4    ;
assign mul5  = i_cordic_fixed_multiplier <<< 'd5    ;
assign mul6  = i_cordic_fixed_multiplier <<< 'd8    ;
assign mul7  = i_cordic_fixed_multiplier <<< 'd10   ;
assign mul8  = i_cordic_fixed_multiplier <<< 'd11   ;
assign mul9  = i_cordic_fixed_multiplier <<< 'd12   ;
assign mul10 = i_cordic_fixed_multiplier <<< 'd14   ;
assign mul11 = i_cordic_fixed_multiplier <<< 'd15   ;
assign mul12 = i_cordic_fixed_multiplier <<< 'd17   ;
assign mul13 = i_cordic_fixed_multiplier <<< 'd18   ;
assign mul14 = i_cordic_fixed_multiplier <<< 'd21   ;


assign signal_cordic_fixed_multiplier = mul1 +mul2 +mul3+mul4 + mul5 +mul6+ mul7+ mul8+ mul9+ mul10+mul11+ mul12+ mul13+mul14;
  
assign o_cordic_fixed_multiplier = (i_signed==2'b11)? (~signal_cordic_fixed_multiplier +1'b1) : signal_cordic_fixed_multiplier;
    
    
endmodule
