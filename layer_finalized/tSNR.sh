
for d in */ ; do
    dcm2nii -o  './' ${d}
done

gunzip *


3dcalc -a  EPI_3D.nii'[5..$]' -expr 'a' -prefix EPI_3D_cat.nii -overwrite
3dcalc -a  EPI_2D.nii'[5..$]' -expr 'a' -prefix EPI_2D_cat.nii -overwrite


cnt=0
#remove last Dummy 3TR
for filename in ./EPI*.nii
do
echo $filename
cp $filename ./Basis_${cnt}a.nii
#3dTcat -prefix Basis_${cnt}a.nii Basis_${cnt}a.nii'[0..184]' -overwrite
3dinfo -nt Basis_${cnt}a.nii >> NT.txt  
cnt=$(($cnt+1))

done


cp /media/ururru/layers/Layer_script/mocobatch_BOLD.m ./
export DYLD_FALLBACK_LIBRARY_PATH="/usr/lib/:$DYLD_LIBRARY_PATH"
/usr/local/MATLAB/R2018a/bin/matlab -nodesktop -nosplash -r "mocobatch_BOLD"


#make pretty T1
start_bias_field.sh  T1.nii
denoise_me.sh bico_T1.nii
rm c?uncorr.nii

 3dTstat  -overwrite -cvarinv  -prefix NOVA_KHS_3D.tSNR.nii \
     BOLD_Basis_0a.nii'[1..$]'

 3dTstat  -overwrite -cvarinv  -prefix NOVA_KHS_2D.tSNR.nii \
     BOLD_Basis_0a.nii'[1..$]'

      3dTstat  -overwrite -cvarinv  -prefix New_KHS_2D.tSNR.nii \
     BOLD_Basis_0a.nii'[1..$]'

     3dTstat  -overwrite -cvarinv  -prefix New_KHS_3D.tSNR.nii \
     BOLD_Basis_0a.nii'[1..$]'


 3dTstat  -overwrite -cvarinv  -prefix NOVA_SBP_2D.tSNR.nii \
     BOLD_Basis_0a.nii'[1..$]'

 3dTstat  -overwrite -cvarinv  -prefix New_SBP_3D.tSNR.nii \
     BOLD_Basis_0a.nii'[1..$]'


antsApplyTransforms --interpolation BSpline[5] -d 3 -i New_KHS_3D.tSNR.nii -r NOVA_KHS_3D.tSNR.nii  -t init_KHS_3D_al.txt -o KHS_3D_al.nii

antsApplyTransforms --interpolation BSpline[5] -d 3 -i New_KHS_2D.tSNR.nii -r NOVA_KHS_2D.tSNR.nii  -t init_KHS_2D.txt -o KHS_2D_al.nii

antsApplyTransforms --interpolation BSpline[5] -d 3 -i New_SBP_2D.tSNR.nii -r NOVA_SBP_2D.tSNR.nii  -t init3_SBP_2D.txt -o SBP_2D_al.nii

antsApplyTransforms --interpolation BSpline[5] -d 3 -i New_SBP_3D.tSNR.nii -r NOVA_SBP_3D.tSNR.nii  -t init3_SBP_3D.txt -o SBP_3D_al.nii
