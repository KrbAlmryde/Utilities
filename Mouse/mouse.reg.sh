#!/bin/bash
#================================================================================
#    Program Name: mouse.reg.sh
#          Author: Kyle Reese Almryde
#            Date: 1/8/2014
#
#     Description: This script performs reconstruction and preprocessing of the
#                  functional Mouse data for the MouseHunger project.
#                  This script assumes there is a $subj.profile file in each
#                  subject's directory which contains information about the
#                  location of raw files to be reconstructed, the number of
#                  slices, and number of repetitions (if applicable).
#
#                  The profile also contains meta information about the mouse
#                  (if applicable) and any additional information about the
#                  scan in question (such as date, time of injection, etc)
#
#    Deficiencies: None, this program meets specifications
#
#================================================================================
#                            FUNCTION DEFINITIONS
#================================================================================

function buildAnat() {
    subj=$1
    dir=$ORIG/$2

    cd ${dir}
    to3d -fse \
        -prefix $subj.rare.nii \
        -xSLAB 12.70L-R \
        -ySLAB 12.70S-I \
        -zSLAB 5.50P-A \
        MRIm*
    mv $subj.rare.nii $PREP/.
}

function buildEPI() {
    subj=$1
    run=$2
    dir=$ORIG/$3
    nSlices=$4
    nReps=$5
    tr=$6

    cd ${dir}
    to3d -epan \
        -prefix $subj.$run.nii \
        -text_outliers \
        -save_outliers $subj.$run.outs.txt \
        -xSLAB 12.70L-R \
        -ySLAB 12.70S-I \
        -zSLAB 5.50A-P \
        -time:zt $nSlices $nReps $tr seqplus 'MRIm*'

    mv $subj.$run.* $PREP/.
}


function build_struc2stand() {
    #------------------------------------------------------------------------
    #       Function    align_struc2stand
    #------------------------------------------------------------------------

    local subj
    local STRUC

    subj=$1
    STRUC=/Volumes/Data/TAP/${subj}/Struc

    if [[ ! -e ${STRUC}/${subj}.spgr.standard+tlrc.HEAD ]]; then

        cd ${STRUC}

        align_epi_anat.py \
            -dset1to2 -cmass cmass \
            -dset1 m001.rare.nii \
            -dset2 m001.rare.nii \
            -cost lpa -suffix .cmass

        3dSkullStrip \
            -input ${subj}.spgr.cmass.nii \
            -prefix ${subj}.spgr.standard

        @auto_tlrc \
            -no_ss -suffix NONE \
            -base TT_N27+tlrc \
            -input ${subj}.spgr.standard.nii

        3drefit -anat ${subj}.spgr.standard+tlrc

    else

        echo "${subj}.spgr.standard+tlrc.HEAD already exists!!"

    fi
}



function build_groupStruc() {
    #------------------------------------------------------------------------
    #       Function    build_groupStruc
    #------------------------------------------------------------------------

    local subj i max
    local STRUC ANAT

    max=${#subj_list[*]}
    ANAT=/Volumes/Data/TAP/ANAT

    # remove old anatomical buckets, if they exist.
    if [[ ${ANAT}/TT_tap*.anat.*+tlrc.HEAD != TT_tap${max}.*+tlrc.HEAD ]]; then

        rm TT_tap*.anat.*+tlrc.HEAD
        rm TT_tap*.anat.*+tlrc.BRIK

    fi


    # iterate over each subject, adding each anatomical image to a group bucket
    for (( i = 0; i < ${#subj_list[*]}; i++ )); do

        subj=${subj_list[$i]}
        STRUC=/Volumes/Data/TAP/${subj}/Struc

        if [[ ! -e ${ANAT}/TT_tap${max}.anat.stand+tlrc ]]; then

            # construct the bucket file containing each subjects standard spgr
            3dbucket \
                -aglueto ${ANAT}/TT_tap${max}.anat.stand+tlrc \
                ${STRUC}/${subj}.spgr.standard+tlrc

            # construct the bucket file containing each subjects fse
            3dbucket \
                -aglueto ${ANAT}/TT_tap${max}.anat.fse+orig \
                ${STRUC}/${subj}.fse+orig

            # label each subbrik of the spgr bucket with the appropriate subject number
            3drefit \
                -sublabel $i ${subj} \
                ${ANAT}/TT_tap${max}.anat.stand+tlrc

            # Do the same for the fse bucket
            3drefit \
                -sublabel $i ${subj} \
                ${ANAT}/TT_tap${max}.anat.fse+orig
        fi

    done

    # create a group averaged anatomical image to use are the template
    3dTstat \
        -mean -median -stdev \
        -prefix ${ANAT}/TT_tap${max}.anat.stats \
        ${ANAT}/TT_tap${max}.anat.stand+tlrc

}

#============================================================
#                Base registration
#============================================================

function base_reg() {
    inFile=$1
    # echo -e "\nFind Base Volume! input File is $inFile\n"
    3dToutcount $inFile.nii \
    | cat -n \
    | sort -k2,2n \
    | head -1 \
    | awk '{print $1-1}'
}


function qtCheck() {
    dir=$1
    prev=`pwd`
    cd $dir
    outFiles=(`ls *.{tshift,volreg,scale,$run}.nii`)

    for file in ${outFiles[*]}; do
        file=${file%.nii}
        echo -e "\nEstimating image quality for $file\n"
        3dToutcount $file.nii | 1dplot -jpeg $file.outs -stdin
        3dTqual -range $file.nii | 1dplot -jpeg $file.qual -one -stdin
    done
    cd $prev
}

#============================================================
#                Slice-timing correction
#============================================================

function tcat() {

    echo -e "\nVolume Concatenation!"
    3dTcat \
        -verb \
        -prefix $subj.$run.tcat.nii \
        $subj.$run.epan.nii'[20..$]'
}

#============================================================
#                Slice-timing correction
#============================================================

function tshift() {

    inFile=$1
    echo -e "\nVolume Temporal Shift! input File is $inFile\n"
    local outFile=$inFile.tshift

    3dTshift \
        -verbose \
        -tzero 0 \
        -prefix $outFile.nii \
        $inFile.nii
}

#============================================================
#                Despiking
#============================================================

function despike() {

    inFile=$1
    echo -e "\nVolume Despike! input File is $inFile\n"
    local outFile=$inFile.despike

    3dDespike \
        -prefix $outFile.nii \
        -ssave $outFile.spikes.nii \
        $inFile.nii
}


#============================================================
#                Volume Registration
#============================================================

function volreg() {

    inFile=$1
    local outFile=$inFile.volreg
    baseVol=$(base_reg $inFile)

    if [[ $baseVol -le 100000000000000 ]]; then
        extractBase $inFile $baseVol

       echo -e "\nVolume Registration! input File is $inFile\n"
        3dvolreg -zpad 4 \
            -verbose \
            -base $inFile.nii[$baseVol] \
            -1Dfile $outFile.dfile.1D \
            -maxdisp1D  ${outFile}.mm.1D \
            -prefix $outFile.nii \
            -Fourier $inFile.nii                     # Read input dataset
                                                    # Generate graph of realignment
        1dplot -jpeg \
            $outFile \
            -volreg \
            -xlabel TIME $outFile.dfile.1D

        echo "base volume = $baseVol" > $subj.$run.baseVol.txt
    else
        echo "There was an error, Base Volume not computed, exiting..."
        exit
    fi
}




#============================================================
#                Extract Base Volume
#============================================================

function extractBase() {

    inFile=$1
    baseVol=$2

    if [[ -z $baseVol ]]; then
        baseVol=$(base_reg $inFile)
    fi

    local outFile=$inFile.BaseVolReg$baseVol
    echo -e "\nExtract Base Volume ${baseVol}! input File is $inFile\n"

    3dbucket \
        -prefix $outFile.nii \
        -fbuc $inFile.nii[$baseVol]

    echo $baseVol
}




#============================================================
#                Masking
#============================================================

function mask() {

    inFile=$1
    echo -e "\nMask Volume Dataset! input File is $inFile\n"
    local outFile=$inFile
    baseVolFile=$(ls *.BaseVolReg*)

    3dAutomask \
        -dilate 1 \
        -prefix $outFile.automask.nii \
        $baseVolFile


    3dMean \
        -datum short \
        -prefix rm.mean.nii \
        $outFile.automask.nii


    3dcalc \
        -a rm.mean.nii \
        -expr 'ispositive(a-0)' \
        -prefix $outFile.fullmask.nii


    3dTstat \
        -prefix rm.$outFile.mean.nii \
        $inFile.nii


    rm rm.mean.nii
}


#============================================================
#                Scaling
#============================================================

function scale() {

    inFile=$1
    echo -e "\nScale Volume Dataset! input File is $inFile\n"
    local outFile=$inFile.scale

    mask $inFile

    if [[ ! -f $inFile.fullmask.edit.nii ]]; then
        MaskFile=fullmask
    else
        MaskFile=fullmask.edit
    fi


    3dcalc \
        -verbose \
        -float \
        -a $inFile.nii \
        -b rm.$inFile.mean.nii \
        -c $inFile.$MaskFile.nii \
        -expr 'c * min(200, a/b*100)' \
        -prefix $outFile.nii

    rm rm.$inFile.mean.nii
    cp $inFile.nii $GIFT/$run/.
    cp $outFile.nii $GIFT/$run/.

}


#============================================================
#                Main Functions
#============================================================

function main_reconstruct() {
    subj=$1
    source $BASE/${subj}/$subj.profile
    buildAnat $subj $rawRare
    buildEPI $subj base $rawBase $numSlices $numRepsBase $funcTR
    buildEPI $subj treat $rawTreat $numSlices $numRepsTreat $funcTR

} # End of main_reconstruct



function main_preprocessing() {
    subj=$1
    for run in {base,treat}; do
        cd $PREP
        tshift $subj.$run
        # despike $subj.$run.tshift
        # volreg $subj.$run.tshift.despike
        volreg $subj.$run.tshift
        scale $subj.$run.tshift.volreg
        qtCheck $PREP
    done

} # End of main_preprocessing


#============================================================
#                Reset Functions
#============================================================

function main_reset() {
    subj=$1
    proc=$2
    if [[ -z $proc ]]; then
        echo "which step would you like to reset?: [all, prep, tcat, despike...] "
        read proc
    fi

    case $proc in
        all )
            rm $PREP/$subj.*
            rm $STATS/$subj.*
            rm $GIFT/{base,treat}/*
        ;;

        prep )
            rm $PREP/$subj.*.{outs,tshift,despike,volreg,scale,mean,fullmask}.*
            rm $PREP/$subj.*.{txt,jpg}
            rm $STATS/$subj.*.{scale,}.*
        ;;
    esac
}


#================================================================================
#                                START OF MAIN
#================================================================================

step=$1
proc=$2

if [[ -z $step ]]; then
    echo -n "Which step in the analysis? [recon, prep]"
    read step
fi

BASE=/Volumes/Data/MouseHunger
GIFT=${BASE}/Gift

for subj in m00{1..7}; do

    ORIG=${BASE}/${subj}/Orig
    PREP=${BASE}/${subj}/Prep
    STATS=${BASE}/${subj}/Stats

    case $step in
        recon )
            main_reconstruct $subj
        ;;

        prep )
            main_preprocessing $subj
        ;;

        reset )
            main_reset $subj $proc
        ;;

        * )
            echo "$step is not a valid option! Exiting..."
        ;;
    esac

done
