#!/bin/bash
. ~/.bashrc

# This script calculates the smoothness (acf parameters) of each SPM residual files 
# using 3dFWHMx in AFNI and averages across all files by executing calculateACF.R
# The average acf parameters will be saved as SPM_acf.txt in the code directory.

# It also calculates the acf parameters for the AFNI 3dLME models and saves the 
# parameters to text files in the code directory.

# Specify variables
# ------------------------------------------------------------------------------------------
# thresholding code directory
codeDir=/Volumes/psych-cog/dsnlab/MDC/functional-workshop/code/thresholding

# RX directories (where the residual files are)
spmDir=/Volumes/psych-cog/dsnlab/MDC/functional-workshop/results/SPM
afniDir=/Volumes/psych-cog/dsnlab/MDC/functional-workshop/results/AFNI

# AFNI 3dLME model names
models=(all 3Ts)

# Estimate acf parameters for AFNI 3dLME models and save this output
# ------------------------------------------------------------------------------------------
cd "${afniDir}"

for model in "${models[@]}"; do
	3dFWHMx -acf -mask "${model}"+tlrc[0] "${model}"_residuals+tlrc > "${codeDir}"/output/"${model}"_acf.txt
done

# Estimate acf parameters for per subject and save this output to a log file
# ------------------------------------------------------------------------------------------
cd "${spmDir}"

for i in Res_*; do 
	j=${i:0:8}
	3dFWHMx -acf -mask mask.nii "${i}" >> residuals.txt
done

# Execute calculateACF.R
# ------------------------------------------------------------------------------------------
Rscript "${codeDir}"/calculateACF.R "${spmDir}"/residuals.txt > "${codeDir}"/output/SPM_acf.txt
