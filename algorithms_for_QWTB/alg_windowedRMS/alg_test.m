function alg_test(calcset) %<<<1
% Part of QWTB. Test script for algorithm windowedRMS.
%
% See also qwtb

CS.verbose = 0;

% Input data
T = 1;
f = 1/T;
A = 1;
N = 40;
fs = 10;
Ts = 1/fs;
t = (0:N-1)*Ts;
y = A   * sin(2*pi * f * t + 0);
u = A/2 * sin(2*pi * f * t + 0);
i = A/4 * sin(2*pi * f * t + pi/4);

% test single waveform input:
DI.y.v = y;

% Call algorithm
DO = qwtb('windowedRMS', DI, CS);
assert(DO.A.v, 1/sqrt(2), 1e-15)

% test double waveform input:
DI.u.v = u;
DI.i.v = i;
DO = qwtb('windowedRMS', DI, CS);
assert(DO.U.v, 0.5/sqrt(2), 1e-15)
assert(DO.I.v, 0.25/sqrt(2), 1e-15)
assert(DO.P.v, DO.U.v * DO.I.v * DO.PF.v, 1e-15)
assert(DO.P.v, DO.U.v * DO.I.v * cos(DO.phi_ef.v), 1e-15)
assert(DO.S.v, DO.U.v * DO.I.v, 1e-15)

% test double waveform input when y is missing
DI = rmfield(DI, 'y');
DO = qwtb('windowedRMS', DI, CS);
assert(DO.U.v, 0.5/sqrt(2), 1e-15)
assert(DO.I.v, 0.25/sqrt(2), 1e-15)

% test all windows
avail_windows = {'hann', 'rect', 'bartlett', 'welch', 'hann', 'hamming', 'blackman', 'BH92', 'flattop', 'HFT70', 'HFT90D', 'HFT95', 'HFT116D', 'HFT144D', 'HFT169D', 'HFT196D', 'HFT223D', 'HFT248D'};
for j = 1:numel(avail_windows)
    DI.window.v = avail_windows{j};
    DO = qwtb('windowedRMS', DI, CS);
    % some windows got quite large error for the defined waveform
    assert(DO.U.v, 0.5/sqrt(2), 2e-2)
    assert(DO.I.v, 0.25/sqrt(2), 2e-2)
    assert(DO.P.v, DO.U.v * DO.I.v * DO.PF.v, 1e-15)
end % for

end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
