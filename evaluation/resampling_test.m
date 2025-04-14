% 2DO:
% MHFE,
% WFFT HFT116D,
% Real data
% 2nd, 3rd, 5th harmonic
% speed!

function resampling_test() %<<<1
addpath('~/metrologie/Q-Wave/qwtb/qwtb')
%% General settings ---------------------------------------- %<<<1
% file_prefix = 'f_no_harm_2_per_-_'; % file prefix for plots and data
file_prefix = 'test_'; % file prefix for plots and data
multiple_harmonics = 1 % will correctly process data and plots inside of this script
alg_prefixes = {'FE', 'SR', 'WF', 'MH', 'WR', 'SV'}; % algorithm prefixes
quantity_prefixes = {'f', 'A', 'ph'}; % quantity prefixes

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
% harmonics 2-5:
harm_multiple = 3;
if multiple_harmonics
    SigParam.f.v = [50 harm_multiple.*50];      % nominal signal frequency (Hz)
    SigParam.A.v = [1 0.1];       % nominal amplitude (V)
    SigParam.ph.v = [0 0];      % nominal signal phase (rad)
    SigParam.O.v = [0 0];      % nominal signal offset (V)
end
SigParam.fs.v = 96e3;   % nominal sampling frequency (Hz)
SigParam.M.v = 5;      % length of the record in multiple of periods
% SigParam.L.v = 20./SigParam.f.v.*SigParam.fs.v;   % that is 20 periods at 50 Hz
SigParam.THD.v = 1e-3;  % nominal harmonic distortion
SigParam.nharm.v = 1;   % nominal number of harmonics
SigParam.noise.v = 0;% nominal signal noise (V)
% Additional parameters:
SigParam.EstimationAlgorithm.v = 'PSFE';  % Estimation algorithm used for resampling
SigParam.SR_Method.v = 'keepn';  %Resampling method of the SplineResample algorithm (possible values: 'keepN','minimizefs','poweroftwo')
SigParam.SignalWindow.v = 'flattop_116D'; % that is hft116D. 'flattop_248D' is better;  % window used in SP-WFFT algorithm.
% XXX! SigParam.SignalWindow.v = 'HFT116D'; % that 'should' be the same for
% WRMS, but it is hardcoded in gen_and_calc due to incompatibility and errors in
% WRMS window function.
SigParam.fEstimateForFit.v = 50;  % Estimate for fitting algorithm
SigParam.SV_SPP.v = 256;  %Required number of samples per period of the signal

%% Varied parameter ---------------------------------------- %<<<1
%---
% % number of periods:
% % round is needed to prevent rounding errors in WaveformGenerator algorithm!
% SigParamVar.M.v = [2 : 0.1 : 20];
% xaxisquantity = 'M.v';
% xaxislabel = 'Record length (samples)';

%---
% signal frequency
% SigParamVar.f.v = [49.9 : 0.0001 : 50.1];
SigParamVar.f.v = [49.9 : 0.1 : 50.1];
if multiple_harmonics
    SigParamVar.f.v = [SigParamVar.f.v; harm_multiple.*SigParamVar.f.v]';
end
% set same value for number of samples instead the number of periods:
SigParam = rmfield(SigParam, 'M');
% SigParam.L.v = 2./SigParam.f.v(1).*SigParam.fs.v; % 5 periods at 50 Hz, % Results differ for 2 or 5 periods
SigParam.L.v = 5./SigParam.f.v(1).*SigParam.fs.v; % 5 periods at 50 Hz, % Results differ for 2 or 5 periods
xaxisquantity = 'f.v';
xaxislabel = 'Signal frequency (Hz)';

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
    for ap = alg_prefixes
        for q = quantity_prefixes
            % example of eval:
            % res.FE_fErr = reshape([ndres.FE_fErr.v{:}], numel(SigParam.f.v), []);
            eval(sprintf('res.%s_%sErr.v = reshape([ndres.%s_%sErr.v{:}], numel(SigParam.%s.v), []);', ...
                            ap{1}, q{1}, ap{1}, q{1}, q{1}));
        end
    end
else % only single harmonic:
    for ap = alg_prefixes
        for q = quantity_prefixes
            % example of eval:
            % res.FE_fErr     = ndres.FE_fErr.v;
            eval(sprintf('res.%s_%sErr.v = ndres.%s_%sErr.v;', ...
                            ap{1}, q{1}, ap{1}, q{1}));
        end
    end
end

% wrap phase results to -pi..pi:
for ap = alg_prefixes
    % example of eval:
    % res.FE_phErr = wrapToPi(res.FE_phErr);
    eval(sprintf('res.%s_phErr.v = wrapToPi(res.%s_phErr.v);', ...
                    ap{1}, ap{1}));
end

%% Plotting ---------------------------------------- %<<<1
make_plot('A', res, ndaxes, 1, file_prefix, xaxislabel, alg_prefixes, quantity_prefixes);
make_plot('ph', res, ndaxes, 1, file_prefix, xaxislabel, alg_prefixes, quantity_prefixes);
if multiple_harmonics
    make_plot('A', res, ndaxes, 2, file_prefix, xaxislabel, alg_prefixes, quantity_prefixes);
    make_plot('ph', res, ndaxes, 2, file_prefix, xaxislabel, alg_prefixes, quantity_prefixes);
end


% % Amplitudes ---------------------------------------- %<<<2
% % main harmonic
% figure
% hold on
% % with (:,1) is needed for xaxis signal frequency in the case of multiple harmonics
% plot(ndaxes.values{1}(:,1), AErrFFTWin(1, :), '-k',...
%      ndaxes.values{1}(:,1), AErrFit(1, :), '-xg',...
%      ndaxes.values{1}(:,1), AErrEst(1, :), '-+b',...
%      ndaxes.values{1}(:,1), AErrResFFT(1, :), '-r');
% xlabel(xaxislabel)
% ylabel('Error from nominal value (V)')
% legend('A: FFT, window',...
%        'A: sine fit',...
%        'A: PSFE estimate',...
%        'A: resampling & FFT rect. window');
% title(sprintf('Main signal component, amplitude errors.\nEstimate of signal fr. based on PSFE.'))
% hold off
%
% saveas(gcf(), [file_prefix 'A_component_1.png'])
% saveas(gcf(), [file_prefix 'A_component_1.fig'])
%
% % second harmonic
% if multiple_harmonics
%     figure
%     hold on
%      % with (:,1) is needed for xaxis signal frequency in the case of multiple harmonics
%     plot(ndaxes.values{1}(:, 1), AErrFFTWin(2, :), '-k',...
%          ndaxes.values{1}(:, 1), AErrFit(2, :), '-xg',...
%          ndaxes.values{1}(:, 1), AErrEst(2, :), '-+b',...
%          ndaxes.values{1}(:, 1), AErrResFFT(2, :), '-r');
%     xlabel(xaxislabel)
%     ylabel('Error from nominal value (V)')
%     legend('A: FFT, window',...
%            'A: sine fit',...
%            'A: PSFE estimate',...
%            'A: resampling & FFT rect. window');
%     title(sprintf('Second signal component, amplitude errors.\nEstimate of signal fr. based on PSFE.'))
%     hold off
%
%     saveas(gcf(), [file_prefix 'A_component_2.png'])
%     saveas(gcf(), [file_prefix 'A_component_2.fig'])
% end
%
% % Phases ---------------------------------------- %<<<2
% % main harmonic
% figure
% hold on
%  % with (:,1) is needed for xaxis signal frequency in the case of multiple harmonics
% plot(ndaxes.values{1}(:, 1), phErrFFTWin(1, :), '-k',...
%      ndaxes.values{1}(:, 1), phErrFit(1, :), '-xg',...
%      ndaxes.values{1}(:, 1), phErrEst(1, :), '-+b',...
%      ndaxes.values{1}(:, 1), phErrResFFT(1, :), '-r');
% xlabel(xaxislabel)
% ylabel('Error from nominal value (rad), wrapped to -pi..pi')
% legend('ph: FFT, window',...
%        'ph: sine fit',...
%        'ph: PSFE estimate',...
%        'ph: resampling & FFT rect. window');
% title(sprintf('Main signal component, phase errors.\nEstimate of signal fr. based on PSFE.'))
% hold off
%
% saveas(gcf(), [file_prefix 'ph_component_1.png'])
% saveas(gcf(), [file_prefix 'ph_component_1.fig'])
%
% % second harmonic
% if multiple_harmonics
%     figure
%     hold on
%      % with (:,1) is needed for xaxis signal frequency in the case of multiple harmonics
%     plot(ndaxes.values{1}(:, 1), phErrFFTWin(2, :), '-k',...
%          ndaxes.values{1}(:, 1), phErrFit(2, :), '-xg',...
%          ndaxes.values{1}(:, 1), phErrEst(2, :), '-+b',...
%          ndaxes.values{1}(:, 1), phErrResFFT(2, :), '-r');
%     xlabel(xaxislabel)
%     ylabel('Error from nominal value (rad), wrapped to -pi..pi')
%     legend('ph: FFT, window',...
%            'ph: sine fit',...
%            'ph: PSFE estimate',...
%            'ph: resampling & FFT rect. window');
%     title(sprintf('Second signal component, phase errors.\nEstimate of signal fr. based on PSFE.'))
%     hold off
%
%     saveas(gcf(), [file_prefix 'ph_component_2.png'])
%     saveas(gcf(), [file_prefix 'ph_component_2.fig'])
% end

save('-7', [file_prefix 'input_and_plot_data.mat'])

end % function resampling_test

%% function make_plot %<<<1
function make_plot(quantity, res, ndaxes, data_index, file_prefix, xaxislabel, alg_prefixes, quantity_prefixes)
    figure
    hold on
    for alg = alg_prefixes
        % eval example:
        % val = ndaxes.values{1}(:,1), FE_AErr(1, :);
        eval(sprintf('val = res.%s_%sErr.v(data_index, :);', alg{1}, quantity));
        plot(ndaxes.values{1}(:,1), val, '-x')
    end
    xlabel = (xaxislabel);
    ylabel = ('Error from nominal value (Hz/V/rad)');
    tmp = 'Error from nominal value\nHarmonic component';
    legend(alg_prefixes);
    hold off
    saveas(gcf(), [file_prefix 'A_component_1.png'])
    saveas(gcf(), [file_prefix 'A_component_1.fig'])
end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=matlab textwidth=80 tabstop=4 shiftwidth=4
