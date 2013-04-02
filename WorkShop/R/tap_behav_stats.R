#!/usr/bin/Rscript --slave --vanilla 
#================================================================================
#	Program Name: tap_behav_stats.R
#		  Author: Kyle Reese Almryde
#			Date: May 10 2012
#
#	 Description: 
#				  
#				  
#
#	Deficiencies: 
#				  
#				  
#		   Notes: This script will need to be condensed sooner than later. At 
#				  the time of writing this (5/10/12) I do not know R well enough
#				  to pass arguments from the shell into the script itself. Until
#				  then, this script has been hardcoded for each individual run. 
#
#
#================================================================================
# 						Script formatting Notes:
#================================================================================
#
# Major blocks of code are delimited by "#====" It represents a significant 
#		section of related code
#
# Subsections of code, those being subordinate to "#====" blocks are delimited
#		by "#----" It represents a specific class or component to the upper block
#
# Individual comments are detailed via "#" 
#
#================================================================================
# 							Table of Contents
#================================================================================
#
#-------------------
# Word Only Subsets
#-------------------
#	Word:Animal; ACC
#	Word:Animal; RT
#		All Responses
#		Correct Responses
#		Incorrect Responses
#
#	Word:Food; ACC
#	Word:Food; RT
#		All Responses
#		Correct Responses
#		Incorrect Responses
#
#--------------------------------
# Word[1,2] and Voice[1] Subsets
#--------------------------------
#	Word:Animal, Voice:Female; ACC
#	Word:Animal, Voice:Female; RT
#		All Responses
#		Correct Responses
#		Incorrect Responses
#
#	Word:Food, Voice:Female; ACC
#	Word:Food, Voice:Female; RT
#		All Responses
#		Correct Responses
#		Incorrect Responses
#
#--------------------------------
# Word[1,2] and Voice[2] Subsets
#--------------------------------
#	Word:Animal, Voice:Male; ACC
#	Word:Animal, Voice:Male; RT
#		All Responses
#		Correct Responses
#		Incorrect Responses
#
#	Word:Food, Voice:Male; ACC
#	Word:Food, Voice:Male; RT
#		All Responses
#		Correct Responses
#		Incorrect Responses
#================================================================================
# 							  Start of Main 
#================================================================================

argv <- commandArgs(TRUE) 
run <- argv[1] # SP1, SP2, TP1, TP2

if(run == "TP1") {
	word <- c("Old","New") 
} else {
	word <- c("Animal","Food")
	voice <- c("Female","Male")
}


#infile <- "/Volumes/Data/TAP/REVIEW/Behav/SP1/Long.Behav.SP1.txt"

infile <- paste("/Volumes/Data/TAP/REVIEW/Behav/",run,"/Long.Behav.",run,".txt",sep="")
study <- read.table(infile, header=TRUE, sep="\t", na.strings="." )
#   "Subject"  	"Trial"   "Target"   "Word"   "Voice"   "RT"   "ACC"
#      1          2          3         4         5       6       7	


     
#================================================================================
# For loop version
#================================================================================
for (i in 1:5)
	something

	
#================================================================================
# Word Only Subsets (ACC, RT, RT-correct, RT-incorrect)
#================================================================================
#--------------------------------------------------------------------------------
# "Word:Animal"       
#	"ACC"
#     1
#--------------------------------------------------------------------------------
word1_acc=subset(study, Word == word[1], select=c(Word,ACC))[2]
word1_acc_sumstats=c(sum(word1_acc),
					 mean(word1_acc),
					 sapply(word1_acc[1],median),
					 sd(word1_acc),
					 var(word1_acc),
					 range(word1_acc))



word1_acc=subset(study, Word == "Animal", select=c(Word,ACC))[2]
	word1_acc_sumstats=c(sum(word1_acc),
						 mean(word1_acc),
						 sapply(word1_acc[1],median),
						 sd(word1_acc),
						 var(word1_acc)
						 range(word1_acc))
	#  Sum   Mean   Median     SD    Var     Range
	#   1     2       3        4      5       6     

#--------------------------------------------------------------------------------
# "Word:Animal"
#	 "RT"
#     1
#--------------------------------------------------------------------------------
# All Responses
word1_rt=subset(study, Word == word[i], select=c(Word,RT,ACC))[2]

word1_rt=subset(study, Word == "Animal", select=c(Word,RT,ACC))[2]

# Correct Responses
word1_rt_corr=subset(study, c((Word == "Animal")&(ACC > 0)),
			 select=c(Word,RT,ACC))[2]

# Incorrect Responses
word1_rt_incor=subset(study,
			 c((Word == "Animal")&(ACC == 0)),
			 select=c(Word,RT,ACC))[2]

	#  Sum   Mean   Median     SD    Var     Range
	#   1     2       3        4      5       6     
	word1_rt_sumstats=c(sum(word1_rt),
						 mean(word1_rt),
						 sapply(word1_rt[1],median),
						 sd(word1_rt),
						 var(word1_rt)
						 range(word1_rt))

	word1_rt_corr_sumstats=c(sum(word1_rt_corr),
							mean(word1_rt_corr),
						 	sapply(word1_rt_corr[1],median),
						 	sd(word1_rt_corr),
						 	var(word1_rt_corr)
							range(word1_rt_corr))

	word1_rt_incor_sumstats=c(sum(word1_rt_incor),
							mean(word1_rt_incor),
						 	sapply(word1_rt_incor[1],median),
						 	sd(word1_rt_incor),
						 	var(word1_rt_incor)
							range(word1_rt_incor))

#--------------------------------------------------------------------------------
# "Word:Food"       
#	"ACC"
#     1
#--------------------------------------------------------------------------------
word2_voice1_acc=subset(study, Word == "Food", select=c(Word,ACC))[2]

	#  Sum   Mean   Median     SD    Var     Range
	#   1     2       3        4      5       6     
	word2_voice1_acc_sumstats=c(sum(word2_voice1_acc),
						 mean(word2_voice1_acc),
						 sapply(word2_voice1_acc[1],median),
						 sd(word2_voice1_acc),
						 var(word2_voice1_acc)
						 range(word2_voice1_acc))

#--------------------------------------------------------------------------------
# "Word:Food"
#	 "RT"
#     1
#--------------------------------------------------------------------------------
# All Responses
word2_voice1_rt=subset(study,
				 Word == "Food",
				 select=c(Word,RT,ACC))[2]

# Correct Responses
word2_voice1_rt_corr=subset(study,
					 c((Word == "Food")&(ACC > 0)),
					 select=c(Word,RT,ACC))[2]

# Incorrect Responses
word2_voice1_rt_incorr=subset(study,
						c((Word == "Food")&(ACC == 0)),
						select=c(Word,RT,ACC))[2]

	#  Sum   Mean   Median     SD    Var     Range
	#   1     2       3        4      5       6     
	word2_voice1_rt_sumstats=c(sum(word2_voice1_rt),
						 mean(word2_voice1_rt),
						 sapply(word2_voice1_rt[1],median),
						 sd(word2_voice1_rt),
						 var(word2_voice1_rt)
						 range(word2_voice1_rt))

	word2_voice1_rt_corr_sumstats=c(sum(word2_voice1_rt_corr),
							mean(word2_voice1_rt_corr),
						 	sapply(word2_voice1_rt_corr[1],median),
						 	sd(word2_voice1_rt_corr),
						 	var(word2_voice1_rt_corr)
							range(word2_voice1_rt_corr))

	word2_voice1_rt_incor_sumstats=c(sum(word2_voice1_rt_incor),
							mean(word2_voice1_rt_incor),
						 	sapply(word2_voice1_rt_incor[1],median),
						 	sd(word2_voice1_rt_incor),
						 	var(word2_voice1_rt_incor)
							range(word2_voice1_rt_incor))
	


#================================================================================
# Word1 & Voice1 Subsets (ACC, RT, RT-correct, RT-incorrect)
#================================================================================

#--------------------------------------------------------------------------------
#  "Word:Animal"
# "Voice:Female"       
#	 "ACC"
#      1
#--------------------------------------------------------------------------------
word1_voice1_acc=subset(study, c((Word == "Animal")&(Voice == "Female")), select=c(Word,ACC))[2]

word1_voice1_acc=subset(study, c((Word == word[1])&(Voice == voice[1])), select=c(Word,ACC))[2]


	word1_voice1_acc_sumstats=c(sum(word1_voice1_acc),
						 mean(word1_voice1_acc),
						 sapply(word1_voice1_acc[1],median),
						 sd(word1_voice1_acc),
						 var(word1_voice1_acc)
						 range(word1_voice1_acc))
	#  Sum   Mean   Median     SD    Var     Range
	#   1     2       3        4      5       6     

#--------------------------------------------------------------------------------
#  "Word:Animal"
# "Voice:Female"       
#	  "RT"
#      1
#--------------------------------------------------------------------------------
# All Responses
word1_voice1_rt=subset(study,
				 c((Word == "Animal")&(Voice == "Female")), 
				 select=c(Word,RT,ACC))[2]

# Correct Responses
word1_voice1_rt_corr=subset(study, 
				 c((Word == "Animal")&(Voice == "Female")&(ACC > 0)),
				 select=c(Word,RT,ACC))[2]

# Incorrect Responses
word1_voice1_rt_incor=subset(study, 
				 c((Word == "Animal")&(Voice == "Female")&(ACC == 0)),
				 select=c(Word,RT,ACC))[2]

	#  Sum   Mean   Median     SD    Var     Range
	#   1     2       3        4      5       6     
	word1_voice1_rt_sumstats=c(sum(word1_voice1_rt),
						 mean(word1_voice1_rt),
						 sapply(word1_voice1_rt[1],median),
						 sd(word1_voice1_rt),
						 var(word1_voice1_rt)
						 range(word1_voice1_rt))

	word1_voice1_rt_corr_sumstats=c(sum(word1_voice1_rt_corr),
									mean(word1_voice1_rt_corr),
									sapply(word1_voice1_rt_corr[1],median),
									sd(word1_voice1_rt_corr),
									var(word1_voice1_rt_corr)
									range(word1_voice1_rt_corr))

	word1_voice1_rt_incor_sumstats=c(sum(word1_voice1_rt_incor),
									mean(word1_voice1_rt_incor),
						 			sapply(word1_voice1_rt_incor[1],median),
								 	sd(word1_voice1_rt_incor),
								 	var(word1_voice1_rt_incor)
									range(word1_voice1_rt_incor))


#================================================================================
# Word2 & Voice1 Subsets (ACC, RT, RT-correct, RT-incorrect)
#================================================================================

#--------------------------------------------------------------------------------
# "Word:Food"       
# "Voice:Female" 
#	"ACC"
#     1
#--------------------------------------------------------------------------------
word2_voice1_acc=subset(study, 
				 c((Word == "Food")&(Voice == "Female")), 
				 select=c(Word,ACC))[2]

	word2_voice1_acc_sumstats=c(sum(word2_voice1_acc),
						 mean(word2_voice1_acc),
						 sapply(word2_voice1_acc[1],median),
						 sd(word2_voice1_acc),
						 var(word2_voice1_acc)
						 range(word2_voice1_acc))
	#  Sum   Mean   Median     SD    Var     Range
	#   1     2       3        4      5       6     

#--------------------------------------------------------------------------------
#  "Word:Food"
# "Voice:Female"       
#	  "RT"
#      1
#--------------------------------------------------------------------------------
# All Responses
word2_voice1_rt=subset(study,
				 c((Word == "Food")&(Voice == "Female")), 
				 select=c(Word,RT,ACC))[2]

# Correct Responses
word2_voice1_rt_corr=subset(study, 
					 c((Word == "Food")&(Voice == "Female")&(ACC > 0)),
					 select=c(Word,RT,ACC))[2]

# Incorrect Responses
word2_voice1_rt_incor=subset(study, 
					 c((Word == "Food")&(Voice == "Female")&(ACC == 0)),
					 select=c(Word,RT,ACC))[2]

	#  Sum   Mean   Median     SD    Var     Range
	#   1     2       3        4      5       6     
	word2_voice1_rt_sumstats=c(sum(word2_voice1_rt),
							 mean(word2_voice1_rt),
							 sapply(word2_voice1_rt[1],median),
							 sd(word2_voice1_rt),
						 	var(word2_voice1_rt)
						 	range(word2_voice1_rt))

	word2_voice1_rt_corr_sumstats=c(sum(word2_voice1_rt_corr),
									mean(word2_voice1_rt_corr),
									sapply(word2_voice1_rt_corr[1],median),
									sd(word2_voice1_rt_corr),
									var(word2_voice1_rt_corr)
									range(word2_voice1_rt_corr))

	word2_voice1_rt_incor_sumstats=c(sum(word2_voice1_rt_incor),
									mean(word2_voice1_rt_incor),
						 			sapply(word2_voice1_rt_incor[1],median),
								 	sd(word2_voice1_rt_incor),
								 	var(word2_voice1_rt_incor)
									range(word2_voice1_rt_incor))


#================================================================================
# Word1 & Voice2 Subsets (ACC, RT, RT-correct, RT-incorrect)
#================================================================================

#--------------------------------------------------------------------------------
#  "Word:Animal"
# "Voice:Male"       
#	 "ACC"
#      1
#--------------------------------------------------------------------------------
word1_voice2_acc=subset(study, 
				 c((Word == "Animal")&(Voice == "Male")), 
				 select=c(Word,ACC))[2]

	word1_voice2_acc_sumstats=c(sum(word1_voice2_acc),
						 mean(word1_voice2_acc),
						 sapply(word1_voice2_acc[1],median),
						 sd(word1_voice2_acc),
						 var(word1_voice2_acc)
						 range(word1_voice2_acc))
	#  Sum   Mean   Median     SD    Var     Range
	#   1     2       3        4      5       6     

#--------------------------------------------------------------------------------
#  "Word:Animal"
# "Voice:Male"       
#	  "RT"
#      1
#--------------------------------------------------------------------------------
# All Responses
word1_voice2_rt=subset(study,
					 c((Word == "Animal")&(Voice == "Male")), 
					 select=c(Word,RT,ACC))[2]

# Correct Responses
word1_voice2_rt_corr=subset(study, 
					 c((Word == "Animal")&(Voice == "Male")&(ACC > 0)),
					 select=c(Word,RT,ACC))[2]

# Incorrect Responses
word1_voice2_rt_incor=subset(study, 
					 c((Word == "Animal")&(Voice == "Male")&(ACC == 0)),
					 select=c(Word,RT,ACC))[2]

	#  Sum   Mean   Median     SD    Var     Range
	#   1     2       3        4      5       6     
	word1_voice2_rt_sumstats=c(sum(word1_voice2_rt),
						 mean(word1_voice2_rt),
						 sapply(word1_voice2_rt[1],median),
						 sd(word1_voice2_rt),
						 var(word1_voice2_rt)
						 range(word1_voice2_rt))

	word1_voice2_rt_corr_sumstats=c(sum(word1_voice2_rt_corr),
									mean(word1_voice2_rt_corr),
									sapply(word1_voice2_rt_corr[1],median),
									sd(word1_voice2_rt_corr),
									var(word1_voice2_rt_corr)
									range(word1_voice2_rt_corr))

	word1_voice2_rt_incor_sumstats=c(sum(word1_voice2_rt_incor),
									mean(word1_voice2_rt_incor),
						 			sapply(word1_voice2_rt_incor[1],median),
								 	sd(word1_voice2_rt_incor),
								 	var(word1_voice2_rt_incor)
									range(word1_voice2_rt_incor))


#================================================================================
# Word2 & Voice2 Subsets (ACC, RT, RT-correct, RT-incorrect)
#================================================================================

#--------------------------------------------------------------------------------
# "Word:Food"       
# "Voice:Male" 
#	"ACC"
#     1
#--------------------------------------------------------------------------------
word2_voice2_acc=subset(study, 
				 c((Word == "Food")&(Voice == "Male")), 
				 select=c(Word,ACC))[2]

	word2_voice2_acc_sumstats=c(sum(word2_voice2_acc),
						 mean(word2_voice2_acc),
						 sapply(word2_voice2_acc[1],median),
						 sd(word2_voice2_acc),
						 var(word2_voice2_acc)
						 range(word2_voice2_acc))
	#  Sum   Mean   Median     SD    Var     Range
	#   1     2       3        4      5       6     

#--------------------------------------------------------------------------------
#  "Word:Food"
# "Voice:Male"       
#	  "RT"
#      1
#--------------------------------------------------------------------------------
# All Responses
word2_voice2_rt=subset(study,
				 c((Word == "Food")&(Voice == "Male")), 
				 select=c(Word,RT,ACC))[2]

# Correct Responses
word2_voice2_rt_corr=subset(study, 
				 c((Word == "Food")&(Voice == "Male")&(ACC > 0)),
				 select=c(Word,RT,ACC))[2]

# Incorrect Responses
word2_voice2_rt_incor=subset(study, 
				 c((Word == "Food")&(Voice == "Male")&(ACC == 0)),
				 select=c(Word,RT,ACC))[2]

	#  Sum   Mean   Median     SD    Var     Range
	#   1     2       3        4      5       6     
	word2_voice2_rt_sumstats=c(sum(word2_voice2_rt),
						 mean(word2_voice2_rt),
						 sapply(word2_voice2_rt[1],median),
						 sd(word2_voice2_rt),
						 var(word2_voice2_rt)
						 range(word2_voice2_rt))

	word2_voice2_rt_corr_sumstats=c(sum(word2_voice2_rt_corr),
									mean(word2_voice2_rt_corr),
									sapply(word2_voice2_rt_corr[1],median),
									sd(word2_voice2_rt_corr),
									var(word2_voice2_rt_corr)
									range(word2_voice2_rt_corr))

	word2_voice2_rt_incor_sumstats=c(sum(word2_voice2_rt_incor),
									mean(word2_voice2_rt_incor),
						 			sapply(word2_voice2_rt_incor[1],median),
								 	sd(word2_voice2_rt_incor),
								 	var(word2_voice2_rt_incor)
									range(word2_voice2_rt_incor))





by(LongFile,Group,summary)




infile2 <- "/Volumes/Data/TAP/REVIEW/Behav/TP1/Long.Behav.TP1.txt"
tp1 <- read.table(infile2, header=TRUE, sep="\t", na.strings="." )
attach(tp1)





