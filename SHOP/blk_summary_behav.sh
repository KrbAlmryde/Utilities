. $PROFILE/${1}_profile.sh

while read cond; do
	. drt_behav.sh $1
done <${CONDITIONS}
