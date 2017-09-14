#!/bin/bash
. ~/.bashrc

# This script extracts mean parameter estimates and SDs within an ROI or parcel
# from subject FX condition contrasts (condition > rest) for each wave. Output is 
# saved as a text file in the output directory.

# Set paths and variables
# ------------------------------------------------------------------------------------------
# paths

con_dir='/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models' #fx contrast directory
atlas_dir='/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/ROIs' #roi/parcellation atlas directory 
output_dir='/Volumes/psych-cog/dsnlab/MDC/functional-workshop/results/ROI_analysis' #roi/parcellation output directory
rx_model='/Volumes/psych-cog/dsnlab/MDC/functional-workshop/results/AFNI/all+tlrc' #rx model (for atlas alignment only)

# variables
subjects=`cat /Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/subject_list.txt`
parcellation_atlas=(craddock_all.nii.gz) #roi/parcellation atlas file
parcellation_map=(31) #parcellation map number (if applicable)
aligned_parcellation_map=(aligned_craddock_400) #aligned roi/parcellation map name
aligned_parcellation_num=(116 292) #parcellation number(s) to extract from; use $(seq 1 N) where N is the total number of parcels to extract from all
waves=(t1 t2 t3) #waves or task names
fx_cons=(con_0001 con_0002 con_0003 con_0004) #fx con files to extract from

if [ ! -f $output_dir/parameterEstimates.txt ]; then
	# Align roi/parcellation map to data
	# ------------------------------------------------------------------------------------------
	echo "aligning parcellation map"
	if [ -f $atlas_dir/${aligned_parcellation_map}+tlrc.BRIK ]; then
		echo "aligned parcellation map already exists"
	else 
	3dAllineate -source $atlas_dir/$parcellation_atlas[$parcellation_map] -master $rx_model -final NN -1Dparam_apply '1D: 12@0'\' -prefix $atlas_dir/$aligned_parcellation_map
	fi

	# Extract mean parameter estimates and SDs for each subject, wave, contrast, and roi/parcel
	# ------------------------------------------------------------------------------------------

	for sub in ${subjects[@]}; do 
		for wave in ${waves[@]}; do 
			for con in ${fx_cons[@]}; do 
				for num in ${aligned_parcellation_num[@]}; do 
					echo ${sub} ${wave} ${con} ${num} `3dmaskave -sigma -quiet -mrange $num $num -mask $atlas_dir/${aligned_parcellation_map}+tlrc $con_dir/${sub}_${wave}_${con}.nii` >> $output_dir/parameterEstimates.txt
				done
			done
		done
	done
else
	echo "parameterEstimates.txt already exists"
fi