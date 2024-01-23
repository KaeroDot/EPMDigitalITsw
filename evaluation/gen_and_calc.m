function [DO, DI, CS] = gen_and_calc(DI, CS)
    % Waveform generation %<<<1
    Signal = qwtb('GenNHarm', DI, CS);

    % Waveform frequency estimation %<<<1
    SignalEstimate = qwtb('PSFE', Signal, CS);
    DO.fErrEstimate.v = DI.f.v - SignalEstimate.f.v;
    DO.AErrEstimate.v = SignalEstimate.A.v - DI.A.v;

    % FFT windowing, only for comparison:
    Signal.window.v = 'flattop_248D';
    WindowedSpectrum = qwtb('SP-WFFT', Signal, CS);
    DO.AErrWinFFT.v = max(WindowedSpectrum.A.v) - DI.A.v;

    % Path 1, resample and FFT analysis %<<<1
    % set output frequency as estimate:
    Signal.fest.v = SignalEstimate.f.v;
    % calculate waveform
    Signal.method.v = 'keepn';
    Resampled = qwtb('SplineResample', Signal, CS);
    ResampledSpectrum = qwtb('SP-WFFT', Resampled, CS);

    DO.AErrResFFT.v = max(ResampledSpectrum.A.v) - DI.A.v;

    % Path 2, sine fitting %<<<1
    Fitted = qwtb('FPNLSF', Signal, CS);
    DO.AErrFit.v = Fitted.A.v - DI.A.v;

    % % ONLY FOR DEBUG:
    % % show all spectra together:
    % Signal.window.v = 'rect';
    % SignalSpectrum = qwtb('SP-WFFT', Signal, CS);
    % hold on
    % semilogy(SignalSpectrum.f.v, SignalSpectrum.A.v, '-xb',...
    %        WindowedSpectrum.f.v, WindowedSpectrum.A.v, '-xk',...
    %        ResampledSpectrum.f.v, ResampledSpectrum.A.v, '-xr',...
    %        Fitted.f.v, Fitted.A.v, 'og')
    % legend('signal', 'signal with window', 'resampled', 'fitted')
    % keyboard
end

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
