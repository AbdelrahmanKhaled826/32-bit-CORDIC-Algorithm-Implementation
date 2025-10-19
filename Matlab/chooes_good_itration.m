

% -------------------------------------------------
% CORDIC Iteration Test
% -------------------------------------------------

% vector =7+3j

real_num    = 7;
imag_num    = 3;
theta_test  = 30;              

true_magn   = 7.6157;
true_angle  = 23.1985;

true_x_rot  = 7.5621;
true_y_rot  = -0.9019;

true_x_rot_c= 4.562;
true_y_rot_c= 6.098;

max_itra    =30;
tolerance   = 1e-4; 


errors_magn = zeros(1, max_itra);
errors_angle= zeros(1, max_itra);
err_sin     = zeros(1, max_itra);
err_cos     = zeros(1, max_itra);
err_x_rot   = zeros(1, max_itra);
err_y_rot   = zeros(1, max_itra);
err_x_rot_c = zeros(1, max_itra);
err_y_rot_c = zeros(1, max_itra);


for i=1:max_itra
    % -------- Vectoring Mode --------
   
    [~ , ~ , magn ,atan0] = cordic(7 , 3,0, i , 0);
    errors_magn(i)       = abs(magn - true_magn);
    errors_angle(i)      = abs(atan0 - true_angle);

    % -------- Rotation Mode --------
    [sin0 , cos0 , ~ , ~] = cordic(1 , 0 ,theta_test, i , 1);
    err_sin(i)          = abs(sin0 - sind(theta_test));
    err_cos(i)          = abs(cos0 - cosd(theta_test));

     % -------- Rotation counterclockwise --------
    [ ~ , ~, ~, ~,new_x , new_y] = cordic(real_num , imag_num ,theta_test, i , 2);
    err_x_rot_c(i)        = abs(new_x - true_x_rot_c);
    err_y_rot_c(i)        = abs(new_y - true_y_rot_c);

    % -------- Rotation clockwise --------
    [ ~ , ~, ~, ~,new_x , new_y] = cordic(real_num , imag_num ,theta_test, i , 3);
    err_x_rot(i)        = abs(new_x - true_x_rot);
    err_y_rot(i)        = abs(new_y - true_y_rot);


end


ref_itr_magn  = find(errors_magn  < tolerance, 1);
ref_itr_angle = find(errors_angle < tolerance, 1);
ref_itr_sin   = find(err_sin      < tolerance, 1);
ref_itr_cos   = find(err_cos      < tolerance, 1);
ref_itr_x     = find(err_x_rot    < tolerance, 1);
ref_itr_y     = find(err_y_rot    < tolerance, 1);
ref_itr_x_c   = find(err_x_rot_c  < tolerance, 1);
ref_itr_y_c   = find(err_y_rot_c  < tolerance, 1);


%{
[~,ref_itr_magn ] = min(errors_magn);
[~,ref_itr_angle] = min(errors_angle);
[~,ref_itr_sin  ] = min(err_sin);
[~,ref_itr_cos  ] = min(err_cos);
[~,ref_itr_x    ] = min(err_x_rot);
[~,ref_itr_y    ] = min(err_y_rot);
[~,ref_itr_x_c  ] = min(err_x_rot_c);
[~,ref_itr_y_c  ] = min(err_y_rot_c);
%}

fprintf('Reference Iterations (for tolerance %.1e):\n', tolerance);
fprintf(' Magnitude : %d iterations\n', ref_itr_magn);
fprintf(' Angle     : %d iterations\n', ref_itr_angle);
fprintf(' Sin       : %d iterations\n', ref_itr_sin);
fprintf(' Cos       : %d iterations\n', ref_itr_cos);
fprintf(' x         : %d iterations\n', ref_itr_x);
fprintf(' y         : %d iterations\n', ref_itr_y);
fprintf(' x         : %d iterations\n', ref_itr_x_c);
fprintf(' y         : %d iterations\n', ref_itr_y_c);


figure;
subplot(2,1,1);
plot(1:max_itra, err_sin,'-or');
xlabel('Iterations'); ylabel('|Error in sin|');
title('CORDIC Rotation Mode - Sin Error');
grid on;

subplot(2,1,2);
plot(1:max_itra, err_cos,'-*b');
xlabel('Iterations'); ylabel('|Error in cos|');
title('CORDIC Rotation Mode - Cos Error');
grid on;

figure;
subplot(2,1,1);
plot(1:max_itra, errors_magn,'-sr');
xlabel('Iterations'); ylabel('|Error in Magnitude|');
title('CORDIC Vectoring Mode - Magnitude Error');
grid on;

subplot(2,1,2);
plot(1:max_itra, errors_angle,'-^g');
xlabel('Iterations'); ylabel('|Error in Angle (deg)|');
title('CORDIC Vectoring Mode - Angle Error');
grid on;


figure;
subplot(2,1,1);
plot(1:max_itra, err_x_rot,'-or');
xlabel('Iterations'); ylabel('|Error in new vector|');
title('CORDIC rotation Mode - x Error');
grid on;

subplot(2,1,2);
plot(1:max_itra, err_y_rot,'-sb');
xlabel('Iterations'); ylabel('|Error in y|');
title('CORDIC Vectoring Mode - y Error');
grid on;

