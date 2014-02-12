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
    local outFiles=(`ls *.{tshift,volreg,scale,tstat,$run,fold}.nii`)

    for file in ${outFiles[*]}; do
        file=${file%.nii}
        echo -e "\nEstimating image quality for $file\n"
        3dToutcount $file.nii | 1dplot -jpeg $file.outs -stdin
        3dTqual -range $file.nii | 1dplot -jpeg $file.qual -one -stdin
    done
    mkdir -p Images
    mv *.{1D,jpg} Images/
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
    if [[ ! -f $outFile.nii ]]; then
        3dTshift \
            -verbose \
            -tzero 0 \
            -prefix $outFile.nii \
            $inFile.nii
    else
        echo "$outFile.nii already exists, skipping..."
    fi
}

#============================================================
#                Despiking
#============================================================

function despike() {

    local inFile=$1
    local outFile=$inFile.despike
    echo -e "\nVolume Despike! input File is $inFile\n"

    3dDespike \
        -prefix $outFile.nii \
        -ssave $outFile.spikes.nii \
        $inFile.nii
}


#============================================================
#                Volume Registration
#============================================================

function volreg() {

    local inFile=$1
    local outFile=$inFile.volreg
    baseVol=$(base_reg $inFile)
    if [[ ! -f $outFile.nii ]]; then
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
    else
        echo "$outFile.nii already exists, skipping..."
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

    if [[ ! -f $outFile.nii ]]; then
        3dbucket \
            -prefix $outFile.nii \
            -fbuc $inFile.nii[$baseVol]

        echo $baseVol
    else
        echo "$outFile.nii already exists, skipping..."
    fi
}

#============================================================
#                Masking
#============================================================

function mask() {

    inFile=$1
    echo -e "\nMask Volume Dataset! input File is $inFile\n"
    local outFile=$inFile
    baseVolFile=$(ls *.BaseVolReg*)

    if [[ -f $outFile.fullmask.nii ]]; then
        echo "fullmask exists, skipping"
    else
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

        rm rm.mean.nii
    fi

}

#============================================================
#                Folding Average
#============================================================

function foldingAverage() {
    #------------------------------------------------------------------------
    #
    #  Purpose: Main function to run the script
    #
    #
    #    Input:
    #
    #   Output:
    #
    #------------------------------------------------------------------------

    local inFile=$1
    local outFile=$inFile
    local run=`echo $inFile | cut -d . -f 2`
    if [[ $run -eq "base" ]]; then
        local limit=200
    else
        local limit=700
    fi

    for (( i = 0, j = 49 ; j < $limit; i+=25, j+=25 )); do
        3dtstat -mean -prefix __.${inFile}.${i}-${j}.nii  "$inFile.nii[${i}..${j}]"
        # 3dbucket -fbuc -aglueto $image.span+orig __.${inFile}.${i}-${j}.nii[0]

        if [[ $i -eq 0 ]]; then
            3dtcat -relabel -tr 1.5 -prefix __.$outFile.fold+orig __.${inFile}.${i}-${j}.nii
            i=`echo $i - 1 | bc`
        else
            3dtcat -relabel -tr 1.5  -glueto __.$outFile.fold+orig __.${inFile}.${i}-${j}.nii
        fi
    done
    3dAFNItoNIFTI -prefix $outFile.fold.nii __.$outFile.fold+orig
    # rm __.${subj}.*

} # End of foldingAverage

#============================================================
#                Tstats
#============================================================

function tstat() {
    local inFile=$1
    local outFile=$inFile
    rm *{automask,mean}*
    echo -e "\nGetting Volume average!"

    3dTstat \
        -prefix $outFile.tstat.nii \
        $inFile.nii
}

#============================================================
#                Scaling
#============================================================

function scale() {

    inFile=$1
    echo -e "\nScale Volume Dataset! input File is $inFile\n"
    local outFile=$inFile.fold.scale

    if [[ ! -f $inFile.fullmask.edit.nii ]]; then
        MaskFile=fullmask
    else
        MaskFile=fullmask.edit
    fi

    tstat $inFile

    3dcalc \
        -verbose \
        -float \
        -a $inFile.nii \
        -b $inFile.tstat.nii \
        -c $inFile.$MaskFile.nii \
        -expr 'c * min(200, a/b*100)' \
        -prefix $outFile.nii


    case $run in
        treat )
            cp $inFile.nii $GIFT/Treatment/Registered/$subj
            cp $outFile.nii $GIFT/Treatment/Scaled/$subj
            cp $inFile.$MaskFile.nii $GIFT/Treatment/Registered/$subj
            cp $inFile.$MaskFile.nii $GIFT/Treatment/Scaled/$subj
            ;;
        base )
            cp $inFile.nii $GIFT/Baseline/Registered/$subj
            cp $outFile.nii $GIFT/Baseline/Scaled/$subj
            cp $inFile.$MaskFile.nii $GIFT/Baseline/Registered/$subj
            cp $inFile.$MaskFile.nii $GIFT/Baseline/Scaled/$subj
            ;;
    esac

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
        volreg $subj.$run.tshift
        mask $subj.$run.tshift.volreg
        foldingAverage $subj.$run.tshift.volreg
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
            rm $PREP/$subj.*.tshift.nii
            rm $PREP/$subj.*.tshift.BaseVolReg*.nii
            rm $PREP/$subj.*.volreg.nii
            rm $PREP/$subj.*.scale.nii
            rm $PREP/$subj.*.tstat.nii
            rm $PREP/$subj.*.fold.nii
            rm $PREP/__.*
            rm $PREP/Images/$subj.*.{txt,jpg,1D}
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

for subj in m00{5,6}; do

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

        scale )
            main_scale $subj
        ;;

        reset )
            main_reset $subj $proc
        ;;

        * )
            echo "$step is not a valid option! Exiting..."
        ;;
    esac

done
