


%% this code test four vector and six angle.

itra=32;
tol = 1e-7;   % tolerance
Nitr = 13;    % iterations inside cordic

% --- test inputs (vectors + angles) ---
test_vectors = [7+3j, 5+2j, -4+6j, 1+1j];  
test_angles  = [0, 30, 60, 120, -45, 180]; 


store_magn  = inf(itra,itra);  
store_angle = inf(itra,itra);
store_sin   = inf(itra,itra);  
store_cos   = inf(itra,itra);


for wl = 13:itra        % word length
    for fl = 1:wl    % fraction length



        max_err_magn = 0;
        max_err_atan = 0;
        max_err_sin  = 0;
        max_err_cos  = 0;

        for v = 1:length(test_vectors)
            x0 = real(test_vectors(v));
            y0 = imag(test_vectors(v));
            
            % --- Vectoring Mode (magnitude + atan) ---
            [~, ~, magn, atan0] = cordic(x0, y0, 0, Nitr, 0);
            
             % quantize
            q_magn = fi(magn, 1, wl, fl);
            q_atan = fi(atan0, 1, wl, fl);
            
            max_err_magn = max(max_err_magn, abs(double(magn) - double(q_magn)));
            max_err_atan = max(max_err_atan, abs(double(atan0) - double(q_atan)));
        end


        for t = 1:length(test_angles)
            theta = test_angles(t);
            
            % --- Rotation Mode (sin, cos) ---
            [sin0, cos0, ~, ~] = cordic(1, 0, theta, Nitr, 1);
            
            q_sin = fi(sin0, 1, wl, fl);
            q_cos = fi(cos0, 1, wl, fl);
            
            max_err_sin = max(max_err_sin, abs(double(sin0) - double(q_sin)));
            max_err_cos = max(max_err_cos, abs(double(cos0) - double(q_cos)));
        end


  
        store_magn(wl,fl)  = max_err_magn;
        store_angle(wl,fl) = max_err_atan;
        store_sin(wl,fl)   = max_err_sin;
        store_cos(wl,fl)   = max_err_cos;

    end
end


[idx_magn_wl, idx_magn_fl] = find(store_magn <tol);
[idx_atan_wl, idx_atan_fl] = find(store_angle <tol);

[idx_sin_wl, idx_sin_fl] = find(store_sin <tol);
[idx_cos_wl, idx_cos_fl] = find(store_cos <tol);



fprintf('Best for Magn (tol=%.1e):\n', tol);
for i = 1:length(idx_magn_wl)
    fprintf('   WL=%d, FL=%d\n', idx_magn_wl(i), idx_magn_fl(i));
end

fprintf('\nBest for Atan (tol=%.1e):\n', tol);
for i = 1:length(idx_atan_wl)
    fprintf('   WL=%d, FL=%d\n', idx_atan_wl(i), idx_atan_fl(i));
end



fprintf('Best for sin (tol=%.1e):\n', tol);
for i = 1:length(idx_sin_wl)
    fprintf('   WL=%d, FL=%d\n', idx_sin_wl(i), idx_sin_fl(i));
end

fprintf('\nBest for cos (tol=%.1e):\n', tol);
for i = 1:length(idx_cos_wl)
    fprintf('   WL=%d, FL=%d\n', idx_cos_wl(i), idx_cos_fl(i));
end



figure;
hold on;

plot(idx_magn_wl, idx_magn_fl,'ro','MarkerSize',16, 'DisplayName','mag');
plot(idx_atan_wl, idx_atan_fl,'bo','MarkerSize',13, 'DisplayName','Atan');
plot(idx_sin_wl, idx_sin_fl,'co','MarkerSize',10, 'DisplayName','sin');
plot(idx_cos_wl, idx_cos_fl,'ko','MarkerSize',7, 'DisplayName','cos');

xlabel('Word Length (WL)');
ylabel('fraction Length (FL)');
title('WL vs FL that meet tolerance');
legend show;
grid on;

