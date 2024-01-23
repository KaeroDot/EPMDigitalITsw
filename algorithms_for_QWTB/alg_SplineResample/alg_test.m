function alg_test(calcset) %<<<1
% Part of QWTB. Test script for algorithm SplineResample.
%
% See also qwtb

% Input data
T = 1;
f = 1/T;
A = 1;
N = 40;
fs = 10;
Ts = 1/fs;
t = (0:N-1)*Ts;
y = A*sin(2*pi*f*t);

DI.y.v = y(1:35);
DI.fs.v = fs;
DI.fest.v = f;

% Call algorithm
% without explicitly set, the method should be 'keepN'
DOnominalmethod = qwtb('SplineResample', DI);
DI.method.v = 'keepN';
DOkeepn = qwtb('SplineResample', DI);
DI.method.v = 'minimizefs';
DOminimizefs = qwtb('SplineResample', DI);
DI.method.v = 'poweroftwo';
DOpoweroftwo = qwtb('SplineResample', DI);

% Check results --------------------------- %<<<1
assert(numel(DOnominalmethod.y.v) == numel(DI.y.v));
assert(numel(DOkeepn.y.v) == numel(DI.y.v));
% assert(numel(DOminimizefs.y.v) ==  ??? XXX
% assert(numel(DOpoweroftwo.y.v) == 2^5; % DOES NOT WORK

                % maxerr = 1e-10;
                % assert((DO.f.v > fnom.*(1-maxerr)) & (DO.f.v < fnom.*(1+maxerr)));

error('algorithm test not finished!')

% Call algorithm

% Test for all available methods

end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
