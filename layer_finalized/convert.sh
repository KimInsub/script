#!/bin/bash

for d in */ ; do
    dcm2nii -o  './' ${d}
done

gunzip *


3dcalc -a  EPI_3D.nii'[5..$]' -expr 'a' -prefix EPI_3D_cat.nii -overwrite
3dcalc -a  EPI_2D.nii'[5..$]' -expr 'a' -prefix EPI_2D_cat.nii -overwrite

#3dcalc -a  VASO.nii'[1..$(2)]' -expr 'a' -prefix one.nii -overwrite
#3dcalc -a VASO.nii'[0..$(2)]' -expr 'a' -prefix two.nii -overwrite


#3dTstat  -overwrite -mean  -prefix one.Mean.nii one.nii'[1..$]'
#3dTstat  -overwrite -mean  -prefix two.Mean.nii two.nii'[1..$]'

#3dTcat -prefix onetwo.nii one.Mean.nii two.Mean.nii -overwrite
3dTcat -prefix onetwo.nii two.Mean.nii  one.Mean.nii -overwrite