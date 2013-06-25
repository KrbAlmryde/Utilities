# This works, its been commented out because it is no longer needed
# 1.upto(60) do |x| 
# 	print "composite -geometry +#{rand 860}+#{rand 307} Target.png Background/Background_frogs.png BMP3:Stimuli/TargetPosition#{x}.bmp\n" 
# end

# 1.upto(20) do |x|
# 	if (x/3)%2 == 0
# 		if x%2 == 0
# 			print "_Animation\\GreenFrogSpeak.gif(1024x294)\t0,.9,0\t0\t!Audio\\M-NN-Fly.wav\t0,0,0\t2000\n"
# 		else if x%2 !=0 
# 			print "_Animation\\LadyFrogSpeak.gif(1024x294)\t0,.9,0\t0\t!Audio\\F-NN-Fly.wav\t0,0,0\t2000\n"
# 		end		
# 		print "_Animation\\GreenFrogSpeak.gif(1024x294)\t0,.9,0\t0\t!Audio\\M-WN-Fly.wav\t0,0,0\t2000\n"
# 		print "_Animation\\LadyFrogSpeak.gif(1024x294)\t0,.9,0\t0\t!Audio\\F-WN-Fly.wav\t0,0,0\t2000\n"
# 		end
# 	end
# end
	


words = IO.readlines("wordlist.txt")

# It mostly works, it doesnt evenly distribute the NN vs WN but its close enough for gov work
0.upto(40) do |x|
	 if (x/3)%2 == 0
		if x%2 == 0
			print "_Animation\\GreenFrogSpeak.gif(1024x294)\t0,.9,0\t0\t!Audio\\M-NN-#{words[x].chomp}.wav\t0,0,0\t2000\n"
		elsif x%2 != 0 
			print "_Animation\\LadyFrogSpeak.gif(1024x294)\t0,.9,0\t0\t!Audio\\F-NN-#{words[x].chomp}.wav\t0,0,0\t2000\n"
		end
	elsif  (x/3)%2 != 0
		if x%2 == 0
			print "_Animation\\GreenFrogSpeak.gif(1024x294)\t0,.9,0\t0\t!Audio\\M-WN-#{words[x].chomp}.wav\t0,0,0\t2000\n"
		elsif x%2 !=0		
			print "_Animation\\LadyFrogSpeak.gif(1024x294)\t0,.9,0\t0\t!Audio\\F-WN-#{words[x].chomp}.wav\t0,0,0\t2000\n"
		end
	end
end






# Todo
# Audio/ Intro
# Audio/ Training1
# Audio/ Fly Rewards
# Audio/ "Its a fly" - WN - M/F 
# Audio/ 










# This code is work in progress, I dont know enough ruby yet to be effective with it, but I will be eventually I hope
# 1.upto(10) do |y|
# 	print "stim\tloc\ttime\t"
# end

# 1.upto(60) do |x|
# 	print "\nBackground/Background_frogs.bmp\t0,0,0\t0\t*"
# 	if x == 24
# 		blah
# 	end
# end


# File.open("wordlist2.txt", "w") 
# { |file| 
# 		print
# }



# exec "bash #{'script.sh'}"
