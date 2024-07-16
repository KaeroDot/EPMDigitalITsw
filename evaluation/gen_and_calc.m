% Function generates signal and estimate quantities using following 
% algorithms:
%  - SP-WFFT
%  - SplineResample (with FFT afterwards)
%  - FPNLSF
%  - and one other selected.
%
%  Inputs: all quantities needed for GenNHarm
%  Outputs: fErrEst          - signal frequencies from EstimationAlgorithm
%           AErrEst          - signal amplitudes from EstimationAlgorithm
%           phErrEst         - signal phases from EstimationAlgorithm
%           fErrResFFT       - signal frequencies from Resampling & FFT
%           AErrResFFT       - signal amplitudes from Resampling & FFT
%           phErrResFFT      - signal phases from Resampling & FFT
%           fErrFit          - signal frequencies from sine fitting
%           AErrFit          - signal amplitudes from sine fitting
%           phErrFit         - signal phases from sine fitting
%           fErrFFTWin       - signal frequencies from windowed FFT
%           AErrFFTWin       - signal amplitudes from windowed FFT
%           phErrFFTWin       - signal phases from windowed FFT
function [DO, DI, CS] = gen_and_calc(DI, CS)
    %% Waveform generation ---------------------------------------- %<<<1
    % Signal = qwtb('WaveformGenerator', DI, CS);
    Signal = qwtb('GenNHarm', DI, CS);

    %% Estimation of parameters ---------------------------------------- %<<<1
    %% Path 1 ---------------------------------------- %<<<2
    % Resample and FFT analysis
    % Frequency estimation:
    SignalEstimate = qwtb(DI.EstimationAlgorithm.v, Signal, CS);
    % set output frequency as signal estimate:
    Signal.fest.v = SignalEstimate.f.v;
    % Resample waveform:
    Signal.method.v = DI.ResamplingMethod.v;
    ResampledSignal = qwtb('SplineResample', Signal, CS);
    % Get amplitude using simple FFT (rectangle window):
    ResampledSignal.window.v = 'rect';
    ResampledSignalSpectrum = qwtb('SP-WFFT', ResampledSignal, CS);
    % Find peaks nearest to the signal frequencies and record amplitudes
    % evaluated by rectangular FFT:
    for j = 1:numel(DI.f.v)
        [~, idx] = min(abs(ResampledSignalSpectrum.f.v - DI.f.v(j)));
        DO.fErrResFFT.v(j) = ResampledSignalSpectrum.f.v(idx) - DI.f.v(j);
        DO.AErrResFFT.v(j) = ResampledSignalSpectrum.A.v(idx) - DI.A.v(j);
        DO.phErrResFFT.v(j) = ResampledSignalSpectrum.ph.v(idx) - DI.ph.v(j);
    end
    % Push estimate results to the output:
    DO.fErrEst.v = SignalEstimate.f.v - DI.f.v(1);
    DO.AErrEst.v = SignalEstimate.A.v - DI.A.v(1);
    DO.phErrEst.v = SignalEstimate.ph.v - DI.ph.v(1);
    % fill in values for other harmonic components by NaN, because estimate
    % gives value only for main harmonic component:
    DO.fErrEst.v = [DO.fErrEst.v repmat(NaN, 1, numel(DI.f.v) - 1)];
    DO.AErrEst.v = [DO.AErrEst.v repmat(NaN, 1, numel(DI.f.v) - 1)];
    DO.phErrEst.v = [DO.phErrEst.v repmat(NaN, 1, numel(DI.f.v) - 1)];

    %% Path 2 ---------------------------------------- %<<<2
    % Sine fitting
    Signal.fest.v = DI.fEstimateForFit.v;
    SignalFit = qwtb(DI.SineFitAlgorithm.v, Signal, CS);
    DO.fErrFit.v = SignalFit.f.v - DI.f.v(1);
    DO.AErrFit.v = SignalFit.A.v - DI.A.v(1);
    DO.phErrFit.v = SignalFit.ph.v - DI.ph.v(1);
    % fill in values for other harmonic components by NaN, because fitting gives
    % value only for main harmonic component:
    DO.fErrFit.v = [DO.fErrFit.v repmat(NaN, 1, numel(DI.f.v) - 1)];
    DO.AErrFit.v = [DO.AErrFit.v repmat(NaN, 1, numel(DI.f.v) - 1)];
    DO.phErrFit.v = [DO.phErrFit.v repmat(NaN, 1, numel(DI.f.v) - 1)];

    % Path 2 additional ---------------------------------------- %<<<2
    % Windowed FFT, only for comparison:
    Signal.window.v = DI.SignalWindow.v;
    SignalSpectrumWindow = qwtb('SP-WFFT', Signal, CS);
    % find peaks nearest to the signal frequencies and record amplitudes
    % evaluated by WFFT:
    for j = 1:numel(DI.f.v)
        [~, idx] = min(abs(SignalSpectrumWindow.f.v - DI.f.v(j)));
        DO.fErrFFTWin.v(j) = SignalSpectrumWindow.f.v(idx) - DI.f.v(j);
        DO.AErrFFTWin.v(j) = SignalSpectrumWindow.A.v(idx) - DI.A.v(j);
        DO.phErrFFTWin.v(j) = SignalSpectrumWindow.ph.v(idx) - DI.ph.v(j);
    end

    %% Plotting spectra for debug ---------------------------------------- %<<<1
    % % show all spectra together:
    % Signal.window.v = 'rect';
    % SignalSpectrum = qwtb('SP-WFFT', Signal, CS);
    % figure
    % hold on
    % semilogy(SignalSpectrum.f.v, SignalSpectrum.A.v, '-xb',...
    %          SignalSpectrumWindow.f.v, SignalSpectrumWindow.A.v, '-xk',...
    %          ResampledSignalSpectrum.f.v, ResampledSignalSpectrum.A.v, '-xr',...
    %          SignalFit.f.v, SignalFit.A.v, 'og')
    % legend(  'signal spectrum rect. window',...
    %          'signal spectrum with window',...
    %          'resampled signal spectrum rect. window',...
    %          'signal fitted')
    % hold off
    % keyboard
end

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
