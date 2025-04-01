%designs a FIR resample filter
% aleksander.lisowiec@itr.lukasiewicz.gov.pl, 10.07.2024
% inputs:
%   fcuts:  the frequency where the passband ends in Hz
%   fstop:  the frequency where the stopband starts in Hz
%   N:      interpolation coefficient
%   M:      decimation coefficient
%   fsampl: sampling frequency in Hz
%   ripp:   ripple in the passband
%   att:    attenuation [dB] in the stopband
% output:
%   dtnn:   filter coefficients
% if fstop >= (N/M)*(fsampl/2) the stopband start is forced at (N/M)*(fsampl/2) to avoid aliasing
% fstop can be given as fsampl and design procedure will force fstop = (N/M)*(fsampl/2)
% the number of filter coefficients increases sharply as fstop approaches (N/M)*(fsampl/2)
% passband amplification is 1
% example assuming fcuts = fc = 2500, fsampl = fs = 12800, N = Nint = 5000, M = Mdec = 5101, ripp = rp = 0.000001, att = at = 40
% h = dtfir1(fc, fs, Nint, Mdec, fs, rp, at)
function dtnn = dtfir1(fcuts,fstop,N,M,fsampl,ripp,att)
if N/M < 1
    if fstop < (N/M)*(fsampl/2)
        fcuts2 = fstop;
    else
        fcuts2 = (N/M)*(fsampl/2);

    end
else
    if fstop < fsampl/2
        fcuts2 = fstop;
    else
        fcuts2 = fsampl/2;
    end
end
fc=[fcuts fcuts2];
magsn=[1 0];
devsn=[ripp 10^(-att/20)];
[nn,Wnn,betan,ftypen]=kaiserord(fc,magsn,devsn,fsampl*N);
dtnn = fir1(nn,Wnn,ftypen,kaiser(nn+1,betan),'noscale');
