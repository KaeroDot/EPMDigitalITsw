% script just loads VSL signal and plots a pretty spectrum for the paper
CS.verbose = 1;

%% Load sampled data
datafiles = {'50Hz_3phase_harm_only_samples.csv',...
             '50Hz_3phase_harm2_only_samples.csv',...
             '50Hz_3phase_only_samples.csv',...
            };
for f = datafiles
    disp('----------------------------------------------------------------------------------------')
    disp(f{1})
    disp('----------------------')
    data = load(f{1});
    % for c = 1:size(data, 2)
    for c = 8:size(data, 2)
        DISampled.y.v = data(:, c);
        DISampled.fs.v = 4e3; % from README
        DISampled.fest.v = 50;

        %% Signal frequency estimate
        % Get estimate of signal frequency to be coherent after resampling. For
        % example, algorithm PSFE can be used:
        Estimate = qwtb('PSFE', DISampled);
        if Estimate.f.v < 40 || Estimate.f.v > 60
            warning('Estimated frequency %f is not in range [40, 60] Hz, probably neutral line, skipping collumn.', Estimate.f.v);
        else
            DISampled.fest.v = Estimate.f.v;

            %% Call algorithms
            % call algorithm:
            DOresamplingSVstream = qwtb('resamplingSVstream', DISampled, CS);
            DOsplineresample = qwtb('SplineResample', DISampled, CS);

            %% Get spectra
            DISampled.window.v = 'rect';
            sp_FFT = qwtb('SP-WFFT', DISampled);
            DISampled.window.v = 'flattop_116D'; % window used in SP-WFFT algorithm
            sp_WFFT = qwtb('SP-WFFT', DISampled);
            DISampled.window.v = 'rect';
            sp_resamplingSVstream = qwtb('SP-WFFT', DOresamplingSVstream, CS);
            sp_splineresample = qwtb('SP-WFFT', DOsplineresample, CS);

            %% Plot
            pFE = {';PSFE estimate;', 'color', [166,206,227]./256, 'linestyle', '-', 'linewidth', 2}; % light blue
            pWR = {';Windowed RMS;','color', [ 31,120,180]./256, 'linestyle', '-', 'linewidth', 2}; % dark blue
            pFFT = {';FFT;','color', [ 31,120,180]./256, 'linestyle', '-', 'linewidth', 2}; % light green
            pWF = {';FFT, window;','color', [178,223,138]./256, 'linestyle', '-', 'linewidth', 2}; % light green
            pMH = {';MHFE;','color', [ 51,160, 44]./256, 'linestyle', '-', 'linewidth', 2}; % dark green
            pSR = {';SplineResampling;','color', [251,154,153]./256, 'linestyle', '-', 'linewidth', 2}; % light red
            pSV = {';resamplingSVstream;','color', [227, 26, 28]./256, 'linestyle', '-', 'linewidth', 2}; % dark red


            figure()
            hold on
            % semilogy(f, A, 'xk', 'markersize', 5, 'linewidth', 2)
            semilogy(sp_FFT.f.v, sp_FFT.A.v, pFFT{:})
            semilogy(sp_WFFT.f.v, sp_WFFT.A.v, pWF{:})
            semilogy(sp_resamplingSVstream.f.v, sp_resamplingSVstream.A.v, pSV{:})
            semilogy(sp_splineresample.f.v, sp_splineresample.A.v, pSR{:})
            hold off
            xlim([0 1000])
            xlabel('Frequency (Hz)')
            ylabel('Signal amplitude')
            legend()
            saveas(gcf(), sprintf('%s_%02d_spectrum_allalgs.png', f{1}, c))
            saveas(gcf(), sprintf('%s_%02d_spectrum_allalgs.fig', f{1}, c))
            close(gcf())

            % export to CSV:
            % pad resamplingSVstream data to have same length as FFT and WFFT:
            paddedSVdataf = [sp_resamplingSVstream.f.v(:); nan(max(0, numel(sp_FFT.f.v(:)) - numel(sp_resamplingSVstream.f.v(:))), 1)];
            paddedSVdataA = [sp_resamplingSVstream.A.v(:); nan(max(0, numel(sp_FFT.A.v(:)) - numel(sp_resamplingSVstream.A.v(:))), 1)];
            maximum = numel(sp_FFT.f.v(:));
            csvdata = [sp_FFT.f.v(:), ...
                    sp_FFT.A.v(:), ...
                    sp_WFFT.f.v(:)(1:maximum), ...
                    sp_WFFT.A.v(:)(1:maximum), ...
                    paddedSVdataf(:)(1:maximum), ...
                    paddedSVdataA(:)(1:maximum), ...
                    sp_splineresample.f.v(:)(1:maximum), ...
                    sp_splineresample.A.v(:)(1:maximum)];

            csvfilename = sprintf('%s_%02d_spectrum_allalgs.csv', f{1}, c)
            fid = fopen(csvfilename, 'w');
            fprintf(fid, 'f_FFT;A_FFT;f_WFFT;A_WFFT;f_resamplingSVstream;A_resamplingSVstream;f_splineresample;A_splineresample\n');
            fclose(fid);
            dlmwrite(csvfilename, csvdata, 'delimiter', ';', '-append');
        end % if Estimate.f.v
    end % for c as collumn in data
end % for f as file in datafiles

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=matlab textwidth=80 tabstop=4 shiftwidth=4
