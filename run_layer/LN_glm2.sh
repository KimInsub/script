
mkdir eachrun/prepro/GLM2
cd eachrun/prepro/GLM2

subj=$1
imgList=(12 16 22 24)
MasterDir=/Users/insubkim/Documents/experiment/mooney/behavior/$subj
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