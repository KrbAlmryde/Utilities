#!/bin/bash
#================================================================================
#	Program Name: eprime_functions.bash
#		  Author: Kyle Reese Almryde
#			Date: May 03 2012
#
#	 Description: 
#				  
#				  
#
#	Deficiencies: 
#				  
#				  
#				  
#				  
#
#================================================================================
#								START OF MAIN
#================================================================================

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#							EPRIME Functions
# Includes functions for converting files types to UNIX-LF, stripping important
# information regarding preformance, as well as construction of long file.
#
# The current list of functions under this heading :
#
# 					eprime_convert
# 					eprime_grab
# 					eprime_oldstudy
# 					eprime_report
# 					eprime_respfix
# 					eprime_restart
# 					eprime_score
# 					eprime_setup
# 					eprime_stack
# 					eprime_stim
# 					eprime_strip
#
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	function eprime_restart ()
	{
		subj=$1; run=$2
		BEHAV=/Volumes/Data/TAP/${subj}/Behav/${run}

		rm ${BEHAV}/*${subj}*
		rm ${BEHAV}/*.txt
	}

	#------------------------------------------------------------------------
	#
	#	Description: a
	#				  
	#		Purpose: a
	#				  
	#		  Input: a
	#				  
	#		 Output: a  
	#				  
	#	  Variables: a
	#				  
	#------------------------------------------------------------------------

	function eprime_setup ()
	{		
		local sublist subj run file_name
		local BACKUP BEHAV

		subj=$1; run=$2
		BACKUP=/Volumes/Data/TAP/BEHAV
		BEHAV=/Volumes/Data/TAP/TS${subj}/Behav/${run}

		case $run in
			SP1 )
				file_name=StudyPhase1_Animal-Food-${subj}-1
				;;
			SP2 )
				file_name=StudyPhase2_Male-Female-${subj}-2
				;;
			TP1 )
				file_name=TestPhase1-Familiarity-${subj}-3
				;;
			TP2 )
				file_name=TestPhase2-Recollection-${subj}-4
				;;
		esac

		cp ${BACKUP}/${file_name}.txt ${BEHAV}/

		iconv \
			-f UTF-16 \
			-t ISO-8859-1 \
			${BEHAV}/${file_name}.txt \
			> ${BEHAV}/iconv.iso.TS${subj}.${run}.txt

		dos2unix ${BEHAV}/iconv.iso.TS${subj}.${run}.txt
	}

	#------------------------------------------------------------------------
	#
	#	Description: a
	#				  
	#		Purpose: a
	#				  
	#		  Input: a
	#				  
	#		 Output: a  
	#				  
	#	  Variables: a
	#				  
	#------------------------------------------------------------------------

	function eprime_convert ()
	{
		local subj run i
		local BEHAV

		subj=$1; run=$2
		BEHAV=/Volumes/Data/TAP/${subj}/Behav/${run}
		ETC=/Volumes/Data/TAP/BEHAV/etc

		if [[ -s ${BEHAV}/iconv.iso.${subj}.${run}.txt ]]; then

			cat ${BEHAV}/iconv.iso.${subj}.${run}.txt \
				> ${BEHAV}/unix.${subj}.${run}.txt

		else

			cp ${ETC}/${subj}-${run}.txt \
				${BEHAV}/unix.${subj}.${run}.txt

		fi
	}


	#------------------------------------------------------------------------
	#
	#	Description: a
	#				  
	#		Purpose: a
	#				  
	#		  Input: a
	#				  
	#		 Output: a  
	#				  
	#	  Variables: a
	#				  
	#------------------------------------------------------------------------

	function eprime_strip ()
	{
		local subj run i
		local BEHAV

		subj=$1; run=$2
		BEHAV=/Volumes/Data/TAP/${subj}/Behav/${run}
		ETC=/Volumes/Data/TAP/BEHAV/etc

		if [[ $run = TP1 ]]; then
			echo -e "Trial\tTiming\tSoundFile\tWordType\tRT\tRESP\tCRESP\tACC" \
			> ${BEHAV}/header.${subj}.${run}.txt
		else
			echo -e "Trial\tTiming\tSoundFile\tWordType\tSpeakerGender\tRT\tRESP\tCRESP\tACC" \
			> ${BEHAV}/header.${subj}.${run}.txt
		fi


		cat ${BEHAV}/unix.${subj}.${run}.txt \
			| sed -n \
				-e '/TrialList:/p' \
				-e '/Target:/p' \
				-e '/WordType:/p' \
				-e '/SpeakerGender:/p' \
				-e '/SlideTarget.RT:/p' \
				-e '/SlideTarget.RESP:/p' \
				-e '/CorrectAnswer:/p' \
			| tr -d '\t' > ${BEHAV}/stripped.${subj}.${run}.txt

	
		# I think this command is equivilant to the grep command below
		#
		#    awk '/TrialList/ {print $2}' \                      
		#    | head -147 > ${BEHAV}/triallist.${subj}.${run}.txt 

		grep TrialList \
			${BEHAV}/stripped.${subj}.${run}.txt \
			| awk '{print $2}' \
			| head -147 \
			> ${BEHAV}/triallist.${subj}.${run}.txt

		grep Target: \
			${BEHAV}/stripped.${subj}.${run}.txt \
			| awk '{print $2}' \
			| tail -147 \
			> ${BEHAV}/soundfile.${subj}.${run}.txt

		grep WordType \
			${BEHAV}/stripped.${subj}.${run}.txt \
			| awk '{print $2}' \
			| sed \
				-e 's/A/Animal/g' \
				-e 's/F/Food/g' \
			| tail -147 \
			> ${BEHAV}/wordtype.${subj}.${run}.txt

		grep SpeakerGender \
			${BEHAV}/stripped.${subj}.${run}.txt \
			| awk '{print $2}' \
			| sed \
				-e 's/^male/Male/g' \
				-e 's/^female/Female/g' \
			| tail -147 \
			> ${BEHAV}/speakergender.${subj}.${run}.txt

		grep RT \
			${BEHAV}/stripped.${subj}.${run}.txt \
			| awk '{print $2}' \
			| tail -147 \
			> ${BEHAV}/rt.${subj}.${run}.txt

		# Removed Response block due to mis-match, making
		# seperate function to handle that issue

		grep CorrectAnswer \
			${BEHAV}/stripped.${subj}.${run}.txt \
			| awk '{print $2}' \
			| tail -147 \
			| sed 's/4/0/g' \
			> ${BEHAV}/cresp.${subj}.${run}.txt

		cp -R ${ETC}/timing.txt ${BEHAV}/timing.${subj}.${run}.txt
	}



	#------------------------------------------------------------------------
	#
	#	Description: a
	#				  
	#		Purpose: a
	#				  
	#		  Input: a
	#				  
	#		 Output: a  
	#				  
	#	  Variables: a
	#				  
	#------------------------------------------------------------------------

	function eprime_respfix ()
	{
		local subj run right left i
		local BEHAV

		subj=$1; run=$2
		BEHAV=/Volumes/Data/TAP/${subj}/Behav/${run}

		case $run in
			SP1 | TP1 )
				case $subj in
					TS015 )
						right="s/^[12]/03/g"
						left="s/^[34]/02/g"
						;;
					* )
						right="s/^[34]/03/g"
						left="s/^[12]/02/g"
						;;
				esac
				;;
			SP2 )
				case $subj in
					TS00[3-9] )
						right="s/^[12]/03/g"
						left="s/^[34]/02/g"
						;;
					TS01[0123678] )
						right="s/^[12]/03/g"
						left="s/^[34]/02/g"
						;;
					   * )
						right="s/^[34]/03/g"
						left="s/^[12]/02/g"
						;;
				 esac
				;;
			TP2 )
				case $subj in
					TS00[3489] )
						right="s/^[12]/03/g"
						left="s/^[34]/02/g"
						;;
					TS01[013678] )
						right="s/^[12]/03/g"
						left="s/^[34]/02/g"
						;;
					   * )
						right="s/^[34]/03/g"
						left="s/^[12]/02/g"
						;;
				 esac
				;;
		esac

   		grep SlideTarget.RESP \
			${BEHAV}/stripped.${subj}.${run}.txt \
			| awk '{print $2}' \
			| sed \
				-e "${right};${left}" \
				-e 's/$/0/g' \
				-e 's/020/2/g;s/030/3/g' \
			| tail -147 \
			> ${BEHAV}/resp.${subj}.${run}.txt
	}



	#------------------------------------------------------------------------
	#
	#	Description: a
	#				  
	#		Purpose: a
	#				  
	#		  Input: a
	#				  
	#		 Output: a  
	#				  
	#	  Variables: a
	#				  
	#------------------------------------------------------------------------

	function eprime_score ()
	{
		local subj run i
		local BEHAV

		subj=$1; run=$2
		BEHAV=/Volumes/Data/TAP/${subj}/Behav/${run}


		paste \
			${BEHAV}/resp.${subj}.${run}.txt \
			${BEHAV}/cresp.${subj}.${run}.txt \
			> ${BEHAV}/score.${subj}.${run}.txt

		awk \
			'{ if( $1==$2){ print $3=1}; if($1 != $2){print $3=0}}' \
			${BEHAV}/score.${subj}.${run}.txt \
			> ${BEHAV}/acc.${subj}.${run}.txt
	}




	#------------------------------------------------------------------------
	#
	#	Description: a
	#				  
	#		Purpose: a
	#				  
	#		  Input: a
	#				  
	#		 Output: a  
	#				  
	#	  Variables: a
	#				  
	#------------------------------------------------------------------------

	function eprime_stack ()
	{
		local subj run i
		local BEHAV

		subj=$1; run=$2
		BEHAV=/Volumes/Data/TAP/${subj}/Behav/${run}

		case $run in
			TP1 )
				paste \
					${BEHAV}/triallist.${subj}.${run}.txt \
					${BEHAV}/timing.${subj}.${run}.txt \
					${BEHAV}/soundfile.${subj}.${run}.txt \
					${BEHAV}/wordtype.${subj}.${run}.txt \
					${BEHAV}/rt.${subj}.${run}.txt \
					${BEHAV}/resp.${subj}.${run}.txt \
					${BEHAV}/cresp.${subj}.${run}.txt \
					${BEHAV}/acc.${subj}.${run}.txt \
					> ${BEHAV}/stacked.${subj}.${run}.txt
				;;
			* )
				paste \
					${BEHAV}/triallist.${subj}.${run}.txt \
					${BEHAV}/timing.${subj}.${run}.txt \
					${BEHAV}/soundfile.${subj}.${run}.txt \
					${BEHAV}/wordtype.${subj}.${run}.txt \
					${BEHAV}/speakergender.${subj}.${run}.txt \
					${BEHAV}/rt.${subj}.${run}.txt \
					${BEHAV}/resp.${subj}.${run}.txt \
					${BEHAV}/cresp.${subj}.${run}.txt \
					${BEHAV}/acc.${subj}.${run}.txt \
					> ${BEHAV}/stacked.${subj}.${run}.txt
				;;
		esac
		
		cat ${BEHAV}/header.${subj}.${run}.txt \
			${BEHAV}/stacked.${subj}.${run}.txt \
			> ${BEHAV}/Final.${subj}.${run}.txt 
	}



	#------------------------------------------------------------------------
	#
	#	Description: a
	#				  
	#		Purpose: a
	#				  
	#		  Input: a
	#				  
	#		 Output: a  
	#				  
	#	  Variables: a
	#				  
	#------------------------------------------------------------------------

	function eprime_report ()
	{
		local subj run time target speaker rt acc match
		local BEHAV STIM REVIEW

		subj=$1
		run=$2; trial='$1'; time='$2'; target='$3'
		word='$4'; speaker='$5'; rt='$6'; acc='$9'
		
		BEHAV=/Volumes/Data/TAP/${subj}/Behav/${run}
		STIM=/Volumes/Data/TAP/STIM
		REVIEW=/Volumes/Data/TAP/REVIEW/Behav/${run}

		
		case $run in
			SP1 )
				ev=( Animal Food ) 
				;;
			SP2 )
				ev=( Male Female )
				;;
			TP1 )
				rt='$5'; acc='$8'
				ev=( O N ) 
				;;
			TP2 )
				ev=( Male Female )
				;;
		esac

		#========================================================================
		# Dprime Calucluation Variables 
		#========================================================================

		# Correct Accecpts
		hits=$( egrep -c "${ev[0]}.*[1]$" ${BEHAV}/stacked.${subj}.${run}.txt )
		
		# Incorrect Accepts
		miss=$( egrep -c "${ev[0]}.*[0]$" ${BEHAV}/stacked.${subj}.${run}.txt )

		# Total possible Hits
		((total_hits=$hits+$miss))
		
		# Correct Rejects				
		cr=$( egrep -c "${ev[1]}.*[1]$" ${BEHAV}/stacked.${subj}.${run}.txt )

		# False Alarms
		fa=$( egrep -c "${ev[1]}.*[0]$" ${BEHAV}/stacked.${subj}.${run}.txt )
		
		# Total possible Correct Rejects
		((total_cr=$cr+$fa))
		
		# Hit Rate
		hitRate=$(echo "scale=2; ($hits)/($total_hits)" | bc)
			
			if [[ ${hitRate} = '0' ]]; then
				hitRate='.01'
			elif [[ ${hitRate} = '1.00' ]]; then
				hitRate='.99'
			fi
		
		# False Alarm Rate
		faRate=$(echo "scale=2; ($fa)/($total_cr)" | bc)
		
			if [[ ${faRate} = '0' ]]; then
				faRate='.01'
			elif [[ ${faRate} = '1.00' ]]; then
				faRate='.99'
			fi
		
		# Dprime score
		dprime=$( echo "( qnorm("$hitRate")-qnorm("$faRate") )" | R --slave | cut -c 5-12 ) 		
		
		
		#========================================================================
		# Mean Accuracy and RT for all conditions, as well as condition specific
		#========================================================================
		#    TP1 trial=$1 time=$2 target=$3 word=$4 rt=$5 resp=$6 cresp=$7 acc=$8
		#      * trial=$1 time=$2 target=$3 word=$4 speaker=$5 rt=$6 resp=$7 cresp=$8 acc=$9
		
		# This variable represents the mean reaction time for correct responses
		uRT=$( awk '/.*[1]$/ {sum+='$rt'} END { print sum/NR }' ${BEHAV}/stacked.${subj}.${run}.txt )
		
		# This variable represents the mean accuracy for all responses
		uACC=$( awk '{sum+='$acc'} END { print sum/NR*100 }' ${BEHAV}/stacked.${subj}.${run}.txt )
		
		
		# This array stores the mean reaction time for correct responses specific 
		# to the individual EV
		evRT=( 
				$( awk '/'${ev[0]}'.*[1]$/ {sum+='$rt'} END {print sum/NR}' ${BEHAV}/stacked.${subj}.${run}.txt ) \
			
				$( awk '/'${ev[1]}'.*[1]$/ {sum+='$rt'} END {print sum/NR}' \
				${BEHAV}/stacked.${subj}.${run}.txt ) \
			)
		
		
		# This array stores the mean accuarcy for items specific to the individual EV
		evACC=( 
				$( awk '/'${ev[0]}'.*/ {sum+='$acc'} END {print sum/'$total_hits'*100}' \
				${BEHAV}/stacked.${subj}.${run}.txt ) \
				
				$( awk '/'${ev[1]}'.*/ {sum+='$acc'} END {print sum/'$total_cr'*100}' \
				${BEHAV}/stacked.${subj}.${run}.txt ) \
			)

		# More things to remember!
		# $1:MeanRT $2:MeanACC $3:${ev[0]}RT $4:${ev[1]}RT $5:${ev[0]}ACC $6:${ev[1]}ACC $7:d'prime
		#========================================================================
		# Group mean ACC, RT, Conditions, and Elements within each condition
		#========================================================================

		Trial=( $( awk '{print '$trial'}' ${BEHAV}/stacked.${subj}.${run}.txt ) )
		Target=( $( awk '{print '$target'}' ${BEHAV}/stacked.${subj}.${run}.txt ) )
		Word=( $( awk '{print '$word'}' ${BEHAV}/stacked.${subj}.${run}.txt ) )
		
		Rt=( $( awk '{print '$rt'}' ${BEHAV}/stacked.${subj}.${run}.txt ) )
		Acc=( $( awk '{print '$acc'}' ${BEHAV}/stacked.${subj}.${run}.txt ) )
		
		#Group=()
			#wd=( $( awk '{print '$word'}' ${BEHAV}/stacked.${subj}.${run}.txt | cut -c 1-2 ) )
			#sp=( $( awk '{print '$speaker'}' ${BEHAV}/stacked.${subj}.${run}.txt | cut -c 1-2 ) )
			wd=( $( awk '{print '$word'}' ${BEHAV}/stacked.${subj}.${run}.txt ) )
			sp=( $( awk '{print '$speaker'}' ${BEHAV}/stacked.${subj}.${run}.txt ) )
			
			for (( g = 0; g < ${#wd[*]}; g++ )); do
				if [[ $run = "TP1" ]]; then
					Group[$g]=$( echo ${wd[$g]} )
				else
					Group[$g]=$( echo -e "${wd[$g]}\t${sp[$g]}" )
				fi
			done

		#========================================================================
		# Report Layout functions for subjects
		#========================================================================

		subject_report ()
		{
			#------------------------------------------------------------------------
			#
			#	Description: a
			#				  
			#		Purpose: a
			#				  
			#		  Input: a
			#				  
			#		 Output: a  
			#				  
			#	  Variables: a
			#				  
			#------------------------------------------------------------------------

			echo -e "\t\t\t$subj $run Report"
			echo -e "============================================"
			echo -e "\t\t\tMean RT: ${uRT}\n\t\t\tMean ACC: ${uACC}%"
			echo -e "--------------------------------------------"
			echo -e "      ${ev[0]}                ${ev[1]}"
			echo -e "--------------------------------------------"
			echo -ne "  RT($total_hits): ${evRT[0]}"
			echo -e "         RT($total_cr): ${evRT[1]}"
			echo -ne " ACC($total_hits): ${evACC[0]}%"
			echo -e "       ACC($total_cr): ${evACC[1]}%"        
			echo -e "============================================"
			echo -e "\t\t\td'prime: $dprime"
			echo -e "--------------------------------------------"
			echo -e "       Hits: $hits        Correct Rejects: $cr"
			echo -e "       Miss: $miss            False Alarms: $fa"
			echo -e "--------------------------------------------"
			echo -e " Total Hits: $total_hits           Total CRs: $total_cr"
			echo -e "--------------------------------------------"
			echo -e "   Hit Rate: $hitRate            FA Rate: $faRate"
			echo -e "============================================"

		}

		subject_longReport ()
		{
					#subject #run    #hits    #miss   #hitRate      #cr    #fa    #faRate   dprime
			echo -e "${subj}\t${run}\t${hits}\t${miss}\t${hitRate}\t${cr}\t${fa}\t${faRate}\t${dprime}"
		}
			
		#========================================================================
		# Report Layout functions for the group
		#========================================================================
		
		group_summary ()
		{
			#------------------------------------------------------------------------
			#
			#	Description: a
			#				  
			#		Purpose: a
			#				  
			#		  Input: a
			#				  
			#		 Output: a  
			#				  
			#	  Variables: a
			#				  
			#------------------------------------------------------------------------

			grpRT=$( awk '{sum+=$1} END {print sum/NR}' ${REVIEW}/Afni.Report.${run}.1D )
			grpACC=$( awk '{sum+=$2} END {print sum/NR}' ${REVIEW}/Afni.Report.${run}.1D )
						
			grp_evRT=(
						$( awk '{sum+=$3} END {print sum/NR}' ${REVIEW}/Afni.Report.${run}.1D )
						$( awk '{sum+=$4} END {print sum/NR}' ${REVIEW}/Afni.Report.${run}.1D )
					)
			
			grp_evACC=(
						$( awk '{sum+=$5} END {print sum/NR}' ${REVIEW}/Afni.Report.${run}.1D )
						$( awk '{sum+=$6} END {print sum/NR}' ${REVIEW}/Afni.Report.${run}.1D )
					)
			
			grp_dprime=$( awk '{sum+=$7} END {print sum/NR}' ${REVIEW}/Afni.Report.${run}.1D )

			
			echo -e "\t\t\tGroup Report $run "
			echo -e "============================================"
			echo -e "\t\t\tGroup RT: ${grpRT}\n\t\t\tGroup ACC: ${grpACC}"
			echo -e "\t\t\tGroup d'prime: $grp_dprime"
			echo -e "--------------------------------------------"
			echo -e "      ${ev[0]}                ${ev[1]}"
			echo -e "--------------------------------------------"
			echo -ne "  Group RT: ${grp_evRT[0]}"
			echo -e "         Group RT: ${grp_evRT[1]}"
			echo -ne " Group ACC: ${grp_evACC[0]}%"
			echo -e "       Group ACC: ${grp_evACC[1]}%"        
			echo -e "============================================"
		
		}
				

		header_print ()
		{
			echo -ne "Subjects\t" > ${REVIEW}/Long.ItemAcc.${run}.txt
			echo -ne "Subjects\t" > ${REVIEW}/Long.ItemRT.${run}.txt
			
			if [[ $run = "TP1" ]]; then 
				echo -e "Subject\tTrial\tTarget\tGroup\tRT\tACC" > ${REVIEW}/Long.Behav.${run}.txt
			else
				echo -e "Subject\tTrial\tTarget\tWord\tVoice\tRT\tACC" > ${REVIEW}/Long.Behav.${run}.txt
			fi
		}

		header_item ()
		{	
			# Make an Item Report for ACC and RT for each subject
			# Creating header of each file
			for (( j = 0; j < ${#Target[*]}; j++ )); do
				echo -ne "${Target[$j]}\t"
			done
		}


		long_behav ()
		{
			for (( j = 0; j < ${#Target[*]}; j++ )); do				
				echo -e "${subj}\t${Trial[$j]}\t${Target[$j]}\t${Group[$j]}\t${Rt[$j]}\t${Acc[$j]}"
			done
		
		}
		
		afni_report ()
		{
			echo "${uRT} ${uACC} ${evRT[0]} ${evRT[1]} ${evACC[0]} ${evACC[1]} $dprime"
		}	

		item_acc ()
		{
			# Filling ACC report
			# OUTPUT should look like this for ACC
			# Subjects	AnFe_Trial1	FoMa_Trial2	Trial3
			# TS001		1		1		0
			# TS002		0		1		0
			
			echo -ne "\n${subj}\t" 
			for (( j = 0; j < ${#Acc[*]}; j++ )); do
				echo -ne "${Acc[$j]}\t"
			done
		}

		item_rt ()
		{
			# Filling RT report			
			# OUTPUT should look like this for RT
			# Subjects	Trial1	Trial2	Trial3
			# TS001		354		300		250
			# TS002		100		587		623

			echo -ne "\n${subj}\t"
			for (( j = 0; j < ${#Rt[*]}; j++ )); do
				echo -ne "${Rt[$j]}\t"
			done
	
		}
		
		
		subject_report > ${REVIEW}/Report.${subj}.${run}.txt
		
		subject_longReport >> ${REVIEW}/Raw.report.${run}.txt
		
		case $subj in
			TS001 )
			
				header_print # will print headers for Item reports and Long Behav
				header_item >> ${REVIEW}/Long.ItemAcc.${run}.txt
				header_item >> ${REVIEW}/Long.ItemRt.${run}.txt
				
												
				item_acc >> ${REVIEW}/Long.ItemAcc.${run}.txt
				item_rt >> ${REVIEW}/Long.ItemRt.${run}.txt
				
				
				afni_report > ${REVIEW}/Afni.Report.${run}.1D
				long_behav >> ${REVIEW}/Long.Behav.${run}.txt

				;;
			TS* )

				item_acc >> ${REVIEW}/Long.ItemAcc.${run}.txt
				item_rt >> ${REVIEW}/Long.ItemRt.${run}.txt
				
				
				afni_report >> ${REVIEW}/Afni.Report.${run}.1D
				long_behav >> ${REVIEW}/Long.Behav.${run}.txt

				;;
		esac


		if [[ $subj = "TS018" ]]; then
			
			group_summary > ${REVIEW}/Report.Group.${run}.txt
			
			1dplot \
				-sepscl \
				-xlabel 'Subjects' \
				-ynames MeanRt MeanACC ${ev[0]}RT ${ev[1]}RT  \
					${ev[0]}ACC ${ev[1]}ACC Dprime \
				-jpeg ${REVIEW}/Afni.Report.${run} \
				${REVIEW}/Afni.Report.${run}.1D'[0..$]'

		fi
	}

	
	
	
	#------------------------------------------------------------------------
	#
	#	Description: eprime_dprime_stim
	#				  
	#		Purpose: a
	#				  
	#		  Input: a
	#				  
	#		 Output: a  
	#				  
	#	  Variables: a
	#				  
	#------------------------------------------------------------------------
	
	function eprime_dprime_stim ()
	{
		local i run time target rt acc match subj
		local BEHAV STIM REVIEW
	
		subj=$1; run=$2;
		time='$2'; target='$3'
	
		BEHAV=/Volumes/Data/TAP/${subj}/Behav/${run}
		STIM=/Volumes/Data/TAP/STIM
		REVIEW=/Volumes/Data/TAP/REVIEW
	
	# Things to remember!!
	
	# TP1 trial=$1 time=$2 target=$3 word=$4 rt=$5 resp=$6 cresp=$7 acc=$8
	#   * trial=$1 time=$2 target=$3 word=$4 speaker=$5 rt=$6 resp=$7 cresp=$8 acc=$9
	
		case $run in
			SP1 )
				match="TP1"; ev=( Animal Food ); speaker='$5'
				MATCH=/Volumes/Data/TAP/${subj}/Behav/TP1
				;;
			SP2 )
				match="TP2"; ev=( Male Female ); speaker='$5'
				MATCH=/Volumes/Data/TAP/${subj}/Behav/TP2
				;;
			TP1 )
				match="SP2"; ev=( O N ) 
				MATCH=/Volumes/Data/TAP/${subj}/Behav/SP2
				;;
			TP2 )
				match="SP2"; ev=( Male Female ); speaker='$5'
				MATCH=/Volumes/Data/TAP/${subj}/Behav/SP2
				;;
		esac
	
	
	
		for j in 0 1; do
			#---------------------------------
			#             Hits  			 #
			#  Capture all correct items     #
			#  per condition                 #
			#---------------------------------
			hits ()
			{
				egrep \
					"${ev[$j]}.*1$" \
					${BEHAV}/stacked.${subj}.${run}.txt \
					| awk '{print '$target'}'
			}
			
			#---------------------------------
			#  Hits or Correct Reject stim file
			egrep "$(hits)" \
				${MATCH}/stacked.${subj}.${match}.txt \
				| awk '{print '$time'}' \
				| tr '\n' ' ' \
			> ${STIM}/stim.${subj}.${match}.${ev[$j]}_hits.1D
			
			
			#---------------------------------
			#       False Alarm Rate         #
			#  Capture all incorrect items   #
			#  per condition                 #
			#---------------------------------
			false_alarms () 
			{
				egrep \
					"${ev[$j]}.*0$" \
					${BEHAV}/stacked.${subj}.${run}.txt \
					| awk '{print '$target'}'
			}
			
			#---------------------------------
			#  False alarms or Incorrect Accept stim file
			egrep "$(false_alarms)" \
				${MATCH}/stacked.${subj}.${match}.txt \
				| awk '{print '$time'}' \
				| tr '\n' ' ' \
			> ${STIM}/stim.${subj}.${match}.${ev[$j]}_miss.1D

		done
	
		#---------------------------------
		#       The Other method....
		#  Capture all incorrect items
		#---------------------------------
		unused ()
		{
			#---------------------------------
			#          Hit Rate  			 #
			#  Capture all correct items     #
			#---------------------------------
			hit_rate () 
			{
				egrep \
					"${ev[0]}.*1$|${ev[1]}.*1$" \
					${BEHAV}/stacked.${subj}.${run}.txt \
					| awk '{print '$target'}'
			}
			
			#---------------------------------
			#  Hits + Correct Reject stim file
			egrep "$(hit_rate)" \
				${MATCH}/stacked.${subj}.${match}.txt \
				| awk '{print '$time'}' \
				| tr '\n' ' ' \
			> ${STIM}/stim.${subj}.${match}.HitRate.1D
			
			
			#---------------------------------
			#       False Alarm Rate
			#  Capture all incorrect items
			#---------------------------------
			fa_rate () 
			{
				egrep \
					"${ev[0]}.*0$|${ev[1]}.*0$" \
					${BEHAV}/stacked.${subj}.${run}.txt \
					| awk '{print '$target'}'
			}
			
			#---------------------------------
			#  False alarms and Incorrect Accept stim file
			egrep "$(fa_rate)" \
				${MATCH}/stacked.${subj}.${match}.txt \
				| awk '{print '$time'}' \
				| tr '\n' ' ' \
			> ${STIM}/stim.${subj}.${match}.FaRate.1D
	
		}


		nope ()
		{
			#---------------------------------
			#             Hits  			 #
			#  Capture all correct items     #
			#  per condition                 #
			#---------------------------------
			hits () 
			{
				egrep \
					"${ev[$j]}.*1$" \
					${BEHAV}/stacked.${subj}.${run}.txt \
					| awk '{print '$time'}' \
					| tr '\n' ' ' \
				> ${STIM}/stim.${subj}.${run}.${ev[$j]}_hits.1D
			}
			
			#---------------------------------
			#       False Alarm Rate         #
			#  Capture all incorrect items   #
			#  per condition                 #
			#---------------------------------
			false_alarms () 
			{
				egrep \
					"${ev[$j]}.*0$" \
					${BEHAV}/stacked.${subj}.${run}.txt \
					| awk '{print '$time'}' \
					| tr '\n' ' ' \
				> ${STIM}/stim.${subj}.${run}.${ev[$j]}_miss.1D
			}
			
			hits
			false_alarms

		}
	}

	#------------------------------------------------------------------------
	#
	#	Description: a
	#				  
	#		Purpose: a
	#				  
	#		  Input: a
	#				  
	#		 Output: a  
	#				  
	#	  Variables: a
	#				  
	#------------------------------------------------------------------------

	function eprime_grab ()
	{
		local subj run i
		local BEHAV

		subj=$1; run=$2
		BEHAV=/Volumes/Data/TAP/${subj}/Behav/${run}
		REVIEW=/Volumes/Data/TAP/REVIEW/Behav/${run}

		cp -R ${BEHAV}/Report.${subj}.${run}.txt ${REVIEW}/
	}

	
	#------------------------------------------------------------------------
	#
	#	Description: a
	#				  
	#		Purpose: a
	#				  
	#		  Input: a
	#				  
	#		 Output: a  
	#				  
	#	  Variables: a
	#				  
	#------------------------------------------------------------------------

	function eprime_loop ()
	{
		local subj run i
		local BEHAV

		for (( i = 0; i < ${#subj_list[*]}; i++ )); do

			run=$1; subj=${subj_list[$i]}
			BEHAV=/Volumes/Data/TAP/${subj}/Behav/${run}

	 		#eprime_score ${subj} ${run}
	 		#eprime_stack ${subj} ${run}
	 		eprime_report ${subj} ${run}
	 		#eprime_grab ${subj} ${run}
	 		#eprime_dprime_stim ${subj} ${run}

		done
	}
	
	

#================================================================================
#================================================================================
# These Functions are not being used at the moment...let them alone

	#------------------------------------------------------------------------
	#
	#	Description: eprime_old_stim
	#				  
	#		Purpose: This function makes the old word stimfiles for SP1
	#				  
	#		  Input: a
	#				  
	#		 Output: a  
	#				  
	#	  Variables: a
	#				  
	#------------------------------------------------------------------------
	
	function eprime_old_stim ()
	{
		## Things to remember!!	##
		# TP1 trial=$1 time=$2 target=$3 word=$4 rt=$5 resp=$6 cresp=$7 acc=$8
		#   * trial=$1 time=$2 target=$3 word=$4 speaker=$5 rt=$6 resp=$7 cresp=$8 acc=$9

	
		local subj run i
		local BEHAV
	
		subj=$1; time='$2'; target='$3'	
	
		STIM=/Volumes/Data/TAP/STIM
		BEHAV=/Volumes/Data/TAP/TS018/Behav/TP1
		BEHAV1=/Volumes/Data/TAP/TS018/Behav/SP2
	
		grep 'O' \
			${BEHAV}/stacked.TS018.TP1.txt \
			| awk '{print '$target'}' \
			> ${TAP}/OLDwords.txt
			
			echo OLDwords
	
		grep \
			-f ${TAP}/OLDwords.txt ${BEHAV1}/stacked.TS018.SP2.txt \
			| awk '{print '$time'}' \
			| tr '\n' ' ' \
			> ${STIM}/stim.SP2.old.1D
			
			echo stim.SP2.old.1D
			
		grep \
			-v -f ${TAP}/OLDwords.txt ${BEHAV1}/stacked.TS018.SP2.txt \
			| awk '{print '$time'}' \
			| tr '\n' ' ' \
			> ${STIM}/stim.SP2.notold.1D
			
			echo stim.SP2.notold.1D
	}





	function eprime_sensory_stim ()
	{
		local i run time target subj
		local BEHAV STIM REVIEW
	
		subj=$1; run=$2;
		time='$2'; target='$3'
	
		BEHAV=/Volumes/Data/TAP/${subj}/Behav/${run}
		STIM=/Volumes/Data/TAP/STIM
	
		# Things to remember!!
		
		# TP1 trial=$1 time=$2 target=$3 word=$4 rt=$5 resp=$6 cresp=$7 acc=$8
		#   * trial=$1 time=$2 target=$3 word=$4 speaker=$5 rt=$6 resp=$7 cresp=$8 acc=$9
	
		case $run in
			SP1 )
				sensor=semantic
				;;
			SP2 )
				sensor=voice
				;;
			TP[12] )
				echo "This is for SP1 and SP2 only!!"
				exit
				;;				
		esac
	
		#---------------------------------
		#          Hit Rate  			 #
		#  Capture all correct items     #
		#---------------------------------
	
		egrep \
			"${ev[0]}.*$|${ev[1]}.*$" \
			${BEHAV}/stacked.${subj}.${run}.txt \
			| awk '{print '$time'}' \
			| tr '\n' ' ' > ${STIM}/stim.${run}.${sensor}.1D

		
		egrep \
			"null.*$" \
			${BEHAV}/stacked.${subj}.${run}.txt \
			| awk '{print '$time'}' \
			| tr '\n' ' ' > ${STIM}/stim.${run}.null.1D

		#echo "*" > ${STIM}/stim.${run}.null.1D
	}
	
	



	#------------------------------------------------------------------------
	#
	#	Description: a
	#				  
	#		Purpose: a
	#				  
	#		  Input: a
	#				  
	#		 Output: a  
	#				  
	#	  Variables: a
	#				  
	#------------------------------------------------------------------------

	function eprime_reportDP ()
	{
		local subj run time target speaker rt acc match
		local hits miss falm corr stimsum hitRate falmRate
		local zhits zfalm dp
		local BEHAV STIM REVIEW
	
		subj=$1; run=$2		
	
		BEHAV=/Volumes/Data/TAP/${subj}/Behav/${run}
		STIM=/Volumes/Data/TAP/STIM
		REVIEW=/Volumes/Data/TAP/REVIEW/${run}/Behav
	
		# Things to remember!!	
		#    TP1 trial=$1 time=$2 target=$3 word=$4 rt=$5 resp=$6 cresp=$7 acc=$8
		# [ST]P* trial=$1 time=$2 target=$3 word=$4 speaker=$5 rt=$6 resp=$7 cresp=$8 acc=$9
	
		case $run in
			SP1 )
				match=TP1; ev=( Animal Food ) 
				MATCH=/Volumes/Data/TAP/${subj}/Behav/TP1
				;;
			SP2 )
				match=TP2; ev=( Male Female )
				MATCH=/Volumes/Data/TAP/${subj}/Behav/TP2
				;;
			TP1 )
				rt='$5'; acc='$8'
				match=SP1; ev=( O N ) 
				MATCH=/Volumes/Data/TAP/${subj}/Behav/SP1
				;;
			TP2 )
				match=SP2; ev=( Male Female )
				MATCH=/Volumes/Data/TAP/${subj}/Behav/SP2
				;;
		esac
	
		time='$2'; target='$3'; speaker='$5'; rt='$6'; acc='$9'
	
	
		hits=$(\
				egrep -c "$(egrep "${ev[0]}.*[1]$"\
				${BEHAV}/stacked.${subj}.${run}.txt \
				| awk '{print '$target'}')" \
				${MATCH}/stacked.${subj}.${match}.txt\
			 )
	
		miss=$(\
				egrep -c "$(egrep "${ev[0]}.*[0]$"\
				${BEHAV}/stacked.${subj}.${run}.txt \
				| awk '{print '$target'}')" \
				${MATCH}/stacked.${subj}.${match}.txt\
			 )
	
		corr=$(\
				egrep -c "$(egrep "${ev[1]}.*[1]$"\
				${BEHAV}/stacked.${subj}.${run}.txt \
				| awk '{print '$target'}')" \
				${MATCH}/stacked.${subj}.${match}.txt\
			 )
	
		falm=$(\
				egrep -c "$(egrep "${ev[1]}.*[0]$"\
				${BEHAV}/stacked.${subj}.${run}.txt \
				| awk '{print '$target'}')" \
				${MATCH}/stacked.${subj}.${match}.txt\
			 )
	
		(( stimsum=($hits+$miss+$corr+$falm) ))
	
		hitRate=$(echo "scale=4; ($hits)/(($hits)+($miss))" | bc)
		falmRate=$(echo "scale=4; ($falm)/(($falm)+($corr))" | bc)
	
		#(( zhits=( $hitRate ) ))
		#(( zfalm=( $falmRate ) ))
		#(( dp=($zhits-$zfalm) ))


		#------------------------------------------------------------------------
		#
		#	Description: a
		#				  
		#		Purpose: a
		#				  
		#		  Input: a
		#				  
		#		 Output: a  
		#				  
		#	  Variables: a
		#				  
		#------------------------------------------------------------------------

		xdprime_report (){
		echo -e "\n$subj $run d' Report\n====================="
		echo -e "           Hits: $hits"
		echo -e "           Miss: $miss"
		echo -e "   False Alarms: $falm"
		echo -e "Correct Rejects: $corr\n--------------------"
		echo -e "    Total Items: $stimsum\n--------------------\n"
		echo -e "       Hit Rate: $hitRate"
		echo -e "        FA Rate: $falmRate\n"
		echo -e "        "
		}
	
		dprime_report >> ${BEHAV}/Report.${subj}.${run}.txt
	}
