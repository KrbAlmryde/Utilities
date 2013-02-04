-- call system notes --


-- A note about Profiles...
   This ->
         foo=(`echo sub0{1..9}` `echo sub{10..20}`)
   is acceptable syntax to create a list of subjects such as the following:
        sub01 sub02 sub03 sub04 sub05 sub06 sub07 sub08 sub09 sub10
        sub11 sub12 sub13 sub14 sub15 sub16 sub17 sub18 sub19 sub20

    Alternatively, This ->
            foo=(`echo sub0{1..9}_run{1..4}`)
    also works to produce a combined list of subject/run combinations:
        sub01_run1 sub01_run2 sub01_run3 sub01_run4
        sub02_run1 sub02_run2 sub02_run3 sub02_run4
        sub03_run1 sub03_run2 sub03_run3 sub03_run4
        sub04_run1 sub04_run2 sub04_run3 sub04_run4
        sub05_run1 sub05_run2 sub05_run3 sub05_run4
        sub06_run1 sub06_run2 sub06_run3 sub06_run4
        sub07_run1 sub07_run2 sub07_run3 sub07_run4
        sub08_run1 sub08_run2 sub08_run3 sub08_run4
        sub09_run1 sub09_run2 sub09_run3 sub09_run4

    Or even This ->
            subID=(`echo sub01_run{1..4}_cond{A..D}`)
    can be used to create subj_run_cond combinations....excellent
    sub01_run1_condA sub01_run1_condB sub01_run1_condC sub01_run1_condD
    sub01_run2_condA sub01_run2_condB sub01_run2_condC sub01_run2_condD
    sub01_run3_condA sub01_run3_condB sub01_run3_condC sub01_run3_condD
    sub01_run4_condA sub01_run4_condB sub01_run4_condC sub01_run4_condD