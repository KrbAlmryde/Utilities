Some code to remeber when using R

# This will read data into R,
tap=read.table("Long.tap.txt",header=T,sep=",",quote="\"")

# This will create objects from the headers, so when you type "sub", all the subjects are printed
attach(tap)

# Things to remember!!

sub = $1	run=$2	target=$3	time=$4		grp=$5	rt=$6 	RESP=$7 acc=$8


# This will create a subset of data, in the instance in which I want to look at a specific
# "subset" of data. For example, I want to only look at TS001 from my data

TS1=subset(tap,sub=="TS001")
Af=subset(tap,grp=="Af")

# When you list the particular element your interested in, then you can get some really interesting
# statistics

