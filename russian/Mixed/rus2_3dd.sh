3dDeconvolve                            \
    -nodata 110 2.000                   \
    -polort A                           \
    -num_stimts 4                       \
    -stim_times 1 rus2_sF1.1D WAV    \
    -stim_label 1 sF1                   \
    -stim_times 2 rus2_sF2.1D WAV    \
    -stim_label 2 sF2                   \
    -stim_times 3 rus2_sM1.1D WAV    \
    -stim_label 3 sM1                   \
    -stim_times 4 rus2_sM2.1D WAV    \
    -stim_label 4 sM2                   \
    -x1D rus2.xmat.1D

1dplot -xlabel Time rus2.xmat.1D'[3..$]'
