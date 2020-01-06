
antsApplyTransforms --interpolation BSpline[5] -d 3 -i reg_T1.nii -r meaned_topup.nii -t transform.txt -o registered_applied.nii

3dcalc -a seg.nii -b meaned_topup.nii -expr  'a*b' -prefix visual_EPI.nii -overwrite 
3dcalc -a seg.nii -b anat_space.nii -expr  'a*b' -prefix visual_anat.nii -overwrite 


fix=visual_EPI.nii
move=visual_anat.nii

antsRegistration \
--verbose 1 \
--dimensionality 3 \
--float 1 \
--output [registered_,registered_Warped.nii.gz,registered_InverseWarped.nii.gz] \
--interpolation Linear \
--use-histogram-matching 0 \
--winsorize-image-intensities [0.005,0.995] \
--transform Rigid[0.05] \
--metric MI[$fix,$move,0.7,32,Regular,0.1] \
--convergence [1000x500,1e-6,10] \
--shrink-factors 2x1 \
--smoothing-sigmas 1x0vox \
--transform Affine[0.1] \
--metric MI[$fix,$move,0.7,32,Regular,0.1] \
--convergence [1000x500,1e-6,10] \
--shrink-factors 2x1 \
--smoothing-sigmas 1x0vox \
--transform SyN[0.1,2,0] \
--metric CC[$fix,$move,1,2] \
--convergence [500x100,1e-6,10] \
--shrink-factors 2x1 \
--smoothing-sigmas 1x0vox \

antsApplyTransforms --interpolation BSpline[5] -d 3 -i $move -r $fix -t registered_1Warp.nii.gz -t registered_0GenericAffine.mat -o registered_applied2.nii
antsApplyTransforms --interpolation BSpline[5] -d 3 -i reg_T1.nii -r meaned_topup.nii -t transform_non.txt -o anat_sapce.nii
