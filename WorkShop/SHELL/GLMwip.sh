3dDeconvolve -nodata 101 3.5 -polort -1 -num_stimts 2 \
-stim_times 1 stim_FR_binaural.1D 'WAV' \
-stim_times 2 stim_FR_dichotic.1D 'WAV' -x1D Wavstim
1dplot -sepscl -thick -xlabel Time -ynames Stim1 Stim2 -jpeg wav Wavstim.xmat.1D'[0..1]'

3dDeconvolve -nodata 101 3.5 -polort -1 -num_stimts 2 \
-stim_times 1 stim_FR_binaural.1D 'GAM' \
-stim_times 2 stim_FR_dichotic.1D 'GAM' -x1D GAMstim
1dplot -sepscl -thick -xlabel Time -ynames Stim1 Stim2 -jpeg gam GAMstim.xmat.1D'[0..1]'


3dDeconvolve -nodata 101 3.5 -polort -1 -num_stimts 2 \
-stim_times 1 stim_FR_binaural.1D 'WAV' \
-stim_times 2 stim_FR_binaural.1D 'GAM' -x1D wavgamBin
1dplot -sepscl -thick -xlabel Time -ynames WAV GAM -jpeg wavgamBin wavgamBin.xmat.1D'[0..1]'

3dDeconvolve -nodata 101 3.5 -polort -1 -num_stimts 2 \
-stim_times 1 stim_FR_dichotic.1D 'WAV' \
-stim_times 2 stim_FR_dichotic.1D 'GAM' -x1D wavgamDich
1dplot -sepscl -thick -xlabel Time -ynames WAV GAM -jpeg wavgamDich wavgamDich.xmat.1D'[0..1]'

3dDeconvolve -nodata 700 3 -polort -a -num_stimts 10 \


     3dDeconvolve -num_stimts 3 -polort -1   \
                  -local_times -x1D name.xmat.1D             \
                  -stim_times 1 '1D: 10 60' 'WAV(10)'        \
                  -stim_times 2 '1D: 10 60' 'BLOCK4(10,1)'   \
                  -stim_times 3 '1D: 10 60' 'SPMG1(10)'      \
      | 1dplot -thick -one -stdin -xlabel Time -ynames WAV BLOCK4 SPMG1



1dplot -sepscl -xlabel Time -ynames baseline Polort1 Polort2 Polort3 Binaural-stim Dichotic-stim Roll Pitch Yaw Z X Y -jpeg DL4_FR_WAV.Regressors-All DL4_FR_WAV.xmat.1D'[0..11]'
1dplot -jpeg ${subrunmod}.RegressofInterest ${subrunmod}.xmat.1D'[4..5]'


3dDeconvolve -nodata 700 3.0 -num_stimts 3 -polort 1 \
-local_times -x1D stdout: \
-stim_times 1 '1D: 80' 'WAV(1860,0.5,2.5,4,0.5,1)' \
-stim_times 2 '1D: 80' 'WAV(1800,120,2.5,4,0.5,1)' \
-stim_times 3 '1D: 80' 'WAV(1800,120,2.5,120,0.5,1)' \
| 1dplot -thick -sepscl -stdin -xlabel Time -ynames Base Polort WAV1 WAV2 WAV3




3dDeconvolve -nodata 700 1 -num_stimts 1 -polort -1	\
-local_times -x1D stdout:	\
-stim_times 1 '1D: 240' 'WAV(1860,100,2.5,4,0.2,1)'	\
 | 1dplot -jpg Rat_delay100 -sepscl -stdin -xlabel dur=1860,delay=100,rise=2.5,fall=4,undershoot=0.2,restore=1


3dDeconvolve -nodata 100 1.0 -num_stimts 3 -polort -1	\
-local_times -x1D stdout:	\
-stim_times 1 '1D: 10' 'WAV'	\
-stim_times 2 '1D: 10' 'WAV(0,0.5,2.5,4,0.2,1)'	\
-stim_times 3 '1D: 10' 'WAV(0,0.5,2,30,0.5,1)'	\
 | 1dplot -thick -sepscl -stdin -xlabel Time -ynames WAV WAV2 WAV3


3dDeconvolve -nodata 100 1.0 -num_stimts 3 -polort -1	\
-local_times -x1D stdout:	\
-stim_times 1 '1D: 10' 'WAV'	\
-stim_times 2 '1D: 10' 'WAV(0,0.5,2.5,4,0.2,1)'	\
-stim_times 3 '1D: 10' 'WAV(0,0.5,2,30,0.5,1)'	\
 | 1dplot -thick -sepscl -stdin -xlabel Time -ynames WAV WAV2 WAV3



3dDeconvolve -nodata 100 1.0 -num_stimts 3 -polort -1	\
-local_times -x1D stdout:	\
-stim_times 1 '1D: 10' 'WAV'	\
-stim_times 2 '1D: 10' 'WAV(0,0.5,2.5,4,0.2,1)'	\
-stim_times 3 '1D: 10' 'WAV(0,0.5,2,30,0.5,1)'	\
 | 1dplot -thick -sepscl -stdin -xlabel Time -ynames WAV WAV2 WAV3




3dDeconvolve -nodata 100 1.0 -num_stimts 3 -polort -1	\
-local_times -x1D stdout:	\
-stim_times 1 '1D: 10' 'WAV(0,0.5,2.5,4,0.5,1)'	\
-stim_times 2 '1D: 10' 'WAV(0,10,10,4,0.5,1)'	\
-stim_times 3 '1D: 10' 'WAV(0,10,10,30,0.5,1)'	\
 | 1dplot -thick -sep -stdin -xlabel Time -ynames WAV WAV01010 WAV0101030
