function [Result] = GetRMSPw(Record,window_name)
%% calculate Amplitudes and Power by Windowed discrete RMS sum
%   [Result] = GetRMSw(Record,window_name)
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
  Result.Ue = sqrt(sum(Recordw .* Recordw)/S2);

else
  RecordU = Record(1,:);
  RecordI = Record(2,:);
  RecordP = RecordU .* RecordI;
  RecordPw = RecordP .* w.^2;
  % calculate all amplitude and power estimates
  Result.Ue = sqrt(sum(Recordw(1,:) .* Recordw(1,:))/S2);

  Result.Ie = sqrt(sum(Recordw(2,:) .* Recordw(2,:))/S2);

  Pe  = sum(RecordPw)/S2;
  Se = Result.Ue * Result.Ie;
  %Result.P = sum(RecordP)/N;
  %Result.S = sqrt(sum(Record(1,:).^2) * sum(Record(2,:).^2))/N;
  % calculate phase estimate
  Pratio = Pe / Se;
  if Pratio > 1
    Pratio = 1;
  end
  phase = abs(acos(Pratio));
  % determine phase sign 
  % r = xcorr(Record(1,:),Record(2,:),10);
  corrLength=length(Record(1,:))+length(Record(2,:))-1; % XXX instead of Record(1,:) you should use already populated variable RecordU etc.
  xc=fftshift(ifft(fft(Record(1,:),corrLength).*conj(fft(Record(2,:),corrLength)))); % XXX instead of Record(1,:) you should use already populated variable RecordU etc.
  r = xc((corrLength+1)/2-10:(corrLength+1)/2+10);

  sr = mean(gradient(r));
  dr = sr<0;
  if dr
    phase = -phase;
  end
  Result.pe = phase;
  Result.Pe = Pe;
  Result.Se = Se;
end

