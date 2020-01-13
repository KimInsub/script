#!/bin/bash

# Insub Kim January 12, 2020
# Performs almost all signal processing for the mooney data
# Most of the codes are from https://github.com/layerfMRI with minor changes made from me.

# *** note ***
# 1) $1 input is subject ID 
# 2) run LN_convert.sh before this code to convert DICOM to NII
# 3) create moma.nii (motion correction mask, restricts motion correction only to this mask)
# 4) requires GLM stimulus timing files to perform the GLM 

echo "starting analysis for ========>" $1

# uses moma.nii as mask for motion correction
echo "======== [start motion correction] ========"
sh /Users/insubkim/Documents/experiment/script/run_layer/LN_moco.sh
echo "=> motion correction done"


# seperate BOLD and VASO responses
echo "======== [start extraction] ========"
sh /Users/insubkim/Documents/experiment/script/run_layer/LN_extract.sh
echo "=> BOLD VASO seperation done"

# preprocess and modify the signal to be % change
echo "======== [start make p sig change] ========"
sh /Users/insubkim/Documents/experiment/script/run_layer/LN_prepro.sh
echo "=> p sig change converstion done"

echo "======== [make file name changes] ========"
sh /Users/insubkim/Documents/experiment/script/run_layer/LN_tidyName.sh


# perform GLM analysis
echo "======== [start GLM] ========"
sh /Users/insubkim/Documents/experiment/script/run_layer/LN_glm1.sh $1
sh /Users/insubkim/Documents/experiment/script/run_layer/LN_glm2.sh $1

