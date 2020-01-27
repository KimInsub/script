#!/bin/bash

mkdir eachrun/prepro/GLM1
cd eachrun/prepro/GLM1

3dMean -prefix BOLD_mean.nii ../BOLD_*.nii -overwrite
3dMean -prefix VASO_mean.nii ../VASO_*.nii -overwrite


3dDeconvolve -input BOLD_mean.nii                   \
    -polort 8                                                           \
    -num_stimts 2                                                       \
    -stim_times 1 /Users/insubkim/Documents/experiment/mooney/on.txt  'BLOCK(16,1)'              \
    -stim_label 1 StimOn                                                \
    -stim_times 2 /Users/insubkim/Documents/experiment/mooney/off.txt  'BLOCK(16,1)'              \
    -stim_label 2 StimOff                                               \
    -gltsym 'SYM: StimOn -StimOff'                      \
    -glt_label 1 on-off                         \
    -gltsym 'SYM: StimOff -StimOn'                      \
    -glt_label 2 off-on                                 \
    -local_times                                                        \
    -float                                                              \
    -fout -tout -x1D X.xmat.1D -xjpeg X.jpg                             \
    -x1D_uncensored X.nocensor.xmat.1D                                  \
    -bucket stats_BOLD.all        \
    -overwrite  

3dDeconvolve -input VASO_mean.nii                   \
    -polort 8                                                           \
    -num_stimts 2                                                       \
    -stim_times 1 /Users/insubkim/Documents/experiment/mooney/on.txt  'BLOCK(16,1)'              \
    -stim_label 1 StimOn                                                \
    -stim_times 2  /Users/insubkim/Documents/experiment/mooney/off.txt  'BLOCK(16,1)'              \
    -stim_label 2 StimOff                                               \
    -gltsym 'SYM: StimOn -StimOff'                      \
    -glt_label 1 on-off                         \
    -gltsym 'SYM: StimOff -StimOn'                      \
    -glt_label 2 off-on                                 \
    -local_times                                                        \
    -float                                                              \
    -fout -tout -x1D X.xmat.1D -xjpeg X.jpg                             \
    -x1D_uncensored X.nocensor.xmat.1D                                  \
    -bucket stats_VASO.all        \
    -overwrite  

3dbucket -prefix Beta_BOLD.nii stats_BOLD.all+orig.BRIK'[7]' -overwrite
3dbucket -prefix Tstat_BOLD.nii stats_BOLD.all+orig.BRIK'[8]' -overwrite
3dbucket -prefix Fstat_BOLD.nii stats_BOLD.all+orig.BRIK'[9]' -overwrite

3dbucket -prefix Beta_VASO.nii stats_VASO.all+orig.HEAD'[7]' -overwrite
3dbucket -prefix Tstat_VASO.nii stats_VASO.all+orig.BRIK'[8]' -overwrite
3dbucket -prefix Fstat_VASO.nii stats_VASO.all+orig.BRIK'[9]' -overwrite

# to get help in draw ROI
LN_upsample.sh Beta_BOLD.nii
LN_upsample.sh Beta_VASO.nii