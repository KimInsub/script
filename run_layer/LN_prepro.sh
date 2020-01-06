#!/bin/bash

################################# prepro  #################################

mkdir eachrun/prepro
cd eachrun/prepro



run=( 0 1 2 3 4 5 6 7 8 )

cond=(BOLD VASO)
for c in "${cond[@]}"
do


    #more clip.txt # check the smallest clip value across all runs
    #clip=$(cut -f1 -d"," clip.txt | sort -n | head -1) # assign the clip value# assign the clip value

    for r in "${run[@]}"
    do
        3dTstat -nzmean -prefix ${c}.${r}.base.nii ../${c}_LN_r${r}.nii'[0..$]' 
        3dcalc -a ../${c}_LN_r${r}.nii  -b ${c}.${r}.base.nii  \
        -expr "(a/b)" -prefix ${c}_r${r}.scaled.nii #remove the space and scale 
        3dDetrend -overwrite -polort 1 -prefix ${c}_r${r}.scaled_dt.nii ${c}_r${r}.scaled.nii
        3dBandpass -notrans -overwrite -prefix ${c}_r${r}.scaled_dt_hp.nii 0.01 99999 ${c}_r${r}.scaled_dt.nii
        3dTstat -mean -prefix ${c}.${r}.base2.nii ${c}_r${r}.scaled_dt_hp.nii'[0..$]' 
        3dcalc -a ${c}_r${r}.scaled_dt_hp.nii -b ${c}.${r}.base2.nii  \
        -expr "(a-b)*100" -prefix ${c}_r${r}.nii #remove the space and scale 

        rm *base*
        rm *scaled*

    done

done


for r in "${run[@]}"
do
    3dcalc -a VASO_r${r}.nii -expr '(a*-1)' -prefix VASO_r${r}.nii -overwrite
done

