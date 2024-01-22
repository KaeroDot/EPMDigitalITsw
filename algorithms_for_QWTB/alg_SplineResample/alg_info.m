function alginfo = alg_info() %<<<1
% Part of QWTB. Info script for algorithm SplineResample
%
% See also qwtb

alginfo.id = 'SplineResample';
alginfo.name = 'resampling name';
alginfo.desc = 'Splines are used to resample sampled data to a new sampling frequency.';
alginfo.citation = 'no citation';
alginfo.remarks = 'no remark';
alginfo.license = 'no license';

alginfo.inputs(1).name = 'Ts';
alginfo.inputs(1).desc = 'Sampling period';
alginfo.inputs(1).alternative = 1;
alginfo.inputs(1).optional = 0;
alginfo.inputs(1).parameter = 0;

alginfo.inputs(2).name = 'fs';
alginfo.inputs(2).desc = 'Sampling frequency';
alginfo.inputs(2).alternative = 1;
alginfo.inputs(2).optional = 0;
alginfo.inputs(2).parameter = 0;

alginfo.inputs(3).name = 't';
alginfo.inputs(3).desc = 'Time series';
alginfo.inputs(3).alternative = 1;
alginfo.inputs(3).optional = 0;
alginfo.inputs(3).parameter = 0;

alginfo.inputs(4).name = 'y';
alginfo.inputs(4).desc = 'Sampled values';
alginfo.inputs(4).alternative = 0;
alginfo.inputs(4).optional = 0;
alginfo.inputs(4).parameter = 0;

alginfo.inputs(5).name = 'Tsest';
alginfo.inputs(5).desc = 'Estimate of sampling period';
alginfo.inputs(5).alternative = 2;
alginfo.inputs(5).optional = 0;
alginfo.inputs(5).parameter = 0;

alginfo.inputs(6).name = 'fsest';
alginfo.inputs(6).desc = 'Estimate of sampling frequency';
alginfo.inputs(6).alternative = 2;
alginfo.inputs(6).optional = 0;
alginfo.inputs(6).parameter = 0;

alginfo.inputs(7).name = 'test';
alginfo.inputs(7).desc = 'Estimate of time series';
alginfo.inputs(7).alternative = 2;
alginfo.inputs(7).optional = 0;
alginfo.inputs(7).parameter = 0;

alginfo.outputs(1).name = 'y';
alginfo.outputs(1).desc = 'Resampled samples';

alginfo.outputs(2).name = 'fs';
alginfo.outputs(2).desc = 'Sampling frequency after resampling, equal to fsest.';

alginfo.outputs(2).name = 'Ts';
alginfo.outputs(2).desc = 'Sampling period after resampling, equal to fsest.';

alginfo.outputs(3).name = 't';
alginfo.outputs(3).desc = 'Time series after resampling, equal to test';

alginfo.providesGUF = 0;
alginfo.providesMCM = 0;

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
