% 2DO:
% MHFE,
% WFFT HFT116D,
% Real data
% 2nd, 3rd, 5th harmonic
% speed!

function resampling_test() %<<<1
addpath('~/metrologie/Q-Wave/qwtb/qwtb')
%% General settings ---------------------------------------- %<<<2
% file_prefix = 'f_no_harm_2_per_-_'; % file prefix for plots and data
file_prefix = 'quick_test'; % file prefix for plots and data
alg_prefixes = {'FE', 'SR', 'WF', 'MH', 'WR', 'SV'}; % algorithm prefixes
quantity_prefixes = {'fErr', 'AErr', 'phErr'}; % quantity prefixes

%% Calculation settings %<<<2
CS.verbose = 0;
CS.var.dir = '/dev/shm/qwtbvar_temp';
CS.var.fnprefix = file_prefix;
CS.var.cleanfiles = 1;

%% Settings of signal ---------------------------------------- %<<<2
% properties of the signal
% no harmonic:
SigParam.f.v = [50];      % nominal signal frequency (Hz)
SigParam.A.v = [1];       % nominal amplitude (V)
SigParam.ph.v = [0];      % nominal signal phase (rad)
SigParam.O.v = [0];      % nominal signal offset (V)
% harmonics 2-5:
harm_multiple = 3; % set to 1 if want only main component
if harm_multiple > 1
    SigParam.f.v = [50 harm_multiple.*50];      % nominal signal frequency (Hz)
    SigParam.A.v = [1 0.1];       % nominal amplitude (V)
    SigParam.ph.v = [0 0];      % nominal signal phase (rad)
    SigParam.O.v = [0 0];      % nominal signal offset (V)
end
SigParam.fs.v = 96e3;   % nominal sampling frequency (Hz)
SigParam.M.v = 5;      % length of the record in multiple of periods
% SigParam.L.v = 20./SigParam.f.v.*SigParam.fs.v;   % that is 20 periods at 50 Hz
SigParam.THD.v = 1e-3;  % nominal harmonic distortion 
% TODO When THD is used?
SigParam.nharm.v = 1;   % nominal number of harmonics
SigParam.noise.v = 0;% nominal signal noise (V)
% Additional parameters:
SigParam.EstimationAlgorithm.v = 'PSFE';  % Estimation algorithm used for resampling
SigParam.SR_Method.v = 'keepn';  %Resampling method of the SplineResample algorithm (possible values: 'keepN','minimizefs','poweroftwo')
SigParam.SignalWindow.v = 'flattop_116D'; % that is hft116D. 'flattop_248D' is better;  % window used in SP-WFFT algorithm.
% TODO! SigParam.SignalWindow.v = 'HFT116D'; % that 'should' be the same for
% WRMS, but it is hardcoded in gen_and_calc due to incompatibility and errors in
% WRMS window function.
SigParam.fEstimateForFit.v = 50;  % Estimate for fitting algorithm
SigParam.SV_SPP.v = 256;  %Required number of samples per period of the signal

%% Varied parameter ---------------------------------------- %<<<2
%---
% % number of periods:
% % round is needed to prevent rounding errors in WaveformGenerator algorithm!
% SigParamVar.M.v = [2 : 0.1 : 20];
% xaxisquantity = 'M.v';
% xaxislabel = 'Record length (samples)';

%---
% signal frequency
SigParamVar.f.v = [49.9 : 0.001 : 50.1];
SigParamVar.f.v = [49.9 : 0.1 : 50.1]; % TODO
if harm_multiple > 1
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

%% Calculation ---------------------------------------- %<<<2
jobfn = qwtbvar('calc', 'gen_and_calc', SigParam, SigParamVar, CS);

%% Parse results ---------------------------------------- %<<<2
% get results
[ndres ndresc ndaxes] = qwtbvar('result', jobfn);
% reshape needed because of multiple harmonics:
if harm_multiple > 1
    for ap = alg_prefixes
        for q = quantity_prefixes
            % example of eval:
            % res.FE_fErr.v = reshape([ndres.FE_fErr.v{:}], numel(SigParam.f.v), []);
            tmp = sprintf('res.%s_%s.v = reshape([ndres.%s_%s.v{:}], numel(SigParam.f.v), []);', ...
                            ap{1}, q{1}, ap{1}, q{1});
            eval(tmp);
        end
    end
else % only single harmonic:
    for ap = alg_prefixes
        for q = quantity_prefixes
            % example of eval:
            % res.FE_fErr.v = ndres.FE_fErr.v;
            tmp = sprintf('res.%s_%s.v = ndres.%s_%s.v;', ...
                            ap{1}, q{1}, ap{1}, q{1})
            eval(tmp);
        end
    end
end
for ap = alg_prefixes
    % example of eval:
    % res.FE_ct.v = ndres.FE_ct.v;
    tmp = sprintf('res.%s_ct.v = ndres.%s_ct.v;', ...
                    ap{1}, ap{1});
    eval(tmp);
end

% wrap phase results to -pi..pi:
for ap = alg_prefixes
    % example of eval:
    % res.FE_phErr = wrapToPi(res.FE_phErr);
    tmp = sprintf('res.%s_phErr.v = wrapToPi(res.%s_phErr.v);', ...
                    ap{1}, ap{1});
    eval(tmp);
end

%% Plotting ---------------------------------------- %<<<2
make_plot('AErr', res, ndaxes, 1, file_prefix, xaxislabel, alg_prefixes);
make_plot('phErr', res, ndaxes, 1, file_prefix, xaxislabel, alg_prefixes);
make_plot('ct', res, ndaxes, 1, file_prefix, xaxislabel, alg_prefixes);
if harm_multiple > 1
    make_plot('AErr', res, ndaxes, 2, file_prefix, xaxislabel, alg_prefixes);
    make_plot('phErr', res, ndaxes, 2, file_prefix, xaxislabel, alg_prefixes);
end

save('-7', [file_prefix 'input_and_plot_data.mat'])

end % function resampling_test

%% function make_plot %<<<1
function make_plot(quantity, res, ndaxes, data_index, file_prefix, xaxislabel, alg_prefixes)
    figure
    hold on
    for alg = alg_prefixes
        % eval example:
        % val = ndaxes.values{1}(:,1), FE_AErr(1, :);
        tmp = sprintf('val = res.%s_%s.v(data_index, :);', alg{1}, quantity);
        eval(tmp);
        plot(ndaxes.values{1}(:,1), val, '-x')
    end
    xlabel(xaxislabel);
    ylabel([quantity ': error from nominal value (Hz/V/rad)']);
    if data_index > 1
        tmp = sprintf('Error from nominal value\nn-th harmonic component');
    else
        tmp = sprintf('Error from nominal value\nmain component');
    end
    title(tmp);
    legend(alg_prefixes);
    hold off
    fn = sprintf('%s_%s_hm_%d.', file_prefix, quantity, data_index);
    saveas(gcf(), [fn '.png'])
    saveas(gcf(), [fn '.fig'])
end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=matlab textwidth=80 tabstop=4 shiftwidth=4
