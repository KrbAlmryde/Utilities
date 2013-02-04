adwarp -apar DL5_spgr_al+tlrc -dpar DL5_spgr_al+orig -prefix DL5_spgr_al -overwrite
adwarp -apar DL6_spgr_al+tlrc -dpar DL6_spgr_al+orig -prefix DL6_spgr_al -overwrite
adwarp -apar DL7_spgr_al+tlrc -dpar DL7_spgr_al+orig -prefix DL7_spgr_al -overwrite
adwarp -apar DL8_spgr_al+tlrc -dpar DL8_spgr_al+orig -prefix DL8_spgr_al -overwrite

# This is the code that I want, it works very nicely for misbehaving brains :)
align_epi_anat.py -dset1to2 -dset1 DL6_spgr_al+tlrc -dset2 TT_N27+tlrc -suffix igned -cost lpa
