% Function resamples a signal to obtain coherent sampling. Interpolation,
% decimation and anti-alias filtering is used to produce the output. Function is
% based on the document and scripts developed by ITR company in the scope of
% DigitalIT EPM Project.
% If some outputs are ommited, the script is optimized for typical usecase of
% substations and 50 Hz line frequency.
%
% Inputs:
%  y: samples.
%  fs: sampling frequency (Hz).
%  f: frequency of the signal (Hz).
%  SPP: (optional) target number of samples per period of the signal, default 256.
%  errA1: (optional) maximum relative deviation of the signal amplitude (V/V), default 50e-6.
%  fcuts: (optional) the frequency where the filter passband ends (Hz), default 55*110.
%  ripp: (optional) passband ripple of the filter (ratio), default 1e-6.
%  att: (optional) attenuation of the filter (dB), default 40.
%  aafilter: (optional) if nonempty, coefficients in this variable will be used as a FIR filter instead of calculating a new filter.
%  verbose: (optional) prints out informations if nonzero, default 0.
%
% Outputs:
%  y_res: resampled values.
%  N: multiplication coefficient used for resampling.
%  M: decimation coefficient used for resampling.
%  fs_res: new sampling frequency of the resampled signal (Hz).
%  aafilter: coefficients of the FIR filter used to prevent antialiasing.
%  t_res: time axis of the resampled signal.

function [y_res, N, M, fs_res, aafilter, t_res] = resamplingSVstream(y, fs, f, SPP, errA1, fcuts, ripp, att, aafilter, verbose)
    %XXX add option to return whole resampled signal, not only whole periods!

    %% Set default values %<<<1
    % nominal value based on substation case:
    if ~exist('SPP', 'var') SPP = 256; end
    if isempty(SPP) SPP = 256; end
    % nominal value based on the pdf:
    if ~exist('errA1', 'var') errA1 = 50e-6; end
    if isempty(errA1) errA1 = 50e-6; end
    % nominal value based on substation case:
    if ~exist('fcuts', 'var') fcuts = 55*110; end
    if isempty(fcuts) fcuts = 55*110; end
    % nominal value based on the pdf, page 4:
    if ~exist('ripp', 'var') ripp = 1e-6; end
    if isempty(ripp) ripp = 1e-6; end
    % nominal value based on the pdf document:
    if ~exist('att', 'var') att = 40; end
    if isempty(att) att = 40; end
    % custom antialiasing filter nominally not set:
    if ~exist('aafilter', 'var') aafilter = []; end
    % nominally verbose is off:
    if ~exist('verbose', 'var') verbose = 0; end
    if isempty(verbose) verbose = 0; end
    verbose = not(not(verbose));

    %% Calculate interpolation and decimation coefficients %<<<1
    % Relative deviation of the number of samples per period from the nominal
    % value deltaSPP. This is the maximum value of deltaSPP. deltaSPP should be
    % less than errA1/k. (See equation 1 in the pdf)
    k = 0.5; % based on pdf document
    deltaSPP = errA1 ./ k;

    % Minimum decimating coefficient.
    % Final M should be larger or equal to min_M.
    % (equation 6 in the pdf)
    min_M = abs(1 ./ (2.*deltaSPP));
    % add floor or round function! maybe M has to be >= N?! XXX
    if verbose printf('Minimal decimating coefficient `min_M` is: %d\n', min_M) end

    % Interpolation coefficient:
    % (equation 7 in the pdf, rounding has to be used to prevent errors)
    N = round(min_M .* SPP .* f ./ fs);
    if verbose printf('Interpolation coefficient `N` is: %d\n', N) end

    % Actual used decimation coefficient:
    % (equation 2 in the pdf)
    M = factorM(N, f, fs, SPP);
    if verbose printf('Selected decimating coefficient `M` is: %d\n', M) end


    %% Design a FIR resample filter %<<<1
    % aafilter = dtfir1(maxfr*maxnofh, fs, Nint, Mdec, fs, ripp, att);
    % inputs:
    %   fcuts:  the frequency where the passband ends in Hz
    %   fstop:  the frequency where the stopband starts in Hz
    %   N:      interpolation coefficient
    %   M:      decimation coefficient
    %   fsampl: sampling frequency in Hz
    %   ripp:   ripple in the passband
    %   att:    attenuation [dB] in the stopband
    % output:
    %   dtnn:   filter coefficients
    if isempty(aafilter)
        % user have not supplied his own filter, calculate filter coefficients:
        aafilter = dtfir1(fcuts, fs, N, M, fs, ripp, att);
    else
        if verbose printf('User supplied antialiasing filter is used.\n') end
    end
    if verbose printf('Length of antialiasing filter is: %d\n', length(aafilter)) end

    %% Performs resampling operation %<<<1
    % ydownsample = fastresample(testsignal, resfilter, Nint, Mdec);
    y_res = fastresample(y, aafilter, N, M);

    % return only whole period multiple of the signal:
    % (this can return empty matrix if not enough samples left!)
    wholeperiods = floor(numel(y_res)./SPP).*SPP;
    if verbose printf('Number of whole periods left in the resampled data: %d\n', wholeperiods) end
    if wholeperiods == 0
        warning('resamplingSVstream: not enough samples left after resampling to return at least one period!')
    end
    y_res = y_res(1:wholeperiods);

    %% Calculate output properties if needed %<<<1
    % new sampling frequency:
    fs_res = fs.*N./M;
    if verbose printf('New sampling frequency is: %.5f\n', fs_res)
    if nargout > 4
        % t_res is expected on the output:
        t_res = [0 : numel(y_res)-1]./fs_res;
    end

end % function

%!demo %<<<1
%! disp('--- Demo 1 ---------------------')
%! disp('Demo 1 will simulate non-coherent sampling and compare DFT spectra of simulated signal and resampled signal.')
%! fs = 12800; L = 2*1280;
%! t = [0:L-1] ./ fs;
%! A = 1; f = 49.25;
%! y = A.*sin(2.*pi.*f.*t + 0);
%! [y_res, N, M, fs_res, aafilter, t_res] = resamplingSVstream(y, fs, f, [], [], [], [], [], [], 1);
%! figure()
%! plot(t, y, '-xb', t_res, y_res, '-+r') 
%! xlabel('t (s)'); ylabel('samples (V)'); legend('original signal', 'resampled signal'); title(sprintf('resamplingSVstream demo 1\nwaveforms of non-coherently sampled signal and resampled signal'));
%! figure
%! specy = abs(fft(y))./(numel(y)./2);
%! specf = fs./length(y).*[0:length(y)-1];
%! specy_res = abs(fft(y_res))./(numel(y_res)./2);
%! specf_res = fs_res./length(y_res).*[0:length(y_res)-1];
%! plot(specf, specy, '-xb', specf_res, specy_res, '-+r', [f f], [0 1.2], '--k');
%! xlim([30 70]); ylim([0 1.2]);
%! xlabel('f (Hz)'); ylabel('DFT amplitude (V)'); ! legend('DFT of simulated signal', 'DFT of resampled signal', 'frequency of original signal'); title(sprintf('resamplingSVstream demo 1\nDFT spectra of non-coherently sampled signal and resampled signal'));
%! printf('Relative error of amplitude, DFT of simulated signal: %.2g\n', (max(specy) - A)./A)
%! printf('Relative error of amplitude, DFT of resampled signal: %.2g\n', (max(specy_res) - A)./A)

%!demo %<<<1
%! disp('--- Demo 2 ---------------------')
%! disp('Demo 2 will simulate non-coherent sampling for signals from 49 Hz to 50 Hz and plot errors. Same anti-aliasing filter is used for repeated resampling calculations.')
%! fs = 12800; L = 2*1280;
%! t = [0:L-1] ./ fs;
%! A = 1;
%! flist = sort([linspace(49, 51, 8) 50]);
%! aafilter = [];
%! for j = 1:numel(flist)
%!     f = flist(j)
%!     y = A.*sin(2.*pi.*f.*t + 0);
%!     [y_res, N, M, fs_res, aafilter] = resamplingSVstream(y, fs, f, [], [], [], [], [], aafilter, 0);
%!     Aerr(j)     = max(abs(fft(y))./(numel(y)./2));
%!     Aerr_res(j) = max(abs(fft(y_res))./(numel(y_res)./2));
%! end
%! plot(flist, Aerr, '-xb', flist, Aerr_res, '-+r')
%! xlabel('signal frequency (Hz)'); ylabel('DFT amplitude (V)'); legend('simulated signal', 'resampled signal'); title(sprintf('resamplingSVstream demo 2\nDFT amplitude errors for various signal frequencies while keeping fixed sampling frequency'));

                        % tests  %<<<1 NOT FINISHED!
                        %!test
                        %!shared y_res, N, M, y, fs, f, SPP, errA1, L, t
                        %! fs = 12800;
                        %! f = 49;
                        %! SPP = 256;
                        %! errA1 = 50e-6;
                        %! L = 1000;
                        %! t = [0:L-1] ./ fs;
                        %! y = 1.*sin(2.*pi.*f.*t + 0);
                        %! [y_res, N, M] = resamplingSVstream(y, fs, f, SPP, errA1, 1);

                        % XXX Finish these parts:
                        %!assert(size(y, 2) == L);
                        %!assert(size(n, 2) == 10);
                        %!assert(size(Upjvs, 2) == 10);
                        %!assert(size(Upjvs1period, 2) == 10);
                        %!assert(size(Spjvs, 2) == 10);
                        %!assert(size(tsamples, 2) == L);
                        %!assert(all(n == [1960 5131 6342 5131 1960 -1960 -5131 -6342 -5131 -1960]))
                        %! A=2;
                        %! [y, n, Upjvs, Upjvs1period, Spjvs, tsamples] = pjvs_wvfrm_generator2(fs, L, t, f, A, ph, fstep, phstep, fm, waveformtype);
                        %!assert(n(1) == 2*1960)
                        %! phstep = pi;
                        %! [y, n, Upjvs, Upjvs1period, Spjvs, tsamples] = pjvs_wvfrm_generator2(fs, L, t, f, A, ph, fstep, phstep, fm, waveformtype);
                        %!assert(size(n, 2) == 11);


% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=matlab textwidth=80 tabstop=4 shiftwidth=4
