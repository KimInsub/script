
mkdir eachRun
cd eachRun


3dMean -prefix Nulled_Basis_b.nii ../Nulled_Basis_*b.nii -overwrite
3dMean -prefix Not_Nulled_Basis_a.nii ../Not_Nulled_Basis_*a.nii -overwrite


NumVol=`3dinfo -nv Nulled_Basis_b.nii`
3dcalc -a Nulled_Basis_b.nii'[3..'`expr $NumVol - 2`']' -b  Not_Nulled_Basis_a.nii'[3..'`expr $NumVol - 2`']' -expr 'a+b' -prefix combined.nii -overwrite
3dTstat -cvarinv -prefix T1_weighted.nii -overwrite combined.nii 
rm combined.nii

3dcalc -a Nulled_Basis_b.nii'[1..$(2)]' -expr 'a' -prefix Nulled.nii -overwrite
3dcalc -a Not_Nulled_Basis_a.nii'[0..$(2)]' -expr 'a' -prefix BOLD.nii -overwrite

3drefit -space ORIG -view orig -TR 5 BOLD.nii
3drefit -space ORIG -view orig -TR 5 Nulled.nii

3dTstat -mean -prefix mean_nulled.nii Nulled.nii -overwrite
3dTstat -mean -prefix mean_notnulled.nii BOLD.nii -overwrite

LN_MP2RAGE_DNOISE -INV1 mean_nulled.nii -INV2 mean_notnulled.nii -UNI T1_weighted.nii -beta 5
LN_upsample.sh dnoised_T1_weighted.nii


run=(0 1 2 3 4 5 6 7 8)
for p in "${run[@]}"
do

3dcalc -a ../Nulled_Basis_${p}b.nii'[1..$(2)]' -expr 'a' -prefix Nulled_r${p}.nii -overwrite
3dcalc -a ../Not_Nulled_Basis_${p}a.nii'[0..$(2)]' -expr 'a' -prefix BOLD_r${p}.nii -overwrite

3drefit -space ORIG -view orig -TR 4 BOLD_r${p}.nii
3drefit -space ORIG -view orig -TR 4 Nulled_r${p}.nii

3dUpsample -overwrite  -datum short -prefix Nulled_intemp_r${p}.nii -n 2 -input Nulled_r${p}.nii
3dUpsample -overwrite  -datum short -prefix BOLD_intemp_r${p}.nii   -n 2 -input   BOLD_r${p}.nii


mv Nulled_intemp_r${p}.nii temp_r${p}.nii 
mv BOLD_intemp_r${p}.nii Nulled_intemp_r${p}.nii
mv temp_r${p}.nii  BOLD_intemp_r${p}.nii


LN_BOCO -Nulled Nulled_intemp_r${p}.nii -BOLD BOLD_intemp_r${p}.nii 
mv VASO_LN.nii VASO_LN_r${p}.nii

  3dTstat  -overwrite -mean  -prefix BOLD.Mean_r${p}.nii \
     BOLD_intemp_r${p}.nii'[1..$]'
  3dTstat  -overwrite -cvarinv  -prefix BOLD.tSNR_r${p}.nii \
     BOLD_intemp_r${p}.nii'[1..$]'
  3dTstat  -overwrite -mean  -prefix VASO.Mean_r${p}.nii \
     VASO_LN_r${p}.nii'[1..$]'
  3dTstat  -overwrite -cvarinv  -prefix VASO.tSNR_r${p}.nii \
     VASO_LN_r${p}.nii'[1..$]'


mv BOLD_intemp_r${p}.nii BOLD_LN_r${p}.nii    
3drefit -TR 2. BOLD_LN_r${p}.nii    
3drefit -TR 2. VASO_LN_r${p}.nii



done



mkdir qa
mv *tSNR* *Mean* qa
mkdir junk
mv *Nulled* BOLD_r* junk





