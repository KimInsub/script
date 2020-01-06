

for d in */ ; do
    dcm2niix -o  './' ${d}
done

mv *.nii 


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

# converts mooney images first than converts original
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
rm ./LIN*.nii

echo "CREATE MOMA"

cp /Users/insubkim/Documents/experiment/script/layer_finalized/mocobatch_VASO3.m ./
export DYLD_FALLBACK_LIBRARY_PATH="/usr/lib/:$DYLD_LIBRARY_PATH"
/Applications/MATLAB_R2016b.app/bin/matlab -nodesktop -nosplash -r "mocobatch_VASO3"
/Applications/MATLAB_R2019b.app/bin/matlab -nodesktop -nosplash -r "mocobatch_VASO3"


rm ./Basis_*.nii
rm ./Basis*.mat


################################# BOLD VASO Extract  #################################

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

3dUpsample -overwrite  -datum short -prefix Nulled_intemp_r${p}.nii -n 2 -input Nulled_r${p}.nii
3dUpsample -overwrite  -datum short -prefix BOLD_intemp_r${p}.nii   -n 2 -input   BOLD_r${p}.nii


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


mv BOLD_intemp_r${p}.nii BOLD_LN_r${p}.nii    
3drefit -TR 2. BOLD_LN_r${p}.nii    
3drefit -TR 2. VASO_LN_r${p}.nii



done


mkdir qa
mv *tSNR* *Mean* qa
mkdir junk
mv *Nulled* BOLD_r* junk

LN_MP2RAGE_DNOISE -INV1 mean_nulled.nii -INV2 mean_notnulled.nii -UNI T1_weighted.nii -beta 5


################################# prepro  #################################

mkdir prepro
cd prepro


run=( 0 1 2 3 4 5 6 7 8 )

cond=(BOLD VASO)
for c in "${cond[@]}"
do


    #more clip.txt # check the smallest clip value across all runs
    #clip=$(cut -f1 -d"," clip.txt | sort -n | head -1) # assign the clip value# assign the clip value

    for r in "${run[@]}"
    do
        3dTstat -nzmean -prefix ${c}.${r}.base.nii ../${c}_LN_r${r}.nii'[0..$]' 
        3dcalc -a ../${c}_LN_r${r}.nii  -b ${c}.${r}.base.nii  \
        -expr "(a/b)" -prefix ${c}_r${r}.scaled.nii #remove the space and scale 
        3dDetrend -overwrite -polort 1 -prefix ${c}_r${r}.scaled_dt.nii ${c}_r${r}.scaled.nii
        3dBandpass -notrans -overwrite -prefix ${c}_r${r}.scaled_dt_hp.nii 0.01 99999 ${c}_r${r}.scaled_dt.nii
        3dTstat -mean -prefix ${c}.${r}.base2.nii ${c}_r${r}.scaled_dt_hp.nii'[0..$]' 
        3dcalc -a ${c}_r${r}.scaled_dt_hp.nii -b ${c}.${r}.base2.nii  \
        -expr "(a-b)*100" -prefix ${c}_r${r}.nii #remove the space and scale 

        rm *base*
        rm *scaled*

    done

done
