#!/bin/bash
. ~/.bashrc

# Run 3dClustSim for each model 
3dClustSim -mask 3Ts+tlrc[0] -acf 0.547571  4.47963  12.7493 > /Volumes/psych-cog/dsnlab/MDC/functional-workshop/code/thresholding/output/3dClustStim_results_AFNI_3Ts.txt

3dClustSim -mask all+tlrc[0] -acf 0.54998  4.47062  12.9177 > /Volumes/psych-cog/dsnlab/MDC/functional-workshop/code/thresholding/output/3dClustStim_results_AFNI_all.txt

3dClustSim -mask mask.nii -acf 0.549495 4.82387 13.24054 > /Volumes/psych-cog/dsnlab/MDC/functional-workshop/code/thresholding/output/3dClustStim_results_SPM.txt