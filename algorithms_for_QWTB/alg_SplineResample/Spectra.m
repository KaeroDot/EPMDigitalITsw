function [Spectrum] = Spectra(Record,Ts,Window,Ns,Overlap,DCremoval,harm)
%
% ISSUES:
% - bad DC value
% - missing last point (at heighest frequency, nyquist criterium)
% - description does not describe some outputs
% - the noise floor negelects DC 3:end, but what about wide windows?
%
%
% Spectra (calculated power and linear spectra (& density) from vector data
%    [Spectrum] = Spectra(Record,Ts,Window,Ns,Overlap,DCremoval,harm)
%
%    Input arguments
%       Record     - sampled input signal
%       Ts         - sampling time (in s)
%       Window     - 'rect', 'bartlett', 'welch', 'hann', 'hamming',
%                    'blackmann', 'BH92', 'flattop', 'sfit', 'mhsf',
%                    'HFT70', 'HFT90D', 'HFT95', 'HFT116D',
%                    'HFT144D', 'HFT169D', 'HFT196D', 'HFT223D',
%                    'HFT248D'
%       Ns         - segment length
%       Overlap    - distance between two analysis windows in samples
%       DCremoval  - 'none' | 'mean' | 'linear'
%       harm       - vector of relative harmonic frequencies (for mhsf only)
%
%       Output arguments
%       Spectrum    - resulting spectrum data structure
% X      .ts        - given sampling time
%        .PS        - RMS power spectrum
%        .PSD       - RMS power spectral density
%        .LS        - RMS linear spectrum
%        .LSdB      - RMS linearspectrum in dB
%        .LSD       - RMS linear spectral density
% X      .Peak      - peak LS level - max() with dc value
% X      .PeakPhase - peak phase
% X      .iPeak     - peak index number
% X      .iHarm     - harmonic index numbers (h = 2 .. max)
% X      .THD       - total harmonic distortions - based on MHSF
% X      .PeakFrequency
%        .NF        - average LSD noise level
%        .NFLS      - average LS noise level
%        .noise     - RMS noise voltage
%        .SNR       - Signal to noise ratio in dB
% X      .f         - frequencies corresponing to calculated PSD or LSD
% X      .xlabel    - X axis label text
% X      .ylabelPS  - Y label for power spectrum
% X      .ylabelPSD - Y label for power spectrum
% X      .ylabelLS  - Y label for power spectrum
% X      .ylabelLSD - Y label for power spectrum
%
%   MISSING:
%       ENBW
%       NENBW
%       .PeakAmplitude - max() without DC value (2:end)
%       S1
%       S2
%       w
%
%
% Reference: G. Heinzel, A. Ruediger and R. Schilling
% "Spectrum and spectral density estimation by the Discrete Fourier
%  transform (DFT), including a comprehensive list of window functions
%  and some new flat-top windows,"
% Max-Planck-Institut fur Gravitationsphysik
% (Albert-Einstein-Institut)
% Teilinstitut Hannover
% February 15, 2002
%
% Copyright (c) 2014 by Rado Lapuh
% All rights reserved.

%% handle missing input arguments
S = size(Record);
if S(1) < S(2)
   Record = Record';
end
Record = Record(:)'; % force row vector
L = length(Record);
frequency = 'absolute';
if (nargin < 2)
   Ts = 1;
   frequency = 'relative'; % concerns the xlabel generation
end
if (nargin < 3)
   Window = 'BH92';        % default window
end
if (nargin < 4)            %% default segment length, bound to 4096
    Ns = max(S);
end
if (nargin < 5)
   Overlap = 0;         % overlap is adjustable to cover most of data
end
if (nargin < 6)
   DCremoval = 'mean';
end
if (nargin < 7)
   harm = 1:3;
end
% if mod(Ns,2) ~= 0
%    Ns = Ns-1;     % force even number of samples in segment
% end

%% handle input arguments
fs = 1/Ts;          % sampling frequency
fres = fs/Ns;        % frequency resolution;
% L >= (Rep-1)*d + Ns
if Overlap == 0
   if L==Ns    % no overlaping, just one pass
      d=1;
      Rep = 1;
   else
      if mod(L,Ns)>0
         Rep = floor(L/Ns)+1;   % use one more segment
      else
         Rep = L/Ns;            % use no overlap
      end
      d = floor((L-Ns)/(Rep-1));     % window overlap distance
   end
else
   d = floor(Ns*Overlap);
   Rep = floor((L-Ns)/d+1);
end
%% select Window
FrequencyEstimated = false;
switch Window
   case 'rect'    % Rectangular
      w = ones(1,Ns);
      zeroRemoval = 1;
   case 'bartlett'   % triangular Bartlett
      w = 2*(0:Ns/2-1)/Ns;
      w(round(Ns/2)+1:Ns) = 2-2*(round(Ns/2):Ns-1)/Ns;
      zeroRemoval = 2;
   case 'welch'
      w = 1-(2*(0:Ns-1)/Ns-1).^2;
      zeroRemoval = 2;
   case 'hann'    % Hanning
      w = (1-cos(2*pi*(0:Ns-1)/Ns))/2;
      zeroRemoval = 2;
   case 'hamming' % Hamming
      w = 0.54-0.46*cos(2*pi*(0:Ns-1)/Ns);
      zeroRemoval = 2;
   case 'blackman'% Blackman
      w = 0.426591 - ...
         0.496561 * cos(2*pi*(0:Ns-1)/Ns) + ...
         0.076849 * cos(4*pi*(0:Ns-1)/Ns);
      zeroRemoval = 3;
   case 'BH92'    % Blackman-Harris with 92 dB side lobe
      w = 0.35875 - ...
         0.48829 * cos(2*pi*(0:Ns-1)/Ns) + ...
         0.14128 * cos(4*pi*(0:Ns-1)/Ns) - ...
         0.01168 * cos(6*pi*(0:Ns-1)/Ns);
      zeroRemoval = 4;
   case 'flattop' % HFT95
      w = 0.26526 - ...
         0.5 * cos(2*pi*(0:Ns-1)/Ns) + ...
         0.23474 * cos(4*pi*(0:Ns-1)/Ns);
      %       w = 1.0000000 - ...
      %          1.9383379 * cos(2*pi*(0:Ns-1)/Ns) + ...
      %          1.3045202 * cos(4*pi*(0:Ns-1)/Ns) - ...
      %          0.4028270 * cos(6*pi*(0:Ns-1)/Ns) + ...
      %          0.0350665 * cos(8*pi*(0:Ns-1)/Ns);
      zeroRemoval = 5;
   case 'HFT70'
      w = 1 - ...
         1.90796 * cos( 2*pi*(0:Ns-1)/Ns) + ...
         1.07349 * cos( 4*pi*(0:Ns-1)/Ns) - ...
         0.18199 * cos( 6*pi*(0:Ns-1)/Ns);
      zeroRemoval = 4;
   case 'HFT90D'
      w = 1 - ...
         1.942604 * cos( 2*pi*(0:Ns-1)/Ns) + ...
         1.340318 * cos( 4*pi*(0:Ns-1)/Ns) - ...
         0.440811 * cos( 6*pi*(0:Ns-1)/Ns) + ...
         0.043097 * cos( 8*pi*(0:Ns-1)/Ns);
      zeroRemoval = 5;
   case 'HFT95'
      w = 1 - ...
         1.9383379 * cos( 2*pi*(0:Ns-1)/Ns) + ...
         1.3045202 * cos( 4*pi*(0:Ns-1)/Ns) - ...
         0.4028270 * cos( 6*pi*(0:Ns-1)/Ns) + ...
         0.0350665 * cos( 8*pi*(0:Ns-1)/Ns);
      zeroRemoval = 5;
   case 'HFT116D' % five term lovest sidelobe flat-top window
      w = 1 - ...
         1.9575375 * cos( 2*pi*(0:Ns-1)/Ns) + ...
         1.4780705 * cos( 4*pi*(0:Ns-1)/Ns) - ...
         0.6367431 * cos( 6*pi*(0:Ns-1)/Ns) + ...
         0.1228389 * cos( 8*pi*(0:Ns-1)/Ns) - ...
         0.0066288 * cos(10*pi*(0:Ns-1)/Ns);
      zeroRemoval = 6;
   case 'HFT144D' % six term lovest sidelobe flat-top window
      w = 1 - ...
         1.96760033 * cos( 2*pi*(0:Ns-1)/Ns) + ...
         1.57983607 * cos( 4*pi*(0:Ns-1)/Ns) - ...
         0.81123644 * cos( 6*pi*(0:Ns-1)/Ns) + ...
         0.22583558 * cos( 8*pi*(0:Ns-1)/Ns) - ...
         0.02773848 * cos(10*pi*(0:Ns-1)/Ns) + ...
         0.00090360 * cos(12*pi*(0:Ns-1)/Ns);
      zeroRemoval = 7;
   case 'HFT169D' % seven term lovest sidelobe flat-top window
      w = 1 - ...
         1.97441842 * cos( 2*pi*(0:Ns-1)/Ns) + ...
         1.65409888 * cos( 4*pi*(0:Ns-1)/Ns) - ...
         0.95788186 * cos( 6*pi*(0:Ns-1)/Ns) + ...
         0.33673420 * cos( 8*pi*(0:Ns-1)/Ns) - ...
         0.06364621 * cos(10*pi*(0:Ns-1)/Ns) + ...
         0.00521942 * cos(12*pi*(0:Ns-1)/Ns) - ...
         0.00010599 * cos(14*pi*(0:Ns-1)/Ns);
      zeroRemoval = 8;
   case 'HFT196D' % eight term lovest sidelobe flat-top window
      w = 1 - ...
         1.979280420 * cos( 2*pi*(0:Ns-1)/Ns) + ...
         1.710288951 * cos( 4*pi*(0:Ns-1)/Ns) - ...
         1.081629853 * cos( 6*pi*(0:Ns-1)/Ns) + ...
         0.448734314 * cos( 8*pi*(0:Ns-1)/Ns) - ...
         0.112376628 * cos(10*pi*(0:Ns-1)/Ns) + ...
         0.015122992 * cos(12*pi*(0:Ns-1)/Ns) - ...
         0.000871252 * cos(14*pi*(0:Ns-1)/Ns) + ...
         0.000011896 * cos(16*pi*(0:Ns-1)/Ns);
      zeroRemoval = 9;
   case 'HFT223D' % nineth term lovest sidelobe flat-top window
      w = 1 - ...
         1.98298997309 * cos( 2*pi*(0:Ns-1)/Ns) + ...
         1.75556083063 * cos( 4*pi*(0:Ns-1)/Ns) - ...
         1.19037717712 * cos( 6*pi*(0:Ns-1)/Ns) + ...
         0.56155440797 * cos( 8*pi*(0:Ns-1)/Ns) - ...
         0.17296769663 * cos(10*pi*(0:Ns-1)/Ns) + ...
         0.03233247087 * cos(12*pi*(0:Ns-1)/Ns) - ...
         0.00324954578 * cos(14*pi*(0:Ns-1)/Ns) + ...
         0.00013801040 * cos(16*pi*(0:Ns-1)/Ns) - ...
         0.00000132725 * cos(16*pi*(0:Ns-1)/Ns);
      zeroRemoval = 10;
   case 'HFT248D' % tenth term lovest sidelobe flat-top window
      w = 1 - ...
         1.985844164102 * cos( 2*pi*(0:Ns-1)/Ns) + ...
         1.791176438506 * cos( 4*pi*(0:Ns-1)/Ns) - ...
         1.282075284005 * cos( 6*pi*(0:Ns-1)/Ns) + ...
         0.667777530266 * cos( 8*pi*(0:Ns-1)/Ns) - ...
         0.240160796576 * cos(10*pi*(0:Ns-1)/Ns) + ...
         0.056656381764 * cos(12*pi*(0:Ns-1)/Ns) - ...
         0.008134974479 * cos(14*pi*(0:Ns-1)/Ns) + ...
         0.000624544650 * cos(16*pi*(0:Ns-1)/Ns) - ...
         0.000019808998 * cos(16*pi*(0:Ns-1)/Ns) + ...
         0.000000132974 * cos(16*pi*(0:Ns-1)/Ns);
      zeroRemoval = 11;
   case 'sfit' % sine fit fundamental component removal
      w = ones(1,Ns);
      zeroRemoval = 1;
      FrequencyEstimated = true;
   case 'mhsf' % multiharmonic sine fit fund. and harm. removal
      w = ones(1,Ns);
      zeroRemoval = 1;
      FrequencyEstimated = true;
   otherwise % none
      w = ones(1,Ns);
      zeroRemoval = 1;
end
w=w(1:end);  % force row vector
S1 = sum(w);      % Normalization sum for linear spectrum
S2 = sum(w.^2);   % Normalization sum for power spectrum
NENBW = Ns * S2/(S1^2); % Normalized Equivalent Noise BandWidth
ENBW = fs * S2/(S1^2);  % Effective Noise BandWidth
%% calculate density spectrum
t   = (0:Ns-1)*Ts;
t   = t(:)';
if strcmp(Window,'sfit')
   % remove fundamental component
   if min(S) > 1        % multiple records detected
      for k=1:Rep
         subrec = Record((k-1)*d+1:(k-1)*d+Ns);    % take segment
         [fe(k),Ae(k),pe(k)] = PSFE(subrec,Ts);
         Record((k-1)*d+1:(k-1)*d+Ns) = Record((k-1)*d+1:(k-1)*d+Ns) - Ae(k)*sin(2*pi*fe(k)*(0:Ns-1)*Ts+pe(k));
      end
      fe = mean(fe);
      Ae = mean(Ae);
      pe = mean(pe);
   else
      [fe,Ae,pe] = PSFE(Record,Ts);
      sineFit = Ae*sin(2*pi*fe*(0:L-1)*Ts+pe);
      Record = Record - sineFit;
   end
end
if strcmp(Window,'mhsf')
   % remove fundamental component
   if min(S) > 1        % multiple records detected
      for k=1:Rep
         subrec = Record((k-1)*d+1:(k-1)*d+Ns);    % take segment
         [fe(k),Ae(k,:),pe(k,:),THD(k)] = MHSF(subrec,Ts,harm);
         for l = 1:length(harm)
            Record((k-1)*d+1:(k-1)*d+Ns) = Record((k-1)*d+1:(k-1)*d+Ns) - Ae(k,l)*sin(2*pi*fe(k)*(0:Ns-1)*Ts+pe(k,l));
         end
      end
      fe = mean(fe);
      Ae = mean(Ae,1);
      pe = mean(pe,1);
   else
      [fe,Ae,pe] = MHSF(Record,Ts,harm);
      for l = 1:length(harm)
         Record = Record - Ae(l)*sin(2*pi*fe*harm(l)*(0:L-1)*Ts+pe(l));
      end
   end
end
for k=1:Rep
   subrec = Record((k-1)*d+1:(k-1)*d+Ns);    % take segment
   switch DCremoval
      case 'mean'
         subrec = subrec - mean(subrec);  % remove DC component
      case 'linear' % even better would be to remove linear regression line from the segment
         B = [ones(length(t),1) t'] \ subrec'; % linear regression coefficients
         % B(1) = n; B(2) = k;
         regline = (t*B(2)+B(1)); regline = regline(:)';
         subrec = subrec - regline;          % DC component and trend removed
      otherwise
   end
   subrecw = subrec .* w;              % multiply with Window function
   yc = fft(subrecw);                  % take FFT of type 1
   ym = abs(yc);                       % FFT magnitude
   ym = ym(1:floor(Ns/2));                    % take only first half
   ym(1:zeroRemoval) = ym(zeroRemoval+1);                    % remove DC
   if k > 1
      ym2 = (ym2*(k-1)+ym.^2)/k;       % current average
   else
      ym2 = ym.^2;                     % squared spectrum
   end
end
if strcmp(Window,'sfit')
   k = round(fe*Ts*Ns+1);    % FFT bin to be replaced
   ym2(k) = Ae^2*S1^2/4;
   yc(k) = ym2(k) * (cos(pe) + i*sin(pe));
end
if strcmp(Window,'mhsf')
   for l = 1:length(harm)
      k = round(fe*harm(l)*Ts*Ns+1);    % FFT bin to be replaced
      ym2(k) = Ae(l)^2*S1^2/4;
      yc(k) = ym2(k) * (cos(pe(l)) + i*sin(pe(l))); %CORRECTION
   end
end
Spectrum.PS  = 4*ym2/(S1^2);           % peak spectrum power
Spectrum.PSD = 2*ym2/(fs*S2);          % RMS Spectral Power Density
Spectrum.LS  = sqrt(Spectrum.PS);      % peak spectrum amplitudes NORMALNI AMPLITUDY TADY v LS!
Spectrum.LSdB = 20*log10(Spectrum.LS); % peak spectrum amplitudes in dB
Spectrum.LSD = sqrt(Spectrum.PSD);     % RMS Spectral Density
Spectrum.Peak = max(Spectrum.LS(2:end));
Spectrum.f   = (0:Ns/2-1)*fres;
[M,I] = max(Spectrum.LS);
if FrequencyEstimated
   Spectrum.PeakFrequency = fe;
else
   Spectrum.PeakFrequency = Spectrum.f(I);
end
Spectrum.iPeak = I;
if I == 1
   I = 2; % I == 1 is DC
end
switch Window
   case {'sfit','mhsf'}
      maxHarmonicIndex = fix((fs/2)/(fe));
      Spectrum.iHarm = round(fe*(2:maxHarmonicIndex)*Ts*Ns+1);
      if Spectrum.iHarm(end) > fix(Ns/2)
         Spectrum.iHarm = Spectrum.iHarm(1:end-1);
      end
   otherwise
      Spectrum.iHarm = (I+I-1:I-1:Ns/2);
end
Spectrum.THD = 20*log10(sqrt(sum(Spectrum.LS(Spectrum.iHarm).^2))/Spectrum.LS(I));
Spectrum.PeakAmplitude = M;
Spectrum.PeakPhase = angle(yc(I));
%        .xlabel    - X axis label text
%        .ylabelPS  - Y label for power spectrum
%        .ylabelPSD - Y label for power spectrum
%        .ylabelLS  - Y label for power spectrum
%        .ylabelLSD - Y label for power spectrum
if frequency == 'relative'
   Spectrum.xlabel = 'Relative sampling frequency (Hz/Hz)';
else
   Spectrum.xlabel = 'Frequency (Hz)';
end
Spectrum.ylabelPS = 'Power spectrum (V^2)';
Spectrum.ylabelPSD = 'Power spectral density (V^2/Hz)';
Spectrum.ylabelLS = 'Amplitude (V)';
Spectrum.ylabelLSdB = 'Magnitude (dB)';
Spectrum.ylabelLSD = 'Linear spectral density (V/$$\sqrt{\textrm{Hz}}$$)';
Spectrum.w = w;
Spectrum.S1 = S1;
Spectrum.S2 = S2;
Spectrum.NENBW = NENBW;
Spectrum.ENBW = ENBW;
Spectrum.ts = Ts;
% calculate average noise level and SNR
Urms = max(Spectrum.LS)/sqrt(2);          % RMS amplitude
Urms_dB = 20*log10(Urms);
LSD_dB = 20*log10(Spectrum.LSD);
% NFt = mean(LSD_dB);
% Lim = NFt + 0.75*(Urms_dB - NFt);
% LSD_dB(LSD_dB > Lim) = [];
NF = median(LSD_dB(3:end)); % neglect DC and its leakage
Spectrum.NF = 10^(NF/20);
Spectrum.NFLS = Spectrum.NF * sqrt(2*ENBW);
Spectrum.noise = Spectrum.NF * sqrt(max(Spectrum.f));
Spectrum.SNR = Urms_dB - 20*log10(Spectrum.noise);
end

