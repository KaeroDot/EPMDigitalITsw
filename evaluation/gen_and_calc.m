function [DO, DI, CS] = gen_and_calc(DI, CS)
    EstimationAlgorithm = 'PSFE';
    ResamplingMethod = 'keepn';
    SignalWindow = 'flattop_248D';
    fEstimateForFit = 50;

    % Waveform generation %<<<1
    Signal = qwtb('GenNHarm', DI, CS);

    % FFT windowing on the signal, only for comparison:
    Signal.window.v = SignalWindow;
    SignalSpectrumWindow = qwtb('SP-WFFT', Signal, CS);
    DO.AErrSigFFTWin.v = max(SignalSpectrumWindow.A.v) - DI.A.v;

    % Path 2, sine fitting %<<<1
    Signal.fest.v = fEstimateForFit;
    SignalFit = qwtb('FPNLSF', Signal, CS);
    DO.AErrSigFit.v = SignalFit.A.v - DI.A.v;

    % Path 1, resample and FFT analysis %<<<1
    % Waveform frequency estimation %<<<1
    SignalEstimate = qwtb(EstimationAlgorithm, Signal, CS);
    DO.fErrSigEst.v = DI.f.v - SignalEstimate.f.v;
    DO.AErrSigEst.v = SignalEstimate.A.v - DI.A.v;

    % set output frequency as estimate:
    Signal.fest.v = SignalEstimate.f.v;
    % resample waveform
    Signal.method.v = ResamplingMethod;
    ResampledSignal = qwtb('SplineResample', Signal, CS);
    ResampledSignalSpectrum = qwtb('SP-WFFT', ResampledSignal, CS);

    % Get amplitude using FFT (no window is set, i.e. rectangle):
    DO.AErrResSigFFT.v = max(ResampledSignalSpectrum.A.v) - DI.A.v;

    % % ONLY FOR DEBUG:
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
    % keyboard
end

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
