f = 49.77;          % signal frequency
f_est = f;          % estimate of signal frequency
N = 1e3;            % number of samples in the record
method = 0;         % 0 for arrayfun, 1 for bsxfun
ts = 0.00025;       % sampling period
t = (0:N-1)*ts;     % timestamps
record = sin(2*pi*f*t); % record - sampled values

%% resampling parameters
% so that number of samples remain the same and the resulting record is
% sampled coherently
%N = length(Record);
Fs = 1/ts;              % sampling frequency
ssfr1 = Fs / f_est;     % the actual ratio
Cycles = floor(N/ssfr1); % return number of full cycles available
ts2 = (Cycles/f_est)/N; % new sampling period
Fs2 = 1/ts2;            % desired new sampling frequency
t2 = (0:N-1)*ts2;       % new timestamps

%% perform resampling
spline = CubicSpline(t, record);    % calculate spline coefficients
tic
record2 = spline.evaluate(t2, method); % resample
toc

X  = Spectra(record,ts,'none');     % do spectrum of input record
X2 = Spectra(record2,ts2,'none');   % do spectrum of resampled record
figure
hold on
plot(X.f,X.LSdB)                    
plot(X2.f,X2.LSdB)
hold off
