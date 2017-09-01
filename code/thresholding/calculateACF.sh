#!/bin/bash
. ~/.bashrc

# This script calculates the smoothness (acf parameters) of each SPM residual files 
# using 3dFWHMx in AFNI and averages across all files by executing calculateACF.R
# The average acf parameters will be saved as SPM_acf.txt in the code directory.

# specify thresholding code directory
codeDir=/Volumes/psych-cog/dsnlab/MDC/functional-workshop/code/thresholding

# specify SPM RX directory (where the residual files are)
rxDir=/Volumes/psych-cog/dsnlab/MDC/functional-workshop/results/SPM

# estimate acf parameters for per subject and save this output to a log file
cd "${rxDir}"

for i in Res_*; do 
	j=${i:0:8}
	3dFWHMx -acf -mask mask.nii $i >> residuals.txt
done

# execute calculateACF.R
Rscript "${codeDir}"/calculateACF.R "${rxDir}"/residuals.txt > "${codeDir}"/output/SPM_acf.txt
