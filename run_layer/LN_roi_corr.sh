#!/bin/bash
# extract correlation for each condition across layers
cd results

conds=(BOLD VASO)
for cond in "${conds[@]}"
do
	3ddot -mask ../roi/a_V1.nii  ../stat/scaled_Beta_M1_I1_${cond}.nii ../stat/scaled_Beta_M2_I1_${cond}.nii ../stat/scaled_Beta_O_I1_${cond}.nii > temp_corr_imgs.txt 
	3ddot -mask ../roi/a_V1.nii  ../stat/scaled_Beta_M1_I2_${cond}.nii ../stat/scaled_Beta_M2_I2_${cond}.nii ../stat/scaled_Beta_O_I2_${cond}.nii >> temp_corr_imgs.txt 
	3ddot -mask ../roi/a_V1.nii  ../stat/scaled_Beta_M1_I3_${cond}.nii ../stat/scaled_Beta_M2_I3_${cond}.nii ../stat/scaled_Beta_O_I3_${cond}.nii >> temp_corr_imgs.txt 
	3ddot -mask ../roi/a_V1.nii  ../stat/scaled_Beta_M1_I4_${cond}.nii ../stat/scaled_Beta_M2_I4_${cond}.nii ../stat/scaled_Beta_O_I4_${cond}.nii >> temp_corr_imgs.txt 

	echo $(cat temp_corr_imgs.txt   ) > ${cond}_a_corr_imgs.txt

	# echo $(cat temp_corr_imgs.txt   ) > temp_corr_imgs.txt

	# tr ' ' ',' <temp_corr_imgs.txt  > temp_temp_corr_imgs.txt 
	# if [[ $cond == BOLD ]]; then
	# 	{ echo -e "BOLD_img1-M1-M2_cor,BOLD_img1-M1-O_cor,BOLD_img1-M2-O_cor,BOLD_img2-M1-M2_cor,BOLD_img2-M1-O_cor,BOLD_img2-M2-O_cor,BOLD_img3-M1-M2_cor,BOLD_img3-M1-O_cor,BOLD_img3-M2-O_cor,BOLD_img4-M1-M2_cor,BOLD_img4-M1-O_cor,BOLD_img4-M2-O_cor"; cat temp_temp_corr_imgs.txt; } > ${cond}_corr_imgs.txt
	# else
	# 	{ echo -e "VASO_img1-M1-M2_cor,VASO_img1-M1-O_cor,VASO_img1-M2-O_cor,VASO_img2-M1-M2_cor,VASO_img2-M1-O_cor,VASO_img2-M2-O_cor,VASO_img3-M1-M2_cor,VASO_img3-M1-O_cor,VASO_img3-M2-O_cor,VASO_img4-M1-M2_cor,VASO_img4-M1-O_cor,VASO_img4-M2-O_cor"; cat temp_temp_corr_imgs.txt; } > ${cond}_corr_imgs.txt
	# fi

	rm temp*.txt

done


conds=(BOLD VASO)
for cond in "${conds[@]}"
do
	3ddot -mask ../roi/d_V1.nii  ../stat/scaled_Beta_M1_I1_${cond}.nii ../stat/scaled_Beta_M2_I1_${cond}.nii ../stat/scaled_Beta_O_I1_${cond}.nii > temp_corr_imgs.txt 
	3ddot -mask ../roi/d_V1.nii  ../stat/scaled_Beta_M1_I2_${cond}.nii ../stat/scaled_Beta_M2_I2_${cond}.nii ../stat/scaled_Beta_O_I2_${cond}.nii >> temp_corr_imgs.txt 
	3ddot -mask ../roi/d_V1.nii  ../stat/scaled_Beta_M1_I3_${cond}.nii ../stat/scaled_Beta_M2_I3_${cond}.nii ../stat/scaled_Beta_O_I3_${cond}.nii >> temp_corr_imgs.txt 
	3ddot -mask ../roi/d_V1.nii  ../stat/scaled_Beta_M1_I4_${cond}.nii ../stat/scaled_Beta_M2_I4_${cond}.nii ../stat/scaled_Beta_O_I4_${cond}.nii >> temp_corr_imgs.txt 

	echo $(cat temp_corr_imgs.txt   ) > ${cond}_d_corr_imgs.txt

	rm temp*.txt

done

conds=(BOLD VASO)
for cond in "${conds[@]}"
do
	3ddot -mask ../roi/m_V1.nii  ../stat/scaled_Beta_M1_I1_${cond}.nii ../stat/scaled_Beta_M2_I1_${cond}.nii ../stat/scaled_Beta_O_I1_${cond}.nii > temp_corr_imgs.txt 
	3ddot -mask ../roi/m_V1.nii  ../stat/scaled_Beta_M1_I2_${cond}.nii ../stat/scaled_Beta_M2_I2_${cond}.nii ../stat/scaled_Beta_O_I2_${cond}.nii >> temp_corr_imgs.txt 
	3ddot -mask ../roi/m_V1.nii  ../stat/scaled_Beta_M1_I3_${cond}.nii ../stat/scaled_Beta_M2_I3_${cond}.nii ../stat/scaled_Beta_O_I3_${cond}.nii >> temp_corr_imgs.txt 
	3ddot -mask ../roi/m_V1.nii  ../stat/scaled_Beta_M1_I4_${cond}.nii ../stat/scaled_Beta_M2_I4_${cond}.nii ../stat/scaled_Beta_O_I4_${cond}.nii >> temp_corr_imgs.txt 

	echo $(cat temp_corr_imgs.txt   ) > ${cond}_m_corr_imgs.txt

	rm temp*.txt

done

conds=(BOLD VASO)
for cond in "${conds[@]}"
do
	3ddot -mask ../roi/u_V1.nii  ../stat/scaled_Beta_M1_I1_${cond}.nii ../stat/scaled_Beta_M2_I1_${cond}.nii ../stat/scaled_Beta_O_I1_${cond}.nii > temp_corr_imgs.txt 
	3ddot -mask ../roi/u_V1.nii  ../stat/scaled_Beta_M1_I2_${cond}.nii ../stat/scaled_Beta_M2_I2_${cond}.nii ../stat/scaled_Beta_O_I2_${cond}.nii >> temp_corr_imgs.txt 
	3ddot -mask ../roi/u_V1.nii  ../stat/scaled_Beta_M1_I3_${cond}.nii ../stat/scaled_Beta_M2_I3_${cond}.nii ../stat/scaled_Beta_O_I3_${cond}.nii >> temp_corr_imgs.txt 
	3ddot -mask ../roi/u_V1.nii  ../stat/scaled_Beta_M1_I4_${cond}.nii ../stat/scaled_Beta_M2_I4_${cond}.nii ../stat/scaled_Beta_O_I4_${cond}.nii >> temp_corr_imgs.txt 

	echo $(cat temp_corr_imgs.txt   ) > ${cond}_u_corr_imgs.txt

	rm temp*.txt

done



#paste -d, - - - < <( tr ' ' '\n' <corr_imgs.txt  ) > BOLD_corr_imgs.txt 


