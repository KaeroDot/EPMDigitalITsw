function dataout = alg_wrapper(datain, calcset)
% Part of QWTB. Wrapper script for algorithm SplineResample.
%
% See also qwtb

% Format input data --------------------------- %<<<1
% Number of samples
N = numel(datain.y.v);

% Get Ts if missing
if not(isfield(datain, 'Ts'))
    if isfield(datain, 'fs')
        datain.Ts.v = 1./datain.fs.v;
        if calcset.verbose
            disp('QWTB: SplineResample wrapper: sampling time was calculated from sampling frequency')
        end
    else
        datain.Ts.v = mean(diff(datain.t.v));
        if calcset.verbose
            disp('QWTB: SplineResample wrapper: sampling time was calculated from time series')
        end
    end
end % if not(isfield(datain, 'Ts'))

% Generate also time series if missing
if not(isfield(datain, 't'))
    datain.t.v = (0:N-1)*datain.Ts.v;
end

% Check value of resampling method
available_methods = {'keepN',...
                     'minimizefs',...
                     'poweroftwo',...
                    };
if isfield(datain, 'method')
    if not(strcmpi(datain.method.v, available_methods))
        msg = sprintf('%s, ', available_methods{:});
        msg = sprintf('QWTB: SplineResample wrapper: required resampling method `%s` is not available. Only following values are permitted: %s', datain.method.v, msg);
        error(msg);
    end
else
    datain.method.v = 'keepN';
end

% Chack bandwidth denominator D
if isfield(datain, 'D')
    if datain.D.v < 1
        error('QWTB: SplineResample wrapper: quantity |D| has to be greater or equal to 1.')
    else
        div = datain.D.v;
    end
else
    div = 1;
end

% Call resampling algorithm ---------------------------  %<<<1
% Find out resampling parameters
[Output] = resamplingParameters(datain.Ts.v, N, datain.fest.v, div);
% Get sampling period based on selected method:
if strcmpi(datain.method.v, 'keepN')
    Tsr = Output.tr(1);
    dataout.Pf.v = Output.p(1);
    dataout.Qf.v = Output.q(1);
elseif strcmpi(datain.method.v, 'minimizefs')
    Tsr = Output.tr(2);
    dataout.Pf.v = Output.p(2);
    dataout.Qf.v = Output.q(2);
elseif strcmpi(datain.method.v, 'poweroftwo')
    Tsr = Output.tr(3);
    dataout.Pf.v = Output.p(3);
    dataout.Qf.v = Output.q(3);
else
    msg = sprintf('%s, ', available_res_methods{:});
    msg = sprintf('QWTB: SplineResample wrapper: required resampling method `%s` is not available. Only following values are permitted: %s', datain.res_method.v, msg);
    error(msg);
end % if strcmpi(datain.method.v,
% create time series from selected sampling period:
tr = (0:N-1)*Tsr;

spline = CubicSpline(datain.t.v, datain.y.v);
dataout.y.v = spline.evaluate(tr);

% Format additional output data:  --------------------------- %<<<1
dataout.t.v = tr;
dataout.Ts.v = Tsr;
dataout.fs.v = 1./Tsr;
dataout.method.v = datain.method.v;

end % function
