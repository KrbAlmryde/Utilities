awk '/ 0/ {print NR;exit}' TS1_TP1_outliers.txt # It works! Woohoo!! But only if the pattern is 0
awk -v x=0 '$1==x{print NR}' TS1_TP1_outliers.txt # close but prints all instances of 0



grep -n -m 1 " 0 " TS1_TP1_outliers.txt # This one is useful if I wanted to print the entire line


cat -n TS1_TP1_outliers.txt | sed -n '/ 0/p' | head -1 #    44	  0 311
nl TS1_TP1_outliers.txt | grep " 0" | head -1  #    44	  0 311
awk  -v x=0 'BEGIN{while (a++<1) $1==x; print NR}' TS1_TP1_outliers.txt

grep -n " 0 " TS1_TP1_outliers.txt
awk '/ 0/ {print NR $1; exit;}' TS1_TP1_outliers.txt

cat -n TS1_TP1_outliers.txt | sort -k2,2n | head -1



2>&1 | tee -a ${run_dir}/log.deconvolve.${submod}.txt
