function alg_test(calcset) %<<<1
% Part of QWTB. Test script for algorithm resamplingSVstream.
%
% See also qwtb

% Based on a script resamplingSVstream, in a fact only copy what is part of
% integrated function of the resamplingSVstream file. This is only basic test
% because the algorithm is quite selftested.

% Generate sample data --------------------------- %<<<1
L = 1280;
A = 1;
DI.fs.v = 12800;
t = [0:L-1] ./ DI.fs.v;
DI.fest.v = 50;
DI.y.v = A.*sin(2.*pi.*DI.fest.v.*t + 0);

% Call algorithm --------------------------- %<<<1
DO = qwtb('resamplingSVstream', DI);

% Check results --------------------------- %<<<1
tmp = max(abs(fft(DO.y.v))./(numel(DO.y.v)./2));
assert(tmp, A, 50e-6);

end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=matlab textwidth=80 tabstop=4 shiftwidth=4
