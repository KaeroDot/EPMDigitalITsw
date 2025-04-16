# Script ressampling_test is the main script to call

## How to run simulations

1. install, setup QWTB
2. add algorithms from algorithms_for_QWTB/ to QWTB directory
3. run `resampling_test_all.m` in GNU Octave or MATLAB

In MS Windows, maybe you will need to change paths in `resampling_test_all.m` to use Windows backslashes instead of slashes in file paths.

## How to replot figures

In Octave/Matlab change to the directory with saved results
Now either:

1. load file with output data, e.g. `varied_M_h1/varied_M_h1input_and_plot_data.mat`
2. replot using function `make_plot` according the lines 129-135 in file `resampling_test.m`:

    ```octave
    make_plot('AErr', 'Amplitude error', ndres, ndaxes, harm_multiple, 1, file_prefix, xaxislabel, alg_prefixes);
    make_plot('phErr', 'Phase error', ndres, ndaxes, harm_multiple, 1, file_prefix, xaxislabel, alg_prefixes);
    make_plot('ct', 'Calculation time', ndres, ndaxes, harm_multiple, 1, file_prefix, xaxislabel, alg_prefixes);
    if harm_multiple > 1
        make_plot('AErr', 'Amplitude error', ndres, ndaxes, harm_multiple, 2, file_prefix, xaxislabel, alg_prefixes);
        make_plot('phErr', 'Phase error', ndres, ndaxes, harm_multiple, 2, file_prefix, xaxislabel, alg_prefixes);
    end
    ```

or

1. open the actual figure in GNU Octave using e.g.:

    ``` octave
    h=openfig('varied_M_h1_AErr_hm_1.fig');
    set(h, 'visible', 'on');
    ```
