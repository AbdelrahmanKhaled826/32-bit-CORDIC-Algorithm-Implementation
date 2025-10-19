
%****************Inputs*********************%

%--------------change values----------------%

len     =14; 
x       = [7,   1,   1,   1,  -1,  1,  1,   1,  -1, 74.5,  4,  10,  1,  1     ];
y       = [100, 0,   0,  -1,  -1,  0,  0,   0,  -1,  35 ,  1,  1,   1,  0     ];
theta   = [0,   30,  240, 90, 190, 10, 100, 230, 0,  0  ,  95, 130, 0,  275.3 ];   % degrees
mode    = [0,   1,   1,   2,  3,   1,  1,   1,   0,  0  ,  2,  3,   1,  1     ];   % 0=vectoring, 1=rotation



%-------------------------------------------------------------------%

word_lenght     =32;
fraction_length =22;
itration        =13;


atan_list=zeros(itration,1);
sin0     = zeros(1,len);
cos0     = zeros(1,len);
magn     = zeros(1,len);
atan0    = zeros(1,len);
new_x    = zeros(1,len);
new_y    = zeros(1,len);



%---------------prepare inverse tan----------------------%

fileID1 = fopen('atan_list.txt','w');
for i = 1:itration
    atan_value = fi(atan(2^-(i-1)),1,word_lenght,fraction_length);
    atan_list(i,1)=atan_value;
    fprintf(fileID1, '%s\n', atan_value.bin);
end
fclose(fileID1);






%---------------prepare RTL inputs----------------------%

fileID2 = fopen('ip_x_list.txt','w');
fileID3 = fopen('ip_y_list.txt','w');
fileID4 = fopen('ip_t_list.txt','w');
fileID11= fopen('ip_mode_list.txt','w');
fileID18= fopen('ip_angle_degree.txt','w');


for i= 1:len
    x_value= fi(x(1,i),1,word_lenght,fraction_length);
    y_value= fi(y(1,i),1,word_lenght,fraction_length);
% will transfer theta to redia to work on rtl but when send to cordic i
% send in degre because i handel it in cordic function un matlab
    theta_rad = deg2rad(theta(1,i));
    t_value = fi(theta_rad, 1, word_lenght, fraction_length);
    %t_value= fi(theta(1,i),1,word_lenght,fraction_length);

    mode_vaue   =mode(1,i);
    angle_value =theta(1,i);

    fprintf(fileID2, '%s\n', x_value.bin);
    fprintf(fileID3, '%s\n', y_value.bin);
    fprintf(fileID4, '%s\n', t_value.bin);
    fprintf(fileID11,'%s\n', dec2bin(mode_vaue,2));
    fprintf(fileID18,'%.1f\n', angle_value);

end
fclose(fileID2);
fclose(fileID3);
fclose(fileID4);
fclose(fileID11);
fclose(fileID18);





%---------------prepare RTL outputs----------------------%
% convert results of cordic to fixed point and binary and save in files to 
% can easily compare RTL output with this outputs.
%---------------------------------------------------------%

fileID5 = fopen('out_mag.txt','w');
fileID6 = fopen('out_angle.txt','w');
fileID7 = fopen('out_cos.txt','w');
fileID8 = fopen('out_sin.txt','w');
fileID9 = fopen('out_new_x.txt','w');
fileID10= fopen('out_new_y.txt','w');


fileID12 = fopen('expect_mag.txt','w');
fileID13 = fopen('expect_angle.txt','w');
fileID14 = fopen('expect_cos.txt','w');
fileID15 = fopen('expect_sin.txt','w');
fileID16 = fopen('expect_new_x.txt','w');
fileID17 = fopen('expect_new_y.txt','w');

for i= 1:len

    [sin0(1,i) , cos0(1,i) , magn(1,i) , atan0(1,i), new_x(1,i) , new_y(1,i)] = cordic(x(1,i) , y(1,i) ,theta(1,i), itration , mode(1,i));

    mag_list    = fi(magn(1,i) ,1,word_lenght,fraction_length);
    angle_list  = fi(deg2rad(atan0(1,i)),1,word_lenght,fraction_length);
    cos_list    = fi(cos0(1,i) ,1,word_lenght,fraction_length);
    sin_list    = fi(sin0(1,i) ,1,word_lenght,fraction_length);
    new_x_list  = fi(new_x(1,i),1,word_lenght,fraction_length);
    new_y_list  = fi(new_y(1,i),1,word_lenght,fraction_length);

   
    fprintf(fileID5, '%s\n', mag_list.bin);
    fprintf(fileID6, '%s\n', angle_list.bin);
    fprintf(fileID7, '%s\n', cos_list.bin);
    fprintf(fileID8, '%s\n', sin_list.bin);
    fprintf(fileID9, '%s\n', new_x_list.bin);
    fprintf(fileID10,'%s\n', new_y_list.bin);

    fprintf(fileID12, '%f\n', magn(1,i));
    fprintf(fileID13, '%f\n', deg2rad(atan0(1,i)));
    fprintf(fileID14, '%f\n', cos0(1,i));
    fprintf(fileID15, '%f\n', sin0(1,i));
    fprintf(fileID16, '%f\n', new_x(1,i));
    fprintf(fileID17,'%f\n', new_y(1,i));



end
fclose(fileID5);
fclose(fileID6);
fclose(fileID7);
fclose(fileID8);
fclose(fileID9);
fclose(fileID10);

fclose(fileID12);
fclose(fileID13);
fclose(fileID14);
fclose(fileID15);
fclose(fileID16);
fclose(fileID17);









