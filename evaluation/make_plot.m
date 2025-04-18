function make_plot(quantity, titlestring, ndres, ndaxes, harm_multiple, data_index, file_prefix, xaxislabel, alg_prefixes)
% quantity: A string specifying the quantity to be plotted (e.g., 'AErr', 'phErr', etc.).
% titlestring: A string representing the title of the plot (e.g., 'Amplitude error', 'Phase error').
% ndres: A structure containing the results of the calculations, with fields for different algorithms and quantities.
% ndaxes: A structure containing the axes values for the plot, typically including the x-axis data.
% harm_multiple: An integer indicating the harmonic multiple being analyzed (e.g., 1 for the main component, 2 for the second harmonic, etc.).
% data_index: An integer specifying which data set to use for plotting (e.g., 1 for the main component, 2 for the second harmonic).
% file_prefix: A string used as a prefix for saving plot files.
% xaxislabel: A string representing the label for the x-axis of the plot.
% alg_prefixes: A cell array of strings containing the prefixes of the algorithms to be plotted (e.g., {'FE', 'SR', 'WF'}).

    figure
    hold on
    % some almost distinct plot properties:
    plotprops = {'-xk', '-+r', '-xg', '-+b', '-xc', '-om'};
    for j = 1:numel(alg_prefixes)
        % eval example:
        % val = ndaxes.values{1}(:,1), FE_AErr(1, :);
        tmp = sprintf('val = ndres.%s_%s.v(data_index, :);', alg_prefixes{j}, quantity);
        eval(tmp);
        plot(ndaxes.values{1}(:,1), val, plotprops{j})
    end
    xlabel(xaxislabel);
    ylabel([titlestring ' (Hz/V/rad/s)']);
    if data_index > 1
        title(sprintf('%s\n%d-th harmonic component', titlestring, harm_multiple));
    else
        title(sprintf('%s\nmain component', titlestring));
    end
    legend(alg_prefixes);
    hold off
    fn = sprintf('%s_%s_h%d.', file_prefix, quantity, data_index);
    saveas(gcf(), [fn 'png'])
    saveas(gcf(), [fn 'fig'])
end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=matlab textwidth=80 tabstop=4 shiftwidth=4
