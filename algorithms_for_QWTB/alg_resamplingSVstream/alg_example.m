%% Example for algorithm resamplingSVstream
% Algorithm use interpolation, decimation and anti-alias filtering to resample waveform.

%% Generate sampled data
% At least three quantities have to be prepared: sampling frequency |fs|, signal
% samples |y| and estimation of signal frequency. In this example an exact
% signal frequency will be used. In real use, the estimate could be obtained by
% using other algorithm, e.g. PSFE.
% The quantity |y| represents 2560 samples of sinus waveform of nominal
% frequency 49.25 Hz, nominal amplitude 1 V and nominal phase 0 rad, sampled
% with sampling frequency 12800 Hz. Signal simulates non-coherent sampling of a
% line voltage in a substation.
fs = 12800;
L = 2*1280;
t = [0:L-1] ./ fs;
A = 1;
f = 49.25;
DISampled.y.v = A.*sin(2.*pi.*f.*t + 0);
DISampled.fs.v = fs;
DISampled.fest.v = f;

%% Signal frequency estimate
% Get estimate of signal frequency to be coherent after resampling. For
% example, algorithm PSFE can be used:
Estimate = qwtb('PSFE', DISampled);
DISampled.fest.v = Estimate.f.v;

%% Call algorithm
% Set verbose output:
CS.verbose = 1;
% call algorithm:
DOResampled = qwtb('resamplingSVstream', DISampled, CS);

%% Get spectra
SpectrumNonCoherent = qwtb('SP-WFFT', DISampled);
SpectrumResampled = qwtb('SP-WFFT', DOResampled);

%% Compare estimated amplitudes
printf('Frequency and amplitude of main signal component.\n');
printf('Simulated:                      f = %.2f, A = %.5f\n', f, A)
id = find(SpectrumNonCoherent.A.v == max(SpectrumNonCoherent.A.v));
printf('As estimated\n')
printf('Non coherent sampling and FFT:  f = %.2f, A = %.5f\n', SpectrumNonCoherent.f.v(id), SpectrumNonCoherent.A.v(id));
id = find(SpectrumResampled.A.v == max(SpectrumResampled.A.v));
printf('Resampled to coherent and FFT: f = %.2f, A = %.5f\n', SpectrumResampled.f.v(id), SpectrumResampled.A.v(id));

%% Plot
figure()
hold on
semilogy(f, A, 'xk', 'markersize', 5, 'linewidth', 2)
semilogy(SpectrumNonCoherent.f.v, abs(SpectrumNonCoherent.A.v), '-b')
semilogy(SpectrumResampled.f.v, abs(SpectrumResampled.A.v), '-r')
hold off
xlim([0 200])
xlabel('Frequency (Hz)')
ylabel('Signal amplitude')
legend('Simulated signal', 'FFT spectrum', 'Resampled and FFT spectrum')
title('Signal spectra')

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=matlab textwidth=80 tabstop=4 shiftwidth=4
