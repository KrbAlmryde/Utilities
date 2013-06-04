. $UTL/${1}_profile


echo "Checking ${spgr} info"; echo ""
cd ${anat_dir}

3dinfo ${spgr}+orig
3dinfo ${fse}+orig

echo "Checking ${runnm} info"; echo ""
cd ${func_dir}
3dinfo ${runnm}_epan+orig

echo "Cool, all done"
