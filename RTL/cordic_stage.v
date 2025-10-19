`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: 
// Create Date: 10/06/2025 03:39:44 AM
// Module Name: cordic_stage
/* Description: 
=================================equetions in vector mode ==========================================
                if y_eq_list(i) >= 0
                    ai = 1;
                else
                    ai = -1;
                end
                
                x_eq_list(i+1) = x_eq_list(i) + (ai*y_eq_list(i)*(2^-(i-1)));
                y_eq_list(i+1) = y_eq_list(i) - (ai*x_eq_list(i)*(2^-(i-1)));
                z_eq_list(i+1) = z_eq_list(i) + (ai*atan(2^-(i-1)));
=============================equetions in rotation mode & rotation counterclkwise=========================
same as in vector mode but diffrence in sign of ai that will be deteremine by i_cordic_stage_z not i_cordic_stage_y
            if z_eq_list(i) >= 0
                ai = -1;
            else
                ai = 1;
            end
=============================equetions in rotation clkwise================================================
               if z_eq_list(i) >= 0
                    ai = +1;
                else
                    ai = -1;
                end
                
             x_eq_list(i+1) = x_eq_list(i) + (ai*y_eq_list(i)*(2^-(i-1)));
             y_eq_list(i+1) = y_eq_list(i) - (ai*x_eq_list(i)*(2^-(i-1)));
             z_eq_list(i+1) = z_eq_list(i) - (ai*atan(2^-(i-1)));
**************************************************************************************/
 
module cordic_stage#(
parameter WORD_LENGTH     =32
)(

input                                 i_cordic_stage_clk        ,
input                                 i_cordic_stage_rst_n      ,  // system active low reset

input               [3:0]             i_cordic_stage_shift_value,  // value of shift every stage 2^i
input               [1:0]             i_cordic_stage_mode       ,       


input       signed  [WORD_LENGTH-1:0] i_cordic_stage_x          ,  // input point x
input       signed  [WORD_LENGTH-1:0] i_cordic_stage_y          ,  // input point y
input       signed  [WORD_LENGTH-1:0] i_cordic_stage_z          ,  // input theta in rotation mode
input       signed  [WORD_LENGTH-1:0] i_cordic_stage_atan_value ,  // the value of atan(2^-i)

output  reg signed  [WORD_LENGTH-1:0] o_cordic_stage_x_eq_list  , 
output  reg signed  [WORD_LENGTH-1:0] o_cordic_stage_y_eq_list  ,
output  reg signed  [WORD_LENGTH-1:0] o_cordic_stage_z_eq_list
    );
       

 wire  signed  [WORD_LENGTH-1:0] signal_cordic_stage_signed_x           ;    
 wire  signed  [WORD_LENGTH-1:0] signal_cordic_stage_signed_y           ;
 wire  signed  [WORD_LENGTH-1:0] signal_cordic_stage_signed_atan        ;

 wire  signed  [WORD_LENGTH-1:0] signal_cordic_stage_signed_x_mode0     ;    
 wire  signed  [WORD_LENGTH-1:0] signal_cordic_stage_signed_y_mode0     ;
 wire  signed  [WORD_LENGTH-1:0] signal_cordic_stage_signed_atan_mode0  ;
 
 wire  signed  [WORD_LENGTH-1:0] signal_cordic_stage_signed_x_mode12    ;    
 wire  signed  [WORD_LENGTH-1:0] signal_cordic_stage_signed_y_mode12    ;
 wire  signed  [WORD_LENGTH-1:0] signal_cordic_stage_signed_atan_mode12 ;
 
 wire  signed  [WORD_LENGTH-1:0] signal_cordic_stage_signed_x_mode3     ;    
 wire  signed  [WORD_LENGTH-1:0] signal_cordic_stage_signed_y_mode3     ;
 wire  signed  [WORD_LENGTH-1:0] signal_cordic_stage_signed_atan_mode3  ; 
    
      
   always @(posedge i_cordic_stage_clk or negedge i_cordic_stage_rst_n )begin
          if(!i_cordic_stage_rst_n)begin
              o_cordic_stage_x_eq_list ='b0;
              o_cordic_stage_y_eq_list ='b0;
              o_cordic_stage_z_eq_list ='b0;
          end else begin
              o_cordic_stage_x_eq_list = i_cordic_stage_x + (signal_cordic_stage_signed_y >>> i_cordic_stage_shift_value);
              o_cordic_stage_y_eq_list = i_cordic_stage_y + (signal_cordic_stage_signed_x >>> i_cordic_stage_shift_value);
              o_cordic_stage_z_eq_list = i_cordic_stage_z + signal_cordic_stage_signed_atan;
          end
      end
      
    
  
   
                                /**************mode 0******************/
    assign signal_cordic_stage_signed_x_mode0     = (i_cordic_stage_y[31])? i_cordic_stage_x :((~i_cordic_stage_x) + 1'b1)  ;  // i replace here because in eq2 instead of subtract i will add
    assign signal_cordic_stage_signed_y_mode0     = (i_cordic_stage_y[31])? ((~i_cordic_stage_y) + 1'b1) : i_cordic_stage_y ;
    assign signal_cordic_stage_signed_atan_mode0  = (i_cordic_stage_y[31])? ((~i_cordic_stage_atan_value) + 1'b1) : i_cordic_stage_atan_value ;

                                /**************mode 1,2******************/
    assign signal_cordic_stage_signed_x_mode12    = (i_cordic_stage_z[31]==1'b0)? i_cordic_stage_x :(~(i_cordic_stage_x) + 1'b1)  ;  
    assign signal_cordic_stage_signed_y_mode12    = (i_cordic_stage_z[31]==1'b0)? (~(i_cordic_stage_y) + 1'b1) : i_cordic_stage_y ;
    assign signal_cordic_stage_signed_atan_mode12 = (i_cordic_stage_z[31]==1'b0)? (~(i_cordic_stage_atan_value) + 1'b1) : i_cordic_stage_atan_value ;

                                /**************mode 3******************/
    assign signal_cordic_stage_signed_x_mode3     = (i_cordic_stage_z[31])? i_cordic_stage_x :(~(i_cordic_stage_x) + 1'b1)  ;  
    assign signal_cordic_stage_signed_y_mode3     = (i_cordic_stage_z[31])? (~(i_cordic_stage_y) + 1'b1) : i_cordic_stage_y ;
    assign signal_cordic_stage_signed_atan_mode3  = (i_cordic_stage_z[31])? i_cordic_stage_atan_value : (~(i_cordic_stage_atan_value) + 1'b1) ;

           /****************value of signal based on mode to can use only one equation ***********************/
    assign signal_cordic_stage_signed_x     = (i_cordic_stage_mode==2'b00)? signal_cordic_stage_signed_x_mode0 : ((i_cordic_stage_mode==2'b11)? signal_cordic_stage_signed_x_mode3 : signal_cordic_stage_signed_x_mode12 ); 
    assign signal_cordic_stage_signed_y     = (i_cordic_stage_mode==2'b00)? signal_cordic_stage_signed_y_mode0 : ((i_cordic_stage_mode==2'b11)? signal_cordic_stage_signed_y_mode3 : signal_cordic_stage_signed_y_mode12 ); 
    assign signal_cordic_stage_signed_atan  = (i_cordic_stage_mode==2'b00)? signal_cordic_stage_signed_atan_mode0 : ((i_cordic_stage_mode==2'b11)? signal_cordic_stage_signed_atan_mode3 : signal_cordic_stage_signed_atan_mode12 ); 


endmodule
