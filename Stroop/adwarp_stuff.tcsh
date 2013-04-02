3dcalc -a 'S20_voice_mask_3dd+tlrc' -b 'S21_voice_mask_3dd+tlrc' -c 'S22_voice_mask_3dd+tlrc' -d 'S24_voice_mask_3dd+tlrc' -e 'S25_voice_mask_3dd+tlrc' -f 'S26_voice_mask_3dd+tlrc' -g 'S27_voice_mask_3dd+tlrc' -h 'S28_voice_mask_3dd+tlrc' -i 'S30_voice_mask_3dd+tlrc' -j 'S32_voice_mask_3dd+tlrc' -k 'S35_voice_mask_3dd+tlrc' -l 'S38_voice_mask_3dd+tlrc' -m 'S39_voice_mask_3dd+tlrc' -n 'S40_voice_mask_3dd+tlrc' -o 'S41_voice_mask_3dd+tlrc' -p 'S42_voice_mask_3dd+tlrc' -expr '(a+b+c+d+e+f+g+h+i+j+k+l+m+n+o+p)/15' -prefix Group_Mask




adwarp -apar S20_spgr+tlrc -dpar S20_voice_mask_3dd+orig
adwarp -apar S21_spgr+tlrc -dpar S21_voice_mask_3dd+orig
adwarp -apar S22_spgr+tlrc -dpar S22_voice_mask_3dd+orig
adwarp -apar S24_spgr+tlrc -dpar S24_voice_mask_3dd+orig
adwarp -apar S25_spgr+tlrc -dpar S25_voice_mask_3dd+orig
adwarp -apar S26_spgr+tlrc -dpar S26_voice_mask_3dd+orig
adwarp -apar S27_spgr+tlrc -dpar S27_voice_mask_3dd+orig
adwarp -apar S28_spgr+tlrc -dpar S28_voice_mask_3dd+orig
adwarp -apar S29_spgr+tlrc -dpar S29_voice_mask_3dd+orig
adwarp -apar S30_spgr+tlrc -dpar S30_voice_mask_3dd+orig
adwarp -apar S32_spgr+tlrc -dpar S32_voice_mask_3dd+orig
adwarp -apar S33_spgr+tlrc -dpar S33_voice_mask_3dd+orig
adwarp -apar S34_spgr+tlrc -dpar S34_voice_mask_3dd+orig
adwarp -apar S35_spgr+tlrc -dpar S35_voice_mask_3dd+orig
adwarp -apar S36_spgr+tlrc -dpar S36_voice_mask_3dd+orig
adwarp -apar S38_spgr+tlrc -dpar S38_voice_mask_3dd+orig
adwarp -apar S39_spgr+tlrc -dpar S39_voice_mask_3dd+orig
adwarp -apar S40_spgr+tlrc -dpar S40_voice_mask_3dd+orig
adwarp -apar S41_spgr+tlrc -dpar S41_voice_mask_3dd+orig
adwarp -apar S42_spgr+tlrc -dpar S42_voice_mask_3dd+orig
