#!/bin/bash


conds=(BOLD VASO)
for cond in "${conds[@]}"
do
	
mv ${cond}_r0.nii ${cond}_M1_r1.nii 
mv ${cond}_r1.nii ${cond}_M1_r2.nii 

mv ${cond}_r2.nii ${cond}_O_r3.nii
mv ${cond}_r3.nii ${cond}_O_r4.nii

mv ${cond}_r4.nii ${cond}_M1_r5.nii 
mv ${cond}_r5.nii ${cond}_M1_r6.nii 

done

