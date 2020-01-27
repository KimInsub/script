#!/bin/bash
# extract each layer signal

mkdir stat
mkdir results

mv eachRun/prepro/GLM1/scaled*.nii ./stat
mv eachRun/prepro/GLM2/scaled*.nii ./stat

mv roi/scaled_dnoised_T1_weighted.nii ./stat

cd results

# T1 signal profile
LN_psig.sh ../stat/scaled_dnoised_T1_weighted.nii ../roi/a_V1.nii 
mv psig.txt T1_signal.txt

# meaned responses GLM

LN_psig.sh ../stat/scaled_Beta_BOLD.nii ../roi/a_V1.nii 
mv psig.txt BOLD_mean.txt

LN_psig.sh ../stat/scaled_Beta_VASO.nii ../roi/a_V1.nii 
mv psig.txt VASO_mean.txt

# all image responses GLM 
LN_psig.sh ../stat/scaled_BOLD.Moon_all.nii ../roi/a_V1.nii 
mv psig.txt BOLD_mooney.txt

LN_psig.sh ../stat/scaled_VASO.Moon_all.nii ../roi/a_V1.nii 
mv psig.txt VASO_mooney.txt


# each image responses GLM 
for filename in ../stat/*.nii
do
	savename="$(echo $filename | cut -d'_' -f3 -f4)"
	suffixname=".txt"
	if [[ $savename != *nii* ]]; then		
		if [[ $filename == *BOLD* ]]; then
			echo "+++++++++++++" $savename "+++++++++++++"
			LN_psig.sh $filename ../roi/a_V1.nii 
			mv psig.txt BOLD_$savename$suffixname
		fi
		if [[ $filename == *VASO* ]]; then
			echo "+++++++++++++" $savename "+++++++++++++"
			LN_psig.sh $filename ../roi/a_V1.nii 
			mv psig.txt VASO_$savename$suffixname
		fi
	fi
done



#paste -d, - - - < <( tr ' ' '\n' <corr_imgs.txt  ) > BOLD_corr_imgs.txt 


