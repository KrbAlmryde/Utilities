# Align TS14.spgr to the fse

#to3d -spgr -prefix TS14.spgr -xFOV 128.00A-P -yFOV 128.00S-I -zSLAB 81.50L-81.50R e7230s7i*
#to3d -fse -prefix TS14.fse -xFOV 120.00R-L -yFOV 120.00A-P -zSLAB 62.50I-62.50S e7230s2i*

align_epi_anat.py -dset1to2 -dset1 TS14.spgr.nii -dset2 TS14.fse.nii -suffix none -cost lpa
mv TS14.spgr.nii.al.nii.nii TS14.spgr.al.nii
mv TS14.spgr.nii.al.nii_mat.aff12.1D TS14.spgr.al_mat.aff12.1D
rm TS14.spgr.nii.al.nii
@auto_tlrc -no_ss -base TT_N27+tlrc -input TS14.spgr.al.nii -suffix .tlrc

####################################################################################################
align_epi_anat.py -dset1to2 -dset1 TS14.spgr+orig -dset2 TS14.fse+orig -suffix .al -cost lpa
@auto_tlrc -no_ss -base TT_N27+tlrc -input TS14.spgr.al+orig -suffix NONE

####################################################################################################
adwarp -prefix DL10_FL_binaural_GAM_irf -apar DL10_spgr_al+tlrc -dpar DL10_FL_binaural_GAM_irf.nii
align_epi_anat.py -anat TS14.spgr.al+orig -epi TS14.SP1.scale.nii -tlrc_apar TS14.spgr.al+tlrc \
	-anat_has_skull no -suffix altest
align_epi_anat.py -anat TS14.spgr+orig -epi TS14.SP1.scale.nii -epi2anat -volreg off -tshift off -anat_has_skull no -epi_base 0 -suffix noprep -tlrc_apar TS14.spgr.al+tlrc



####################################################################################################
@auto_tlrc -no_ss -base TT_N27+tlrc -input TS14.spgr.al+orig -suffix NONE


# Align TS14.spgr_al+tlrc to the TT_N27+tlrc standard brain for goodness of fit
align_epi_anat.py -anat_has_skull NO -dset1to2 -dset1 TS14.spgr_al+tlrc -dset2 TT_N27+tlrc -suffix igned -cost lpa


# Warp Functional Data to Standard space using the subjects own brain typical way
adwarp -apar TS14.spgr_aligned+tlrc -dpar peak+orig

# Warp Functional Data to Standard space using the subjects own brain using align_epi_anat.py program
align_epi_anat.py -anat TS14.spgr.al+orig -epi TS14.SP1.scale.nii -tlrc_apar TS14.spgr.al+tlrc -anat_has_skull no -suffix altest


 align_epi_anat.py -anat TS14.spgr+orig -epi epan.nii -epi_base 9 -child_epi peak+orig.HEAD -epi2anat -anat_has_skull no -suffix _altest -tlrc_apar TS14.spgr_al+tlrc

 align_epi_anat.py -anat TS14.spgr+orig -epi TS14.SP1.scale.nii -epi2anat -volreg off -tshift off -anat_has_skull no -suffix _noprep -tlrc_apar TS14.spgr.al+tlrc



3dAllineate -cubic -1Dmatrix_apply DL10_spgr_al_mat.aff12.1D -prefix DL10_FL_binaural_GAM_irf_al 3dAllineate -cubic -1Dmatrix_apply DL10_spgr_al_mat.aff12.1D -prefix DL10_FL_binaural_GAM_irf+orig
