function dataout = alg_wrapper(datain, calcset)
% Part of QWTB. Wrapper script for algorithm SplineResample.
%
% See also qwtb

% Format input data --------------------------- %<<<1
% Get time vector if missing %<<<2
if isfield(datain, 'Ts')
    datain.t.v = (0 : numel(datain.y.v) - 1) .* datain.Ts.v;
    if calcset.verbose
        disp('QWTB: SplineResample wrapper: sampling time series was calculated from sampling period')
    end
elseif isfield(datain, 'fs')
    datain.t.v = (0 : numel(datain.y.v) - 1) ./ datain.fs.v;
    if calcset.verbose
        disp('QWTB: SplineResample wrapper: sampling time series was calculated from sampling frequency')
    end
end

% Get new time vector if missing %<<<2
if isfield(datain, 'Tsest')
    datain.test.v = (0 : numel(datain.y.v) - 1) .* datain.Tsest.v;
    if calcset.verbose
        disp('QWTB: SplineResample wrapper: new sampling time series was calculated from sampling period')
    end
elseif isfield(datain, 'fsest')
    datain.test.v = (0 : numel(datain.y.v) - 1) ./ datain.fsest.v;
    if calcset.verbose
        disp('QWTB: SplineResample wrapper: new sampling time series was calculated from sampling frequency')
    end
end

% Call resampling algorithm ---------------------------  %<<<1
spline = CubicSpline(datain.t.v, datain.y.v);
dataout.y.v = spline.evaluate(datain.test.v);

% Format additional output data:  --------------------------- %<<<1
dataout.Ts.v = mean(diff(datain.test.v));
dataout.fs.v = 1./dataout.Ts.v;
dataout.t.v = datain.test.v;

end % function
