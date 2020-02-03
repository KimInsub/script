#!/bin/bash
# extract correlation for each condition across layers

# mean subtraction
cd stat

# 3dMean -prefix meanBOLD.nii scaled_Beta_*_*_BOLD*.nii

# for filename in scaled_Beta_*_*_BOLD*.nii
# do
# 	3dcalc -overwrite -prefix demean_${filename} -a ${filename} -b meanBOLD.nii -expr 'a-b'
# done

# 3dMean -prefix meanVASO.nii scaled_Beta_*_*VASO*.nii
# for filename in scaled_Beta_*_*VASO*.nii
# do
# 	3dcalc -overwrite -prefix demean_${filename} -a ${filename} -b meanVASO.nii -expr 'a-b'
# done



conds=(BOLD VASO)
for cond in "${conds[@]}"
do
	img=(1 2 3 4)
	for p in "${img[@]}"
	do
		3dMean -prefix meaned_I${p}_${cond}.nii scaled_Beta_M1_I${p}_${cond}.nii scaled_Beta_M2_I${p}_${cond}.nii scaled_Beta_O_I${p}_${cond}.nii 
		3dcalc -overwrite -prefix demean_scaled_Beta_M1_I${p}_${cond}.nii -a scaled_Beta_M1_I${p}_${cond}.nii -b meaned_I${p}_${cond}.nii -expr 'a-b'       
		3dcalc -overwrite  -prefix demean_scaled_Beta_M2_I${p}_${cond}.nii -a scaled_Beta_M2_I${p}_${cond}.nii -b meaned_I${p}_${cond}.nii -expr 'a-b'       
		3dcalc -overwrite  -prefix demean_scaled_Beta_O_I${p}_${cond}.nii -a scaled_Beta_O_I${p}_${cond}.nii -b meaned_I${p}_${cond}.nii -expr 'a-b'       
	done
done



cd ../results

#perform correlation
conds=(BOLD VASO)
img=(1 2 3 4)
lay=(a d m u)
for cond in "${conds[@]}"
do
	for la in "${lay[@]}"
	do
		for ii in "${img[@]}"
		do
			3ddot -demean -mask ../roi/${la}_V1.nii  ../stat/scaled_Beta_M1_I${ii}_${cond}.nii ../stat/scaled_Beta_M2_I${ii}_${cond}.nii ../stat/scaled_Beta_O_I${ii}_${cond}.nii >> temp_corr_imgs.txt 
		done
	echo $(cat temp_corr_imgs.txt   ) > ${cond}_${la}_corr_imgs.txt
	rm temp*.txt
	done
done



# conds=(BOLD VASO)
# for cond in "${conds[@]}"
# do
# 	img=(1 2 3 4)
# 	for p in "${img[@]}"
# 	do
# 		3dMean -prefix meaned_I{p}.nii scaled_Beta_M1_I{p}_${cond}.nii scaled_Beta_M2_I{p}_${cond}.nii scaled_Beta_O_I{p}_${cond}.nii 
# 		3dcalc -prefix -a scaled_Beta_M1_I{p}_${cond}.nii -b meaned_I{p}.nii -expr 'a-b'       

# 	done
# done


# conds=(BOLD VASO)
# for cond in "${conds[@]}"
# do
# 	3ddot   -demean -mask ../roi/d_V1.nii  ../stat/demean_scaled_Beta_M1_I1_${cond}.nii ../stat/demean_scaled_Beta_M2_I1_${cond}.nii ../stat/demean_scaled_Beta_O_I1_${cond}.nii > temp_corr_imgs.txt 
# 	3ddot   -demean -mask ../roi/d_V1.nii  ../stat/demean_scaled_Beta_M1_I2_${cond}.nii ../stat/demean_scaled_Beta_M2_I2_${cond}.nii ../stat/demean_scaled_Beta_O_I2_${cond}.nii >> temp_corr_imgs.txt 
# 	3ddot   -demean -mask ../roi/d_V1.nii  ../stat/demean_scaled_Beta_M1_I3_${cond}.nii ../stat/demean_scaled_Beta_M2_I3_${cond}.nii ../stat/demean_scaled_Beta_O_I3_${cond}.nii >> temp_corr_imgs.txt 
# 	3ddot   -demean -mask ../roi/d_V1.nii  ../stat/demean_scaled_Beta_M1_I4_${cond}.nii ../stat/demean_scaled_Beta_M2_I4_${cond}.nii ../stat/demean_scaled_Beta_O_I4_${cond}.nii >> temp_corr_imgs.txt 

# 	echo $(cat temp_corr_imgs.txt   ) > ${cond}_d_corr_imgs.txt

# 	rm temp*.txt

# done

# conds=(BOLD VASO)
# for cond in "${conds[@]}"
# do
# 	3ddot   -demean -mask ../roi/m_V1.nii  ../stat/scaled_Beta_M1_I1_${cond}.nii ../stat/scaled_Beta_M2_I1_${cond}.nii ../stat/scaled_Beta_O_I1_${cond}.nii > temp_corr_imgs.txt 
# 	3ddot   -demean -mask ../roi/m_V1.nii  ../stat/scaled_Beta_M1_I2_${cond}.nii ../stat/scaled_Beta_M2_I2_${cond}.nii ../stat/scaled_Beta_O_I2_${cond}.nii >> temp_corr_imgs.txt 
# 	3ddot   -demean -mask ../roi/m_V1.nii  ../stat/scaled_Beta_M1_I3_${cond}.nii ../stat/scaled_Beta_M2_I3_${cond}.nii ../stat/scaled_Beta_O_I3_${cond}.nii >> temp_corr_imgs.txt 
# 	3ddot   -demean -mask ../roi/m_V1.nii  ../stat/scaled_Beta_M1_I4_${cond}.nii ../stat/scaled_Beta_M2_I4_${cond}.nii ../stat/scaled_Beta_O_I4_${cond}.nii >> temp_corr_imgs.txt 

# 	echo $(cat temp_corr_imgs.txt   ) > ${cond}_m_corr_imgs.txt

# 	rm temp*.txt

# done

# conds=(BOLD VASO)
# for cond in "${conds[@]}"
# do
# 	3ddot   -demean -mask ../roi/u_V1.nii  ../stat/scaled_Beta_M1_I1_${cond}.nii ../stat/scaled_Beta_M2_I1_${cond}.nii ../stat/scaled_Beta_O_I1_${cond}.nii > temp_corr_imgs.txt 
# 	3ddot -demean  -mask ../roi/u_V1.nii  ../stat/scaled_Beta_M1_I2_${cond}.nii ../stat/scaled_Beta_M2_I2_${cond}.nii ../stat/scaled_Beta_O_I2_${cond}.nii >> temp_corr_imgs.txt 
# 	3ddot -demean  -mask ../roi/u_V1.nii  ../stat/scaled_Beta_M1_I3_${cond}.nii ../stat/scaled_Beta_M2_I3_${cond}.nii ../stat/scaled_Beta_O_I3_${cond}.nii >> temp_corr_imgs.txt 
# 	3ddot -demean  -mask ../roi/u_V1.nii  ../stat/scaled_Beta_M1_I4_${cond}.nii ../stat/scaled_Beta_M2_I4_${cond}.nii ../stat/scaled_Beta_O_I4_${cond}.nii >> temp_corr_imgs.txt 

# 	echo $(cat temp_corr_imgs.txt   ) > ${cond}_u_corr_imgs.txt

# 	rm temp*.txt

# done



#paste -d, - - - < <( tr ' ' '\n' <corr_imgs.txt  ) > BOLD_corr_imgs.txt 

	# echo $(cat temp_corr_imgs.txt   ) > temp_corr_imgs.txt

	# tr ' ' ',' <temp_corr_imgs.txt  > temp_temp_corr_imgs.txt 
	# if [[ $cond == BOLD ]]; then
	# 	{ echo -e "BOLD_img1-M1-M2_cor,BOLD_img1-M1-O_cor,BOLD_img1-M2-O_cor,BOLD_img2-M1-M2_cor,BOLD_img2-M1-O_cor,BOLD_img2-M2-O_cor,BOLD_img3-M1-M2_cor,BOLD_img3-M1-O_cor,BOLD_img3-M2-O_cor,BOLD_img4-M1-M2_cor,BOLD_img4-M1-O_cor,BOLD_img4-M2-O_cor"; cat temp_temp_corr_imgs.txt; } > ${cond}_corr_imgs.txt
	# else
	# 	{ echo -e "VASO_img1-M1-M2_cor,VASO_img1-M1-O_cor,VASO_img1-M2-O_cor,VASO_img2-M1-M2_cor,VASO_img2-M1-O_cor,VASO_img2-M2-O_cor,VASO_img3-M1-M2_cor,VASO_img3-M1-O_cor,VASO_img3-M2-O_cor,VASO_img4-M1-M2_cor,VASO_img4-M1-O_cor,VASO_img4-M2-O_cor"; cat temp_temp_corr_imgs.txt; } > ${cond}_corr_imgs.txt
	# fi

