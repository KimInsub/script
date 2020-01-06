for d in */ ; do
    dcm2nii -o  './' ${d}
done

gunzip *


cnt=0
for filename in ./*.nii
do
echo $filename
cp $filename ./Basis_${cnt}a.nii
3dTcat -prefix Basis_${cnt}a.nii Basis_${cnt}a.nii'[4..7]' Basis_${cnt}a.nii'[4..$]' -overwrite
cp ./Basis_${cnt}a.nii ./Basis_${cnt}b.nii

3dinfo -nt Basis_${cnt}a.nii >> NT.txt
3dinfo -nt Basis_${cnt}b.nii >> NT.txt
cnt=$(($cnt+1))

done

rm ./2019*.nii


cp /media/ururru/layers/Layer_script/mocobatch_VASO3.m ./
export DYLD_FALLBACK_LIBRARY_PATH="/usr/lib/:$DYLD_LIBRARY_PATH"
/usr/local/MATLAB/R2018a/bin/matlab -nodesktop -nosplash -r "mocobatch_VASO3"



rm ./Basis_*.nii



3dMean -prefix Nulled_Basis_b.nii Nulled_Basis_*b.nii -overwrite
3dMean -prefix Not_Nulled_Basis_a.nii Not_Nulled_Basis_*a.nii -overwrite


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

3dUpsample -overwrite  -datum short -prefix Nulled_intemp.nii -n 2 -input Nulled.nii
3dUpsample -overwrite  -datum short -prefix BOLD_intemp.nii   -n 2 -input   BOLD.nii

NumVol=`3dinfo -nv BOLD_intemp.nii`

3dTcat -overwrite -prefix Nulled_intemp.nii Nulled_intemp.nii'[0]' Nulled_intemp.nii'[0..'`expr $NumVol - 2`']' 

mv Nulled_intemp.nii temp.nii 
mv BOLD_intemp.nii Nulled_intemp.nii
mv temp.nii  BOLD_intemp.nii



LN_BOCO -Nulled Nulled_intemp.nii -BOLD BOLD_intemp.nii 

  3dTstat  -overwrite -mean  -prefix BOLD.Mean.nii \
     BOLD_intemp.nii'[1..$]'
  3dTstat  -overwrite -cvarinv  -prefix BOLD.tSNR.nii \
     BOLD_intemp.nii'[1..$]'
  3dTstat  -overwrite -mean  -prefix VASO.Mean.nii \
     VASO_LN.nii'[1..$]'
  3dTstat  -overwrite -cvarinv  -prefix VASO.tSNR.nii \
     VASO_LN.nii'[1..$]'

#LN_SKEW -timeseries BOLD_intemp.nii
#LN_SKEW -timeseries VASO_LN.nii

3drefit -TR 2. BOLD_intemp.nii
3drefit -TR 2. VASO_LN.nii

LN_MP2RAGE_DNOISE -INV1 mean_nulled.nii -INV2 mean_notnulled.nii -UNI T1_weighted.nii -beta 5

#start_bias_field.sh dnoised_T1_weighted.nii
mv BOLD_intemp.nii BOLD_LN.nii    

3dDeconvolve -input ../BOLD_LN.nii                   \
    -polort 8                                                           \
    -num_stimts 2                                                       \
    -stim_times 1 ../on.txt  'BLOCK(36,1)'              \
    -stim_label 1 StimOn                                                \
    -stim_times 2 ../off.txt  'BLOCK(36,1)'              \
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

3dDeconvolve -input ../VASO_LN.nii                   \
    -polort 8                                                           \
    -num_stimts 2                                                       \
    -stim_times 1 ../on.txt  'BLOCK(36,1)'              \
    -stim_label 1 StimOn                                                \
    -stim_times 2 ../off.txt  'BLOCK(36,1)'              \
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

3dbucket -prefix Beta_VASO.nii stats_VASO.all+orig.HEAD'[10]' -overwrite
3dbucket -prefix Tstat_VASO.nii stats_VASO.all+orig.BRIK'[11]' -overwrite
3dbucket -prefix Fstat_VASO.nii stats_VASO.all+orig.BRIK'[12]' -overwrite



LN_GRADSMOOTH -gradfile dnoised_T1_weighted.nii -input Tstat_VASO.nii -FWHM 1 -within -selectivity 0.08
LN_GRADSMOOTH -gradfile dnoised_T1_weighted.nii -input Tstat_BOLD.nii -FWHM 1 -within -selectivity 0.08

 #run cut_mask.sh

 #now process EPI according to time points that you want to analyze
 #run TC_BOLD.sh

afni_LayerMe.sh dnoised_T1_weighted.nii LN_V1.nii
mv dnoised_T1_weighted.nii.dat result_T1.dat


afni_LayerMe.sh Beta_VASO.nii LN_V1.nii
mv Beta_VASO.nii.dat result_VASO_Beta.dat

afni_LayerMe.sh Beta_BOLD.nii LN_V1.nii
mv Beta_BOLD.nii.dat result_BOLD_Beta.dat

afni_LayerMe.sh Tstat_VASO.nii LN_V1.nii
mv Tstat_VASO.nii.dat result_VASO_Tstat.dat

afni_LayerMe.sh Tstat_BOLD.nii LN_V1.nii
mv Tstat_BOLD.nii.dat result_BOLD_Tstat.dat


afni_LayerMe.sh smoothed_Tstat_VASO.nii LN_V1.nii
mv smoothed_Tstat_VASO.nii.dat result_sm_VASO_Tstat.dat

afni_LayerMe.sh smoothed_Tstat_BOLD.nii LN_V1.nii
mv smoothed_Tstat_BOLD.nii.dat result_sm_BOLD_Tstat.dat




















afni_LayerMe.sh sig_all_pr.nii LN_V1.nii
mv sig_all_pr.nii.dat result_pr.dat
afni_LayerMe.sh sig_all_up.nii LN_V1.nii
mv sig_all_up.nii.dat result_up.dat
afni_LayerMe.sh sig_all_orig.nii LN_V1.nii
mv sig_all_orig.nii.dat result_orig.dat


3dcopy sig_all_orig.nii sig_all_orig
3dcopy sig_all_pr.nii sig_all_pr
3dcopy sig_all_up.nii sig_all_up


3ddot -mask V1_layer.nii -NIML sig_all_orig+orig.HEAD sig_all_up+orig.HEAD sig_all_pr+orig.BRIK >> corr.1D
3ddot -mask V1_layer_d.nii -NIML sig_all_orig+orig.HEAD sig_all_up+orig.HEAD sig_all_pr+orig.BRIK >> corr.1D
3ddot -mask V1_layer_m.nii -NIML sig_all_orig+orig.HEAD sig_all_up+orig.HEAD sig_all_pr+orig.BRIK >> corr.1D
3ddot -mask V1_layer_u.nii -NIML sig_all_orig+orig.HEAD sig_all_up+orig.HEAD sig_all_pr+orig.BRIK >> corr.1D



1dRplot corr.1D



3dcalc -a LN_lh.nii -expr  'within(a,1,4)' -prefix Layer_d_lh.nii -overwrite 
3dcalc -a LN_lh.nii -expr 'within(a,5,8)' -prefix Layer_m_lh.nii -overwrite
3dcalc -a LN_lh.nii -expr  'within(a,9,11)' -prefix Layer_u_lh.nii -overwrite 



3dcalc -a LN_rh.nii -expr  'within(a,1,4)' -prefix Layer_d_rh.nii -overwrite 
3dcalc -a LN_rh.nii -expr 'within(a,5,8)' -prefix Layer_m_rh.nii -overwrite
3dcalc -a LN_rh.nii -expr  'within(a,9,11)' -prefix Layer_u_rh.nii -overwrite 


3dmerge -gmax -prefix cut_deep.nii Layer_d_?h.nii -overwrite
3dmerge -gmax -prefix cut_middle.nii Layer_m_?h.nii -overwrite
3dmerge -gmax -prefix cut_up.nii Layer_u_?h.nii -overwrite

3ddot -mask cut_up.nii -NIML   -dosums  orig+orig.HEAD unprime+orig.HEAD prime+orig.HEAD >> corr.1D
3ddot -mask cut_middle.nii -NIML   -dosums  orig+orig.HEAD unprime+orig.HEAD prime+orig.HEAD >> corr.1D
3ddot -mask cut_deep.nii -NIML   -dosums orig+orig.HEAD unprime+orig.HEAD prime+orig.HEAD >> corr.1D


1dRplot mid.1D


ideal voxels
==>101 52 37
==>134 45 32

