# make_random_timing.py \
#     -tr 3.0 \
#     -num_runs 1 \
#     -run_time 432 \
#     -num_stim 8 \
#     -num_reps 29 \
#     -stim_dur 0.5 \
#     -stim_labels sF1 sF2 sM1 sM2 dF1 dF2 dM1 dM2 \
#     -max_rest 1 \
#     -prefix rus1 \
#     -post_stim_rest 12.0 \
#     -show_timing_stats
#     # -save_3dd_cmd rus1_3dd.sh

# bash rus1_3dd.sh



make_random_timing.py \
    -tr 2.0 \
    -num_runs 1 \
    -run_time 432 \
    -num_stim 8 \
    -num_reps 29 \
    -stim_dur 0.5 \
    -stim_labels sF1 sF2 sM1 sM2 dF1 dF2 dM1 dM2 \
    -prefix rus2 \
    -post_stim_rest 12.0 \
    -show_timing_stats \
    -save_3dd_cmd rus2_3dd.sh

bash rus2_3dd.sh