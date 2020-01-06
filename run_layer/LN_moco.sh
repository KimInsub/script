#!/bin/bash

cp /Users/insubkim/Documents/experiment/script/layer_finalized/mocobatch_VASO3.m ./
export DYLD_FALLBACK_LIBRARY_PATH="/usr/lib/:$DYLD_LIBRARY_PATH"
/Applications/MATLAB_R2019b.app/bin/matlab -nodesktop -nosplash -r "mocobatch_VASO3"


rm ./Basis_*.nii
rm ./Basis*.mat

