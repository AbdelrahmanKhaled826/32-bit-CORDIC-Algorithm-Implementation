`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Abdelrahman Khaled
// Create Date: 10/07/2025 11:05:22 AM
// Module Name: cordic_tb
//////////////////////////////////////////////////////////////////////////////////


module cordic_tb();

//==================== Parameters ====================
parameter WORD_LENGTH     = 32;
parameter FRACTION_LENGTH = 22;
parameter ITERATION       = 13;
parameter MUL_LENGTH      = 64;
parameter LEN             = 14;



 reg                            i_cordic_clk    ; 
 reg                            i_cordic_rst_n  ; 
 reg         [1:0]              i_cordic_mode   ; 
 reg  signed  [WORD_LENGTH-1:0] i_cordic_x      ; 
 reg  signed  [WORD_LENGTH-1:0] i_cordic_y      ; 
 reg  signed  [WORD_LENGTH-1:0] i_cordic_theta  ; 

 wire signed  [WORD_LENGTH-1 :0] o_codic_out1    ; 
 wire signed  [WORD_LENGTH-1 :0] o_codic_out2    ;


integer i;
integer f1,f2,f3,f4,f5,f6,f7;

real  scale ;
real magnitude_real,magnitude_err;
real angle_err,     angle_real   ;
real sine_real,     sine_err     ;
real cose_real,     cose_err     ;
real X_real,        X_err        ;
real Y_real,        Y_err        ;




cordic u_cordic(
.i_cordic_clk   (i_cordic_clk   ) ,
.i_cordic_rst_n (i_cordic_rst_n ) ,
.i_cordic_mode  (i_cordic_mode  ) ,
.i_cordic_x     (i_cordic_x     ) ,
.i_cordic_y     (i_cordic_y     ) ,
.i_cordic_theta (i_cordic_theta ) ,
.o_codic_out1   (o_codic_out1)    ,
.o_codic_out2   (o_codic_out2)

);




//===================================================
reg signed  [WORD_LENGTH-1:0]  ip_x_list [0:LEN-1] ;
reg signed  [WORD_LENGTH-1:0]  ip_y_list [0:LEN-1] ;
reg signed  [WORD_LENGTH-1:0]  ip_t_list [0:LEN-1] ;

reg   [1:0]  ip_mode_list [0:LEN-1] ;


initial
   begin
    $readmemb("D:\\projects\\cordic\\matlab_files\\ip_x_list.txt",ip_x_list);
    $readmemb("D:\\projects\\cordic\\matlab_files\\ip_y_list.txt",ip_y_list);
    $readmemb("D:\\projects\\cordic\\matlab_files\\ip_t_list.txt",ip_t_list);
    $readmemb("D:\\projects\\cordic\\matlab_files\\ip_mode_list.txt",ip_mode_list);

   end

//===================================================

integer file;

real expect_mag   [0:LEN-1];
real expect_atan  [0:LEN-1];
real expect_sin   [0:LEN-1];
real expect_cos   [0:LEN-1];
real expect_new_x [0:LEN-1];
real expect_new_y [0:LEN-1];
real real_angle   [0:LEN-1];


initial begin
    // --- expect_mag ---
    file = $fopen("D:/projects/cordic/matlab_files/expect_mag.txt", "r");
    if (file == 0) $fatal(1,"Failed to open expect_mag.txt");
    for (i = 0; i < LEN && !$feof(file); i = i + 1)
        f1=$fscanf(file, "%f\n", expect_mag[i]);
    $fclose(file);

    // --- expect_atan ---
    file = $fopen("D:/projects/cordic/matlab_files/expect_angle.txt", "r");
    if (file == 0) $fatal(1,"Failed to open expect_angle.txt");
    for (i = 0; i < LEN && !$feof(file); i = i + 1)
        f2=$fscanf(file, "%f\n", expect_atan[i]);
    $fclose(file);

    // --- expect_sin ---
    file = $fopen("D:/projects/cordic/matlab_files/expect_sin.txt", "r");
    if (file == 0) $fatal(1,"Failed to open expect_sin.txt");
    for (i = 0; i < LEN && !$feof(file); i = i + 1)
        f3=$fscanf(file, "%f\n", expect_sin[i]);
    $fclose(file);

    // --- expect_cos ---
    file = $fopen("D:/projects/cordic/matlab_files/expect_cos.txt", "r");
    if (file == 0) $fatal(1,"Failed to open expect_cos.txt");
    for (i = 0; i < LEN && !$feof(file); i = i + 1)
        f4=$fscanf(file, "%f\n", expect_cos[i]);
    $fclose(file);

    // --- expect_new_x ---
    file = $fopen("D:/projects/cordic/matlab_files/expect_new_x.txt", "r");
    if (file == 0) $fatal(1,"Failed to open expect_new_x.txt");
    for (i = 0; i < LEN && !$feof(file); i = i + 1)
        f5=$fscanf(file, "%f\n", expect_new_x[i]);
    $fclose(file);

    // --- expect_new_y ---
    file = $fopen("D:/projects/cordic/matlab_files/expect_new_y.txt", "r");
    if (file == 0) $fatal(1,"Failed to open expect_new_y.txt");
    for (i = 0; i < LEN && !$feof(file); i = i + 1)
        f6=$fscanf(file, "%f\n", expect_new_y[i]);
    $fclose(file);

    // --- real_angle ---
    file = $fopen("D:/projects/cordic/matlab_files/ip_angle_degree.txt", "r");
    if (file == 0) $fatal(1,"Failed to open ip_angle_degree.txt");
    for (i = 0; i < LEN && !$feof(file); i = i + 1)
        f7=$fscanf(file, "%.1f\n", real_angle[i]);
    $fclose(file);
    
    $display(" All expected MATLAB values loaded successfully.");
end





/*===================================================
Clock Generation*/
initial begin
    i_cordic_clk = 0;
    forever #5 i_cordic_clk = ~i_cordic_clk; // 100 MHz
end



/*===================================================
Reset*/
initial begin
    i_cordic_rst_n = 1;
    #2;
    i_cordic_rst_n = 0;
    #3;
    i_cordic_rst_n = 1;
   
end



/*===================================================
Test Vectors*/

initial 
begin
    $display("**************************************************************");
    $display("                STARTING CORDIC TESTBENCH                     ");
    $display("**************************************************************");
    $display("     *******************************************************   ");
    $display("          ********************************************         ");
    $display("                **********************************             ");   
    scale = (1 << FRACTION_LENGTH );
    #5; // wait for reset
    
    for(i=0;i<LEN;i=i+1)begin
        i_cordic_mode   =   ip_mode_list[i];
        i_cordic_x      =   ip_x_list   [i];
        i_cordic_y      =   ip_y_list   [i];
        i_cordic_theta  =   ip_t_list   [i];
        repeat (25) @(posedge i_cordic_clk); // Wait pipeline
        display(i_cordic_mode,i);    

    end
    
    
    
    $display("\n**************************************************************");
    $display("                 CORDIC TESTBENCH COMPLETED                   ");
    $display("**************************************************************");
    $display("     *******************************************************   ");
    $display("          ********************************************         ");
    $display("                **********************************             ");

    $stop;
end





task display;
    input [1:0] mode;
    input [31:0] i;
    begin
     $display("\n==============================================================");
     $display("                       MODE   %d                              ",mode);
     $display("==============================================================");
     case (mode)
     2'b00: begin
        magnitude_real =   $itor($signed(o_codic_out1))   / scale ;
        angle_real     =   ($itor($signed(o_codic_out2))   / scale) ;
        
        magnitude_err  =  (( expect_mag[i]-(magnitude_real )) / expect_mag[i]) * 100.0;
        angle_err      =  (( expect_atan[i]-(angle_real )) / expect_atan[i]) * 100.0;
        $display("magntuide RTL     =  %b ",o_codic_out1);
        $display("magnitude RTL     =  %.4f ",magnitude_real);        
        $display("magnitude expect  =  %.4f ",expect_mag[i]);
        $display("magnitude ERR     =  %.3f%% ",magnitude_err>=0? magnitude_err:-magnitude_err);
        
        $display("Atan RTL          =  %b ",o_codic_out2);
        $display("Atan RTL          =  %.4f ",angle_real * (180.0 / 3.141592653589793) ); 
        $display("Atan expect       =  %.4f ",expect_atan[i]* (180.0 / 3.141592653589793));
        $display("Atan ERR          =  %.3f%% ",angle_err>=0? angle_err:-angle_err);

     end
     2'b01: begin
        sine_real= $itor($signed(o_codic_out2))   / scale ;
        cose_real= $itor($signed(o_codic_out1))   / scale ;
       
        sine_err = (expect_sin[i] - sine_real) / expect_sin[i] *100.0;
        cose_err = (expect_cos[i] - cose_real) / expect_cos[i] *100.0;

        $display("Cos RTL       =  %b ",o_codic_out1);
        $display("Cose RTL      =  %.4f ",cose_real );
        $display("Cose Expect   =  %.4f ",expect_cos[i]);
        $display("Cose Err      =  %.3f%% ",cose_err >=0 ? cose_err :-cose_err);
        
        $display("Sine RTL      =  %b ",o_codic_out2);
        $display("Sine RTL      =  %.4f ",sine_real );
        $display("Sine Expect   =  %.4f ",expect_sin[i]);
        $display("Sine Err      =  %.3f%% ",sine_err >=0 ? sine_err  :-sine_err);
        
     
     end
     default: begin        
        X_real  = $itor($signed(o_codic_out1))   / scale ;  
        Y_real  = $itor($signed(o_codic_out2))   / scale ;  
        
        X_err   = (expect_new_x[i]- X_real) / expect_new_x[i] *100 ;
        Y_err   = (expect_new_y[i]- Y_real) / expect_new_y[i] *100 ;
        $display("X RTL        =  %b ",o_codic_out1);
        $display("X RTL        =  %.4f ", X_real);
        $display("X Expect     =  %.4f ",expect_new_x[i]);
        $display("X Err        =  %.3f%% ",X_err >=0 ? X_err  :-Y_err);

        $display("Y RTL        =  %b ",o_codic_out2);
        $display("Y RTL        =  %.4f ", Y_real);
        $display("Y Expext     =  %.4f ",expect_new_y[i]);
        $display("Y Err        =  %.3f%% ",Y_err >=0 ? Y_err  :-Y_err);

     
     end
     endcase
     

    end
endtask






endmodule
