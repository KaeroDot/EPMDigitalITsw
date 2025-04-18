% runs all evaluation tests at once

           resampling_test(1, 'results/varied_M_h1/varied_M_h1', 1)
close all; resampling_test(2, 'results/varied_f_h1/varied_f_h1', 1)
close all; resampling_test(3, 'results/varied_fs_h1/varied_fs_h1', 1)
close all; resampling_test(4, 'results/varied_noise_h1/varied_noise_h1', 1)

close all; resampling_test(1, 'results/varied_M_h2/varied_M_h2', 2)
close all; resampling_test(2, 'results/varied_f_h2/varied_f_h2', 2)
close all; resampling_test(3, 'results/varied_fs_h2/varied_fs_h2', 2)
close all; resampling_test(4, 'results/varied_noise_h2/varied_noise_h2', 2)

close all; resampling_test(1, 'results/varied_M_h3/varied_M_h3', 3)
close all; resampling_test(2, 'results/varied_f_h3/varied_f_h3', 3)
close all; resampling_test(3, 'results/varied_fs_h3/varied_fs_h3', 3)
close all; resampling_test(4, 'results/varied_noise_h3/varied_noise_h3', 3)

close all; resampling_test(1, 'results/varied_M_h5/varied_M_h5', 5)
close all; resampling_test(2, 'results/varied_f_h5/varied_f_h5', 5)
close all; resampling_test(3, 'results/varied_fs_h5/varied_fs_h5', 5)
close all; resampling_test(4, 'results/varied_noise_h5/varied_noise_h5', 5)

% special test only for resamplingSVstream to check calculation time
close all; resampling_test(5, 'results/varied_max_error_h1//varied_max_error_h1', 1)

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=matlab textwidth=80 tabstop=4 shiftwidth=4
