f = 49.77;
f_est = f;
N = 2000;
ts = 0.00025;
t = (0:N-1)*ts;
record = sin(2*pi*f*t);

%% resampling parameters
% so that number of samples remain the same and the resulting record is
% sampled coherently
%N = length(Record);
Fs = 1/ts;
ssfr1 = Fs / f_est;     % the actual ratio
Cycles = floor(N/ssfr1);        % return number of full cycles available
ts2 = (Cycles/f_est)/N;
Fs2 = 1/ts2; % dersired new sampling frequency
t2 = (0:N-1)*ts2;

%% perform resampling
spline = CubicSpline(t, record);
record2 = spline.evaluate(t2);

X  = Spectra(record,ts,'none');
X2 = Spectra(record2,ts2,'none');
plot(X.f,X.LSdB)
hold on
plot(X2.f,X2.LSdB)
hold off
