clear;clc;
f = 50;
U = 100;
I = 5;
N = 1000;
ts = 1/4000;
t = (0:N-1) * ts;

Record1 = U * sin(2*pi * f * t); % voltage
result1 = GetRMSPw(Record1,'blackman');
disp('case for providing single vector')
disp(result1)

Record2(1,:) = U * sin(2*pi * f * t); % voltage
Record2(2,:) = I * sin(2*pi * f * t + pi/3); % current
result2 = GetRMSPw(Record2,'blackman');
disp('case for providing double vector')
disp(result2)
