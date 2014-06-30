#Utilities

This project contains scripts and programs related primarily to the processing of experimental functional Magnetic Resonance Imaging studies involving language processing within the brain. It also houses programs and scripts used for other lab projects not related to fMRI processing. The primary intention of this repository is  as a resource for research staff to contribute to, learn from, and assist in fMRI processing and coding/scripting in general. 

Many of the fMRI specific scripts use [AFNI](http://afni.nimh.nih.gov/) as the primary tool for fMRI analysis and preprocessing. However, there are some examples which make use of [FSL](http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/) as well. 

Please dont expect examples of mind numbingly beautiful code or examples of how it is done right. You might find that here but you're just as likely to find the opposite as well. This repository is a collection of the work Ive done over the last 6 years, ala 2008 - 2014. 






##Directory layout

- **AttnMem**
    > Scripts for a published experiment investigating attention and memory in spoken language.

    > [**NewHope.tcsh**](./AttnMem/NewHope.tcsh) is the script you really want to check out. Makes extensive use of AFNI.   

    >Otherwise there is a lot of junk in here that Ive kept primarily mostly for personal reasons, and a few provide examples of how to do things that I have referred back to a few times in the past. 
    
    > Check out our paper! [Modulating the Focus of Attention for Spoken Words at Encoding Affects Frontoparietal Activation for Incidental Verbal Memory] (http://www.hindawi.com/journals/ijbi/2012/579786/)

- **Dichotic**
    > Pilot study that never took off.

- **Iceword**
    > fMRI experiment examining language features. Scripts designed to process and analyze data collected. Currently on-going. Everything in here served a purpose. 

- **Mouse**
    > Pilot fMRI experiment examining Mice's response to induced hunger in the brain. 

    > [**mouse.reg.sh**](./Mouse/mouse.reg.sh) is probably the most interesting as far as processing and analysis goes. Uses AFNI exclusively

- **NBack**
    > Scripts for constructing an game/experiment examining 4yr olds attention

- **Rat**
    > A pilot project involving the analysis of rat brains

- **Russian**
    > fMRI experiment examining language features. Scripts designed to process and analysis data collected. Currently on-going.

- **Stroop**
    > Scripts for a published project investigating the "Stroop Effect" in the auditory domain. Our paper for proof! [Neural Substrates of Attentive Listening Assessed with a Novel Auditory Stroop Task](http://www.ncbi.nlm.nih.gov/pmc/articles/PMC3020403/)

- **SustainedAttention**
    > A project similar to the NBack, investigating Sustained Attention in 4yr olds. Scripts for constructing the game and experiment.

- **Tap**
    > A project investigating Transfer-appropriate processing, rejected

- **WordBoundary**
    > fMRI experiment examining language features. Scripts designed to process and analysis data collected.

- **WordBoundary2**
    > Part two of the WordBoundary Experiment. Currently on-going.

- **WorkShop**
    > Work-in-Progress scripts and makeshift testing ground. There are some real gems of learning in here. It's also a complete mess in terms of its organization...be careful in there

- **NiftiViewer**
    > A long term project that doesnt really have a presence in here. For more details on this project, check out the dedicated github papge [**here**](https://github.com/CreativeCodingLab/aluminum/tree/master/osx/examples/niftiViewer)

- **tillsprojectpythoncode**
    > Scripts for  