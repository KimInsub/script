#!/bin/bash

cd roi

LN_GROW_LAYERS -rim lh_Layermask.nii -N 9
mv layers.nii lh_V1.nii

LN_GROW_LAYERS -rim rh_Layermask.nii -N 9
mv layers.nii rh_V1.nii

3dcalc -a rh_V1.nii -expr  'within(a,1,3)' -prefix rh_d_V1.nii -overwrite 
3dcalc -a rh_V1.nii -expr 'within(a,4,6)' -prefix rh_m_V1.nii -overwrite
3dcalc -a rh_V1.nii -expr  'within(a,7,9)' -prefix rh_u_V1.nii -overwrite 


3dcalc -a lh_V1.nii -expr  'within(a,1,3)' -prefix lh_d_V1.nii -overwrite 
3dcalc -a lh_V1.nii -expr 'within(a,4,6)' -prefix lh_m_V1.nii -overwrite
3dcalc -a lh_V1.nii -expr  'within(a,7,9)' -prefix lh_u_V1.nii -overwrite 


3dmask_tool -input ?h_V1.nii -prefix a_V1.nii -overwrite 
3dmask_tool -input ?h_d_V1.nii -prefix d_V1.nii -overwrite 
3dmask_tool -input ?h_m_V1.nii -prefix m_V1.nii -overwrite 
3dmask_tool -input ?h_u_V1.nii -prefix u_V1.nii -overwrite 

