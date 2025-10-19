
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cordicStep - performs one CORDIC microrotation
%
%
%
%Inputs -->   x0    : real component input      (used in vector mode  )
% 			  y0    : imaginary component input (used in vector mode  )
% 		      theta0: angle input               (used in rotation mode)
%			  itr   : number of iterations
%		      mode  : 0--> selects vector   mode. 
%                     1--> selects rotation mode.
%
%
% Outputs --> sin0 : result of sin angle        (used in rotation mode)
% 		      cos0 : result of cos angle        (used in rotation mode)
%
%			  magn : magnitude of vector        (used in vector mode  )
%             atan0: angle of vector            (used in vector mode  )
%
%             new_x: new x after rotation       (used in rotation mode)
%             new_y: new y after rotation       (used in rotation mode)
%
%                      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% direction of rotation --------> in vector : idicate by sign of yi
%                       |
%                       |
%                        ------> in rotation : idicate by (-ve) sign of thetai
%                       
%                      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%
% the equations must to multiplier by cos(theta) and we don't make this to
% reduce the hardware complexity, due of this the result of equations be 
% incorrect and higher than the actual value. to solve this problem we
% notic that The vectors  amplitude is scaled by the exact same number 1.647 
% regardless of the initial point. This means that we have not actually 
% failed to obtain the amplitude of the vectors; we obtained them scaled by 
% a constant factor that is only a function of the number of iterations,
% not the inputs, which means we can use a single constant multiplier
% to obtain the actual length of the vector.
%                      
%                       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% limitation of the basic CORDIC is that it only works correctly in the
% right half-plane (angles between −90° and +90°). 
% To extend the range to the full 360°--->Rotation CORDIC: rotate the input vector by ±90°
%                                     |   depending on the sign of 𝑦0, and adjust the
%                                     |   initial angle accordingly.
%                                     |
%                                     --->Vectoring CORDIC: If 𝑥0<0 flip the sign of x, 
%                                         keep y the same, and then correct the final
%                                          computed angle. 
%                    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [sin0 , cos0 , magn , atan0, new_x , new_y] = cordic(x0 , y0 ,theta0, itr , mode)


    % initialize outputs so MATLAB never complains they are undefined
    sin0 = 0;%[];
    cos0 = 0;%[];
    magn = 0;%[];
    atan0 = 0;%[];
    new_x = 0;%[];
    new_y = 0;%[];

x_eq_list = [zeros(1,itr+1)];
y_eq_list = [zeros(1,itr+1)];
z_eq_list = [zeros(1,itr+1)];

ai=0;
vec=0;
ves=0;  
d=1;

% ---scaling factor------
k = prod(1 ./ sqrt(1 + 2.^(-2*(0:itr-1)))); 
%k=1/1.6467



% ----initial values------     
x_eq_list(1)=x0;
y_eq_list(1)=y0;


switch mode
%   --------- vector mode-----------------------------
    case 0         
        if x0 < 0 
            x_eq_list(1)=-x0;
            y_eq_list(1)=y0;
            d=sign(y0);
        else
            x_eq_list(1)=x0;
            y_eq_list(1)=y0;
        end

        
        for i=1:(itr)

            if y_eq_list(i) >= 0
                ai = 1;
            else
                ai = -1;
            end
            
            x_eq_list(i+1) = x_eq_list(i) + (ai*y_eq_list(i)*(2^-(i-1)));
            y_eq_list(i+1) = y_eq_list(i) - (ai*x_eq_list(i)*(2^-(i-1)));
            z_eq_list(i+1) = z_eq_list(i) + (ai*atan(2^-(i-1)));

        end
%------------ rotation mode &rotation vector Counterclockwise---------------------------
    case {1,2}  
        if theta0<=90
            z_eq_list(1)=deg2rad(theta0);
            vec=1;
            ves=1;
        elseif theta0<=180 && theta0>90
            z_eq_list(1)=deg2rad(180-theta0);
            vec=-1;
            ves=1;
        elseif theta0<270 && theta0>180
            z_eq_list(1)=deg2rad(theta0-180);
            vec=-1;
            ves=-1;
        else
            z_eq_list(1)=deg2rad(360-theta0);
            vec=1;
            ves=-1;
        end
        
        for i=1:(itr)
            if z_eq_list(i) >= 0
                ai = -1;
            else
                ai = 1;
            end


            x_eq_list(i+1) = x_eq_list(i) + (ai*y_eq_list(i)*(2^-(i-1)));
            y_eq_list(i+1) = y_eq_list(i) - (ai*x_eq_list(i)*(2^-(i-1)));
            z_eq_list(i+1) = z_eq_list(i) + (ai*atan(2^-(i-1)));

        end
%----------------------rotation vector clockwise-------------------------------%
    
        case 3
            if theta0<=90
                z_eq_list(1)=deg2rad(theta0);
                vec=1;
                ves=1;
            elseif theta0<=180 && theta0>90
                z_eq_list(1)=deg2rad(180-theta0);
                vec=-1;
                ves=1;
            elseif theta0<270 && theta0>180
                z_eq_list(1)=deg2rad(theta0-180);
                vec=-1;
                ves=-1;
            else
                z_eq_list(1)=deg2rad(360-theta0);
                vec=1;
                ves=-1;
            
            end


            for i=1:(itr)
               if z_eq_list(i) >= 0
                    ai = +1;
                else
                    ai = -1;
                end


             x_eq_list(i+1) = x_eq_list(i) + (ai*y_eq_list(i)*(2^-(i-1)));
             y_eq_list(i+1) = y_eq_list(i) - (ai*x_eq_list(i)*(2^-(i-1)));
             z_eq_list(i+1) = z_eq_list(i) - (ai*atan(2^-(i-1)));
           end
    end




    

%-------------------------outputs--------------------

switch mode
    case 0         
        if x0 < 0 
             atan0 = (d*(pi-(d*z_eq_list(end)))) *(180/pi);
        else
            atan0   = z_eq_list(end)*(180/pi);
        
        end
        magn    = x_eq_list(end)*k;   
        sin0    =0;%[];
        cos0    =0;%[];

    case 1         
        magn    = 0;%[];
        atan0   = 0;%[];
        sin0    = y_eq_list(end)*k*ves;
        cos0    = x_eq_list(end)*k*vec; 
        new_y    =0;%[];
        new_x    =0;%[];
        
    case 2         
        magn    = 0;%[];
        atan0   = 0;%[];
        sin0    = 0;%[];
        cos0    = 0;%[];
        new_y    = y_eq_list(end)*k*ves;
        new_x    = x_eq_list(end)*k*vec;
        
    case 3     
        magn    = 0;%[];
        atan0   = 0;%[];
        sin0    = 0;%[];
        cos0    = 0;%[];
        new_y    = y_eq_list(end)*k*ves;
        new_x    = x_eq_list(end)*k*vec;

end
end