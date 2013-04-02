case $1 in
      "learn" )
                clusterFiles=(
                    c1_cm_c4_cm_c69_cm_learn_IC2_s1_p_gm_l_t_thr_t_manual_t.nii.gz
                    c5_cm_c1_cm_c64_cm_learn_IC2_s2_p_gm_l_t_thr_t_manual_t.nii.gz
                    c1_cm_c3_cm_c80_cm_learn_IC2_s3_p_gm_l_t_thr_t_manual_t.nii.gz
                    c4_cm_c2_cm_c36_cm_learn_IC7_s1_p_gm_r_t_thr_t_manual_t.nii.gz
                    c4_cm_c1_cm_c49_cm_learn_IC7_s2_p_gm_r_t_thr_t_manual_t.nii.gz
                    c2_cm_c1_cm_c42_cm_learn_IC7_s3_p_gm_r_t_thr_t_manual_t.nii.gz
                    c1_cm_c1_cm_c55_cm_learn_IC25_s1_p_gm_l_t_thr_t_manual_t.nii.gz
                    c1_cm_c1_cm_c56_cm_learn_IC25_s1_p_gm_r_t_thr_t_manual_t.nii.gz
                    c1_cm_c2_cm_c58_cm_learn_IC25_s1_p_gm_l_t_thr_t_manual_t.nii.gz
                    c2_cm_c2_cm_c58_cm_learn_IC25_s1_p_gm_l_t_thr_t_manual_t.nii.gz
                    c1_cm_c1_cm_c50_cm_learn_IC25_s2_p_gm_r_t_thr_t_manual_t.nii.gz
                    c2_cm_c3_cm_c53_cm_learn_IC25_s2_p_gm_l_t_thr_t_manual_t.nii.gz
                    c6_cm_c4_cm_c53_cm_learn_IC25_s2_p_gm_l_t_thr_t_manual_t.nii.gz
                    c9_cm_c4_cm_c53_cm_learn_IC25_s2_p_gm_l_t_thr_t_manual_t.nii.gz
                    c1_cm_c1_cm_c45_cm_learn_IC25_s3_p_gm_l_t_thr_t_manual_t.nii.gz
                    c1_cm_c1_cm_c46_cm_learn_IC25_s3_p_gm_r_t_thr_t_manual_t.nii.gz
                    c3_cm_c1_cm_c47_cm_learn_IC25_s3_p_gm_l_t_thr_t_manual_t.nii.gz
                    c9_cm_c8_cm_c49_cm_learn_IC25_s3_p_gm_l_t_thr_t_manual_t.nii.gz
                    c1_cm_c1_cm_c30_cm_learn_IC31_s1_p_gm_r_t_thr_t_manual_t.nii.gz
                    c1_cm_c2_cm_c25_cm_learn_IC31_s1_p_gm_r_t_thr_t_manual_t.nii.gz
                    c2_cm_c3_cm_c26_cm_learn_IC31_s1_p_gm_l_t_thr_t_manual_t.nii.gz
                    c5_cm_c3_cm_c28_cm_learn_IC31_s1_p_gm_r_t_thr_t_manual_t.nii.gz
                    c6_cm_c5_cm_c29_cm_learn_IC31_s1_p_gm_l_t_thr_t_manual_t.nii.gz
                    c7_cm_c3_cm_c28_cm_learn_IC31_s1_p_gm_r_t_thr_t_manual_t.nii.gz
                    c1_cm_c1_cm_c31_cm_learn_IC31_s2_p_gm_r_t_thr_t_manual_t.nii.gz
                    c1_cm_c1_cm_c32_cm_learn_IC31_s2_p_gm_r_t_thr_t_manual_t.nii.gz
                    c1_cm_c1_cm_c35_cm_learn_IC31_s2_p_gm_l_t_thr_t_manual_t.nii.gz
                    c1_cm_c1_cm_c38_cm_learn_IC31_s2_p_gm_r_t_thr_t_manual_t.nii.gz
                    c3_cm_c2_cm_c32_cm_learn_IC31_s2_p_gm_r_t_thr_t_manual_t.nii.gz
                    c4_cm_c2_cm_c34_cm_learn_IC31_s2_p_gm_l_t_thr_t_manual_t.nii.gz
                    c6_cm_c1_cm_c40_cm_learn_IC31_s2_p_gm_l_t_thr_t_manual_t.nii.gz
                    c1_cm_c1_cm_c39_cm_learn_IC31_s3_p_gm_l_t_thr_t_manual_t.nii.gz
                    c1_cm_c1_cm_c42_cm_learn_IC31_s3_p_gm_r_t_thr_t_manual_t.nii.gz
                    c1_cm_c2_cm_c38_cm_learn_IC31_s3_p_gm_r_t_thr_t_manual_t.nii.gz
                    c11_cm_c2_cm_c41_cm_learn_IC31_s3_p_gm_l_t_thr_t_manual_t.nii.gz
                    c2_cm_c2_cm_c44_cm_learn_IC31_s3_p_gm_r_t_thr_t_manual_t.nii.gz
                    c6_cm_c3_cm_c40_cm_learn_IC31_s3_p_gm_r_t_thr_t_manual_t.nii.gz
                    c1_cm_c3_cm_c51_cm_learn_IC39_s1_p_gm_r_t_thr_t_manual_t.nii.gz
                    c1_cm_c5_cm_c54_cm_learn_IC39_s1_p_gm_l_t_thr_t_manual_t.nii.gz
                    c3_cm_c2_cm_c52_cm_learn_IC39_s1_p_gm_r_t_thr_t_manual_t.nii.gz
                    c4_cm_c7_cm_c54_cm_learn_IC39_s1_p_gm_l_t_thr_t_manual_t.nii.gz
                    c5_cm_c4_cm_c54_cm_learn_IC39_s1_p_gm_r_t_thr_t_manual_t.nii.gz
                    c1_cm_c1_cm_c50_cm_learn_IC39_s2_p_gm_r_t_thr_t_manual_t.nii.gz
                    c1_cm_c1_cm_c51_cm_learn_IC39_s2_p_gm_r_t_thr_t_manual_t.nii.gz
                    c1_cm_c2_cm_c50_cm_learn_IC39_s2_p_gm_l_t_thr_t_manual_t.nii.gz
                    c2_cm_c1_cm_c54_cm_learn_IC39_s2_p_gm_l_t_thr_t_manual_t.nii.gz
                    c2_cm_c3_cm_c50_cm_learn_IC39_s2_p_gm_l_t_thr_t_manual_t.nii.gz
                    c3_cm_c1_cm_c47_cm_learn_IC39_s2_p_gm_r_t_thr_t_manual_t.nii.gz
                    c1_cm_c1_cm_c59_cm_learn_IC39_s3_p_gm_l_t_thr_t_manual_t.nii.gz
                    c1_cm_c1_cm_c61_cm_learn_IC39_s3_p_gm_r_t_thr_t_manual_t.nii.gz
                    c1_cm_c5_cm_c62_cm_learn_IC39_s3_p_gm_r_t_thr_t_manual_t.nii.gz
                    c1_cm_c6_cm_c62_cm_learn_IC39_s3_p_gm_l_t_thr_t_manual_t.nii.gz
                    c2_cm_c7_cm_c62_cm_learn_IC39_s3_p_gm_l_t_thr_t_manual_t.nii.gz
                    c4_cm_c1_cm_c60_cm_learn_IC39_s3_p_gm_r_t_thr_t_manual_t.nii.gz )
                ;;

    "unlearn" )
                clusterFiles=(
                    c1_cm_c1_cm_c52_cm_unlearn_s1_IC14_p_gm_r_t_thr_t_manual_t.nii.gz
                    c4_cm_c1_cm_c53_cm_unlearn_s1_IC14_p_gm_l_t_thr_t_manual_t.nii.gz
                    c1_cm_c1_cm_c58_cm_unlearn_s2_IC14_p_gm_r_t_thr_t_manual_t.nii.gz
                    c2_cm_c2_cm_c57_cm_unlearn_s2_IC14_p_gm_l_t_thr_t_manual_t.nii.gz
                    c6_cm_c2_cm_c51_cm_unlearn_s3_IC14_p_gm_l_t_thr_t_manual_t.nii.gz )
                ;;
esac

