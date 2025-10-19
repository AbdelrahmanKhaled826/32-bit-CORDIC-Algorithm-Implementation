`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Abdelrahman Khaled
// Create Date: 10/05/2025 04:06:12 AM
// Module Name: cordic
/* Description: cordicStep - performs one CORDIC microrotation
   ports:
   ip==>    i_cordic_clk  : clock of the system.
            i_cordic_rst_n: active low reset.
            i_cordic_mode:   0--> selects vector   mode to calculate magnitude and angle of vector. 
                             1--> selects rotation mode to calculate sine and cose of theta.
                             2--> selects rotation mode to calculate new point (x,y) after rotation Counterclockwise.
                             3--> selects rotation mode to calculate new point (x,y) after rotation clockwise.
           
             
           i_cordic_x    : real component input      (used in vector mode  )
           i_cordic_y   : imaginary component input (used in vector mode  )
          
           i_cordic_theta: angle input as a redian  (used in rotation mode)


 op==>     o_codic_out1 : magnitude of vector       (used in vector mode  )     -- mode 0
           o_codic_out2: angle of vector            (used in vector mode  )     -- mode 0
 
            o_codic_out2 : result of sin angle      (used in rotation mode)     --mode 1
            o_codic_out1 : result of cos angle      (used in rotation mode)     --mode 1

            o_codic_out1: new x after rotation     (used in rotation mode)     -- mode 2 ,3 
            o_codic_out2: new y after rotation     (used in rotation mode)     -- mode 2 ,3
 
 
           x_eq_list(i+1) = x_eq_list(i) + (ai*y_eq_list(i)*(2^-(i-1)));
           y_eq_list(i+1) = y_eq_list(i) - (ai*x_eq_list(i)*(2^-(i-1)));
           z_eq_list(i+1) = z_eq_list(i) + (ai*atan(2^-(i-1)));

*/
//////////////////////////////////////////////////////////////////////////////////

module cordic#(
parameter ITERATION       =13,
parameter WORD_LENGTH     =32,
parameter FRACTION_LENGTH =22,
parameter MUL_LENGTH      =64
)(

input                                 i_cordic_clk    ,
input                                 i_cordic_rst_n  ,
input               [1:0]             i_cordic_mode   ,

input       signed  [WORD_LENGTH-1:0] i_cordic_x      ,
input       signed  [WORD_LENGTH-1:0] i_cordic_y      ,
input       signed  [WORD_LENGTH-1:0] i_cordic_theta  ,

output  reg signed  [WORD_LENGTH-1:0] o_codic_out1    , 
output  reg signed  [WORD_LENGTH-1:0] o_codic_out2    

);


/*=================================================================
parameter to store the values of  scaling factore =0.6073 in 13 iteration*/
//localparam  [31:0] K = 32'b0_000000000_1001101101110100111011; 

/*=================================================================
parameter to store the values of  90,180,270,360 redian in fixed point. */
localparam signed [31:0] theta_90_in_redian     = 32'b0_000000001_1001001000011111101101; // 90  = 1.5708
localparam signed [31:0] theta_180_in_redian    = 32'b0_000000011_0010010000111111011011; // 180 = 3.1416
localparam signed [31:0] theta_270_in_redian    = 32'b0_000000100_1011011001011111001000; // 270 = 4.7124
localparam signed [31:0] theta_360_in_redian    = 32'b0_000000110_0100100001111110110101; // 360 = 6.2832

/*=================================================================
used to handel the angle to work in first and fourth quarter*/
wire   signal_cordic_d; 

/*=================================================================
signals used to handle the values of x,y,theta for first iteration*/
wire signed [WORD_LENGTH-1:0] signal_cordic_x_at_begin ;
wire signed [WORD_LENGTH-1:0] signal_cordic_y_at_begin ;
reg  signed [WORD_LENGTH-1:0] signal_cordic_z_at_begin ;


/*=================================================================
reg used to know the sign of the output angle*/

reg  signed [1:0] signal_cordic_sign_cose ;
reg  signed [1:0] signal_cordic_sign_sine ;

/*=================================================================
signals used to handle the values of x,y,theta in pipline*/
//wire signed [WORD_LENGTH-1:0] signal_cordic_pip_x [0:ITERATION-1],signal_cordic_shift_x [0:ITERATION] ;
//wire signed [WORD_LENGTH-1:0] signal_cordic_pip_y [0:ITERATION-1],signal_cordic_shift_y [0:ITERATION];
//wire signed [WORD_LENGTH-1:0] signal_cordic_pip_z [0:ITERATION-1],signal_cordic_shift_z [0:ITERATION];
wire signed [WORD_LENGTH-1:0] signal_cordic_shift_x [0:ITERATION];
wire signed [WORD_LENGTH-1:0] signal_cordic_shift_y [0:ITERATION];
wire signed [WORD_LENGTH-1:0] signal_cordic_shift_z [0:ITERATION];



/*=================================================================
signals used to handle the values of output atan , sin ,cos*/
reg signed [WORD_LENGTH-1:0] signal_cordic_output_atan_reg;
reg signed [WORD_LENGTH-1:0] signal_cordic_output_sine_reg; 
reg signed [WORD_LENGTH-1:0] signal_cordic_output_cose_reg;

//=================================================================

wire signed [MUL_LENGTH-1 :0] signal_cordic_mul_k_x; 
reg  signed [WORD_LENGTH-1:0] signal_cordic_input_k_x;

wire signed [MUL_LENGTH-1 :0] signal_cordic_mul_k_y;  
reg  signed [WORD_LENGTH-1:0] signal_cordic_input_k_y; 



/*=================================================================
store the values of inverse tan in rom*/

(* rom_style = "block" *)
reg signed  [WORD_LENGTH-1:0]  atan_lut [0:ITERATION-1] ;


initial
   begin
    $readmemb("atan_list.txt",atan_lut);   
   end

/*=================================================================
 store the values of shift in rom*/
(* rom_style = "block" *)
reg   [3:0]  shift_lut [0:ITERATION] ;      

initial
   begin
    $readmemb("shift_value.txt",shift_lut);   
   end



/*===========================handel inputs==========================*/

//handle initial values of input x,y 
assign signal_cordic_d          = (!i_cordic_mode && i_cordic_x[31] )? i_cordic_y [31]:1'b0;
assign signal_cordic_x_at_begin = (!i_cordic_mode && i_cordic_x[31] )? (~i_cordic_x + 1'b1) : i_cordic_x ;
assign signal_cordic_y_at_begin = i_cordic_y ;

//handle initial values of input angle  
always @(*)begin
    case (i_cordic_mode)
        2'b00  :begin
            signal_cordic_z_at_begin = 'b0; 
            signal_cordic_sign_cose  = 2'b00;
            signal_cordic_sign_sine  = 2'b00;
        end
        default: begin
            if(i_cordic_theta <= theta_90_in_redian)begin           
                signal_cordic_z_at_begin = i_cordic_theta ;
                signal_cordic_sign_cose  = 2'b01;
                signal_cordic_sign_sine  = 2'b01;
            end
            else if (i_cordic_theta <= theta_180_in_redian)begin   
                signal_cordic_z_at_begin = theta_180_in_redian - i_cordic_theta ;
                signal_cordic_sign_cose  = 2'b11;
                signal_cordic_sign_sine  = 2'b01;
            end
            else if (i_cordic_theta < theta_270_in_redian)begin
                signal_cordic_z_at_begin = i_cordic_theta - theta_180_in_redian ;
                signal_cordic_sign_cose  = 2'b11;
                signal_cordic_sign_sine  = 2'b11;
            end 
            else begin
                signal_cordic_z_at_begin = theta_360_in_redian - i_cordic_theta ;
                signal_cordic_sign_cose  = 2'b01;
                signal_cordic_sign_sine  = 2'b11;
            end
        end
    endcase
end


assign signal_cordic_shift_x[0] = signal_cordic_x_at_begin;
assign signal_cordic_shift_y[0] = signal_cordic_y_at_begin;
assign signal_cordic_shift_z[0] = signal_cordic_z_at_begin;




//============================================piplined=================================================


genvar i;
generate
    for(i=0;i<ITERATION;i=i+1) begin : CORDIC_PIPE        
       /* cordic_stage u_cordic_stage
        (
        .i_cordic_stage_rst_n      (i_cordic_rst_n)         , 
        .i_cordic_stage_shift_value(shift_lut[i])            ,  
        .i_cordic_stage_mode       (i_cordic_mode)          ,       
        .i_cordic_stage_x          (signal_cordic_shift_x[i]),  
        .i_cordic_stage_y          (signal_cordic_shift_y[i]),  
        .i_cordic_stage_z          (signal_cordic_shift_z[i]),  
        .i_cordic_stage_atan_value (atan_lut[i])            ,  
        .o_cordic_stage_x_eq_list  (signal_cordic_pip_x[i])    ,  
        .o_cordic_stage_y_eq_list  (signal_cordic_pip_y[i])    ,
        .o_cordic_stage_z_eq_list  (signal_cordic_pip_z[i])
         );
         
        cordic_register u_cordic_register
        (
        .i_cordic_register_clk  (i_cordic_clk)          , 
        .i_cordic_register_rst_n(i_cordic_rst_n)        ,  
        .i_cordic_register_x    (signal_cordic_pip_x[i])   ,  
        .i_cordic_register_y    (signal_cordic_pip_y[i])   ,  
        .i_cordic_register_z    (signal_cordic_pip_z[i])   ,  
        .o_cordic_register_x_reg(signal_cordic_shift_x[i+1]) ,  
        .o_cordic_register_y_reg(signal_cordic_shift_y[i+1]) ,
        .o_cordic_register_z_reg(signal_cordic_shift_z[i+1])
         ); 
         */
         
         
         cordic_stage u_cordic_stage
                 (
                 .i_cordic_stage_clk        (i_cordic_clk)           ,
                 .i_cordic_stage_rst_n      (i_cordic_rst_n)         , 
                 .i_cordic_stage_shift_value(shift_lut[i])           ,  
                 .i_cordic_stage_mode       (i_cordic_mode)          ,       
                 .i_cordic_stage_x          (signal_cordic_shift_x[i]),  
                 .i_cordic_stage_y          (signal_cordic_shift_y[i]),  
                 .i_cordic_stage_z          (signal_cordic_shift_z[i]),  
                 .i_cordic_stage_atan_value (atan_lut[i])            ,  
                 .o_cordic_stage_x_eq_list  (signal_cordic_shift_x[i+1])    ,  
                 .o_cordic_stage_y_eq_list  (signal_cordic_shift_y[i+1])    ,
                 .o_cordic_stage_z_eq_list  (signal_cordic_shift_z[i+1])
                  );
         
         
    end
endgenerate





/*===========================handel outputs==========================*/

always @(*)begin
    o_codic_out1            =  'b0;
    o_codic_out2            =  'b0;
    signal_cordic_input_k_y =  'b0;
    signal_cordic_input_k_x =  'b0;
    case (i_cordic_mode)
        2'b00: begin
            if(i_cordic_x[31])begin
                if(signal_cordic_d)begin //d=-1:y<0
                    signal_cordic_output_atan_reg =(~signal_cordic_shift_z[13]) + 1'b1 +(~theta_180_in_redian) + 1'b1;
                end
                else begin //d=0 : y>0
                    signal_cordic_output_atan_reg =theta_180_in_redian + (~signal_cordic_shift_z[13]) + 1'b1;
                end
            end 
            else begin
                    signal_cordic_output_atan_reg = signal_cordic_shift_z[13];
            end
            signal_cordic_input_k_x = signal_cordic_shift_x[13] ; 
            //    instead of display 64 bits(44 fraction). i will display only 32bit(1signed+9real+22fraction) 
            o_codic_out1   = {signal_cordic_mul_k_x[63],signal_cordic_mul_k_x[52:22]};
            o_codic_out2   =  signal_cordic_output_atan_reg;    
        end
        2'b01: begin
            signal_cordic_input_k_x = signal_cordic_shift_x[13] ;
            signal_cordic_input_k_y = signal_cordic_shift_y[13] ;
            //    instead of display 64 bits(44 fraction). i will display only 32bit(1signed+9real+22fraction) 
            o_codic_out1   = {signal_cordic_mul_k_x[63],signal_cordic_mul_k_x[52:22]};//signal_cordic_mul_k_x ;
            o_codic_out2   = {signal_cordic_mul_k_y[63],signal_cordic_mul_k_y[52:22]};//signal_cordic_mul_k_y;
        end
        2'b10,
        2'b11: begin
            signal_cordic_input_k_x = signal_cordic_shift_x[13] ;
            signal_cordic_input_k_y = signal_cordic_shift_y[13] ;
            //    instead of display 64 bits(44 fraction). i will display only 32bit(1signed+9real+22fraction) 
            o_codic_out1 =  {signal_cordic_mul_k_x[63],signal_cordic_mul_k_x[52:22]};//signal_cordic_mul_k_x ;
            o_codic_out2 =  {signal_cordic_mul_k_y[63],signal_cordic_mul_k_y[52:22]};//signal_cordic_mul_k_y;                                                                                               
        end
        default:begin
           o_codic_out1 = 'b0;
           o_codic_out2 = 'b0;        
        end
    endcase

end



cordic_fixed_multiplier U_x_cordic_fixed_multiplier(
.i_cordic_fixed_multiplier(signal_cordic_input_k_x),
.i_signed(signal_cordic_sign_cose),
.o_cordic_fixed_multiplier(signal_cordic_mul_k_x)
    );
 
cordic_fixed_multiplier U_y_cordic_fixed_multiplier(
    .i_cordic_fixed_multiplier(signal_cordic_input_k_y),
    .i_signed(signal_cordic_sign_sine),
    .o_cordic_fixed_multiplier(signal_cordic_mul_k_y)
        );





endmodule
