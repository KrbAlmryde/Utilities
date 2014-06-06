#================================================================================
# Directory Name: MousefMRI
#         Author: Kyle Reese Almryde
#           Host: Hagar@128.196.62.95
#           Date: 4/18/2014
#
#        Project: Mouse Hunger
#             PI: Ben Renquist
#          Grant: RENQUIST_STARTUP 2101670
#
#    Description: This project is a continuation and 'restart' of the original Mouse.
#                 This study attempts to model deactivation of insulin signaling
#                 in mice which have been genetically modified to be susceptible
#                 to a ligate transmitted via an engineered virus....
#
#       Contents: /Volumes/
#          Tools: AFNI for data reconstruction and preprocessing
#                 FSL/GIFT for ICA analysis
#  Current State:
#
#================================================================================

HISTORY:

Today is 4/18/2014

     Repetition Time: 6000 ms  # Or 6 secs
Numer of Repetitions: 100
Duration of Scanning: 10 minutes
       Design Matrix: O->Air: 60000ms, 
                      X->Carbogen: 60000ms 
                      O-X-O-X-O-X-O-X-O-X


-20 slices for the whole brain volume per time point, 
-100 time points, 6 seconds per time point
-10 minutes total scanning, alternating air and carbogen each minute
-2000 total slices for all time points (20x100)
-registration may be necessary because the brain seems to slowly "settle" for the 10 minute period. 






