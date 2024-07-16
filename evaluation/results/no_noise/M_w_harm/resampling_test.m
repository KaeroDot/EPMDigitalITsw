clear all
addpath('~/metrologie/Q-Wave/qwtb/qwtb')
%% General settings ---------------------------------------- %<<<1
file_prefix = 'M_w_harm_-_'; % file prefix for plots and data
multiple_harmonics = 1 % will correctly process data and plots inside of this script
%% Calculation settings
CS.verbose = 0;
CS.var.dir = '/dev/shm/qwtbvar_temp';
CS.var.fnprefix = file_prefix;
CS.var.cleanfiles = 1;

%% Settings of signal ---------------------------------------- %<<<1
% properties of the signal
% no harmonic:
SigParam.f.v = [50];      % nominal signal frequency (Hz)
SigParam.A.v = [1];       % nominal amplitude (V)
SigParam.ph.v = [0];      % nominal signal phase (rad)
SigParam.O.v = [0];      % nominal signal offset (V)
% 3rd harmonic:
    SigParam.f.v = [50 150];      % nominal signal frequency (Hz)
    SigParam.A.v = [1 0.1];       % nominal amplitude (V)
    SigParam.ph.v = [0 0];      % nominal signal phase (rad)
    SigParam.O.v = [0 0];      % nominal signal offset (V)
SigParam.fs.v = 96e3;   % nominal sampling frequency (Hz)
SigParam.M.v = 5;      % length of the record in multiple of periods
% SigParam.L.v = 20./SigParam.f.v.*SigParam.fs.v;   % that is 20 periods at 50 Hz
SigParam.THD.v = 1e-3;  % nominal harmonic distortion
SigParam.nharm.v = 1;   % nominal number of harmonics
SigParam.noise.v = 1e-6;% nominal signal noise (V)
% Additional parameters:
SigParam.EstimationAlgorithm.v = 'PSFE';  % Estimation algorithm used for resampling
SigParam.ResamplingMethod.v = 'keepn';  %Resampling method of the SplineResample algorithm
    % (possible values: 'keepN','minimizefs','poweroftwo')
SigParam.SignalWindow.v = 'flattop_248D';  % window used in SP-WFFT algorithm
SigParam.fEstimateForFit.v = 50;  % Estimate for fitting algorithm
SigParam.SineFitAlgorithm.v = 'FPNLSF';  % Algorithm for sine fitting:


%% Varied parameter ---------------------------------------- %<<<1
%---
% number of periods:
% round is needed to prevent rounding errors in WaveformGenerator algorithm!
SigParamVar.M.v = [2 : 0.1 : 20];
xaxisquantity = 'M.v';
xaxislabel = 'Record length (samples)';

%---
% % signal frequency
% SigParamVar.f.v = [49.9 : 0.0001 : 50.1];
% % SigParamVar.f.v = [SigParamVar.f.v; 3.*SigParamVar.f.v]';
% % set same value for number of samples instead the number of periods:
% SigParam = rmfield(SigParam, 'M');
% SigParam.L.v = 2./SigParam.f.v(1).*SigParam.fs.v; % 5 periods at 50 Hz, % Results differ for 2 or 5 periods
% SigParam.L.v = 5./SigParam.f.v(1).*SigParam.fs.v; % 5 periods at 50 Hz, % Results differ for 2 or 5 periods
% xaxisquantity = 'f.v';
% xaxislabel = 'Signal frequency (Hz)';

%---
% % sampling frequency
% SigParamVar.fs.v = [4000 : 100/3 : 96000];
% xaxisquantity = 'fs.v';
% xaxislabel = 'Sampling frequency (Hz)';

%---
% % Signal noise
% SigParamVar.noise.v = logspace(-6, -2, 200);
% xaxisquantity = 'noise.v';
% xaxislabel = 'Noise (σ)';

%% Calculation ---------------------------------------- %<<<1
jobfn = qwtbvar('calc', 'gen_and_calc', SigParam, SigParamVar, CS);

%% Parse results ---------------------------------------- %<<<1
% get results
[ndres ndresc ndaxes] = qwtbvar('result', jobfn);
% reshape needed because of multiple harmonics:
if multiple_harmonics
    fErrEst     = reshape([ndres.fErrEst.v{:}],     numel(SigParam.f.v), []);
    AErrEst     = reshape([ndres.AErrEst.v{:}],     numel(SigParam.f.v), []);
    phErrEst    = reshape([ndres.phErrEst.v{:}],    numel(SigParam.f.v), []);
    fErrResFFT  = reshape([ndres.fErrResFFT.v{:}],  numel(SigParam.f.v), []);
    AErrResFFT  = reshape([ndres.AErrResFFT.v{:}],  numel(SigParam.f.v), []);
    phErrResFFT = reshape([ndres.phErrResFFT.v{:}], numel(SigParam.f.v), []);
    fErrFit     = reshape([ndres.fErrFit.v{:}],     numel(SigParam.f.v), []);
    AErrFit     = reshape([ndres.AErrFit.v{:}],     numel(SigParam.f.v), []);
    phErrFit    = reshape([ndres.phErrFit.v{:}],    numel(SigParam.f.v), []);
    fErrFFTWin  = reshape([ndres.fErrFFTWin.v{:}],  numel(SigParam.f.v), []);
    AErrFFTWin  = reshape([ndres.AErrFFTWin.v{:}],  numel(SigParam.f.v), []);
    phErrFFTWin = reshape([ndres.phErrFFTWin.v{:}], numel(SigParam.f.v), []);
else
    fErrEst     = ndres.fErrEst.v;
    AErrEst     = ndres.AErrEst.v;
    phErrEst    = ndres.phErrEst.v;
    fErrResFFT  = ndres.fErrResFFT.v;
    AErrResFFT  = ndres.AErrResFFT.v;
    phErrResFFT = ndres.phErrResFFT.v;
    fErrFit     = ndres.fErrFit.v;
    AErrFit     = ndres.AErrFit.v;
    phErrFit    = ndres.phErrFit.v;
    fErrFFTWin  = ndres.fErrFFTWin.v;
    AErrFFTWin  = ndres.AErrFFTWin.v;
    phErrFFTWin = ndres.phErrFFTWin.v;
end

% wrap phase results to -pi..pi:
phErrEst = wrapToPi(phErrEst);
phErrResFFT = wrapToPi(phErrResFFT);
phErrFit = wrapToPi(phErrFit);
phErrFFTWin = wrapToPi(phErrFFTWin);

%% Plotting ---------------------------------------- %<<<1
% Amplitudes ---------------------------------------- %<<<2
% main harmonic
figure
hold on
 % with (:,1) is needed for xaxis signal frequency in the case of multiple harmonics
plot(ndaxes.values{1}(:,1), AErrFFTWin(1, :), '-k',...
     ndaxes.values{1}(:,1), AErrFit(1, :), '-xg',...
     ndaxes.values{1}(:,1), AErrEst(1, :), '-+b',...
     ndaxes.values{1}(:,1), AErrResFFT(1, :), '-r');
xlabel(xaxislabel)
ylabel('Error from nominal value (V)')
legend('A: FFT, window',...
       'A: sine fit',...
       'A: PSFE estimate',...
       'A: resampling & FFT rect. window');
title(sprintf('Main signal component, amplitude errors.\nEstimate of signal fr. based on PSFE.'))
hold off

saveas(gcf(), [file_prefix 'A_component_1.png'])
saveas(gcf(), [file_prefix 'A_component_1.fig'])

% second harmonic
if multiple_harmonics
    figure
    hold on
     % with (:,1) is needed for xaxis signal frequency in the case of multiple harmonics
    plot(ndaxes.values{1}(:, 1), AErrFFTWin(2, :), '-k',...
         ndaxes.values{1}(:, 1), AErrFit(2, :), '-xg',...
         ndaxes.values{1}(:, 1), AErrEst(2, :), '-+b',...
         ndaxes.values{1}(:, 1), AErrResFFT(2, :), '-r');
    xlabel(xaxislabel)
    ylabel('Error from nominal value (V)')
    legend('A: FFT, window',...
           'A: sine fit',...
           'A: PSFE estimate',...
           'A: resampling & FFT rect. window');
    title(sprintf('Second signal component, amplitude errors.\nEstimate of signal fr. based on PSFE.'))
    hold off

    saveas(gcf(), [file_prefix 'A_component_2.png'])
    saveas(gcf(), [file_prefix 'A_component_2.fig'])
end

% Phases ---------------------------------------- %<<<2
% main harmonic
figure
hold on
 % with (:,1) is needed for xaxis signal frequency in the case of multiple harmonics
plot(ndaxes.values{1}(:, 1), phErrFFTWin(1, :), '-k',...
     ndaxes.values{1}(:, 1), phErrFit(1, :), '-xg',...
     ndaxes.values{1}(:, 1), phErrEst(1, :), '-+b',...
     ndaxes.values{1}(:, 1), phErrResFFT(1, :), '-r');
xlabel(xaxislabel)
ylabel('Error from nominal value (V)')
legend('ph: FFT, window',...
       'ph: sine fit',...
       'ph: PSFE estimate',...
       'ph: resampling & FFT rect. window');
title(sprintf('Main signal component, phase errors.\nEstimate of signal fr. based on PSFE.'))
hold off

saveas(gcf(), [file_prefix 'ph_component_1.png'])
saveas(gcf(), [file_prefix 'ph_component_1.fig'])

% second harmonic
if multiple_harmonics
    figure
    hold on
     % with (:,1) is needed for xaxis signal frequency in the case of multiple harmonics
    plot(ndaxes.values{1}(:, 1), phErrFFTWin(2, :), '-k',...
         ndaxes.values{1}(:, 1), phErrFit(2, :), '-xg',...
         ndaxes.values{1}(:, 1), phErrEst(2, :), '-+b',...
         ndaxes.values{1}(:, 1), phErrResFFT(2, :), '-r');
    xlabel(xaxislabel)
    ylabel('Error from nominal value (V)')
    legend('ph: FFT, window',...
           'ph: sine fit',...
           'ph: PSFE estimate',...
           'ph: resampling & FFT rect. window');
    title(sprintf('Second signal component, phase errors.\nEstimate of signal fr. based on PSFE.'))
    hold off

    saveas(gcf(), [file_prefix 'ph_component_2.png'])
    saveas(gcf(), [file_prefix 'ph_component_2.fig'])
end

save('-7', [file_prefix 'input_and_plot_data.mat'])

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
