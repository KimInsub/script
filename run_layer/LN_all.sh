#!/bin/bash

# run LN_convert.sh first

## convert first
## create moma 

echo "start Analysis for ========>" $1


echo "======== [start motion correction] ========"
#sh /Users/insubkim/Documents/experiment/script/run_layer/LN_moco.sh
echo "=> motion correction done"


echo "======== [start extraction] ========"
#sh /Users/insubkim/Documents/experiment/script/run_layer/LN_extract.sh
echo "=> BOLD VASO seperation done"


echo "======== [start make p sig change] ========"
#sh /Users/insubkim/Documents/experiment/script/run_layer/LN_prepro.sh
echo "=> p sig change converstion done"

echo "======== [start GLM] ========"
sh /Users/insubkim/Documents/experiment/script/run_layer/LN_glm1.sh $1
sh /Users/insubkim/Documents/experiment/script/run_layer/LN_glm2.sh $1
