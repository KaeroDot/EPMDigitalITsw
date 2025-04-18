% Function generates signal and estimate quantities using following 
% algorithms:
%  - FE: frequency estimation algorithm defined in DI.EstimationAlgorithm
%  - SR: Spline resampling + FFT rectangular window
%  - WF: WFFT HFT116D,
%  - MH: MHFE,
%  - WR: WRMS
%  - SV: resamplingSVstream
%
%  Inputs: all quantities needed for GenNHarm
%  Outputs:
%           FE_fErr     - signal frequency estimated by algorithm defined in DI.EstimationAlgorithm
%           FE_AErr     - signal frequency
%           FE_phErr    - signal frequency
%           FE_ct       - calculation time
%           SR_fErr     - signal frequency estimated by Spline Resample + FFT
%           SR_AErr     - signal amplitude
%           SR_phErr    - signal phase
%           SR_fErr     - signal frequency estimated by Spline Resample + FFT
%           SR_AErr     - signal amplitude
%           SR_phErr    - signal phase
%           SR_ct       - calculation time
%           WF_fErr     - signal frequency estimated by Windowed FFT
%           WF_AErr     - signal amplitude
%           WF_phErr    - signal phase
%           WF_ct       - calculation time
%           MH_fErr     - signal frequency estimated by MultiHarmonic Frequency Estimator
%           MH_AErr     - signal amplitude
%           MH_phErr    - signal phase
%           MH_ct       - calculation time
%           WR_fErr     - signal frequency estimated by Windowed RMS
%           WR_AErr     - signal amplitude
%           WR_phErr    - signal phase
%           WR_ct       - calculation time
%           SV_fErr     - signal frequency estimated by Upscale+Downscale+FFT
%           SV_AErr     - signal amplitude
%           SV_phErr    - signal phase
%           SV_ct
%
function [DO, DI, CS] = gen_and_calc(DI, CS) %<<<1
    %% Waveform generation ---------------------------------------- %<<<2
    % Signal = qwtb('WaveformGenerator', DI, CS);
    Signal = qwtb('GenNHarm', DI, CS);

    %% FE - Estimation Algorithm ---------------------------------------- %<<<2
    tic;
    FE = qwtb(DI.EstimationAlgorithm.v, Signal, CS);
    DO.FE_ct.v = toc;
    % Push estimate results to the output:
    DO.FE_f.v       = FE.f.v;
    DO.FE_fErr.v    = FE.f.v - DI.f.v(1);
    DO.FE_A.v       = FE.A.v;
    DO.FE_AErr.v    = FE.A.v - DI.A.v(1);
    DO.FE_ph.v      = FE.ph.v;
    DO.FE_phErr.v   = FE.ph.v - DI.ph.v(1);
    % Fill in values for other harmonic components by NaN, because estimate
    % gives value only for main harmonic component and this would spoil easy
    % plotting.
    DO.FE_f.v       = [DO.FE_f.v        repmat(NaN, 1, numel(DI.f.v) - 1)];
    DO.FE_fErr.v    = [DO.FE_fErr.v     repmat(NaN, 1, numel(DI.f.v) - 1)];
    DO.FE_A.v       = [DO.FE_A.v        repmat(NaN, 1, numel(DI.f.v) - 1)];
    DO.FE_AErr.v    = [DO.FE_AErr.v     repmat(NaN, 1, numel(DI.f.v) - 1)];
    DO.FE_ph.v      = [DO.FE_ph.v       repmat(NaN, 1, numel(DI.f.v) - 1)];
    DO.FE_phErr.v   = [DO.FE_phErr.v    repmat(NaN, 1, numel(DI.f.v) - 1)];

    % SR - Spline Resample and FFT ---------------------------------------- %<<<2
    % Set estimated output frequency as signal estimate for Spline Resampling
    % method:
    Signal.fest.v = FE.f.v;
    % Resample waveform:
    Signal.method.v = DI.SR_Method.v;
    tic;
    SR = qwtb('SplineResample', Signal, CS);
    DO.SR_ct.v = toc;
    % Get spectrum using simple FFT (rectangle window):
    SR.window.v = 'rect';
    SR_Spectrum = qwtb('SP-WFFT', SR, CS);
    % Find peaks nearest to the signal frequencies and get amplitudes
    % evaluated by rectangular FFT, push to the output:
    for j = 1:numel(DI.f.v)
        [~, idx] = min(abs(SR_Spectrum.f.v - DI.f.v(j)));
        DO.SR_f.v(j)        = SR_Spectrum.f.v(idx);
        DO.SR_fErr.v(j)     = SR_Spectrum.f.v(idx) - DI.f.v(j);
        DO.SR_A.v(j)        = SR_Spectrum.A.v(idx);
        DO.SR_AErr.v(j)     = SR_Spectrum.A.v(idx) - DI.A.v(j);
        DO.SR_ph.v(j)       = SR_Spectrum.ph.v(idx);
        DO.SR_phErr.v(j)    = SR_Spectrum.ph.v(idx) - DI.ph.v(j);
    end

    % WF - WFFT HFT116D ---------------------------------------- %<<<2
    % Windowed FFT
    Signal.window.v = DI.SignalWindow.v;
    tic;
    WF_Spectrum = qwtb('SP-WFFT', Signal, CS);
    DO.WF_ct.v = toc;
    % find peaks nearest to the signal frequencies and record amplitudes
    % evaluated by WFFT:
    for j = 1:numel(DI.f.v)
        [~, idx] = min(abs(WF_Spectrum.f.v - DI.f.v(j)));
        DO.WF_f.v(j)        = WF_Spectrum.f.v(idx);
        DO.WF_fErr.v(j)     = WF_Spectrum.f.v(idx) - DI.f.v(j);
        DO.WF_A.v(j)        = WF_Spectrum.A.v(idx);
        DO.WF_AErr.v(j)     = WF_Spectrum.A.v(idx) - DI.A.v(j);
        DO.WF_ph.v(j)       = WF_Spectrum.ph.v(idx);
        DO.WF_phErr.v(j)    = WF_Spectrum.ph.v(idx) - DI.ph.v(j);
    end

    % MH - MHFE %<<<2
    % TODO just simulate output for now
    Signal.fest.v = FE.f.v;
    Signal.ExpComp.v = DI.f.v./DI.f.v(1);
    MH = qwtb('MFSF', Signal, CS);
    DO.MH_fErr.v  = MH.f.v - DI.f.v;
    DO.MH_AErr.v  = MH.A.v - DI.A.v;
    DO.MH_phErr.v = MH.ph.v - DI.ph.v;
    tic;
    DO.MH_ct.v = toc;

    % WR - WRMS %<<<2
    Signal.window.v = 'HFT116D'; % due to incompatibility with alg_SP-WFFT
    tic;
    WR = qwtb('windowedRMS', Signal, CS);
    DO.WR_ct.v = toc;
    % RMS value to the output, but in peak value:
    DO.WR_f.v       = NaN;
    DO.WR_fErr.v    = NaN;
    DO.WR_A.v       = WR.A.v.*2.^0.5;
    DO.WR_AErr.v    = WR.A.v.*2.^0.5 - DI.A.v(1);
    DO.WR_ph.v      = NaN;
    DO.WR_phErr.v   = NaN;
    % Fill in values for other harmonic components by NaN, because estimate
    % gives value only for main harmonic component and this would spoil easy
    % plotting.
    DO.WR_f.v       = [DO.WR_f.v        repmat(NaN, 1, numel(DI.f.v) - 1)];
    DO.WR_fErr.v    = [DO.WR_fErr.v     repmat(NaN, 1, numel(DI.f.v) - 1)];
    DO.WR_A.v       = [DO.WR_A.v        repmat(NaN, 1, numel(DI.f.v) - 1)];
    DO.WR_AErr.v    = [DO.WR_AErr.v     repmat(NaN, 1, numel(DI.f.v) - 1)];
    DO.WR_ph.v      = [DO.WR_ph.v       repmat(NaN, 1, numel(DI.f.v) - 1)];
    DO.WR_phErr.v   = [DO.WR_phErr.v    repmat(NaN, 1, numel(DI.f.v) - 1)];

    % SV - resamplingSVstream and FFT ---------------------------------------- %<<<2
    % Set estimated output frequency and samples per periods for resamplingSVstream:
    Signal.fest.v = FE.f.v;
    Signal.SPP.v = DI.SV_SPP.v;
    if isfield(DI, 'max_rel_A_err')
        Signal.max_rel_A_err.v = DI.max_rel_A_err.v;
    end
    % Resample waveform:
    tic;
    SV = qwtb('resamplingSVstream', Signal, CS);
    DO.SV_ct.v = toc;
    if numel(SV.y.v) == 0
        warning('gen_and_calc: resamplingSVstream resulted in empty signal. NaN values set as result.')
        DO.SV_fErr.v  = NaN.*ones(size(DI.f.v));
        DO.SV_AErr.v  = NaN.*ones(size(DI.f.v));
        DO.SV_phErr.v = NaN.*ones(size(DI.f.v));
    else
        % Get spectrum using simple FFT (rectangle window):
        SV.window.v = 'rect';
        SV_Spectrum = qwtb('SP-WFFT', SV, CS);
        % Find peaks nearest to the signal frequencies and get amplitudes
        % evaluated by rectangular FFT, push to the output:
        for j = 1:numel(DI.f.v)
            [~, idx] = min(abs(SV_Spectrum.f.v - DI.f.v(j)));
            DO.SV_fErr.v(j) = SV_Spectrum.f.v(idx) - DI.f.v(j);
            DO.SV_AErr.v(j) = SV_Spectrum.A.v(idx) - DI.A.v(j);
            DO.SV_phErr.v(j) = SV_Spectrum.ph.v(idx) - DI.ph.v(j);
        end
    end

    % Plotting spectra for debug ---------------------------------------- %<<<2
    % % show all spectra and values together, only for debug purposes:
    % figure
    % hold on
    % semilogy(FE.f.v, FE.A.v, 'or', 'linewidth', 5, ...
    %          SR_Spectrum.f.v, SR_Spectrum.A.v, '-xr', ...
    %          WF_Spectrum.f.v, WF_Spectrum.A.v, '-xb', ...
    %          SV_Spectrum.f.v, SV_Spectrum.A.v, '-xg', ...
    %          FE.f.v, WR.A.v, 'ob', 'linewidth', 5);
    % legend(  'FE, frequency estimate',...
    %          'SR, spline resample',...
    %          'WF, spectrum flattop window',...
    %          'SV, resampling SV stream',...
    %          'WR, windowed RMS')
    % hold off
    % keyboard
end

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=matlab textwidth=80 tabstop=4 shiftwidth=4
