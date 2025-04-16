% TODO
% MHFE,
% WFFT HFT116D,
% Real data

function resampling_test(test_case, file_prefix, harm_multiple) %<<<1

% addpath('~/metrologie/Q-Wave/qwtb/qwtb')
addpath('~/metrologie/Q-Wave/qwtb/qwtb')
%% Input settings ---------------------------------------- %<<<2
if not(exist('test_case'))
    test_case = 1; % nominal test case number 1, signal frequency
end
if not(exist('file_prefix'))
    file_prefix = 'quick_test'; % file prefix for plots and data
end
% additional harmonics: none, 2, 3, 5:
if not(exist('harm_multiple'))
    harm_multiple = 1; % set to 1 if want only main component
end

% constants:
alg_prefixes = {'FE', 'SR', 'WF', 'MH', 'WR', 'SV'}; % algorithm prefixes
quantity_prefixes = {'fErr', 'AErr', 'phErr'}; % quantity prefixes

%% Calculation settings %<<<2
CS.verbose = 0;
CS.var.dir = '/dev/shm/qwtbvar_temp';
CS.var.fnprefix = file_prefix;
CS.var.cleanfiles = 1;
CS.var.method = 'multicore';
CS.var.procno = 20;

%% Settings of signal ---------------------------------------- %<<<2
% properties of the signal
% no harmonic:
SigParam.f.v = [50];      % nominal signal frequency (Hz)
SigParam.A.v = [1];       % nominal amplitude (V)
SigParam.ph.v = [0];      % nominal signal phase (rad)
SigParam.O.v = [0];      % nominal signal offset (V)
if harm_multiple > 1
    SigParam.f.v =  [50 harm_multiple.*50];      % nominal signal frequency (Hz)
    SigParam.A.v =  [1 0.1];       % nominal amplitude (V)
    SigParam.ph.v = [0 0];      % nominal signal phase (rad)
    SigParam.O.v =  [0 0];      % nominal signal offset (V)
end
SigParam.fs.v = 96e3;   % nominal sampling frequency (Hz)
SigParam.M.v = 5;      % length of the record in multiple of periods
% SigParam.L.v = 20./SigParam.f.v.*SigParam.fs.v;   % that is 20 periods at 50 Hz
% SigParam.THD.v = 1e-3;  % nominal harmonic distortion - not used because amplitudes are given
SigParam.nharm.v = 1;   % nominal number of harmonics
SigParam.noise.v = 0;% nominal signal noise (V)
% Additional parameters:
SigParam.EstimationAlgorithm.v = 'PSFE';  % Estimation algorithm used for resampling
SigParam.SR_Method.v = 'keepn';  %Resampling method of the SplineResample algorithm (possible values: 'keepN','minimizefs','poweroftwo')
SigParam.SignalWindow.v = 'flattop_116D'; % that is hft116D. 'flattop_248D' is better;  % window used in SP-WFFT algorithm.
% TODO! SigParam.SignalWindow.v = 'HFT116D'; % that 'should' be the same for
% WRMS, but it is hardcoded in gen_and_calc due to incompatibility and errors in WRMS window function. TODO
SigParam.fEstimateForFit.v = 50;  % Estimate for fitting algorithm
SigParam.SV_SPP.v = 256;  %Required number of samples per period of the signal

%% Varied parameter ---------------------------------------- %<<<2
if test_case == 1 % varied number of periods %<<<3
    % round is needed to prevent rounding errors in WaveformGenerator algorithm!
    SigParamVar.M.v = [3 : 0.1 : 20];
    xaxisquantity = 'M.v';
    xaxislabel = 'Record length (samples)';
elseif test_case == 2 % varied signal frequency %<<<3
    SigParamVar.f.v = [49.9 : 0.001 : 50.1];
    if harm_multiple > 1
        SigParamVar.f.v = [SigParamVar.f.v; harm_multiple.*SigParamVar.f.v]';
    end
    % set same value for number of samples instead the number of periods:
    SigParam = rmfield(SigParam, 'M');
    % SigParam.L.v = 2./SigParam.f.v(1).*SigParam.fs.v; % 5 periods at 50 Hz, % Results differ for 2 or 5 periods
    SigParam.L.v = 5./SigParam.f.v(1).*SigParam.fs.v; % 5 periods at 50 Hz, % Results differ for 2 or 5 periods
    xaxisquantity = 'f.v';
    xaxislabel = 'Signal frequency (Hz)';
elseif test_case == 3 % varied sampling frequency %<<<3
    % sampling frequency
    SigParamVar.fs.v = [4000 : 100/3 : 96000];
    xaxisquantity = 'fs.v';
    xaxislabel = 'Sampling frequency (Hz)';
elseif test_case == 4 % varied signal noise %<<<3
    SigParamVar.noise.v = logspace(-6, -2, 200);
    xaxisquantity = 'noise.v';
    xaxislabel = 'Noise (σ)';
else
    error('resampling_test: unknown test_case!')
end

%% Ensure path ---------------------------------------- %<<<2
fdir = fileparts(file_prefix);
if not(isempty(fdir))
    if not(exist(fdir, 'dir'))
        mkdir(fdir);
    end
end

%% Calculation ---------------------------------------- %<<<2
jobfn = qwtbvar('calc', 'gen_and_calc', SigParam, SigParamVar, CS);

%% Parse results ---------------------------------------- %<<<2
% get results
[ndres ndresc ndaxes] = qwtbvar('result', jobfn);

% reshape usefull in case of multiple harmonics:
if harm_multiple > 1
    for ap = alg_prefixes
        for q = quantity_prefixes
            % example of eval:
            % res.FE_fErr.v = reshape([ndres.FE_fErr.v{:}], numel(SigParam.f.v), []);
            tmp = sprintf('ndres.%s_%s.v = reshape([ndres.%s_%s.v{:}], numel(SigParam.f.v), []);', ...
                            ap{1}, q{1}, ap{1}, q{1});
            eval(tmp);
        end
    end
end
% wrap phase results to -pi..pi:
for ap = alg_prefixes
    % example of eval:
    % ndres.FE_phErr = wrapToPi(ndres.FE_phErr);
    tmp = sprintf('ndres.%s_phErr.v = wrapToPi(ndres.%s_phErr.v);', ...
                    ap{1}, ap{1});
    eval(tmp);
end

%% Plotting ---------------------------------------- %<<<2
make_plot('AErr', 'Amplitude error', ndres, ndaxes, harm_multiple, 1, file_prefix, xaxislabel, alg_prefixes);
make_plot('phErr', 'Phase error', ndres, ndaxes, harm_multiple, 1, file_prefix, xaxislabel, alg_prefixes);
make_plot('ct', 'Calculation time', ndres, ndaxes, harm_multiple, 1, file_prefix, xaxislabel, alg_prefixes);
if harm_multiple > 1
    make_plot('AErr', 'Amplitude error', ndres, ndaxes, harm_multiple, 2, file_prefix, xaxislabel, alg_prefixes);
    make_plot('phErr', 'Phase error', ndres, ndaxes, harm_multiple, 2, file_prefix, xaxislabel, alg_prefixes);
end

save('-7', [file_prefix 'input_and_plot_data.mat'])

end % function resampling_test

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=matlab textwidth=80 tabstop=4 shiftwidth=4
