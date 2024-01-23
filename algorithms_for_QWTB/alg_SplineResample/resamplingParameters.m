function [Output] = resamplingParameters(ts,N,fEst,div)
% resamplingParameters returns resampling parameters for coherent sampling
%
% input parameters
%   ts    is original sampling time in s
%   N     is the original record length
%   fEst  is the estimated fundamental component frequency
%   div   (optional) is output sampling frequency divider (not affecting
%   case 1), see *
%
% output parameters
%   Output.Nr   are resulting number of samples 
%   Output.tr   are resulting sampling times
%   Output.p    are integer upsampling factors
%   Output.q    are integer decimation factors
%   
%  every output paramerter is a vector, where indexes point to these cases:
%  1  keep original N, so N = Output.Nr
%  2  minimize sampling rate change, so ts =~ Output.tr
%  3  force Output.Nr = 2^n, where n is integer and Nr is closest to N
%
%  * div > 1 (typically integer) will reduce the resampled bandwidth, so
%  there should be no meaningfull spectral components above 1/(2*ts*div) or
%  appropriate digital filtering shall be employed before resampling

if (nargin < 4)
  div = 1;
end

ssfr = 1 / (ts*fEst);    % the actual sampling/signal frequency ratio
Cycles = floor(N/ssfr);  % number of full cycles available
%   case 1  keep original N, so N = Output.Nr
Nr = N;
NewSamplingTime = (Cycles/fEst)/Nr;
[p,q] = rat(ts / NewSamplingTime);
if p*q > 2^31
  p = 1; q = 1;
end
Output.Nr(1) = N;
Output.tr(1) = NewSamplingTime;
Output.p(1)  = p;
Output.q(1)  = q;
% case 2  minimize sampling rate change, so ts/div =~Output.tr
Nr = round(Cycles * ssfr / div);      % 
NewSamplingTime = (Cycles/fEst)/Nr;
[p,q] = rat(ts / NewSamplingTime);
if p*q > 2^31
  p = 1; q = 1;
end
Output.Nr(2) = Nr;
Output.tr(2) = NewSamplingTime;
Output.p(2)  = p;
Output.q(2)  = q;
% case 3  force Output.Nr = 2^n, where n is integer
Nr = round(Cycles * ssfr / div);      % 
n = log(Nr)/log(2);
nr = round(n);
Nr = 2^nr;
NewSamplingTime = (Cycles/fEst)/Nr;
[p,q] = rat(ts / NewSamplingTime);
if p*q > 2^31
  p = 1; q = 1;
end
Output.Nr(3) = Nr;
Output.tr(3) = NewSamplingTime;
Output.p(3)  = p;
Output.q(3)  = q;

end
