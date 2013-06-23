#!/bin/bash
#================================================================================
#    Program Name: rus1_3dd.sh
#          Author: Kyle Reese Almryde
#            Date: 02/25/2013 @ 17:04:23 PM
#
#     Description: This script runs a deconvolution on the provided EVENT timing
#                  information. 3dDeconvolve will check the design matrix for
#                  collinearity and construct a matrix based on the convolved
#                  wave-forms. 1dplot will produce a pretty picture to look at.
#
#================================================================================
#                                UGLY DETAILS
#================================================================================
#
# TR = 3.00 seconds
# number of conditions = 4 (sF1, sF2, sM1, sM2)
# total number of repetitions = 120 (30 per condition, excluding nulls)
# Total TRs = 140 (120 events, 15 nulls, 5 tail events)
#================================================================================
#                                START OF MAIN
#================================================================================


3dDeconvolve                            \
    -nodata 420 1.000                   \
    -polort A                           \
    -num_stimts 5                       \
    -stim_times 1 rus2_sF1.1D WAV    \
    -stim_label 1 sF1                   \
    -stim_times 2 rus2_sF2.1D WAV    \
    -stim_label 2 sF2                   \
    -stim_times 3 rus2_sM1.1D WAV    \
    -stim_label 3 sM1                   \
    -stim_times 4 rus2_sM2.1D WAV    \
    -stim_label 4 sM2                   \
    -stim_times 5 rus2_NULL.1D WAV    \
    -stim_label 5 null                   \
    -x1D rus2.xmat.1D


1dplot -thick -sepscl -xlabel Time \
-ynames sF1 sF2 sM1 sM2 NULL \
-censor_RGB \#000 -CENSORTR 0-1 \
-censor_RGB red -CENSORTR 3-4 \
-censor_RGB \#000 -CENSORTR 6-7 \
-censor_RGB green -CENSORTR 9-10 \
-censor_RGB green -CENSORTR 12-13 \
-censor_RGB blue -CENSORTR 15-16 \
-censor_RGB \#000 -CENSORTR 18-19 \
-censor_RGB red -CENSORTR 21-22 \
-censor_RGB red -CENSORTR 24-25 \
-censor_RGB green -CENSORTR 27-28 \
-censor_RGB blue -CENSORTR 30-31 \
-censor_RGB purple -CENSORTR 33-34 \
-censor_RGB red -CENSORTR 36-37 \
-censor_RGB green -CENSORTR 39-40 \
-censor_RGB purple -CENSORTR 42-43 \
-censor_RGB purple -CENSORTR 45-46 \
-censor_RGB red -CENSORTR 48-49 \
-censor_RGB green -CENSORTR 51-52 \
-censor_RGB green -CENSORTR 54-55 \
-censor_RGB \#000 -CENSORTR 57-58 \
-censor_RGB blue -CENSORTR 60-61 \
-censor_RGB red -CENSORTR 63-64 \
-censor_RGB purple -CENSORTR 66-67 \
-censor_RGB green -CENSORTR 69-70 \
-censor_RGB purple -CENSORTR 72-73 \
-censor_RGB red -CENSORTR 75-76 \
-censor_RGB blue -CENSORTR 78-79 \
-censor_RGB red -CENSORTR 81-82 \
-censor_RGB \#000 -CENSORTR 84-85 \
-censor_RGB \#000 -CENSORTR 87-88 \
-censor_RGB \#000 -CENSORTR 90-91 \
-censor_RGB green -CENSORTR 93-94 \
-censor_RGB green -CENSORTR 96-97 \
-censor_RGB \#000 -CENSORTR 99-100 \
-censor_RGB blue -CENSORTR 102-103 \
-censor_RGB blue -CENSORTR 105-106 \
-censor_RGB purple -CENSORTR 108-109 \
-censor_RGB blue -CENSORTR 111-112 \
-censor_RGB purple -CENSORTR 114-115 \
-censor_RGB \#000 -CENSORTR 117-118 \
-censor_RGB blue -CENSORTR 120-121 \
-censor_RGB blue -CENSORTR 123-124 \
-censor_RGB green -CENSORTR 126-127 \
-censor_RGB green -CENSORTR 129-130 \
-censor_RGB red -CENSORTR 132-133 \
-censor_RGB red -CENSORTR 135-136 \
-censor_RGB blue -CENSORTR 138-139 \
-censor_RGB \#000 -CENSORTR 141-142 \
-censor_RGB red -CENSORTR 144-145 \
-censor_RGB blue -CENSORTR 147-148 \
-censor_RGB purple -CENSORTR 150-151 \
-censor_RGB \#000 -CENSORTR 153-154 \
-censor_RGB green -CENSORTR 156-157 \
-censor_RGB red -CENSORTR 159-160 \
-censor_RGB red -CENSORTR 162-163 \
-censor_RGB green -CENSORTR 165-166 \
-censor_RGB \#000 -CENSORTR 168-169 \
-censor_RGB blue -CENSORTR 171-172 \
-censor_RGB red -CENSORTR 174-175 \
-censor_RGB \#000 -CENSORTR 177-178 \
-censor_RGB green -CENSORTR 180-181 \
-censor_RGB green -CENSORTR 183-184 \
-censor_RGB red -CENSORTR 186-187 \
-censor_RGB red -CENSORTR 189-190 \
-censor_RGB red -CENSORTR 192-193 \
-censor_RGB blue -CENSORTR 195-196 \
-censor_RGB green -CENSORTR 198-199 \
-censor_RGB \#000 -CENSORTR 201-202 \
-censor_RGB blue -CENSORTR 204-205 \
-censor_RGB \#000 -CENSORTR 207-208 \
-censor_RGB \#000 -CENSORTR 210-211 \
-censor_RGB red -CENSORTR 213-214 \
-censor_RGB blue -CENSORTR 216-217 \
-censor_RGB blue -CENSORTR 219-220 \
-censor_RGB blue -CENSORTR 222-223 \
-censor_RGB blue -CENSORTR 225-226 \
-censor_RGB \#000 -CENSORTR 228-229 \
-censor_RGB \#000 -CENSORTR 231-232 \
-censor_RGB blue -CENSORTR 234-235 \
-censor_RGB red -CENSORTR 237-238 \
-censor_RGB \#000 -CENSORTR 240-241 \
-censor_RGB green -CENSORTR 243-244 \
-censor_RGB blue -CENSORTR 246-247 \
-censor_RGB green -CENSORTR 249-250 \
-censor_RGB purple -CENSORTR 252-253 \
-censor_RGB \#000 -CENSORTR 255-256 \
-censor_RGB \#000 -CENSORTR 258-259 \
-censor_RGB blue -CENSORTR 261-262 \
-censor_RGB \#000 -CENSORTR 264-265 \
-censor_RGB green -CENSORTR 267-268 \
-censor_RGB red -CENSORTR 270-271 \
-censor_RGB blue -CENSORTR 273-274 \
-censor_RGB \#000 -CENSORTR 276-277 \
-censor_RGB green -CENSORTR 279-280 \
-censor_RGB \#000 -CENSORTR 282-283 \
-censor_RGB \#000 -CENSORTR 285-286 \
-censor_RGB green -CENSORTR 288-289 \
-censor_RGB blue -CENSORTR 291-292 \
-censor_RGB purple -CENSORTR 294-295 \
-censor_RGB blue -CENSORTR 297-298 \
-censor_RGB red -CENSORTR 300-301 \
-censor_RGB green -CENSORTR 303-304 \
-censor_RGB green -CENSORTR 306-307 \
-censor_RGB blue -CENSORTR 309-310 \
-censor_RGB \#000 -CENSORTR 312-313 \
-censor_RGB \#000 -CENSORTR 315-316 \
-censor_RGB blue -CENSORTR 318-319 \
-censor_RGB purple -CENSORTR 321-322 \
-censor_RGB red -CENSORTR 324-325 \
-censor_RGB red -CENSORTR 327-328 \
-censor_RGB \#000 -CENSORTR 330-331 \
-censor_RGB purple -CENSORTR 333-334 \
-censor_RGB green -CENSORTR 336-337 \
-censor_RGB green -CENSORTR 339-340 \
-censor_RGB purple -CENSORTR 342-343 \
-censor_RGB blue -CENSORTR 345-346 \
-censor_RGB purple -CENSORTR 348-349 \
-censor_RGB green -CENSORTR 351-352 \
-censor_RGB blue -CENSORTR 354-355 \
-censor_RGB red -CENSORTR 357-358 \
-censor_RGB \#000 -CENSORTR 360-361 \
-censor_RGB green -CENSORTR 363-364 \
-censor_RGB \#000 -CENSORTR 366-367 \
-censor_RGB red -CENSORTR 369-370 \
-censor_RGB blue -CENSORTR 372-373 \
-censor_RGB red -CENSORTR 375-376 \
-censor_RGB red -CENSORTR 378-379 \
-censor_RGB red -CENSORTR 381-382 \
-censor_RGB blue -CENSORTR 384-385 \
-censor_RGB purple -CENSORTR 387-388 \
-censor_RGB red -CENSORTR 390-391 \
-censor_RGB red -CENSORTR 393-394 \
-censor_RGB green -CENSORTR 396-397 \
-censor_RGB green -CENSORTR 399-400 \
-censor_RGB green -CENSORTR 402-403 \
    rus2.xmat.1D'[4..$]'















