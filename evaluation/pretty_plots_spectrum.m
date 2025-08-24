% script just generates simple signal and plots a pretty spectrum for the deliverable

%% Generate sampled data
fs = 12800;
L =  12800;
t = [0:L-1] ./ fs;
A = 1;
f = 49.25;
DISampled.y.v = A.*sin(2.*pi.*f.*t + 0) + A./10.*sin(2.*pi.*5.*f.*t);
DISampled.fs.v = fs;
DISampled.fest.v = f;
CS.verbose = 1;
filename_appendix = '_50periods';

figfilename = ['results/pretty_spectrum' filename_appendix '.png']
csvfilename = ['results/pretty_spectrum' filename_appendix '.csv'];

%% Signal frequency estimate
% Get estimate of signal frequency to be coherent after resampling. For
% example, algorithm PSFE can be used:
Estimate = qwtb('PSFE', DISampled);
DISampled.fest.v = Estimate.f.v;

%% Call algorithms
% call algorithm:
DOresamplingSVstream = qwtb('resamplingSVstream', DISampled, CS);
DOsplineresample = qwtb('SplineResample', DISampled, CS);

%% Get spectra
DISampled.window.v = 'rect';
sp_FFT = qwtb('SP-WFFT', DISampled);
DISampled.window.v = 'flattop_116D'; % window used in SP-WFFT algorithm
sp_WFFT = qwtb('SP-WFFT', DISampled);
DISampled.window.v = 'rect';
sp_resamplingSVstream = qwtb('SP-WFFT', DOresamplingSVstream, CS);
sp_splineresample = qwtb('SP-WFFT', DOsplineresample, CS);

%% Plot
pFE = {';PSFE estimate;', 'color', [166,206,227]./256, 'linestyle', '-', 'linewidth', 2}; % light blue
pWR = {';Windowed RMS;','color', [ 31,120,180]./256, 'linestyle', '-', 'linewidth', 2}; % dark blue
pFFT = {';FFT;','color', [ 31,120,180]./256, 'linestyle', '-', 'linewidth', 2}; % light green
pWF = {';FFT, window;','color', [178,223,138]./256, 'linestyle', '-', 'linewidth', 2}; % light green
pMH = {';MHFE;','color', [ 51,160, 44]./256, 'linestyle', '-', 'linewidth', 2}; % dark green
pSR = {';SplineResampling;','color', [251,154,153]./256, 'linestyle', '-', 'linewidth', 2}; % light red
pSV = {';resamplingSVstream;','color', [227, 26, 28]./256, 'linestyle', '-', 'linewidth', 2}; % dark red


figure()
hold on
% semilogy(f, A, 'xk', 'markersize', 5, 'linewidth', 2)
semilogy(sp_FFT.f.v, sp_FFT.A.v, pFFT{:})
semilogy(sp_WFFT.f.v, sp_WFFT.A.v, pWF{:})
semilogy(sp_resamplingSVstream.f.v, sp_resamplingSVstream.A.v, pSV{:})
semilogy(sp_splineresample.f.v, sp_splineresample.A.v, pSR{:})
hold off
xlim([0 1000])
xlabel('Frequency (Hz)')
ylabel('Signal amplitude')
legend()
saveas(gcf(), figfilename)

% export to CSV:
% pad resamplingSVstream data to have same length as FFT and WFFT:
paddedSVdataf = [sp_resamplingSVstream.f.v(:); nan(max(0, numel(sp_FFT.f.v(:)) - numel(sp_resamplingSVstream.f.v(:))), 1)];
paddedSVdataA = [sp_resamplingSVstream.A.v(:); nan(max(0, numel(sp_FFT.A.v(:)) - numel(sp_resamplingSVstream.A.v(:))), 1)];
csvdata = [sp_FFT.f.v(:), ...
           sp_FFT.A.v(:), ...
           sp_WFFT.f.v(:), ...
           sp_WFFT.A.v(:), ...
           paddedSVdataf(:), ...
           paddedSVdataA(:), ...
           sp_splineresample.f.v(:), ...
           sp_splineresample.A.v(:)];

fid = fopen(csvfilename, 'w');
fprintf(fid, 'f_FFT;A_FFT;f_WFFT;A_WFFT;f_resamplingSVstream;A_resamplingSVstream;f_splineresample;A_splineresample\n');
fclose(fid);
dlmwrite(csvfilename, csvdata, 'delimiter', ';', '-append');

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=matlab textwidth=80 tabstop=4 shiftwidth=4
