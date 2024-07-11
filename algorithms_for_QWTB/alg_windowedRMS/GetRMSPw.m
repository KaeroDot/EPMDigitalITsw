function [Result] = GetRMSPw(Record,window_name,SNR)
%% calculate Amplitudes and Power by Windowed discrete RMS sum
%   [U I Pactive Papparent] = GetRMSw(RecordU,RecordI,window_name)
%
%   output
%     Result        structure with all results
%       .Uw         windowed RMS voltage amplitude in V
%       .Iw         windowed RMS current amplitude in A
%       .Pw         windowed active power in W
%       .Sw         windowed apparent power in VA
%       .P          non-windowed active power in W
%       .S          non-windowed apparent power in VA
%       .phase      phase in rad
%
%   input
%     Record(1xN)   input signal record
%                 or
%     Record(2xN)   
%                 1: voltage sampled data in V
%                 2: current sampled data in A
%     window_name chosen window from
%                 'hann'
%                 'rect' or no window
%                 'bartlett'
%                 'welch'
%                 'hann'
%                 'hamming'
%                 'blackman' (default)
%                 'BH92'
%                 'flattop'
%                 'HFT70'
%                 'HFT90D'
%                 'HFT95'
%                 'HFT116D'
%                 'HFT144D'
%                 'HFT169D'
%                 'HFT196D'
%                 'HFT223D'
%                 'HFT248D'

if (nargin == 2)
    SNR = -20;
end
if (nargin == 1)
    window_name = 'blackman';
end
RecordSize = size(Record);
N = max(RecordSize);
M = min(RecordSize);

w = win(N,window_name);   % returns selected window function
S2 = sum(w.^2);

Recordw = Record .* w;
if M == 1
  % one signal
  Result.Uw = sqrt(sum(Recordw .* Recordw)/S2);
else
  RecordU = Record(1,:);
  RecordI = Record(2,:);
  RecordP = RecordU .* RecordI;
  RecordPw = RecordP .* w.^2;
  % calculate all amplitude and power estimates
  Result.Uw = sqrt(sum(Recordw(1,:) .* Recordw(1,:))/S2);
  Result.Uwc = Result.Uw; % / SNR_Ucorrection;
  Result.Iw = sqrt(sum(Recordw(2,:) .* Recordw(2,:))/S2);
  Result.Iwc = Result.Iw; % / SNR_Icorrection;  
  Result.Pw  = sum(RecordPw)/S2;
  Result.Sw = Result.Uw * Result.Iw; 
  Result.P = sum(RecordP)/N;
  Result.S = sqrt(sum(Record(1,:).^2) * sum(Record(2,:).^2))/N;
  % calculate phase estimate
  Pratio = Result.Pw / (Result.Sw);
  if Pratio > 1
    Pratio = 1;
  end
  phase = abs(acos(Pratio));
  % determine phase sign 
  r = xcorr(Record(1,:),Record(2,:),10);
  sr = mean(gradient(r));
  dr = sr<0;
  if dr
    phase = -phase;
  end
  Result.phase = phase;
end

