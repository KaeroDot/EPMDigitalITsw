addpath('~/metrologie/Q-Wave/qwtb/qwtb/')

datafiles = {'50Hz_3phase_harm_only_samples.csv',...
             '50Hz_3phase_harm2_only_samples.csv',...
             '50Hz_3phase_only_samples.csv',...
            };
outline = {};
# output csv file header:
outline{end+1} = "filename, signal id, samples, f at max A, max A, noise rms, SNR (dB)\n";
for f = datafiles
    data = load(f{1});
    for c = 2:size(data, 2)
    % for c = 2:2
        DI.y.v = data(:, c);
        DI.fs.v = 4e3; % from README
        DOfft = qwtb('SP-WFFT', DI);
        loglog(DOfft.f.v, DOfft.A.v, '-')
        title(sprintf('%s\n signal no %d', f{1}, c), 'interpreter','none')
        xlabel('frequency (Hz)')
        ylabel('amplitude (V, A)')
        fn = sprintf('%s_%02d.png', f{1}, c)
        saveas(gcf(), fn, 'png')

        idmax = find(DOfft.A.v == max(DOfft.A.v))(1);
        tmp = sprintf('%.9f, ', [c,...
                                        numel(DI.y.v),...
                                        DOfft.f.v(idmax),...
                                        DOfft.A.v(idmax),...
                                        DOfft.noise_rms.v,...
                                        DOfft.SNRdB.v,...
                                        ]);
        outline{end+1} = [f{1} ',' tmp "\n"];
    end
end % for f
fh = fopen('values.csv', 'w');
fprintf(fh, '%s', strcat(outline{:}));
fclose(fh);
