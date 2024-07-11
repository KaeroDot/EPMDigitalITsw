function alginfo = alg_info() %<<<1
% Part of QWTB. Info script for algorithm windowedRMS
%
% See also qwtb

alginfo.id = 'windowedRMS';
alginfo.name = 'Windowed RMS';
alginfo.desc = 'Algorithm estimate RMS amplitude of a sampled waveform |y|. If inputs |u| (sampled voltage) and |i| (sampled current) are supplied instead of |y|, algorithms calculates not only RMS amplitudes, but also active power, apparent power, and phase between two waveforms. Possible values for |window| are: `hann`, `rect`, `bartlett`, `welch`, `hann`, `hamming`, `blackman`, `BH92`, `flattop`, `HFT70`, `HFT90D`, `HFT95`, `HFT116D`, `HFT144D`, `HFT169D`, `HFT196D`, `HFT223D`, `HFT248D`.';
alginfo.citation = 'Rado Lapuh, "Signal Parameter Estimation using windowed RMS method"';
alginfo.remarks = '';
alginfo.license = 'no license';

alginfo.inputs(1).name = 'y';
alginfo.inputs(1).desc = 'Sampled values';
alginfo.inputs(1).alternative = 0;
alginfo.inputs(1).optional = 1;
alginfo.inputs(1).parameter = 0;

alginfo.inputs(2).name = 'u';
alginfo.inputs(2).desc = 'Sampled voltage';
alginfo.inputs(2).alternative = 0;
alginfo.inputs(2).optional = 1;
alginfo.inputs(2).parameter = 0;

alginfo.inputs(3).name = 'i';
alginfo.inputs(3).desc = 'Sampled current';
alginfo.inputs(3).alternative = 0;
alginfo.inputs(3).optional = 1;
alginfo.inputs(3).parameter = 0;

alginfo.inputs(4).name = 'window';
alginfo.inputs(4).desc = 'Name of window function';
alginfo.inputs(4).alternative = 0;
alginfo.inputs(4).optional = 1;
alginfo.inputs(4).parameter = 1;

alginfo.outputs(1).name = 'A';
alginfo.outputs(1).desc = 'RMS amplitude of a single signal';

alginfo.outputs(2).name = 'U';
alginfo.outputs(2).desc = 'RMS amplitude of a voltage signal';

alginfo.outputs(3).name = 'I';
alginfo.outputs(3).desc = 'RMS amplitude of a current signal';

alginfo.outputs(4).name = 'P';
alginfo.outputs(4).desc = 'Windowed active power';

alginfo.outputs(5).name = 'S';
alginfo.outputs(5).desc = 'Windowed apparent power';

alginfo.outputs(6).name = 'phi_ef';
alginfo.outputs(6).desc = 'Effective phase shift, acos(PF) [rad]';

alginfo.outputs(7).name = 'PF';
alginfo.outputs(7).desc = 'Power factor';

alginfo.providesGUF = 0;
alginfo.providesMCM = 0;

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
