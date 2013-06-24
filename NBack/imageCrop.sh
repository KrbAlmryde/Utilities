#!/bin/bash
#================================================================================
#	Program Name: imageCrop.bash
#		  Author: Kyle Reese Almryde
#			Date: June 29 2012
#
#	 Description: This script uses the ImageMagick tool 'convert -crop' to batch
#				  crop my array items for the N-back task.
#
#	Deficiencies: None, this program meets specifications
#
#
#	     Updates: I have added the ImageMagick tool composite to overlay the
#				  image frame.
#
#================================================================================
#								START OF MAIN
#================================================================================

# Because I am working on this project cross-platform, this script needs to be
# able to account for the differences in the directory structure. This test makes
# sure the variables are correctly defined.

if [[ -d /Users/kylealmryde/Dropbox ]]; then
	# If this script is executed via the Macintosh
	OBACK=/Users/kylealmryde/Dropbox/DirectRT/N-Back/1-back/Arrays
	TBACK=/Users/kylealmryde/Dropbox/DirectRT/N-Back/2-back/Arrays
	NBACK=/Users/kylealmryde/Dropbox/DirectRT/N-Back
else
	# If this script is executed via Linux Ubuntu
	OBACK=/home/kyle/Dropbox/DirectRT/N-Back/1-back/Arrays
	TBACK=/home/kyle/Dropbox/DirectRT/N-Back/2-back/Arrays
	NBACK=/home/kyle/Dropbox/DirectRT/N-Back
fi

# Make a Cropped and Framed directory to store the new images
# This way I can keep the original images intact.
OCROP=${OBACK}/cropped
OFRAME=${OBACK}/framed
ODOG=${OBACK}/dogposition
TCROP=${TBACK}/cropped
TFRAME=${TBACK}/framed
TDOG=${TBACK}/dogposition

# Create directories for the Cropped and Frammed images
if [[ -d $OCROP ]]; then
	echo "Folders exist"
else
	mkdir $OCROP $OFRAME $ODOG $TCROP $TFRAME $TDOG
fi


# Make an array that will contain the names of the image files. This array will also
# be used as a counter for the for loop
oneback=( `ls ${OBACK}/*.bmp | awk -F '/' '{print $9}' | awk -F '.' '{print $1}'` )
twoback=( `ls ${TBACK}/*.bmp | awk -F '/' '{print $9}' | awk -F '.' '{print $1}'` )

# The for loop counter. Since both arrays (oneback,twoback) are the same size, better to make a single
# varialbe to act as the counter for the sake of clarity
counter=${#oneback[*]}


# This for loop iterates over each image listed in the array. For the value i is supplied for the oneback array
# and the value j is supplied for the twoback. This is due in part to legacy and part towards looking ahead to
# later code, in case I do need to count the arrays differently
for (( i = 0, j = 0; i < ${counter}; i++, j++ )); do

	# This will crop the array images so that ONLY the array images compose the image. In addition the files
	# are saved in 8-bit 256 color depth bitmaps so DirectRT can properly read them.
	convert -crop '1024x178+0+590' ${OBACK}/${oneback[i]}.bmp -colors 256 BMP3:${OCROP}/${oneback[i]}_cropped.bmp
	convert -crop '1024x178+0+590' ${TBACK}/${twoback[j]}.bmp -colors 256 BMP3:${TCROP}/${twoback[j]}_cropped.bmp

	# This will overlay the frame.png image so that there is uniformity amongst the cropped images.
	composite ${NBACK}/frame.png ${OCROP}/${oneback[i]}_cropped.bmp BMP3:${OFRAME}/${oneback[i]}_framed.bmp
	composite ${NBACK}/frame.png ${TCROP}/${twoback[j]}_cropped.bmp BMP3:${TFRAME}/${twoback[j]}_framed.bmp

	# This control structure will add the StandingDog image to the *framed images. It checks the name of the file
	# and positions the StandingDog image in the appropriate position. The vector which defines the positon is provided
	if [[ ${oneback[i]:0:8} = "1-1back-" ]]; then
		# Place the dog at positon 1, at vector 10,12
		composite -geometry +10+12 StandingDog.png ${OFRAME}/${oneback[i]}_framed.bmp BMP3:${ODOG}/${oneback[i]}_dogPos1.bmp
	elif [[ ${oneback[i]:0:8} = "2-1back-" ]]; then
		# Place the dog at positon 2, at vector 180,12
		composite -geometry +180+12 StandingDog.png ${OFRAME}/${oneback[i]}_framed.bmp BMP3:${ODOG}/${oneback[i]}_dogPos2.bmp
	elif [[ ${oneback[i]:0:8} = "3-1back-" ]]; then
		# Place the dog at positon 3, at vector350,12
		composite -geometry +350+12 StandingDog.png ${OFRAME}/${oneback[i]}_framed.bmp BMP3:${ODOG}/${oneback[i]}_dogPos3.bmp
	elif [[ ${oneback[i]:0:8} = "4-1back-" ]]; then
		# Place the dog at positon 4, at vector 520,12
		composite -geometry +520+12 StandingDog.png ${OFRAME}/${oneback[i]}_framed.bmp BMP3:${ODOG}/${oneback[i]}_dogPos4.bmp
	elif [[ ${oneback[i]:0:8} = "5-1back-" ]]; then
		# Place the dog at positon 5, at vector 690,12
		composite -geometry +690+12 StandingDog.png ${OFRAME}/${oneback[i]}_framed.bmp BMP3:${ODOG}/${oneback[i]}_dogPos5.bmp
	elif [[ ${oneback[i]:0:8} = "6-1back-" ]]; then
		# Place the dog at positon 6, at vector 860,12
		composite -geometry +860+12 StandingDog.png ${OFRAME}/${oneback[i]}_framed.bmp BMP3:${ODOG}/${oneback[i]}_dogPos6.bmp

	# For the four training items, I need to further modify the control structure
	elif [[ ${oneback[i]:0:8} = "Train-1-" ]]; then
		composite -geometry +10+12 StandingDog.png ${OFRAME}/${oneback[i]}_framed.bmp BMP3:${ODOG}/${oneback[i]}_dogPos1.bmp
	elif [[ ${oneback[i]:0:8} = "Train-3-" ]]; then
		composite -geometry +350+12 StandingDog.png ${OFRAME}/${oneback[i]}_framed.bmp BMP3:${ODOG}/${oneback[i]}_dogPos3.bmp
	elif [[ ${oneback[i]:0:8} = "Train-5-" ]]; then
		composite -geometry +690+12 StandingDog.png ${OFRAME}/${oneback[i]}_framed.bmp BMP3:${ODOG}/${oneback[i]}_dogPos5.bmp
	elif [[ ${oneback[i]:0:8} = "Train-6-" ]]; then
		composite -geometry +860+12 StandingDog.png ${OFRAME}/${oneback[i]}_framed.bmp BMP3:${ODOG}/${oneback[i]}_dogPos6.bmp
	fi


	# Due to the way in which I named the array images, I have to run the following control structure twice, with slight
	# modifications to the name
	if [[ ${twoback[j]:0:2} = "1_" ]]; then
		# Place the dog at positon 1, at vector 10,12
		composite -geometry +10+12 StandingDog.png ${TFRAME}/${twoback[j]}_framed.bmp BMP3:${TDOG}/${twoback[j]}_dogPos1.bmp
	elif [[ ${twoback[j]:0:2} = "2_" ]]; then
		# Place the dog at positon 2, at vector 180,12
		composite -geometry +180+12 StandingDog.png ${TFRAME}/${twoback[j]}_framed.bmp BMP3:${TDOG}/${twoback[j]}_dogPos2.bmp
	elif [[ ${twoback[j]:0:2} = "3_" ]]; then
		# Place the dog at positon 3, at vector350,12
		composite -geometry +350+12 StandingDog.png ${TFRAME}/${twoback[j]}_framed.bmp BMP3:${TDOG}/${twoback[j]}_dogPos3.bmp
	elif [[ ${twoback[j]:0:2} = "4_" ]]; then
		# Place the dog at positon 4, at vector 520,12
		composite -geometry +520+12 StandingDog.png ${TFRAME}/${twoback[j]}_framed.bmp BMP3:${TDOG}/${twoback[j]}_dogPos4.bmp
	elif [[ ${twoback[j]:0:2} = "5_" ]]; then
		# Place the dog at positon 5, at vector 690,12
		composite -geometry +690+12 StandingDog.png ${TFRAME}/${twoback[j]}_framed.bmp BMP3:${TDOG}/${twoback[j]}_dogPos5.bmp
	elif [[ ${twoback[j]:0:2} = "6_" ]]; then
		# Place the dog at positon 6, at vector 860,12
		composite -geometry +860+12 StandingDog.png ${TFRAME}/${twoback[j]}_framed.bmp BMP3:${TDOG}/${twoback[j]}_dogPos6.bmp

	# For the four training items
	elif [[ ${twoback[j]:0:8} = "Train-1_" ]]; then
		composite -geometry +10+12 StandingDog.png ${TFRAME}/${twoback[j]}_framed.bmp BMP3:${TDOG}/${twoback[j]}_dogPos1.bmp
	elif [[ ${twoback[j]:0:8} = "Train-2_" ]]; then
		composite -geometry +180+12 StandingDog.png ${TFRAME}/${twoback[j]}_framed.bmp BMP3:${TDOG}/${twoback[j]}_dogPos2.bmp
	elif [[ ${twoback[j]:0:8} = "Train-3_" ]]; then
		composite -geometry +350+12 StandingDog.png ${TFRAME}/${twoback[j]}_framed.bmp BMP3:${TDOG}/${twoback[j]}_dogPos3.bmp
	elif [[ ${twoback[j]:0:8} = "Train-4_" ]]; then
		composite -geometry +520+12 StandingDog.png ${TFRAME}/${twoback[j]}_framed.bmp BMP3:${TDOG}/${twoback[j]}_dogPos4.bmp
	fi

done

<<<<<<< HEAD
# This command crops a gif the '\!' is necessary in order to properly crop the whole image sequence
=======
# This command crops a gif the '\?' is necessary in order to properly crop the whole image sequence
>>>>>>> c388accc3877fb367f9b3b3512fef5b71ebe8b61
#convert Dog_position1.gif -crop 1024x590+0+0\! test2Dog_position1.gif


