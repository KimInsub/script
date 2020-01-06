for d in */ ; do
    dcm2nii -o  './' ${d}
done

gunzip *



TargetNumer=264
for filename in ./*.nii
do
output1="$(3dinfo -nt $filename)"

if (( $output1 == TargetNumer )); then
    echo $filename
else
    rm $filename
fi

done

mv *.nii ../
cd ../

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

echo "CREATE MOMA"

cp /media/ururru/layers/Layer_script/mocobatch_VASO3.m ./
export DYLD_FALLBACK_LIBRARY_PATH="/usr/lib/:$DYLD_LIBRARY_PATH"
/usr/local/MATLAB/R2018a/bin/matlab -nodesktop -nosplash -r "mocobatch_VASO3"



rm ./Basis_*.nii
rm ./Basis*.mat


################################# allRuns  #################################

mkdir allRuns
cd allRuns

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

mv BOLD_intemp.nii BOLD_LN.nii    
LN_MP2RAGE_DNOISE -INV1 mean_nulled.nii -INV2 mean_notnulled.nii -UNI T1_weighted.nii -beta 5













################################# ALL GLM  #################################
mkdir GLM
cd GLM
3dDeconvolve -input ../BOLD_LN.nii                   \
    -polort 8                                                           \
    -num_stimts 2                                                       \
    -stim_times 1 /media/ururru/layers/mooney_VASO/stimFile/on.txt  'BLOCK(16,1)'              \
    -stim_label 1 StimOn                                                \
    -stim_times 2 /media/ururru/layers/mooney_VASO/stimFile/off.txt  'BLOCK(16,1)'              \
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
    -stim_times 1 /media/ururru/layers/mooney_VASO/stimFile/on.txt  'BLOCK(16,1)'              \
    -stim_label 1 StimOn                                                \
    -stim_times 2 /media/ururru/layers/mooney_VASO/stimFile/off.txt  'BLOCK(16,1)'              \
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




################################# EACH RUN  #################################
cd ../../
mkdir eachRun
cd eachRun


3dMean -prefix Nulled_Basis_b.nii ../Nulled_Basis_*b.nii -overwrite
3dMean -prefix Not_Nulled_Basis_a.nii ../Not_Nulled_Basis_*a.nii -overwrite


NumVol=`3dinfo -nv Nulled_Basis_b.nii`
3dcalc -a Nulled_Basis_b.nii'[3..'`expr $NumVol - 2`']' -b  Not_Nulled_Basis_a.nii'[3..'`expr $NumVol - 2`']' -expr 'a+b' -prefix combined.nii -overwrite
3dTstat -cvarinv -prefix T1_weighted.nii -overwrite combined.nii 
rm combined.nii


run=(0 1 2 3 4 5 6 7 8)
for p in "${run[@]}"
do

3dcalc -a ../Nulled_Basis_${p}b.nii'[1..$(2)]' -expr 'a' -prefix Nulled_r${p}.nii -overwrite
3dcalc -a ../Not_Nulled_Basis_${p}a.nii'[0..$(2)]' -expr 'a' -prefix BOLD_r${p}.nii -overwrite

3drefit -space ORIG -view orig -TR 4 BOLD_r${p}.nii
3drefit -space ORIG -view orig -TR 4 Nulled_r${p}.nii

3dTstat -mean -prefix mean_nulled.nii Nulled_r${p}.nii -overwrite
3dTstat -mean -prefix mean_notnulled.nii BOLD_r${p}.nii -overwrite

3dUpsample -overwrite  -datum short -prefix Nulled_intemp_r${p}.nii -n 2 -input Nulled_r${p}.nii
3dUpsample -overwrite  -datum short -prefix BOLD_intemp_r${p}.nii   -n 2 -input   BOLD_r${p}.nii

#NumVol=`3dinfo -nv BOLD_intemp_r${p}.nii`
#3dTcat -overwrite -prefix Nulled_intemp_r${p}.nii Nulled_intemp_r${p}.nii'[0]' Nulled_intemp_r${p}.nii'[0..'`expr $NumVol - 2`']' 


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

#LN_SKEW -timeseries BOLD_intemp.nii
#LN_SKEW -timeseries VASO_LN.nii

mv BOLD_intemp_r${p}.nii BOLD_LN_r${p}.nii    
3drefit -TR 2. BOLD_LN_r${p}.nii    
3drefit -TR 2. VASO_LN_r${p}.nii



done

LN_MP2RAGE_DNOISE -INV1 mean_nulled.nii -INV2 mean_notnulled.nii -UNI T1_weighted.nii -beta 5


################################# preprocessing  #################################

mkdir prepro
cd  prepro

cond=(BOLD VASO)
for c in "${cond[@]}"
do
    run=( 0 1 2 3 4 5 6 7 8)
    for r in "${run[@]}"
    do
        3dClipLevel ../${c}_LN_r${r}.nii >> clip.txt
        3dTstat -mean -prefix ${c}.${r}.base.nii ../${c}_LN_r${r}.nii'[0..$]' 

    done

    more clip.txt # check the smallest clip value across all runs
    clip=$(cut -f1 -d"," clip.txt | sort -n | head -1) # assign the clip value# assign the clip value

    for r in "${run[@]}"
    do
        3dcalc -a ../${c}_LN_r${r}.nii -b ${c}.${r}.base.nii  \
        -expr "(100 * a/b) * step(b-$clip)" -prefix ${c}_r${r}.scaled.nii #remove the space and scale 
        3dDetrend -overwrite -polort 1 -prefix ${c}_r${r}.scaled_dt.nii ${c}_r${r}.scaled.nii
        3dBandpass -overwrite -prefix ${c}_r${r}.scaled_dt_hp.nii 0.01 99999 ${c}_r${r}.scaled_dt.nii
        3dcalc  -a ${c}_r${r}.scaled_dt_hp.nii -b ${c}.${r}.base.nii \
        -expr 'a+b' -prefix ${c}_r${r}.nii
    done
done

    run=( 0 1 2 3 4 5 6 7 8)
    for r in "${run[@]}"
    do
        3dcalc -a VASO_r${r}.nii -expr '(a*-1)' -prefix VASO_r${r}.nii -overwrite
    done



rm *scaled*
rm *base*



    run=( 0 1 2 3 4 5 6 7 8)
    for r in "${run[@]}"
    do
        LN_GRADSMOOTH -gradfile dnoised_T1_weighted.nii -input BOLD_r${r}.nii -FWHM 1.4 -within -selectivity 0.08
        LN_GRADSMOOTH -gradfile dnoised_T1_weighted.nii -input VASO_r${r}.nii -FWHM 1.4 -within -selectivity 0.08
    done
################################# changeName  #################################

conds=(BOLD VASO)
for cond in "${conds[@]}"
do
mv ${cond}_r0.nii ${cond}_M1_r1.nii
mv ${cond}_r1.nii ${cond}_M1_r2.nii
mv ${cond}_r2.nii ${cond}_M1_r3.nii

mv ${cond}_r3.nii ${cond}_O_r1.nii
mv ${cond}_r4.nii ${cond}_O_r2.nii
mv ${cond}_r5.nii ${cond}_O_r3.nii

mv ${cond}_r6.nii ${cond}_M2_r1.nii
mv ${cond}_r7.nii ${cond}_M2_r2.nii
mv ${cond}_r8.nii ${cond}_M2_r3.nii

done

  run=( 0 1 2 3 4 5 6 7 8)
    for r in "${run[@]}"
    do
        LN_GRADSMOOTH -gradfile dnoised_T1_weighted.nii -input BOLD_r${r}.nii -FWHM 1.4 -within -selectivity 0.08
        LN_GRADSMOOTH -gradfile dnoised_T1_weighted.nii -input VASO_r${r}.nii -FWHM 1.4 -within -selectivity 0.08
    done


conds=(BOLD VASO)
for cond in "${conds[@]}"
do
cp ${cond}_M1_r1.nii ${cond}_r0.nii
cp ${cond}_M1_r2.nii ${cond}_r1.nii
cp ${cond}_M1_r3.nii  ${cond}_r2.nii
 
cp  ${cond}_O_r1.nii ${cond}_r3.nii
cp  ${cond}_O_r2.nii  ${cond}_r4.nii
cp  ${cond}_O_r3.nii ${cond}_r5.nii

cp ${cond}_M2_r1.nii ${cond}_r6.nii 
cp ${cond}_M2_r2.nii  ${cond}_r7.nii
cp ${cond}_M2_r3.nii ${cond}_r8.nii

done


################################# GLM  #################################


mkdir GLM
cd GLM

subj=YJY
imgList=(12 16 24 25)
MasterDir=/media/ururru/layers/mooney_VASO/stimFile
conds=(BOLD VASO)

for cond in "${conds[@]}"
do
3dDeconvolve -input ../${cond}_M1*.nii                 \
    -polort 8                                                           \
    -num_stimts 4                                                       \
    -stim_times 1 ${MasterDir}/${subj}_mooney1_img${imgList[0]}.txt  'BLOCK(16,1)'              \
    -stim_label 1 M1_img1                                                \
    -stim_times 2 ${MasterDir}/${subj}_mooney1_img${imgList[1]}.txt  'BLOCK(16,1)'             \
    -stim_label 2 M1_img2                                               \
    -stim_times 3 ${MasterDir}/${subj}_mooney1_img${imgList[2]}.txt  'BLOCK(16,1)'             \
    -stim_label 3 M1_img3                                               \
    -stim_times 4 ${MasterDir}/${subj}_mooney1_img${imgList[3]}.txt  'BLOCK(16,1)'             \
    -stim_label 4 M1_img4                                                                        \
    -local_times                                                        \
    -float                                                              \
    -fout -tout -x1D X.xmat.1D -xjpeg X.jpg                             \
    -x1D_uncensored X.nocensor.xmat.1D                                  \
    -bucket stats_${cond}.M1.all        \
    -overwrite  

3dbucket -prefix Beta_M1_I1_${cond}.nii stats_${cond}.M1.all+orig.BRIK'[1]' -overwrite
3dbucket -prefix Beta_M1_I2_${cond}.nii stats_${cond}.M1.all+orig.BRIK'[4]' -overwrite
3dbucket -prefix Beta_M1_I3_${cond}.nii stats_${cond}.M1.all+orig.BRIK'[7]' -overwrite
3dbucket -prefix Beta_M1_I4_${cond}.nii stats_${cond}.M1.all+orig.BRIK'[10]' -overwrite


3dDeconvolve -input ../${cond}_O*.nii                 \
    -polort 8                                                           \
    -num_stimts 4                                                       \
    -stim_times 1 ${MasterDir}/${subj}_original_img${imgList[0]}.txt  'BLOCK(16,1)'              \
    -stim_label 1 O_img1                                                \
    -stim_times 2 ${MasterDir}/${subj}_original_img${imgList[1]}.txt  'BLOCK(16,1)'             \
    -stim_label 2 O_img2                                               \
    -stim_times 3 ${MasterDir}/${subj}_original_img${imgList[2]}.txt  'BLOCK(16,1)'             \
    -stim_label 3 O_img3                                               \
    -stim_times 4 ${MasterDir}/${subj}_original_img${imgList[3]}.txt  'BLOCK(16,1)'             \
    -stim_label 4 O_img4                                                                        \
    -local_times                                                        \
    -float                                                              \
    -fout -tout -x1D X.xmat.1D -xjpeg X.jpg                             \
    -x1D_uncensored X.nocensor.xmat.1D                                  \
    -bucket stats_${cond}.O1.all        \
    -overwrite  

3dbucket -prefix Beta_O_I1_${cond}.nii stats_${cond}.O1.all+orig.BRIK'[1]' -overwrite
3dbucket -prefix Beta_O_I2_${cond}.nii stats_${cond}.O1.all+orig.BRIK'[4]' -overwrite
3dbucket -prefix Beta_O_I3_${cond}.nii stats_${cond}.O1.all+orig.BRIK'[7]' -overwrite
3dbucket -prefix Beta_O_I4_${cond}.nii stats_${cond}.O1.all+orig.BRIK'[10]' -overwrite


3dDeconvolve -input ../${cond}_M2*.nii                \
    -polort 8                                                           \
    -num_stimts 4                                                       \
    -stim_times 1 ${MasterDir}/${subj}_mooney2_img${imgList[0]}.txt  'BLOCK(16,1)'              \
    -stim_label 1 M2_img1                                                \
    -stim_times 2 ${MasterDir}/${subj}_mooney2_img${imgList[1]}.txt  'BLOCK(16,1)'             \
    -stim_label 2 M2_img2                                               \
    -stim_times 3 ${MasterDir}/${subj}_mooney2_img${imgList[2]}.txt  'BLOCK(16,1)'             \
    -stim_label 3 M2_img3                                               \
    -stim_times 4 ${MasterDir}/${subj}_mooney2_img${imgList[3]}.txt  'BLOCK(16,1)'             \
    -stim_label 4 M2_img4                                                                        \
    -local_times                                                        \
    -float                                                              \
    -fout -tout -x1D X.xmat.1D -xjpeg X.jpg                             \
    -x1D_uncensored X.nocensor.xmat.1D                                  \
    -bucket stats_${cond}.M2.all        \
    -overwrite  


3dbucket -prefix Beta_M2_I1_${cond}.nii stats_${cond}.M2.all+orig.BRIK'[1]' -overwrite
3dbucket -prefix Beta_M2_I2_${cond}.nii stats_${cond}.M2.all+orig.BRIK'[4]' -overwrite
3dbucket -prefix Beta_M2_I3_${cond}.nii stats_${cond}.M2.all+orig.BRIK'[7]' -overwrite
3dbucket -prefix Beta_M2_I4_${cond}.nii stats_${cond}.M2.all+orig.BRIK'[10]' -overwrite

3dcalc  -a Beta_M2_I1_${cond}.nii -b Beta_M1_I1_${cond}.nii -expr 'a-b' -prefix ${cond}.Moon_1.nii
3dcalc  -a Beta_M2_I2_${cond}.nii -b Beta_M1_I2_${cond}.nii -expr 'a-b' -prefix ${cond}.Moon_2.nii
3dcalc  -a Beta_M2_I3_${cond}.nii -b Beta_M1_I3_${cond}.nii -expr 'a-b' -prefix ${cond}.Moon_3.nii
3dcalc  -a Beta_M2_I4_${cond}.nii -b Beta_M1_I4_${cond}.nii -expr 'a-b' -prefix ${cond}.Moon_4.nii
3dMean -prefix ${cond}.Moon_all.nii ${cond}.Moon_?.nii -overwrite


done 

################################# LOLOLO  #################################

conds=(BOLD VASO)
MasterDir=/media/ururru/layers/mooney_VASO/stimFile
for cond in "${conds[@]}"
do
3dDeconvolve -input ../${cond}_r0.nii ../${cond}_r1.nii                 \
    -polort 3                                                           \
    -num_stimts 2                                                       \
    -stim_times 1 ${MasterDir}/LO_object.txt 'BLOCK(16,1)'             \
    -stim_label 1 object                                               \
    -stim_times 2 ${MasterDir}/LO_scram.txt  'BLOCK(16,1)'             \
    -stim_label 2 scram                                                                        \
    -local_times                                                        \
    -gltsym 'SYM: +1*object -1*scram' \
    -glt_label 1 object-scram \
    -float                                                              \
    -fout -tout -x1D X.xmat.1D -xjpeg X.jpg                             \
    -x1D_uncensored X.nocensor.xmat.1D                                  \
    -bucket stats_${cond}.all        \
    -overwrite  
done

3dbucket -prefix LO_tstat_${cond}.nii stats_${cond}.all+orig.HEAD'[8]' -overwrite
3dbucket -prefix LO_beta_${cond}.nii stats_${cond}.all+orig.HEAD'[7]' -overwrite



################################# preprocessing  #################################

3dDeconvolve -input ../VASO_r?.nii                   \
    -polort 8                                                           \
    -num_stimts 12                                                       \
    -stim_times 1 ${MasterDir}/${subj}_mooney1_img${imgList[0]}.txt  'BLOCK(16,1)'              \
    -stim_label 1 M1_img1                                                \
    -stim_times 2 ${MasterDir}/${subj}_mooney1_img${imgList[1]}.txt  'BLOCK(16,1)'             \
    -stim_label 2 M1_img2                                               \
    -stim_times 3 ${MasterDir}/${subj}_mooney1_img${imgList[2]}.txt  'BLOCK(16,1)'             \
    -stim_label 3 M1_img3                                               \
    -stim_times 4 ${MasterDir}/${subj}_mooney1_img${imgList[3]}.txt  'BLOCK(16,1)'             \
    -stim_label 4 M1_img4                                               \
    -stim_times 5 ${MasterDir}/${subj}_mooney2_img${imgList[0]}.txt  'BLOCK(16,1)'             \
    -stim_label 5 M2_img1                                               \
    -stim_times 6 ${MasterDir}/${subj}_mooney2_img${imgList[0]}.txt  'BLOCK(16,1)'             \
    -stim_label 6 M2_img2                                               \
    -stim_times 7 ${MasterDir}/${subj}_mooney2_img${imgList[0]}.txt  'BLOCK(16,1)'             \
    -stim_label 7 M2_img3                                               \
    -stim_times 8 ${MasterDir}/${subj}_mooney2_img${imgList[0]}.txt  'BLOCK(16,1)'             \
    -stim_label 8 M2_img4                                               \
    -stim_times 9 ${MasterDir}/${subj}_original_img${imgList[0]}.txt  'BLOCK(16,1)'             \
    -stim_label 9 O_img1                                               \
    -stim_times 10 ${MasterDir}/${subj}_original_img${imgList[0]}.txt  'BLOCK(16,1)'             \
    -stim_label 10 O_img2                                               \
    -stim_times 11 ${MasterDir}/${subj}_original_img${imgList[0]}.txt  'BLOCK(16,1)'             \
    -stim_label 11 O_img3                                               \
    -stim_times 12 ${MasterDir}/${subj}_original_img${imgList[0]}.txt  'BLOCK(16,1)'             \
    -stim_label 12 O_img4                                 \
    -gltsym 'SYM: M2_img1 -M1_img1'                      \
    -glt_label 1 moon1                        \
    -gltsym 'SYM: M2_img2 -M1_img2'                      \
    -glt_label 2 moon2                                 \
    -gltsym 'SYM: M2_img3 -M1_img3'                      \
    -glt_label 3 moon3                       \
    -gltsym 'SYM: M2_img4 -M1_img4'                      \
    -glt_label 4 moon4                                 \
    -gltsym 'SYM: +M2_img1 +M2_img2 +M2_img3 +M2_img4 -M1_img1 -M1_img2 -M1_img3 -M1_img4'                      \
    -glt_label 5 moon_all                              \
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

3dTcat -overwrite -prefix send.nii 20190724_131214usedforNOVAmotors010a001.nii'[2..6]'
