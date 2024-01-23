clear all
addpath('~/metrologie/Q-Wave/qwtb/qwtb')
% generate some noncoherent signal:

SigParam.f.v = 50;
SigParam.A.v = 1;
SigParam.fs.v = 96e3;
% SigParam.L.v = 20./SigParam.f.v.*SigParam.fs.v ; % that is 20 periods at 50 Hz
SigParam.L.v = 5./SigParam.f.v.*SigParam.fs.v ;
SigParam.ph.v = 0;
SigParam.O.v = 0;
SigParam.THD.v = 0;
SigParam.nharm.v = 1;
SigParam.noise.v = 1e-6;

SigParamVar.f.v = [49.9:0.05:50.1];
% SigParamVar.fs.v = [1/4000 1/8000];
% SigParamVar.L.v = [1e3 1.1e3 1.2e3];

CS.verbose = 0;
CS.var.dir = '_temp';
CS.var.fnprefix = 'var';
CS.var.cleanfiles = 1;

jobfn = qwtbvar('calc', 'gen_and_calc', SigParam, SigParamVar, CS);

[f, fErrEstimate] = qwtbvar('plot2D', jobfn, 'f.v', 'fErrEstimate.v');
[f, AErrEstimate] = qwtbvar('plot2D', jobfn, 'f.v', 'AErrEstimate.v');
[f, AErrWinFFT] = qwtbvar('plot2D', jobfn, 'f.v', 'AErrWinFFT.v');
[f, AErrResFFT] = qwtbvar('plot2D', jobfn, 'f.v', 'AErrResFFT.v');
[f, AErrFit] = qwtbvar('plot2D', jobfn, 'f.v', 'AErrFit.v');

hold on
plot(f.v, AErrWinFFT.v, '-r',...
     f.v, AErrResFFT.v, '-b',...
     f.v, AErrFit, '-g');
% plot(f.v, AErrEstimate.v, '--k', f.v, fErrEstimate.v, '--g')
hold off
xlabel('signal f (Hz)')
ylabel('error from nominal value (V)')
legend('A: windowing flattop',...
       'A: resampling',...
       'A: from estimate',...
       'A: from fit');

% 'f: from estimate, used for resampling')
saveas(gcf(), 'resampling_vs_wfft.png')

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
