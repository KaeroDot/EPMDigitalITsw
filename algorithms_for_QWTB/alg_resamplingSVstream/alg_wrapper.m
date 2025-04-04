function dataout = alg_wrapper(datain, calcset)
% Part of QWTB. Wrapper script for algorithm resamplingSVstream.
%
% See also qwtb

% Format input data --------------------------- %<<<1
% Get fs if missing
if not(isfield(datain, 'fs'))
    if isfield(datain, 'Ts')
        datain.fs.v = 1./datain.Ts.v;
        if calcset.verbose
            disp('QWTB: resamplingSVstream wrapper: sampling frequency was calculated from sampling period')
        end
    else
        datain.fs.v = 1./mean(diff(datain.t.v));
        if calcset.verbose
            disp('QWTB: resamplingSVstream wrapper: sampling frequency was calculated from time series')
        end
    end
end % if not(isfield(datain, 'fs'))

if isfield(datain, 'max_rel_A_err')
    max_rel_A_err = datain.max_rel_A_err.v;
else
    max_rel_A_err = [];
end

if isfield(datain, 'AA_stop')
    AA_stop = datain.AA_stop.v;
else
    AA_stop = [];
end

if isfield(datain, 'AA_ripple')
    AA_ripple = datain.AA_ripple.v;
else
    AA_ripple = [];
end

if isfield(datain, 'AA_att')
    AA_att = datain.AA_att.v;
else
    AA_att = [];
end

if isfield(datain, 'AA_filter')
    AA_filter = datain.AA_filter.v;
else
    AA_filter = [];
end

if isfield(datain, 'SPP')
    SPP = datain.SPP.v;
else
    SPP = [];
end

% Call the algorithm ---------------------------  %<<<1
[dataout.y.v, dataout.N.v, dataout.M.v, dataout.fs.v, dataout.AA_filter.v, dataout.t.v] = resamplingSVstream( ...
    datain.y.v, ...
    datain.fs.v, ...
    datain.fest.v, ...
    SPP, ...
    max_rel_A_err, ...
    AA_stop, ...
    AA_ripple, ...
    AA_att, ...
    AA_filter, ...
    1, ...
    calcset.verbose);

end % function
