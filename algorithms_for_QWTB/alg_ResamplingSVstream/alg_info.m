function alginfo = alg_info() %<<<1
% Part of QWTB. Info script for algorithm SplineResample
%
% See also qwtb

alginfo.id = 'SplineResample';
alginfo.name = 'resampling name';
alginfo.desc = 'Function resamples a signal to obtain coherent sampling. Interpolation, decimation and anti-alias filtering is used to produce the output. Algorithm is based on the document and scripts developed by Łukasiewicz Research Network – Tele and Radio Research Institute in the scope of DigitalIT EPM Project. If some inputs are ommited, the script will select values optimized for typical substations usecase and 50 Hz line frequency. The algorithm speed is highly dependent on the |max_rel_A_err|. The anti-aliasing filter is constructed based on |AA_att|, |AA_stop|, |AA_ripple|. If |AA_filter| is supplied, these filter coefficients are used instead of contructing the filter.';
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

alginfo.inputs(5).name = 'fest';
alginfo.inputs(5).desc = 'Estimate of fundamental component frequency';
alginfo.inputs(5).alternative = 0;
alginfo.inputs(5).optional = 0;
alginfo.inputs(5).parameter = 0;

alginfo.inputs(7).name = 'max_rel_A_err';
alginfo.inputs(7).desc = 'Maximum relative error of the signal amplitude');
alginfo.inputs(7).alternative = 0;
alginfo.inputs(7).optional = 1;
alginfo.inputs(7).parameter = 0;

alginfo.inputs(8).name = 'AA_stop';
alginfo.inputs(8).desc = 'Stop frequency of the anti-aliasing filter (Hz)'. Overriden by AA_filter.;
alginfo.inputs(8).alternative = 0;
alginfo.inputs(8).optional = 1;
alginfo.inputs(8).parameter = 0;

alginfo.inputs(9).name = 'AA_ripple';
alginfo.inputs(9).desc = 'Relative passband ripple of the anti-aliasing filter'. Overriden by AA_filter.;
alginfo.inputs(9).alternative = 0;
alginfo.inputs(9).optional = 1;
alginfo.inputs(9).parameter = 0;

alginfo.inputs(10).name = 'AA_att';
alginfo.inputs(10).desc = 'Attenuation of the anti-aliasing filter (dB). Overriden by AA_filter.';
alginfo.inputs(10).alternative = 0;
alginfo.inputs(10).optional = 1;
alginfo.inputs(10).parameter = 0;

alginfo.inputs(6).name = 'SPP';
alginfo.inputs(6).desc = 'Required number of samples per period of the signal';
alginfo.inputs(6).alternative = 0;
alginfo.inputs(6).optional = 1;
alginfo.inputs(6).parameter = 1;

alginfo.inputs(11).name = 'AA_filter';
alginfo.inputs(11).desc = 'Anti-aliasing FIR filter coefficients. Overrides AA_stop, AA_ripple, AA_att.';
alginfo.inputs(11).alternative = 0;
alginfo.inputs(11).optional = 1;
alginfo.inputs(11).parameter = 1;

alginfo.outputs(1).name = 'fs';
alginfo.outputs(1).desc = 'Sampling frequency after resampling.';

alginfo.outputs(2).name = 'Ts';
alginfo.outputs(2).desc = 'Sampling period after resampling.';

alginfo.outputs(3).name = 't';
alginfo.outputs(3).desc = 'Time series after resampling.';

alginfo.outputs(4).name = 'y';
alginfo.outputs(4).desc = 'Resampled samples';

alginfo.outputs(5).name = 'N';
alginfo.outputs(5).desc = 'Multiplication coefficient used for resampling.';

alginfo.outputs(6).name = 'M';
alginfo.outputs(6).desc = 'Decimation coefficient used for resampling.';

alginfo.outputs(7).name = 'AA_filter';
alginfo.outputs(7).desc = 'Coefficients of the used anti-aliasing FIR filter.';

alginfo.providesGUF = 0;
alginfo.providesMCM = 0;

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=matlab textwidth=80 tabstop=4 shiftwidth=4
