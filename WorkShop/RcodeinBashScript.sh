#!/bin/bash
#================================================================================
#	Program Name: R.bash
#		  Author: Kyle Reese Almryde
#			Date: May 04 2012
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


Here is an excerpt of a bash script showing its use -- notice that several 
bash variables are referenced within it:

#!/bin/bash
			  .
			  .
R --slave --vanilla --quiet --no-save  <<EEE
#  ---edit so path to R-graphics/.RData is correct---
attach("/home/mfcl/R-graphics/.RData")
if( $keep ) {
   junk <- paste("$1",".medley.png",sep="")
   print(paste("saving plotfile",junk))
} else {
   junk <-  "$tempfile"
}
png(file=junk,height=$ht,width=$wd)  # open plot file
plotmedley("$1")                # do the plot
dum <- dev.off()                # close file
system(paste("display",junk))   # display it
EEE
			  .
			  .


Cheers, Pierre

Christian Schulz wrote:
> Hi
> 
> how is it possible to use more than one command when i'm
> didn't want use R CMD BATCH for specific reason?
> 
> $ echo "(x<-1:10)" | R --vanilla
> works
> 
> $ echo "(x<-1:10 ;y<-20:30 ;lm(y ~ x))" | R --vanilla
> works not.
> 
> Is it further possible using  bash variables like $i  from a loop
> in the bash echo call  i.e.   dm$x$i$k <- 
> read.data("dmdata$x$i$k.dat",header=T)
> 
> many thanks for a starting point!
> christian