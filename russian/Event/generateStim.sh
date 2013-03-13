b="==================="
# TR = 2.6 secs
# Stimulus duration = 0.5 secs
# number of events = 8
# number of event reps = 29
# number of stimuli = 232
# Post stimulus delay = 0.5

# 29 single-female1
# 29 single-female2
# 29 double-female1
# 29 double-female2
# 29 sing-e male1
# 29 sing-e male2
# 29 doub-e male1
# 29 doub-e male2

# echo -e "\n$b$b\n\t\tSim1\n$b$b\n"
# make_random_timing.py \
#     -tr 3 \
#     -prefix rus1 \
#     -num_runs 1 \
#     -run_time 600 \
#     -num_stim 8 \
#     -num_reps 29 \
#     -stim_dur 0.5 \
#     -min_rest 0.5 \
#     -max_rest 15 \
#     -show_timing_stats \
#     -stim_labels sF1 sF2 dF1 dF2 sM1 sM2 dM1 dM2 \
#     -show_timing_stats \
#     -save_3dd_cmd rus1_3dd


echo -e "\n$b$b\n\t\tSim1\n$b$b\n"
make_random_timing.py \
    -tr 3 \
    -prefix rus1 \
    -num_runs 1 \
    -run_time 420 \
    -num_stim 4 \
    -num_reps 40 \
    -stim_dur 0.5 \
    -max_rest 1 \
    -show_timing_stats \
    -stim_labels sF1 sF2 sM1 sM2 \
    -show_timing_stats \
    -save_3dd_cmd rus1_3dd

echo -e "\n$b$b\n\t\tTiming Stats\n$b$b\n"
timing_tool.py -multi_timing rus1*.1D -tr 3.0 -show_tr_stats

sleep 10

bash rus1_3dd


# echo -e "\n$b$b\n\t\tSim2\n$b$b\n"
# make_random_timing.py \
#     -prefix rus2 \
#     -run_time 500 \
#     -num_stim 8 \
#     -num_runs 1 \
#     -stim_dur 0.5 \
#     -num_reps 29 \
#     -min_rest 0 \
#     -max_rest 0.5 \
#     -show_timing_stats \
#     -stim_labels sF1 sF2 dF1 dF2 sM1 sM2 dM1 dM2 \
#     -show_timing_stats \
#     -verb 4 \
#     -save_3dd_cmd rus2_3dd

# echo -e "\n$b$b\n\t\tSim2\n$b$b\n"
# RSFgen \
#     -nt 250 \
#     -num_stimts 8 \
#     -nblock 1 1 -nreps 1 29 \
#     -nblock 2 1 -nreps 2 29 \
#     -nblock 3 1 -nreps 3 29 \
#     -nblock 4 1 -nreps 4 29 \
#     -nblock 5 1 -nreps 5 29 \
#     -nblock 6 1 -nreps 6 29 \
#     -nblock 7 1 -nreps 7 29 \
#     -nblock 8 1 -nreps 8 29 \
#     -one_file \
#     -prefix rus1_rsfgen

# echo -e "\n$b$b\n\t\tSim2\n$b$b\n"

# optseq2 \
#     --ntp 180 \
#     --tr 3    \
#     --psdwin 0 20 \
#     --ev sF1 1.5 29 \
#     --ev sF2 1.5 29 \
#     --ev dF1 1.5 29 \
#     --ev dF2 1.5 29 \
#     --ev sM1 1.5 29 \
#     --ev sM2 1.5 29 \
#     --ev dM1 1.5 29 \
#     --ev dM2 1.5 29 \
#     --nkeep 3 \
#     --o rus1 \
#     --nsearch 10000

# echo -e "\n$b$b\n\t\tSim4\n$b$b\n"

# optseq2 \
#     --ntp 250 \
#     --tr 2   \
#     --psdwin 0 18 \
#     --ev sF1 3 29 \
#     --ev sF2 3 29 \
#     --ev dF1 3 29 \
#     --ev dF2 3 29 \
#     --ev sM1 3 29 \
#     --ev sM2 3 29 \
#     --ev dM1 3 29 \
#     --ev dM2 3 29 \
#     --nkeep 3 \
#     --o rus2 \
#     --nsearch 10000


# optseq2 \
#     --ntp 70 \
#     --tr 3 \
#     --psdwin 0 18 3 \
#     --ev evt1 3 50 \
#     --nkeep 3 \
#     --o ex1 \
#     --nsearch 2000

# ntp     == number of time points
# tr      == repetition time (duh!)
# psdwin  == post stimulus duration window
# ev _ _  == event duration, repetitions
# nkeep   == the number of 'best' solutions kept
# o       == outfile name
# nsearch == number of iterations per second to perform



# Set params to resemble WB1

# numstim = 232
# tr = 2.0
# stimTrs = 116 => numstim / tr

# total = 140 => 116 +

# optseq2 --ntp 100 --tr 2 \
#         --psdwin 0 20 \
#         --ev evt1 2 30 \
#         --nkeep 3 \
#         --o ex1 \
#         --nsearch 10000

# optseq2 --ntp 60 --tr 2 \
#         --psdwin 0 20 \
#         --ev evt1 2 30 \
#         --nkeep 3 \
#         --o ex1.1 \
#         --nsearch 10000

# optseq2 --ntp 90 --tr 2 \
#         --psdwin 0 20 \
#         --ev evt1 2 30 \
#         --nkeep 3 \
#         --o ex1.2 \
#         --nsearch 10000


# optseq2 --ntp 120 --tr 2.5 \
#         --psdwin 0 25 2.5\
#         --ev evt1 2.5 20 \
#         --ev evt2 5.0 10 \
#         --ev evt3 7.5 15 \
#         --nkeep 3 \
#         --o ex2 \
#         --nsearch 1000

