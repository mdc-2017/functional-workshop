#!/bin/bash
. ~/.bashrc

# Change directory to the model results folder
cd /Volumes/psych-cog/dsnlab/MDC/functional-workshop/results/AFNI

# Specify 3dLME model
# AFNI documentation https://afni.nimh.nih.gov/pub/dist/doc/program_help/3dLME.html
# Every line in the model must be followed by '\'
#	- prefix = model name
#	- jobs = number of parallel processors
#	- model = model formula
#	- resid = residual file name 
#	- ranEff = random effects, 1 = intercept
#	- SS_type = sum of squares type, 3 = marginal
#	- qVars = quantitative variables
#	- qVars = centering values for quantitative variables
#	- mask = binarized group-level mask
#	- num_glt = number of contrasts (i.e. general linear tests)
#	- gltLabel k = contrast label for contrast k
#	- gltCode k = contrast code for contrast k
#	- datatable = data structure with a header

3dLME -prefix age_3TsExclusions \
	-jobs 8 \
	-model  "target*domain*age_c+target*domain*age_c2" \
	-resid	age_3TsExclusions_residuals	\
	-ranEff "~1+age_c" \
	-SS_type 3 \
	-qVars "age_c,age_c2" \
	-qVarCenters "0,0" \
	-mask /Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/RX_mask/groupAverage_opt.nii \
	-num_glt 9 \
	-gltLabel 1 'self-other' -gltCode  1 'target : 1*self -1*other' \
	-gltLabel 2 'social-academic' -gltCode  2 'domain : 1*social -1*academic' \
	-gltLabel 3 'self-other.social-academic' -gltCode  3 'target : 1*self -1*other domain : 1*social -1*academic' \
	-gltLabel 4 'social_self-other' -gltCode  4 'target : 1*self -1*other domain : 1*social' \
	-gltLabel 5 'academic_self-other' -gltCode  5 'target : 1*self -1*other domain : 1*academic' \
	-gltLabel 6 'age.self-other' -gltCode  6 'target : 1*self -1*other age_c : ' \
	-gltLabel 7 'age2.self-other' -gltCode  7 'target : 1*self -1*other age_c2 : ' \
	-gltLabel 8 'age.self-other.social-academic' -gltCode  8 'target : 1*self -1*other domain : 1*social -1*academic age_c : ' \
	-gltLabel 9 'age2.self-other.social-academic' -gltCode  9 'target : 1*self -1*other domain : 1*social -1*academic age_c2 : ' \
	-dataTable \
	Subj	target	domain	age_c	age_c2	InputFile \
	s005	self	academic	-3.091915563	9.55994184872161	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s005_t1_con_0001.nii \
	s005	self	social	-3.091915563	9.55994184872161	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s005_t1_con_0002.nii \
	s005	other	academic	-3.091915563	9.55994184872161	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s005_t1_con_0003.nii \
	s005	other	social	-3.091915563	9.55994184872161	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s005_t1_con_0004.nii \
	s005	self	academic	-0.0273972600000008	0.000750609855507641	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s005_t2_con_0001.nii \
	s005	self	social	-0.0273972600000008	0.000750609855507641	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s005_t2_con_0002.nii \
	s005	other	academic	-0.0273972600000008	0.000750609855507641	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s005_t2_con_0003.nii \
	s005	other	social	-0.0273972600000008	0.000750609855507641	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s005_t2_con_0004.nii \
	s005	self	academic	3.66027397	13.3976055354596	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s005_t3_con_0001.nii \
	s005	self	social	3.66027397	13.3976055354596	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s005_t3_con_0002.nii \
	s005	other	academic	3.66027397	13.3976055354596	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s005_t3_con_0003.nii \
	s005	other	social	3.66027397	13.3976055354596	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s005_t3_con_0004.nii \
	s016	self	academic	-2.50819672	6.29105078621876	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s016_t1_con_0001.nii \
	s016	self	social	-2.50819672	6.29105078621876	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s016_t1_con_0002.nii \
	s016	other	academic	-2.50819672	6.29105078621876	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s016_t1_con_0003.nii \
	s016	other	social	-2.50819672	6.29105078621876	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s016_t1_con_0004.nii \
	s016	self	academic	-0.416438360000001	0.17342090767949	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s016_t2_con_0001.nii \
	s016	self	social	-0.416438360000001	0.17342090767949	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s016_t2_con_0002.nii \
	s016	other	academic	-0.416438360000001	0.17342090767949	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s016_t2_con_0003.nii \
	s016	other	social	-0.416438360000001	0.17342090767949	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s016_t2_con_0004.nii \
	s016	self	academic	3.66027397	13.3976055354596	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s016_t3_con_0001.nii \
	s016	self	social	3.66027397	13.3976055354596	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s016_t3_con_0002.nii \
	s016	other	academic	3.66027397	13.3976055354596	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s016_t3_con_0003.nii \
	s016	other	social	3.66027397	13.3976055354596	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s016_t3_con_0004.nii \
	s018	self	academic	-3.187858373	10.1624410063062	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s018_t1_con_0001.nii \
	s018	self	social	-3.187858373	10.1624410063062	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s018_t1_con_0002.nii \
	s018	other	academic	-3.187858373	10.1624410063062	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s018_t1_con_0003.nii \
	s018	other	social	-3.187858373	10.1624410063062	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s018_t1_con_0004.nii \
	s018	self	academic	0.10136986	0.0102758485164196	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s018_t2_con_0001.nii \
	s018	self	social	0.10136986	0.0102758485164196	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s018_t2_con_0002.nii \
	s018	other	academic	0.10136986	0.0102758485164196	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s018_t2_con_0003.nii \
	s018	other	social	0.10136986	0.0102758485164196	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s018_t2_con_0004.nii \
	s018	self	academic	3.46027397	11.9734959474596	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s018_t3_con_0001.nii \
	s018	self	social	3.46027397	11.9734959474596	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s018_t3_con_0002.nii \
	s018	other	academic	3.46027397	11.9734959474596	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s018_t3_con_0003.nii \
	s018	other	social	3.46027397	11.9734959474596	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s018_t3_con_0004.nii \
	s019	self	academic	-2.7431694	7.52497835709636	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s019_t1_con_0001.nii \
	s019	self	social	-2.7431694	7.52497835709636	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s019_t1_con_0002.nii \
	s019	other	academic	-2.7431694	7.52497835709636	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s019_t1_con_0003.nii \
	s019	other	social	-2.7431694	7.52497835709636	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s019_t1_con_0004.nii \
	s019	self	academic	0.0465753400000004	0.00216926229611564	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s019_t2_con_0001.nii \
	s019	self	social	0.0465753400000004	0.00216926229611564	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s019_t2_con_0002.nii \
	s019	other	academic	0.0465753400000004	0.00216926229611564	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s019_t2_con_0003.nii \
	s019	other	social	0.0465753400000004	0.00216926229611564	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s019_t2_con_0004.nii \
	s019	self	academic	3.53150685	12.4715406315969	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s019_t3_con_0001.nii \
	s019	self	social	3.53150685	12.4715406315969	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s019_t3_con_0002.nii \
	s019	other	academic	3.53150685	12.4715406315969	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s019_t3_con_0003.nii \
	s019	other	social	3.53150685	12.4715406315969	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s019_t3_con_0004.nii \
	s022	self	academic	-3.215607456	10.3401313110828	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s022_t1_con_0001.nii \
	s022	self	social	-3.215607456	10.3401313110828	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s022_t1_con_0002.nii \
	s022	other	academic	-3.215607456	10.3401313110828	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s022_t1_con_0003.nii \
	s022	other	social	-3.215607456	10.3401313110828	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s022_t1_con_0004.nii \
	s022	self	academic	-0.394520549999999	0.155646464372302	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s022_t2_con_0001.nii \
	s022	self	social	-0.394520549999999	0.155646464372302	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s022_t2_con_0002.nii \
	s022	other	academic	-0.394520549999999	0.155646464372302	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s022_t2_con_0003.nii \
	s022	other	social	-0.394520549999999	0.155646464372302	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s022_t2_con_0004.nii \
	s022	self	academic	2.93150685	8.59373241159692	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s022_t3_con_0001.nii \
	s022	self	social	2.93150685	8.59373241159692	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s022_t3_con_0002.nii \
	s022	other	academic	2.93150685	8.59373241159692	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s022_t3_con_0003.nii \
	s022	other	social	2.93150685	8.59373241159692	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s022_t3_con_0004.nii \
	s023	self	academic	-3.292274871	10.8390738262181	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s023_t1_con_0001.nii \
	s023	self	social	-3.292274871	10.8390738262181	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s023_t1_con_0002.nii \
	s023	other	academic	-3.292274871	10.8390738262181	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s023_t1_con_0003.nii \
	s023	other	social	-3.292274871	10.8390738262181	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s023_t1_con_0004.nii \
	s023	self	academic	-0.197260269999999	0.0389116141204726	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s023_t2_con_0001.nii \
	s023	self	social	-0.197260269999999	0.0389116141204726	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s023_t2_con_0002.nii \
	s023	other	academic	-0.197260269999999	0.0389116141204726	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s023_t2_con_0003.nii \
	s023	other	social	-0.197260269999999	0.0389116141204726	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s023_t2_con_0004.nii \
	s023	self	academic	2.92054795	8.5296003282492	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s023_t3_con_0001.nii \
	s023	self	social	2.92054795	8.5296003282492	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s023_t3_con_0002.nii \
	s023	other	academic	2.92054795	8.5296003282492	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s023_t3_con_0003.nii \
	s023	other	social	2.92054795	8.5296003282492	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s023_t3_con_0004.nii \
	s024	self	academic	-3.144419492	9.88737394166954	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s024_t1_con_0001.nii \
	s024	self	social	-3.144419492	9.88737394166954	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s024_t1_con_0002.nii \
	s024	other	academic	-3.144419492	9.88737394166954	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s024_t1_con_0003.nii \
	s024	other	social	-3.144419492	9.88737394166954	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s024_t1_con_0004.nii \
	s024	self	academic	0.683449359999999	0.467103027684408	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s024_t2_con_0001.nii \
	s024	self	social	0.683449359999999	0.467103027684408	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s024_t2_con_0002.nii \
	s024	other	academic	0.683449359999999	0.467103027684408	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s024_t2_con_0003.nii \
	s024	other	social	0.683449359999999	0.467103027684408	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s024_t2_con_0004.nii \
	s024	self	academic	3.43561644	11.8034603227983	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s024_t3_con_0001.nii \
	s024	self	social	3.43561644	11.8034603227983	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s024_t3_con_0002.nii \
	s024	other	academic	3.43561644	11.8034603227983	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s024_t3_con_0003.nii \
	s024	other	social	3.43561644	11.8034603227983	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s024_t3_con_0004.nii \
	s029	self	academic	-2.93989071	8.64295738674431	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s029_t1_con_0001.nii \
	s029	self	social	-2.93989071	8.64295738674431	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s029_t1_con_0002.nii \
	s029	other	academic	-2.93989071	8.64295738674431	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s029_t1_con_0003.nii \
	s029	other	social	-2.93989071	8.64295738674431	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s029_t1_con_0004.nii \
	s029	self	academic	-0.0794520500000004	0.00631262824920257	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s029_t2_con_0001.nii \
	s029	self	social	-0.0794520500000004	0.00631262824920257	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s029_t2_con_0002.nii \
	s029	other	academic	-0.0794520500000004	0.00631262824920257	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s029_t2_con_0003.nii \
	s029	other	social	-0.0794520500000004	0.00631262824920257	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s029_t2_con_0004.nii \
	s029	self	academic	3.29863014	10.8809608005164	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s029_t3_con_0001.nii \
	s029	self	social	3.29863014	10.8809608005164	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s029_t3_con_0002.nii \
	s029	other	academic	3.29863014	10.8809608005164	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s029_t3_con_0003.nii \
	s029	other	social	3.29863014	10.8809608005164	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s029_t3_con_0004.nii \
	s030	self	academic	-3.513661202	12.3458150424401	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s030_t1_con_0001.nii \
	s030	self	social	-3.513661202	12.3458150424401	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s030_t1_con_0002.nii \
	s030	other	academic	-3.513661202	12.3458150424401	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s030_t1_con_0003.nii \
	s030	other	social	-3.513661202	12.3458150424401	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s030_t1_con_0004.nii \
	s030	self	academic	0.177595630000001	0.0315402077950972	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s030_t2_con_0001.nii \
	s030	self	social	0.177595630000001	0.0315402077950972	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s030_t2_con_0002.nii \
	s030	other	academic	0.177595630000001	0.0315402077950972	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s030_t2_con_0003.nii \
	s030	other	social	0.177595630000001	0.0315402077950972	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s030_t2_con_0004.nii \
	s030	self	academic	3.24109589	10.5047025681749	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s030_t3_con_0001.nii \
	s030	self	social	3.24109589	10.5047025681749	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s030_t3_con_0002.nii \
	s030	other	academic	3.24109589	10.5047025681749	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s030_t3_con_0003.nii \
	s030	other	social	3.24109589	10.5047025681749	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s030_t3_con_0004.nii \
	s032	self	academic	-3.459016393	11.9647944070427	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s032_t1_con_0001.nii \
	s032	self	social	-3.459016393	11.9647944070427	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s032_t1_con_0002.nii \
	s032	other	academic	-3.459016393	11.9647944070427	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s032_t1_con_0003.nii \
	s032	other	social	-3.459016393	11.9647944070427	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s032_t1_con_0004.nii \
	s032	self	academic	0.18852459	0.0355415210346681	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s032_t2_con_0001.nii \
	s032	self	social	0.18852459	0.0355415210346681	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s032_t2_con_0002.nii \
	s032	other	academic	0.18852459	0.0355415210346681	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s032_t2_con_0003.nii \
	s032	other	social	0.18852459	0.0355415210346681	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s032_t2_con_0004.nii \
	s032	self	academic	1.89863014	3.60479640851642	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s032_t3_con_0001.nii \
	s032	self	social	1.89863014	3.60479640851642	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s032_t3_con_0002.nii \
	s032	other	academic	1.89863014	3.60479640851642	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s032_t3_con_0003.nii \
	s032	other	social	1.89863014	3.60479640851642	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s032_t3_con_0004.nii \
	s035	self	academic	-3.210382514	10.306555886197	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s035_t1_con_0001.nii \
	s035	self	social	-3.210382514	10.306555886197	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s035_t1_con_0002.nii \
	s035	other	academic	-3.210382514	10.306555886197	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s035_t1_con_0003.nii \
	s035	other	social	-3.210382514	10.306555886197	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s035_t1_con_0004.nii \
	s035	self	academic	-0.252054790000001	0.0635316171619445	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s035_t2_con_0001.nii \
	s035	self	social	-0.252054790000001	0.0635316171619445	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s035_t2_con_0002.nii \
	s035	other	academic	-0.252054790000001	0.0635316171619445	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s035_t2_con_0003.nii \
	s035	other	social	-0.252054790000001	0.0635316171619445	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s035_t2_con_0004.nii \
	s035	self	academic	2.79452055	7.8093451043723	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s035_t3_con_0001.nii \
	s035	self	social	2.79452055	7.8093451043723	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s035_t3_con_0002.nii \
	s035	other	academic	2.79452055	7.8093451043723	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s035_t3_con_0003.nii \
	s035	other	social	2.79452055	7.8093451043723	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s035_t3_con_0004.nii \
	s038	self	academic	-2.44535519	5.97976200525994	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s038_t1_con_0001.nii \
	s038	self	social	-2.44535519	5.97976200525994	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s038_t1_con_0002.nii \
	s038	other	academic	-2.44535519	5.97976200525994	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s038_t1_con_0003.nii \
	s038	other	social	-2.44535519	5.97976200525994	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s038_t1_con_0004.nii \
	s038	self	academic	0.265753419999999	0.0706248802416961	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s038_t2_con_0001.nii \
	s038	self	social	0.265753419999999	0.0706248802416961	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s038_t2_con_0002.nii \
	s038	other	academic	0.265753419999999	0.0706248802416961	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s038_t2_con_0003.nii \
	s038	other	social	0.265753419999999	0.0706248802416961	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s038_t2_con_0004.nii \
	s038	self	academic	4.24931507	18.0566785641291	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s038_t3_con_0001.nii \
	s038	self	social	4.24931507	18.0566785641291	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s038_t3_con_0002.nii \
	s038	other	academic	4.24931507	18.0566785641291	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s038_t3_con_0003.nii \
	s038	other	social	4.24931507	18.0566785641291	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s038_t3_con_0004.nii \
	s040	self	academic	-3.167123288	10.0306699213919	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s040_t1_con_0001.nii \
	s040	self	social	-3.167123288	10.0306699213919	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s040_t1_con_0002.nii \
	s040	other	academic	-3.167123288	10.0306699213919	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s040_t1_con_0003.nii \
	s040	other	social	-3.167123288	10.0306699213919	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s040_t1_con_0004.nii \
	s040	self	academic	-0.36712329	0.134779510060424	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s040_t2_con_0001.nii \
	s040	self	social	-0.36712329	0.134779510060424	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s040_t2_con_0002.nii \
	s040	other	academic	-0.36712329	0.134779510060424	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s040_t2_con_0003.nii \
	s040	other	social	-0.36712329	0.134779510060424	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s040_t2_con_0004.nii \
	s040	self	academic	2.79726027	7.82466501812048	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s040_t3_con_0001.nii \
	s040	self	social	2.79726027	7.82466501812048	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s040_t3_con_0002.nii \
	s040	other	academic	2.79726027	7.82466501812048	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s040_t3_con_0003.nii \
	s040	other	social	2.79726027	7.82466501812048	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s040_t3_con_0004.nii \
	s042	self	academic	-2.72876712	7.4461699951931	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s042_t1_con_0001.nii \
	s042	self	social	-2.72876712	7.4461699951931	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s042_t1_con_0002.nii \
	s042	other	academic	-2.72876712	7.4461699951931	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s042_t1_con_0003.nii \
	s042	other	social	-2.72876712	7.4461699951931	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s042_t1_con_0004.nii \
	s042	self	academic	0.0136986300000004	0.00018765246387691	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s042_t2_con_0001.nii \
	s042	self	social	0.0136986300000004	0.00018765246387691	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s042_t2_con_0002.nii \
	s042	other	academic	0.0136986300000004	0.00018765246387691	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s042_t2_con_0003.nii \
	s042	other	social	0.0136986300000004	0.00018765246387691	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s042_t2_con_0004.nii \
	s042	self	academic	3.44931507	11.8977744521291	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s042_t3_con_0001.nii \
	s042	self	social	3.44931507	11.8977744521291	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s042_t3_con_0002.nii \
	s042	other	academic	3.44931507	11.8977744521291	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s042_t3_con_0003.nii \
	s042	other	social	3.44931507	11.8977744521291	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s042_t3_con_0004.nii \
	s045	self	academic	-3.229508197	10.4297231944902	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s045_t1_con_0001.nii \
	s045	self	social	-3.229508197	10.4297231944902	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s045_t1_con_0002.nii \
	s045	other	academic	-3.229508197	10.4297231944902	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s045_t1_con_0003.nii \
	s045	other	social	-3.229508197	10.4297231944902	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s045_t1_con_0004.nii \
	s045	self	academic	-0.194528030000001	0.0378411544556812	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s045_t2_con_0001.nii \
	s045	self	social	-0.194528030000001	0.0378411544556812	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s045_t2_con_0002.nii \
	s045	other	academic	-0.194528030000001	0.0378411544556812	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s045_t2_con_0003.nii \
	s045	other	social	-0.194528030000001	0.0378411544556812	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s045_t2_con_0004.nii \
	s045	self	academic	3.04383562	9.26493528158078	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s045_t3_con_0001.nii \
	s045	self	social	3.04383562	9.26493528158078	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s045_t3_con_0002.nii \
	s045	other	academic	3.04383562	9.26493528158078	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s045_t3_con_0003.nii \
	s045	other	social	3.04383562	9.26493528158078	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s045_t3_con_0004.nii \
	s058	self	academic	-2.50410959	6.27056483872997	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s058_t1_con_0001.nii \
	s058	self	social	-2.50410959	6.27056483872997	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s058_t1_con_0002.nii \
	s058	other	academic	-2.50410959	6.27056483872997	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s058_t1_con_0003.nii \
	s058	other	social	-2.50410959	6.27056483872997	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s058_t1_con_0004.nii \
	s058	self	academic	0.0191780799999997	0.000367798752486387	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s058_t2_con_0001.nii \
	s058	self	social	0.0191780799999997	0.000367798752486387	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s058_t2_con_0002.nii \
	s058	other	academic	0.0191780799999997	0.000367798752486387	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s058_t2_con_0003.nii \
	s058	other	social	0.0191780799999997	0.000367798752486387	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s058_t2_con_0004.nii \
	s058	self	academic	4.15068493	17.2281853881291	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s058_t3_con_0001.nii \
	s058	self	social	4.15068493	17.2281853881291	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s058_t3_con_0002.nii \
	s058	other	academic	4.15068493	17.2281853881291	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s058_t3_con_0003.nii \
	s058	other	social	4.15068493	17.2281853881291	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s058_t3_con_0004.nii \
	s064	self	academic	-3.189041096	10.1699831119769	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s064_t1_con_0001.nii \
	s064	self	social	-3.189041096	10.1699831119769	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s064_t1_con_0002.nii \
	s064	other	academic	-3.189041096	10.1699831119769	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s064_t1_con_0003.nii \
	s064	other	social	-3.189041096	10.1699831119769	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s064_t1_con_0004.nii \
	s064	self	academic	0.323287669999999	0.104514917574028	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s064_t2_con_0001.nii \
	s064	self	social	0.323287669999999	0.104514917574028	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s064_t2_con_0002.nii \
	s064	other	academic	0.323287669999999	0.104514917574028	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s064_t2_con_0003.nii \
	s064	other	social	0.323287669999999	0.104514917574028	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s064_t2_con_0004.nii \
	s064	self	academic	3.82874467	14.6592857480534	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s064_t3_con_0001.nii \
	s064	self	social	3.82874467	14.6592857480534	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s064_t3_con_0002.nii \
	s064	other	academic	3.82874467	14.6592857480534	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s064_t3_con_0003.nii \
	s064	other	social	3.82874467	14.6592857480534	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s064_t3_con_0004.nii \
	s065	self	academic	-2.44657534	5.98573089429612	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s065_t1_con_0001.nii \
	s065	self	social	-2.44657534	5.98573089429612	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s065_t1_con_0002.nii \
	s065	other	academic	-2.44657534	5.98573089429612	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s065_t1_con_0003.nii \
	s065	other	social	-2.44657534	5.98573089429612	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s065_t1_con_0004.nii \
	s065	self	academic	-0.21643836	0.0468455636794895	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s065_t2_con_0001.nii \
	s065	self	social	-0.21643836	0.0468455636794895	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s065_t2_con_0002.nii \
	s065	other	academic	-0.21643836	0.0468455636794895	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s065_t2_con_0003.nii \
	s065	other	social	-0.21643836	0.0468455636794895	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s065_t2_con_0004.nii \
	s065	self	academic	3.32876712	11.0806905391931	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s065_t3_con_0001.nii \
	s065	self	social	3.32876712	11.0806905391931	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s065_t3_con_0002.nii \
	s065	other	academic	3.32876712	11.0806905391931	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s065_t3_con_0003.nii \
	s065	other	social	3.32876712	11.0806905391931	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s065_t3_con_0004.nii \
	s072	self	academic	-2.53424658	6.42240572824169	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s072_t1_con_0001.nii \
	s072	self	social	-2.53424658	6.42240572824169	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s072_t1_con_0002.nii \
	s072	other	academic	-2.53424658	6.42240572824169	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s072_t1_con_0003.nii \
	s072	other	social	-2.53424658	6.42240572824169	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s072_t1_con_0004.nii \
	s072	self	academic	-0.38630137	0.149228748463877	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s072_t2_con_0001.nii \
	s072	self	social	-0.38630137	0.149228748463877	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s072_t2_con_0002.nii \
	s072	other	academic	-0.38630137	0.149228748463877	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s072_t2_con_0003.nii \
	s072	other	social	-0.38630137	0.149228748463877	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s072_t2_con_0004.nii \
	s072	self	academic	2.90684932	8.44977296918446	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s072_t3_con_0001.nii \
	s072	self	social	2.90684932	8.44977296918446	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s072_t3_con_0002.nii \
	s072	other	academic	2.90684932	8.44977296918446	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s072_t3_con_0003.nii \
	s072	other	social	2.90684932	8.44977296918446	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s072_t3_con_0004.nii \
	s073	self	academic	-2.87671233	8.27547382957403	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s073_t1_con_0001.nii \
	s073	self	social	-2.87671233	8.27547382957403	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s073_t1_con_0002.nii \
	s073	other	academic	-2.87671233	8.27547382957403	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s073_t1_con_0003.nii \
	s073	other	social	-2.87671233	8.27547382957403	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s073_t1_con_0004.nii \
	s073	self	academic	0.11202186	0.0125488971178597	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s073_t2_con_0001.nii \
	s073	self	social	0.11202186	0.0125488971178597	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s073_t2_con_0002.nii \
	s073	other	academic	0.11202186	0.0125488971178597	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s073_t2_con_0003.nii \
	s073	other	social	0.11202186	0.0125488971178597	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s073_t2_con_0004.nii \
	s073	self	academic	3.05479452	9.33176955942204	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s073_t3_con_0001.nii \
	s073	self	social	3.05479452	9.33176955942204	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s073_t3_con_0002.nii \
	s073	other	academic	3.05479452	9.33176955942204	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s073_t3_con_0003.nii \
	s073	other	social	3.05479452	9.33176955942204	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s073_t3_con_0004.nii \
	s081	self	academic	-2.75890411	7.61155188817489	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s081_t1_con_0001.nii \
	s081	self	social	-2.75890411	7.61155188817489	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s081_t1_con_0002.nii \
	s081	other	academic	-2.75890411	7.61155188817489	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s081_t1_con_0003.nii \
	s081	other	social	-2.75890411	7.61155188817489	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s081_t1_con_0004.nii \
	s081	self	academic	-0.638356160000001	0.407498587009947	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s081_t2_con_0001.nii \
	s081	self	social	-0.638356160000001	0.407498587009947	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s081_t2_con_0002.nii \
	s081	other	academic	-0.638356160000001	0.407498587009947	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s081_t2_con_0003.nii \
	s081	other	social	-0.638356160000001	0.407498587009947	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s081_t2_con_0004.nii \
	s081	self	academic	2.7260274	7.43122538555076	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s081_t3_con_0001.nii \
	s081	self	social	2.7260274	7.43122538555076	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s081_t3_con_0002.nii \
	s081	other	academic	2.7260274	7.43122538555076	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s081_t3_con_0003.nii \
	s081	other	social	2.7260274	7.43122538555076	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s081_t3_con_0004.nii \
	s089	self	academic	-2.80547945	7.8707149443723	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s089_t1_con_0001.nii \
	s089	self	social	-2.80547945	7.8707149443723	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s089_t1_con_0002.nii \
	s089	other	academic	-2.80547945	7.8707149443723	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s089_t1_con_0003.nii \
	s089	other	social	-2.80547945	7.8707149443723	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s089_t1_con_0004.nii \
	s089	self	academic	0.163934429999999	0.0268744973394247	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s089_t2_con_0001.nii \
	s089	self	social	0.163934429999999	0.0268744973394247	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s089_t2_con_0002.nii \
	s089	other	academic	0.163934429999999	0.0268744973394247	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s089_t2_con_0003.nii \
	s089	other	social	0.163934429999999	0.0268744973394247	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s089_t2_con_0004.nii \
	s089	self	academic	3.54718168	12.5824978709276	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s089_t3_con_0001.nii \
	s089	self	social	3.54718168	12.5824978709276	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s089_t3_con_0002.nii \
	s089	other	academic	3.54718168	12.5824978709276	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s089_t3_con_0003.nii \
	s089	other	social	3.54718168	12.5824978709276	/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s089_t3_con_0004.nii \