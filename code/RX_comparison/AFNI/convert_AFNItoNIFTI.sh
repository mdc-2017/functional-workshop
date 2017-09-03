#!/bin/bash
. ~/.bashrc

# Define path to AFNI results directory, model names, and contrast numbers
# ------------------------------------------------------------------------------------------
resultsDir=/Volumes/psych-cog/dsnlab/MDC/functional-workshop/results/AFNI
thresholdedDir=/Volumes/psych-cog/dsnlab/MDC/functional-workshop/results/thresholdedMaps
models=(3Ts all)
selfOther=13
age_selfOther=23
age2_selfOther=25

# Convert AFNI contrasts to nifti files
# ------------------------------------------------------------------------------------------
# AFNI documentation https://afni.nimh.nih.gov/pub/dist/doc/program_help/3dAFNItoNIFTI.html
for model in  "${models[@]}" ; do
	3dAFNItoNIFTI -prefix "${resultsDir}"/self-other_"${model}" "${resultsDir}"/"${model}"+tlrc["${selfOther}"]
	3dAFNItoNIFTI -prefix "${resultsDir}"/age.self-other_"${model}" "${resultsDir}"/"${model}"+tlrc["${age_selfOther}"]
	3dAFNItoNIFTI -prefix "${resultsDir}"/age2.self-other_"${model}" "${resultsDir}"/"${model}"+tlrc["${age2_selfOther}"]
done
