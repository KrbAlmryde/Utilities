# Extract just the rows of interest.  By using the -e the sed commands are all executed together, so we retain the line ordering of the file
cat ${file} | sed -n -e '/SoundFile/p' -e '/SlideTarget.RT:/p' -e '/SlideTarget.RESP/p' -e '/SlideTarget.CRESP/p' | tr -d '\t' > temp

# Add a clean list of the sound files, swap _ for spaces in wav file names
cat temp | sed -n -e 's/SoundFile: test items//p' | colrm 1 3 | sed 's/ /_/g'  >> soundfile

# Get lines containing RT (or Target.RESP or CRESP) and save the 2nd field
cat temp | grep RT | awk '{print $2}' >> rt
cat temp | grep Target.RESP | awk '{print $2}' >> resp
cat temp | grep CRESP | awk '{print $2}' >> cresp
# Paste the fields I want in contiguous space separated columns
paste -d" " soundfile rt resp cresp >> access_${name}.txt
rm soundfile cresp resp rt temp






