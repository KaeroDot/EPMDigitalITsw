% Example for algorithm SplineResample.

% Generate sampled data
% Three quantities have to be prepared: time series |t| and signal |y|,
% representing 2000 samples of sinus waveform of nominal frequency 49.77 Hz, nominal
% amplitude 1 V and nominal phase 0 rad, sampled with sampling period 0.25 ms.
% Signal simulates non-coherent sampling.
f = 49.77;
A = 1;
N = 2000;
fs = 4000;
ts = 1/fs;
SimulatedSignal.t.v = (0:N-1)*ts;
SimulatedSignal.y.v = A*sin(2*pi*f*SimulatedSignal.t.v);

% Next required resampling parameters are developed so that number of samples
% remain the same and the resulting record is sampled coherently. The knowledge
% of true signal frequency is required.
ssfr1 = fs / f;     % The actual sampling/signal ratio
Cycles = floor(N/ssfr1); % Number of full cycles available
SimulatedSignal.fsest.v = N/(Cycles/f);

% Call algorithm SplineResample
ResampledSignal = qwtb('SplineResample', SimulatedSignal);

% Get spectra of both signals for plotting
SpectrumNonCoherent = qwtb('SP-WFFT', SimulatedSignal);
SpectrumResampled = qwtb('SP-WFFT', ResampledSignal);

% Compare amplitude of the main signal component:
printf('-------------------------------\n')
printf('Frequency and amplitude of main signal component.\n');
printf('Simulated:                      f = %.2f, A = %.5f\n', f, A)
id = find(SpectrumNonCoherent.A.v == max(SpectrumNonCoherent.A.v));
printf('As estimated\n')
printf('Non coherent sampling and FFT:  f = %.2f, A = %.5f\n', SpectrumNonCoherent.f.v(id), SpectrumNonCoherent.A.v(id));
id = find(SpectrumResampled.A.v == max(SpectrumResampled.A.v));
printf('Resampled to coherent and FFT): f = %.2f, A = %.5f\n', SpectrumResampled.f.v(id), SpectrumResampled.A.v(id));
printf('-------------------------------\n')

% Now plot and compare both spectra.
hold on
semilogy(SpectrumNonCoherent.f.v, abs(SpectrumNonCoherent.A.v), '-k')
semilogy(SpectrumResampled.f.v, abs(SpectrumResampled.A.v), '-r')
hold off
xlabel('frequency (Hz)')
xlabel('signal amplitude')
legend('original signal', 'resampled signal')
title('Signal spectra')
