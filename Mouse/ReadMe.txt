#================================================================================
# Directory Name: MouseHunger
#         Author: Kyle Reese Almryde
#           Host: Hagar@128.196.62.95
#           Date: 11/18/2013
#
#        Project: Mouse Hunger
#             PI: Ben Renquist
#          Grant: RENQUIST_STARTUP 2101670
#
#    Description: This study attempts to model deactivation of insulin signaling
#                 in mice which have been genetically modified to be susceptible
#                 to a ligate transmitted via an engineered virus....
#
#       Contents: /Volumes/
#          Tools: AFNI for data reconstruction and preprocessing
#                 FSL/GIFT for ICA analysis
#
#  Current State: Data Collection (11/18/2013 - )
#
#================================================================================

HISTORY:

Today is 11/6/2013
    Spent 4 hours working through mouse fMRI parameters and dealing with a faulty
    phase-array coil, collected some data, but at this point it is all but junk

Today is 11/18/2013
    Collected our first set of images. After 6 hrs of tuning and tweaking, I think
    we have something to work with. The order of scanning and protocols used for each is as follows:


    -----------------------------------------------------------------
    1: Localizer - Tripilot_RARE
    2: EPI localizer - EPI128_4shots_200khz, 1 repetition
    3: EPI Baseline - EPI128_4shots_200khz, 100 repetition

    # Mouse was removed from scanner, injected with treatment solution,
    # returned to scanner after about 5 minutes

    4: Localizer - Tripilot_RARE
    5: EPI Localizer - EPI128_4shots_200khz, 1 repetition
    6: EPI Treatment - EPI128_4shots_200khz, 500 repetition
    7: Anatomical - RARE_8_bas


    Image parameter details
    -------------------------
    =================
    || EPI details ||
    =================
    FOV=2.56 cm   1.28 cm?
    Slice Thickness = 0.50 mm
    Inter-slice Distance = 0.50 mm
    Number of Slices = 15
    Orientation = Axial (coronal)
    Repetition Time = 1200.0 ms
    TE effective 1 = 21.0 ms
    Number of Repetitions = {1, 100, 500}  # localizer, baseline, treatment

    ==================
    || RARE details ||
    ==================
    FOV=2.56 cm  1.28 cm?
    Slice Thickness = 0.50 mm
    Inter-slice Distance = 0.50 mm
    Number of Slice = 23
    Orientation = Axial (coronal)


    Associative Data files, NOTE: Only files necessary for analysis are listed
    ---------------------------------------------------------------------------
    EPI Baseline -- 100 reps, Baseline-1.1_Renquist_11-18-2013__E3_P1_2
    EPI Treatment -- 500 reps, Baseline-1.1_Renquist_11-18-2013__E6_P1_2
    RARE Anatomical -- Baseline-1.1_Renquist_11-18-2013__E7_P1_2



Today is 11/26/2013
    Collected our second set of pilot data. This was a female mouse whom treatment
    was administered via a catheter. One dataset was collected, the other dataset
    was unintentionally over anesthetized and died.

    =================
    || EPI details ||
    =================
    FOV=2.56 cm
    Slice Thickness = 0.50 mm
    Inter-slice Distance = 0.50 mm
    Number of Slices = 19
    Orientation = Axial (coronal)
    Repetition Time = 1500.0 ms
    Number of Repetitions = {10, 200, 700}  # localizer, baseline, treatment

    ==================
    || RARE details ||
    ==================
    FOV=2.56 cm
    Slice Thickness = 0.50 mm
    Inter-slice Distance = 0.50 mm
    Number of Slice = 19
    Orientation = Axial (coronal)

    RARE Anatomical -- Pilot2.1_Renquist_11-27-2013__E5_P1_2
    EPI Localizer -- Pilot2.1_Renquist_11-27-2013__E6_P1_2
    EPI Baseline -- Pilot2.1_Renquist_11-27-2013__E7_P1_2
    EPI Treatment -- Pilot2.1_Renquist_11-27-2013__E8_P1_2

    ====================
    || Treatment Notes||
    ====================
    @ TR 13 treatment was applied
    @ TR 53 treatment was finished
    Treatment began 20secs into scan:: 13 TRs into the scan
    Treatment finished application at 1 min, 4secs



    ============================================================================
    Preprocessing
    -------------
    For details on the scripts used, see scripts in folder:
        /usr/local/utilities/Mouse

