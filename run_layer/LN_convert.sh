#!/bin/bash

# convert Dicom 2 nii 

for d in */ ; do
    dcm2niix -o  './' ${d}
done

rm *.json
mkdir extra

TargetNumer=264
for filename in ./*.nii
do
output1="$(3dinfo -nt $filename)"

if (( $output1 == TargetNumer )); then
    echo $filename
else
    mv $filename extra
fi

done

mv *.nii ../
cd ../


# change filenames
# converts mooney images first than converts original

rm NT.txt

cnt=0
for filename in ./*.nii
do
echo $filename
mv $filename ./Basis_${cnt}a.nii
3dTcat -prefix Basis_${cnt}a.nii Basis_${cnt}a.nii'[4..7]' Basis_${cnt}a.nii'[4..$]' -overwrite
cp ./Basis_${cnt}a.nii ./Basis_${cnt}b.nii

3dinfo -nt Basis_${cnt}a.nii >> NT.txt
3dinfo -nt Basis_${cnt}b.nii >> NT.txt
cnt=$(($cnt+1))

done

