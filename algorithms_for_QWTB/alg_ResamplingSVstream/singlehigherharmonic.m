%generates a signal with a fundamental and single harmonic
% aleksander.lisowiec@itr.lukasiewicz.gov.pl, 10.07.2024
%input
%   fund:       fundamental frequency [Hz]
%   fsampling:  sampling frequency [Hz]
%   hnumber:    number of higher harmonic
%   hlevel:     level of higher harmonic
%   duration:   duration of the signal [s]
function signal = singlehigherharmonic(fund,fsampling,hnumber,hlevel,duration)
t = 0:1/fsampling:duration;
x2 = zeros(1,length(t));

    x2 = x2 + sin(2*pi*fund*t);
    if hnumber > 1.5
        x2 = x2 + hlevel*sin(2*pi*fund*hnumber*t);
    end

signal = x2;
