#!/bin/bash



afni_LayerMe.sh dnoised_T1_weighted.nii a_V1.nii

3ddot -mask V1_layer.nii -NIML sig_all_orig+orig.HEAD sig_all_up+orig.HEAD sig_all_pr+orig.BRIK >> corr.1D
3ddot -mask V1_layer_d.nii -NIML sig_all_orig+orig.HEAD sig_all_up+orig.HEAD sig_all_pr+orig.BRIK >> corr.1D
3ddot -mask V1_layer_m.nii -NIML sig_all_orig+orig.HEAD sig_all_up+orig.HEAD sig_all_pr+orig.BRIK >> corr.1D
3ddot -mask V1_layer_u.nii -NIML sig_all_orig+orig.HEAD sig_all_up+orig.HEAD sig_all_pr+orig.BRIK >> corr.1D

