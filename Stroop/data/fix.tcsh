#!/bin/sh

for run in voice word
	do
		cat ${run}_fvfw_stim.txt space.txt ${run}_mvmw_stim.txt > ${run}_cong_temp.txt  
		cat ${run}_fvmw_stim.txt space.txt ${run}_mvfw_stim.txt > ${run}_incong_temp.txt
		cat ${run}_fvnw_stim.txt space.txt ${run}_mvnw_stim.txt > ${run}_neut_temp.txt
		< ${run}_cong_temp.txt awk '1' RS=" " > ${run}_cong1.txt
		< ${run}_incong_temp.txt   awk '1' RS=" " > ${run}_incong1.txt
		< ${run}_neut_temp.txt   awk '1' RS=" " > ${run}_neut1.txt
		sort -g ${run}_cong1.txt > ${run}_cong2.txt
		sort -g ${run}_incong1.txt > ${run}_incong2.txt
		sort -g ${run}_neut1.txt > ${run}_neut2.txt
		awk 'FNR==1{A[++a]=$1;next}{A[a]=A[a] OFS $1;next}END {while(A[++i]) print A[i]}' ${run}_cong2.txt > ${run}_congruent.txt	
		awk 'FNR==1{A[++a]=$1;next}{A[a]=A[a] OFS $1;next}END {while(A[++i]) print A[i]}' ${run}_incong2.txt > ${run}_incongruent.txt	
		awk 'FNR==1{A[++a]=$1;next}{A[a]=A[a] OFS $1;next}END {while(A[++i]) print A[i]}' ${run}_neut2.txt > ${run}_neutral.txt	
 		rm ${run}*_temp.txt
 		rm ${run}_*1.txt
 		rm ${run}_*2.txt
	done


