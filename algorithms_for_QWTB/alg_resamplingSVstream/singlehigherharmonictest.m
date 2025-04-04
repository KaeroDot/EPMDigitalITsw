%script for testing the resampling procedure in a loop with varying fline frequency
% aleksander.lisowiec@itr.lukasiewicz.gov.pl, 10.07.2024
%calculates and displays the relative percentage errors in fundamental and higher harmonic amplitude determination after resample
ripp = 0.000001;
att = 40;
%max line frequency is 55 Hz and we want to determine the spectrum up to maxnofh of harmonics
minfr = 49;
maxfr = 55;
maxnofh = 100;
nperperiod = 256;   %nominal number of samples per period
fs = 12800;         %sampling frequency
Nint = 5000;        %interpolation coefficient
interval = 0.06;    %interval [s] over which the samples of test signal have been calculated
higherharmonic = 13; %additional harmonic besides the fundamental
higherharmoniclevel = 0.1;
Mdecmax = factorM(Nint,minfr,fs,nperperiod);
resfilter=dtfir1(maxfr*maxnofh,fs,Nint,Mdecmax,fs,ripp,att);
disp('lenght of resample filter:'), disp(length(resfilter))
err = [];
for nn=-40:40
fline = 50+nn*0.025;
refsignal=singlehigherharmonic(fline,nperperiod*fline,higherharmonic,higherharmoniclevel,interval);
testsignal=singlehigherharmonic(fline,fs,higherharmonic,higherharmoniclevel,interval);
Mdec = factorM(Nint,fline,fs,nperperiod)
spectrumnoresampl=fft(testsignal(1:nperperiod));
ydownsample=fastresample(testsignal,resfilter,Nint,Mdec);
spectrumref=fft(refsignal(1:nperperiod));
spectrumtest=fft(ydownsample(1:nperperiod));
abs(spectrumtest(2));
relerrfundamental=100*((abs(spectrumtest(2))-abs(spectrumref(2)))/abs(spectrumtest(2)));
relerrhigerharmonic=100*((abs(spectrumtest(higherharmonic+1))-abs(spectrumref(higherharmonic+1)))/abs(spectrumref(higherharmonic+1)));
relerrfundamentalnoresample=100*((abs(spectrumnoresampl(2))-abs(spectrumref(2)))/abs(spectrumref(2)));
err=[err,relerrfundamental];
end
plot(err)

