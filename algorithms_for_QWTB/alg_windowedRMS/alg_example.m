%% Example for algorithm windowedRMS
% Algorithm calculate RMS value of a sampled signal

%% Generate single sine wave sampled data
% The signal is not coherently sampled.
DI = [];
t = (0 : 1000-1) * 1/4000;
DI.y.v = 1 * sin(2*pi * 50 * t);

%% Calculate RMS
DO = qwtb('windowedRMS', DI);

%% Check result
% Error of the amplitude estimate:
amplitude_error = DO.A.v - 1/sqrt(2)

%% Generate voltage and current sine waves
% If two signals are supplied representing voltage and current, power and
% apparent power will be calculated.
DI = [];
t = (0 : 1000-1) * 1/4000;
DI2.u.v = 1   * sin(2*pi * 50 * t + 0);
DI2.i.v = 0.5 * sin(2*pi * 50 * t + pi/4);

%% Calculate RMS
DO2 = qwtb('windowedRMS', DI2);

%% Check result
% Error of the voltage and current estimates:
voltage_error = DO2.U.v - 1/sqrt(2)
current_error = DO2.I.v - 0.5/sqrt(2)
%%
% Error of the phase estimate:
phase_error = DO2.phi_ef.v - pi/4
