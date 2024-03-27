clear all
addpath('~/metrologie/Q-Wave/qwtb/qwtb')
% generate some noncoherent signal:

SigParam.f.v = 50;      % nominal signal frequency (Hz)
SigParam.A.v = 1;       % nominal amplitude (V)
SigParam.fs.v = 96e3;   % nominal sampling frequency (Hz)
% SigParam.L.v = 20./SigParam.f.v.*SigParam.fs.v;   % that is 20 periods at 50 Hz
SigParam.L.v = 5./SigParam.f.v.*SigParam.fs.v;      % length of the record in multiple of periods
SigParam.ph.v = 0;      % nominal signal phase (rad)
SigParam.O.v = 0;       % nominal offset (V)
SigParam.THD.v = 1e-3;  % nominal harmonic distortion
SigParam.nharm.v = 1;   % nominal number of harmonics
SigParam.noise.v = 0e-6;% nominal signal noise (V)

% Varied parameter:
% SigParamVar.f.v = [49.9 : 0.01 : 50.1];
% SigParamVar.L.v = [1:0.05:10]./SigParam.f.v.*SigParam.fs.v;
SigParamVar.fs.v = [4000 : 4000 : 96000];

% Additional parameters:
SigParam.EstimationAlgorithm.v = 'PSFE';
SigParam.ResamplingMethod.v = 'keepn';
SigParam.SignalWindow.v = 'flattop_248D';
SigParam.fEstimateForFit.v = 50;

CS.verbose = 0;
CS.var.dir = '_temp';
CS.var.fnprefix = 'var';
CS.var.cleanfiles = 1;

jobfn = qwtbvar('calc', 'gen_and_calc', SigParam, SigParamVar, CS);

% signal amplitude using fft with window:
[x, AErrSigFFTWin] = qwtbvar('plot2D', jobfn, 'fs.v', 'AErrSigFFTWin.v');
% signal amplitude using sine fitting:
[x, AErrSigFit] = qwtbvar('plot2D', jobfn, 'fs.v', 'AErrSigFit.v');
% signal amplitude using algorithm for signal frequency estimate:
[x, AErrSigEst] = qwtbvar('plot2D', jobfn, 'fs.v', 'AErrSigEst.v');
% signal amplitude using fft of resampled signal:
[x, AErrResSigFFT] = qwtbvar('plot2D', jobfn, 'fs.v', 'AErrResSigFFT.v');

figure
hold on
plot(x.v, AErrSigFFTWin.v, '-k',...
     x.v, AErrSigFit.v, '-xg',...
     x.v, AErrSigEst.v, '-+b',...
     x.v, AErrResSigFFT.v, '-r');
% plot(f.v, AErrEstimate.v, '--k', f.v, fErrEstimate.v, '--g')
hold off
% xlabel('Signal f (Hz)')
xlabel('Sampling frequency (Hz)')
ylabel('Error from nominal value (V)')
legend('A: Signal FFT, window',...
       'A: Signal Fit',...
       'A: Signal Estimate',...
       'A: Resampling signal and FFT, rect. window');

title(sprintf('Amplitude errors.\nEstimate of signal fr. based on PSFE.'))

% 'f: from estimate, used for resampling')
saveas(gcf(), 'resampling_vs_wfft.png')
saveas(gcf(), 'resampling_vs_wfft.fig')

% Signal = qwtb('GenNHarm', SigParam);
% SignalSpectrum = qwtb('SP-WFFT', Signal);
%
% Signal.fest.v = 11;
% Signal.res_method.v = 'resample';
%
% Resampled = qwtb('ResampleCoherent', Signal);
% ResampledSpectrum = qwtb('SP-WFFT', Resampled);
%
% figure()
% hold on
% loglog(SignalSpectrum.f.v, SignalSpectrum.A.v, '-b', ResampledSpectrum.f.v, ResampledSpectrum.A.v, '-r')
% hold off
%
% max(SignalSpectrum.A.v) - SigParam.A.v
% max(ResampledSpectrum.A.v) - SigParam.A.v
