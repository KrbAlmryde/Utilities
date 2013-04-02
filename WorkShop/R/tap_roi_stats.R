#!/usr/bin/Rscript --slave --vanilla 
#================================================================================
#	Program Name: tap_roi_stats.R
#		  Author: Kyle Reese Almryde
#			Date: May 13 2012
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

# initiate script in the current working directory

argv <- commandArgs(TRUE) 
run <- argv[1] # SP1, SP2, TP1, TP2

if(run == "TP1") {
	word <- c("old","new") 
} else {
	word <- c("animal","food")
	voice <- c("female","male")
}

infile <- paste("/Volumes/Data/TAP/REVIEW/ANOVA/Long.ROI.tap.txt",sep="")


roi = c("Angular_Gyrus", "Anterior_Cingulate_Cortex", 
"Caudate_Nucleus", "Cuneus", "Fusiform_Gyrus", "Heschls_Gyrus", 
"Inferior_Frontal_Gyrus_Opercularis", "Inferior_Frontal_Gyrus_Orbitalis", 
"Inferior_Frontal_Gyrus_Triangularis", "Inferior_Parietal_Lobule", 
"Insula_Lobe", "Lingual_Gyrus", "Medial_Temporal_Pole", 
"Mid_Orbital_Gyrus", "Middle_Cingulate_Cortex", "Middle_Frontal_Gyrus", 
"Middle_Orbital_Gyrus", "Middle_Temporal_Gyrus", "Pallidum", 
"Paracentral_Lobule", "Postcentral_Gyrus", "Posterior_Cingulate_Cortex", 
"Precentral_Gyrus", "Precuneus", "Putamen", "Rectal_Gyrus", 
"Rolandic_Operculum", "SMA", "Superior_Frontal_Gyrus", 
"Superior_Medial_Gyrus", "Superior_Orbital_Gyrus", "Superior_Parietal_Lobule", 
"Superior_Temporal_Gyrus", "SupraMarginal_Gyrus", "Temporal_Pole", 
"Thalamus")


long <- read.table(infile, header=TRUE, sep=",")

# Data should be in this format
#------------------------------------------------------------------
# Ref,Subject,Run,Dprime,Condition,Hemisphere,ROI,Intensity,Voxels
# 0,TS001,SP1,0.039,mean_animal,L,Angular,0.223,24
# 0,TS001,SP1,0.039,mean_food,R,Angular,0.534,12


#------------------------------------------------------------------------------------
# Ref  Subject   Run   Dprime   Condition   Hemisphere   ROI   Intensity   Voxels
#  1     2        3      4          5           6         7       8          9
#------------------------------------------------------------------------------------


## This contains the Left Superior and Inferior_Parietal_Lobule ROIs for each
## subject under run SP1 and the mean_animal condition
animal_ISPL_L <- subset(long,c((Run == "SP1")&
				(Condition == "mean_animal")&
				(Hemisphere == "L")&
				(grepl("*_Parietal_Lobule", long$ROI))),
		select=Subject:Intensity)
## This is sorted by both ROI and Dprime in Ascending (Low to High) order

order_animal_ISPL_L<- ISPL_L[order(ISPL_L[6],ISPL_L[3]),]

# Ref <- data.frame(Ref=rep(0:17,2))
lh_animal_ISPL_L<-cbind(data.frame(Ref=rep(0:17,2), order_ISPL_L))
 
#lh_ISPL_L<- ISPL_L[order(ISPL_L[4]),]
## This plots both ROIs independently and provides a legend that represents just
## those ROIs I want to plot. The axis command at the bottom labels the data 
## correctly :)
interaction.plot(lh_animal_ISPL_L[[1]], factor(lh_animal_ISPL_L[[7]]), lh_animal_ISPL_L[[8]],
				fixed=TRUE, 
				xaxt="n",
				xlab="Subjects in order of Memory Performance Lowest to Highest",
				ylab="% change intensity",
				main="Study Phase 1: Animal Words, Left Hemisphere",
				col = 2:3, 
				leg.bty = "b",
				trace.label="Regions of Interest",
				type="b",
				pch=1:2)
axis(1,at=1:18,labels=c(14,9,15,16,5,12,3,18,6,4,7,2,1,11,17,8,10,13),tick=TRUE)
grid()



# Calculate the correlation between Dprime and ROI
cor(lh_animal_ISPL_L[1:18,][4],lh_animal_ISPL_L[1:18,][8]) # IPL
cor(lh_animal_ISPL_L[1:18,][4],lh_animal_ISPL_L[19:36,][8]) # SPL

# This performs the correlation of the first 18 lines of Intensity against the last
# 18 lines of Intensity. 
## In other words, this calculates the correlation of the intensity of IPL against
## SPL :-) 
cr<-cor(lh_ISPL_L[1:18,][8],lh_ISPL_L[19:36,][8])
cv<-cov(lh_ISPL_L[1:18,][8],lh_ISPL_L[19:36,][8])
m<-lm(lh_ISPL_L[[8]]~lh_ISPL_L[[4]])

abline(coef(m))
#===============================================================================
# Now for Mean Food
#===============================================================================
food_ISPL_L <- subset(long,c((Run == "SP1")&
				(Condition == "mean_food")&
				(Hemisphere == "L")&
				(grepl("*_Parietal_Lobule", long$ROI))),
		select=Subject:Intensity)
## This is sorted by both ROI and Dprime in Ascending (Low to High) order

order_food_ISPL_L<- food_ISPL_L[order(food_ISPL_L[6],food_ISPL_L[3]),]

# Ref <- data.frame(Ref=rep(0:17,2))
lh_food_ISPL_L<-cbind(data.frame(Ref=rep(0:17,2), order_food_ISPL_L))

#lh_ISPL_L<- ISPL_L[order(ISPL_L[4]),]
## This plots both ROIs independently and provides a legend that represents just
## those ROIs I want to plot. The axis command at the bottom labels the data 
## correctly :)
interaction.plot(lh_food_ISPL_L[[1]], factor(lh_food_ISPL_L[[7]]), lh_food_ISPL_L[[8]],
				fixed=TRUE, 
				xaxt="n",
				ylim=range(lh_food_ISPL_L[[8]]),
				xlab="Subjects in order of Memory Performance Lowest to Highest",
				ylab="% change intensity",
				main="Study Phase 1: Food Words, Left Hemisphere",
				col = 2:3, 
				leg.bty = "b",
				trace.label="Regions of Interest",
				type="b",
				pch=1:2)
axis(1,at=1:18,labels=c(14,9,15,16,5,12,3,18,6,4,7,2,1,11,17,8,10,13),tick=TRUE)
grid()





#===============================================================================
# Now for Mean Animal & Food
#===============================================================================

order_long<-long[order(long$Dprime,long$ROI,long$Intensity),]
			 			 
ISPL_L <- subset(long,
				c((Run == "SP1")&
				(grepl("mean_*", long$Condition))&
				(Hemisphere == "L")&
				(grepl("*_Parietal_Lobule", long$ROI))),
				select=Subject:Intensity)
			 
ev1<-factor(or_ISPL_L[[4]]) == "mean_animal"
ev2<-factor(or_ISPL_L[[4]]) == "mean_food"																		#ISPL_L[order(ISPL_L[4],ISPL_L[6],ISPL_L[3]),]			 
																							#lh_ISPL_L<-cbind(data.frame(Ref=rep(0:17,4), ISPL_L[order(ISPL_L[4],ISPL_L[6],ISPL_L[3]),]))
or_ISPL_L<-ISPL_L[order(ISPL_L[6],ISPL_L[4],ISPL_L[3]),]
cb_ISPL_L<-cbind(data.frame(Ref=rep(0:17,4), or_ISPL_L))
cb_ISPL_L[ev1,1:8]


matplot(c(1, 18), 
		c(-0.01, 0.3), 
		type= "n", 
		xlab = "Subjects in order of Memory Performance Lowest to Highest", 
		ylab = "% change intensity",
		main = "Study Phase 1: Animal & Food Words, Left Hemisphere")

cb_ISPL_L[ev1,1:8]


# > head(OrchardSprays)
#   decrease rowpos colpos treatment
# 1       57      1      1         D
# 2       95      2      1         E
# 3        8      3      1         B
# 4       69      4      1         H
# 5       92      5      1         G
# 6       90      6      1         F

> with(OrchardSprays, {
+     interaction.plot(treatment, rowpos, decrease)
+     interaction.plot(rowpos, treatment, decrease, cex.axis=0.8)
+     ## order the rows by their mean effect
+     rowpos <- factor(rowpos,
+                      levels = sort.list(tapply(decrease, rowpos, mean)))
+     interaction.plot(rowpos, treatment, decrease, col = 2:9, lty = 1)
+ })

with(cb_ISPL_L, { 
	interaction.plot(

}



interaction.plot(cb_ISPL_L[[1]], factor(cb_ISPL_L[ev1,7]), cb_ISPL_L[[8]],
				fixed=TRUE, 
				xaxt="n",
				ylim=range(lh_food_ISPL_L[[8]]),
				xlab="Subjects in order of Memory Performance Lowest to Highest",
				ylab="% change intensity",
				main="Study Phase 1: Food Words, Left Hemisphere",
				col = 2:3, 
				leg.bty = "b",
				trace.label="Regions of Interest",
				type="b",
				pch=1:2)
axis(1,at=1:18,labels=c(14,9,15,16,5,12,3,18,6,4,7,2,1,11,17,8,10,13),tick=TRUE)
grid()




matpoints(cb_ISPL_L[ev1,c(1,8)], cb_ISPL_L[ev2,c(1,8)], pch = "sS", col = c(2,4))



table(iris$Species) # is data.frame with 'Species' factor
iS <- iris$Species == "setosa"
iV <- iris$Species == "versicolor"
op <- par(bg = "bisque")
matplot(c(1, 8), c(0, 4.5), type= "n", xlab = "Length", ylab = "Width",
		main = "Petal and Sepal Dimensions in Iris Blossoms")
matpoints(iris[iS,c(1,3)], iris[iS,c(2,4)], pch = "sS", col = c(2,4))
matpoints(iris[iV,c(1,3)], iris[iV,c(2,4)], pch = "vV", col = c(2,4))
legend(1, 4, c("    Setosa Petals", "    Setosa Sepals",
			   "Versicolor Petals", "Versicolor Sepals"),
	   pch = "sSvV", col = rep(c(2,4), 2))






matplot(c(1, 18), 
		c(-0.01, 0.3), 
		type= "n", 
		xlab = "Subjects in order of Memory Performance Lowest to Highest", 
		ylab = "% change intensity",
		main = "Study Phase 1: Animal & Food Words, Left Hemisphere")

ISPL_L[conAnimal,1:8], iris[iS,c(2,4)]

matpoints(iris[iS,c(1,3)], iris[iS,c(2,4)], pch = "sS", col = c(2,4))



table(iris$Species) # is data.frame with 'Species' factor
iS <- iris$Species == "setosa"
iV <- iris$Species == "versicolor"
op <- par(bg = "bisque")
matplot(c(1, 8), c(0, 4.5), type= "n", xlab = "Length", ylab = "Width",
		main = "Petal and Sepal Dimensions in Iris Blossoms")
matpoints(iris[iS,c(1,3)], iris[iS,c(2,4)], pch = "sS", col = c(2,4))
matpoints(iris[iV,c(1,3)], iris[iV,c(2,4)], pch = "vV", col = c(2,4))
legend(1, 4, c("    Setosa Petals", "    Setosa Sepals",
			   "Versicolor Petals", "Versicolor Sepals"),
	   pch = "sSvV", col = rep(c(2,4), 2))






> data( Cars93, package =" MASS") 
> coplot( Horsepower ~ MPG.city | Origin, data = Cars93)
> coplot( ISPL_L$ROI ~ ISP_L$Intensity | ISP_L$Condition)









#################################################################################
# Below are notes about specific function behavior as well as pseudo-code 

## Subset ##
subset(airquality, Day == 1, select = -Temp)
subset(airquality, select = Ozone:Wind)
with(airquality, subset(Ozone, Temp > 80))
# sometimes requiring a logical 'subset' argument is a nuisance
nm <- rownames(state.x77)
start_with_M <- nm %in% grep("^M", nm, value=TRUE)
subset(state.x77, start_with_M, Illiteracy:Murder)
# but in recent versions of R this can simply be
subset(state.x77, grepl("^M", nm), Illiteracy:Murder)

		# How to subset data into its own data frame
		IPL_L <- subset(long,c((Run == "SP1")&
				(Condition == "mean_animal")&
				(Hemisphere == "L")&
				(ROI == "Inferior_Parietal_Lobule")),
			select=c(Subject,Dprime,ROI,Intensity))


## Order ##
long[order(long$Dprime),])


## Plot ##
# not so useful :-(
with(iris,plot( Petal.Length, Petal.Width, pch = as.integer( Species)))

# VERY useful
interaction.plot( rats $ poison, rats $ treat, rats $ time)


	> with(ToothGrowth, {
	+     interaction.plot(dose, supp, len, fixed=TRUE)
	+     dose <- ordered(dose)
	+     interaction.plot(dose, supp, len, fixed=TRUE, col = 2:3, leg.bty = "o")
	+     interaction.plot(dose, supp, len, fixed=TRUE, col = 2:3, type = "p")
	+ })


	with(lh_ISPL_L, {
	    interaction.plot(Ref, ROI, Intensity, fixed=TRUE)
	    Dprime <- ordered(Dprime)
	    interaction.plot(Ref, ROI, Intensity, fixed=TRUE, col = 2:3, leg.bty = "o")
	    interaction.plot(Ref, ROI, Intensity, fixed=TRUE, col = 2:3, type = "p")
	})



## Depreciated, but keeping for convalescence
# matplot( ISPL_L[[c(1,7,8)]],
# 			type="o",
# 			pch=1:4,
# 			las=0,
# 			xaxt="n",
# 			xlab="Subject",
# 			ylab="% change intensity",
# 			main="ROI Intensity",
# 			ylim=c(-0.3,0.3),
# 			xlim=c(1,18), #change this perhaps?
# 			cex.main=1,
# 			cex.lab=1,
# 			cex.axis=1 )
# 
# grid()
# 
# legend(1,0.05, c(roi[10], roi[32], roi[10], roi[32]), pch=1:4)
# 
# matplot(lh_ISPL_L[[1]], lh_ISPL_L[[8]], xaxt='n', pch="a", ylim=c(-0.1,0.3))
# 
# 
# axis(1,at=0:17,labels=c(6,17,15,11,5,7,18,10,16,9,8,1,2,12,4,3,13,14),tick=TRUE)
# 
# # The original
# # axis(1,1:18,labels=TRUE,tick=TRUE)
