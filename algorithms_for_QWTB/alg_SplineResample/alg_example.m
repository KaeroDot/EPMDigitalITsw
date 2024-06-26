%% Example for algorithm SplineResample.
% Algorithm use splines to resample sampled data to a new sampling frequency.

%% Generate sampled data
% Three quantities have to be prepared: time series |t| and signal |y|,
% representing 2000 samples of sinus waveform of nominal frequency 49.77 Hz, nominal
% amplitude 1 V and nominal phase 0 rad, sampled with sampling period 0.25 ms.
% Signal simulates non-coherent sampling.
f = 49.77;
A = 1;
N = 2000;
fs = 4000;
Ts = 1/fs;
Sampled.t.v = [0 : N-1] * Ts;
Sampled.y.v = A*sin(2 * pi * f * Sampled.t.v);

%% Signal frequency estimate
% Get estimate of signal frequency to be coherent after resampling. For
% example, algorithm PSFE can be used:
Estimate = qwtb('PSFE', Sampled);
Sampled.fest.v = Estimate.f.v;

%% Call algorithm
Resampled = qwtb('SplineResample', Sampled);

%% Get spectra
SpectrumNonCoherent = qwtb('SP-WFFT', Sampled);
SpectrumResampled = qwtb('SP-WFFT', Resampled);

%% Compare estimated amplitudes
printf('Frequency and amplitude of main signal component.\n');
printf('Simulated:                      f = %.2f, A = %.5f\n', f, A)
id = find(SpectrumNonCoherent.A.v == max(SpectrumNonCoherent.A.v));
printf('As estimated\n')
printf('Non coherent sampling and FFT:  f = %.2f, A = %.5f\n', SpectrumNonCoherent.f.v(id), SpectrumNonCoherent.A.v(id));
id = find(SpectrumResampled.A.v == max(SpectrumResampled.A.v));
printf('Resampled to coherent and FFT: f = %.2f, A = %.5f\n', SpectrumResampled.f.v(id), SpectrumResampled.A.v(id));

%% Plot
hold on
semilogy(f, A, 'xk')
semilogy(SpectrumNonCoherent.f.v, abs(SpectrumNonCoherent.A.v), '-k')
semilogy(SpectrumResampled.f.v, abs(SpectrumResampled.A.v), '-r')
hold off
xlabel('Frequency (Hz)')
ylabel('Signal amplitude')
legend('Simulated signal', 'FFT spectrum', 'Resampled and FFT spectrum')
title('Signal spectra')
