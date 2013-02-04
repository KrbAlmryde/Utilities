# Brace expanision is AWESOME (in bash)
# Lets use it to create a nested subject directory for the WB1 study

mkdir -p {sub001,sub002,sub003}/{Access,DTI,Func,Morph,Pictures,RealignDetails,Reg,SubjectROIs}

# This creates the following architecture
<<_
	sub001/
		Access
		DTI
		Func
		Morph
		Pictures
		RealignDetails
		Reg
		SubjectROIs
		
	sub002/
		Access
		DTI
		Func
		Morph
		Pictures
		RealignDetails
		Reg
		SubjectROIs

	sub003/
		Access
		DTI
		Func
		Morph
		Pictures
		RealignDetails
		Reg
		SubjectROIs
_

# But that leaves us with an incomplete subject directory. We could run another
# command similar to the previous example and complete the setup, OR we could get
# it all done at once via nested brace-expansion!

mkdir -p {sub001,sub002,sub003}/{Access,DTI/Bed.bedpostX,Func/{Eprime,{Run1,Run2,Run3}/RealignDetails},Morph/Seg,Pictures,RealignDetails,Reg,SubjectROIs}

# This creates the following architecture, which looks a little more complete
# wouldnt you say? 
<<_

	sub001/
		Access
		DTI
		Func/
			Eprime
			Run1/
				RealignDetails
			Run2/
				RealignDetails
			Run3/
				RealignDetails
		Morph/
			Seg
		Pictures
		RealignDetails
		Reg
		SubjectROIs


	sub002/
		Access
		DTI
		Func/
			Eprime
			Run1/
				RealignDetails
			Run2/
				RealignDetails
			Run3/
				RealignDetails
		Morph/
			Seg
		Pictures
		RealignDetails
		Reg
		SubjectROIs


	sub003/
		Access
		DTI
		Func/
			Eprime
			Run1/
				RealignDetails
			Run2/
				RealignDetails
			Run3/
				RealignDetails
		Morph/
			Seg
		Pictures
		RealignDetails
		Reg
		SubjectROIs

_

# Huh, would you look at that? We just build the entire directory structure in 
# ONE LINE! But lets be honest, ALL of that on one line?! That looks a mess, so 
# lets break it up a little bit for readability's sake (Run this in a script!!!)

mkdir -p \
	{sub001,sub002,sub003}/\
		{Access,\
		DTI/\
			Bed.bedpostX,\
		Func/\
			{Eprime,\
			{Run1,Run2,Run3}/\
				RealignDetails},\
		Morph/Seg,\
		Pictures,RealignDetails,Reg,SubjectROIs}		
		
		
