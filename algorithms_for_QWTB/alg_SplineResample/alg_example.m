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
Ts = 1/fs;
DI.t.v = (0:N-1)*Ts;
DI.y.v = A*sin(2*pi*f*DI.t.v);
% Set estimate of signal frequency to exact signal frequency and resampling method to keep the number of samples.
DI.fest.v = f;
DI.method.v = 'keepN';

% Call algorithm SplineResample
DO = qwtb('SplineResample', DI);

% Get spectra of both signals for plotting
SpectrumNonCoherent = qwtb('SP-WFFT', DI);
SpectrumResampled = qwtb('SP-WFFT', DO);

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

% Plot and compare both spectra.
hold on
semilogy(f, A, 'xk')
semilogy(SpectrumNonCoherent.f.v, abs(SpectrumNonCoherent.A.v), '-k')
semilogy(SpectrumResampled.f.v, abs(SpectrumResampled.A.v), '-r')
hold off
xlabel('Frequency (Hz)')
ylabel('Signal amplitude')
legend('Simulated signal', 'FFT spectrum', 'Resampled and FFT spectrum')
title('Signal spectra')
