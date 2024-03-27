function [DO, DI, CS] = gen_and_calc(DI, CS)
    EstimationAlgorithm = 'PSFE';
    ResamplingMethod = 'keepn';
    SignalWindow = 'flattop_248D';
    fEstimateForFit = 50;

    % Waveform generation %<<<1
    Signal = qwtb('WaveformGenerator', DI, CS);

    % FFT windowing on the signal, only for comparison:
    Signal.window.v = SignalWindow;
    SignalSpectrumWindow = qwtb('SP-WFFT', Signal, CS);
    % find peaks nearest to the signal frequencies and record amplitudes
    % evalueated by WFFT:
    for j = 1:numel(DI.f.v)
        [~, idx] = min(abs(SignalSpectrumWindow.f.v - DI.f.v(j)));
        DO.AErrSigFFTWin_all.v(j) = SignalSpectrumWindow.A.v(idx) - DI.A.v(j);
    end
    % FIX THIS IN THE FUTURE
    % Because QWTBVAR still cannot return vectors:
    % keep 1st and 2nd peaks:
    DO.AErrSigFFTWin.v = DO.AErrSigFFTWin_all.v(1);
    DO.AErrSigFFTWin_2.v = DO.AErrSigFFTWin_all.v(2);

    % Path 2, sine fitting %<<<1
    Signal.fest.v = fEstimateForFit;
    SignalFit = qwtb('FPNLSF', Signal, CS);
    DO.AErrSigFit.v = SignalFit.A.v - DI.A.v(1);

    % Path 1, resample and FFT analysis %<<<1
    % Waveform frequency estimation %<<<1
    SignalEstimate = qwtb(EstimationAlgorithm, Signal, CS);
    DO.fErrSigEst.v = DI.f.v - SignalEstimate.f.v;
    DO.AErrSigEst.v = SignalEstimate.A.v - DI.A.v(1);

    % set output frequency as estimate:
    Signal.fest.v = SignalEstimate.f.v;
    % resample waveform
    Signal.method.v = ResamplingMethod;
    ResampledSignal = qwtb('SplineResample', Signal, CS);
    % Get amplitude using FFT (no window is set, i.e. rectangle):
    ResampledSignalSpectrum = qwtb('SP-WFFT', ResampledSignal, CS);
    % find peaks nearest to the signal frequencies and record amplitudes
    % evalueated by WFFT:
    for j = 1:numel(DI.f.v)
        [~, idx] = min(abs(ResampledSignalSpectrum.f.v - DI.f.v(j)));
        DO.AErrResSigFFT_all.v(j) = ResampledSignalSpectrum.A.v(idx) - DI.A.v(j);
    end
    % FIX THIS IN THE FUTURE
    % Because QWTBVAR still cannot return vectors:
    % keep 1st and 2nd peaks:
    DO.AErrResSigFFT.v = DO.AErrResSigFFT_all.v(1);
    DO.AErrResSigFFT_2.v = DO.AErrResSigFFT_all.v(2);

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
    % % END OF ONLY FOR DEBUG
    %
    %
    % NASTY HACK BECAUSE QWTBVAR CANNOT RETURN VECTOR OR MATRIX
    DI.f.v = DI.f.v(1);
end

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
