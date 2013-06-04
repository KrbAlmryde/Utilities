3dmerge -dxyz=1 -1clust 1 -1123 -1thresh 2.262 -prefix FA_Mask mean_FA_Tvalue+tlrc

3dcalc -prefix FA_Hippo -a TT_mask_template+tlrc -b FA_Merge2+tlrc -expr '(a*b)'

3dmerge -dxyz=1 -1clust 1 -2065 -1thresh 3.01 -prefix FF_Merge2 mean_Ff_Tvalue+tlrc

3dcalc -prefix FF_Hippo -a TT_mask_template+tlrc -b FF_Merge2+tlrc -expr '(a*b)'

3dmerge -dxyz=1 -1clust 1 -2096 -1thresh 3.374 -prefix MF_Merge2 mean_Mf_Tvalue+tlrc

3dcalc -prefix MF_Hippo -a TT_mask_template+tlrc -b MF_Merge2+tlrc -expr '(a*b)'

3dmerge -dxyz=1 -1clust 1 -2096 -1thresh 3.374 -prefix NF_Merge2 mean_Nf_Tvalue+tlrc



3dcalc -prefix FA_Hippo -a TT_mask_template+tlrc -b FA_Merge2+tlrc -expr '(a*b)'
3dcalc -prefix FF_Hippo -a TT_mask_template+tlrc -b FF_Merge2+tlrc -expr '(a*b)'
3dcalc -prefix MF_Hippo -a TT_mask_template+tlrc -b MF_Merge2+tlrc -expr '(a*b)'
3dcalc -prefix NF_Hippo -a TT_mask_template+tlrc -b NF_Merge2+tlrc -expr '(a*b)'