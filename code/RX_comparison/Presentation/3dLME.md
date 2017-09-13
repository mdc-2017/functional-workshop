-   [Make 3dLME data table](#make-3dlme-data-table)
    -   [load packages](#load-packages)
    -   [load data](#load-data)
    -   [tidy data](#tidy-data)
    -   [exclude subjects based on motion and number of
        timepoints](#exclude-subjects-based-on-motion-and-number-of-timepoints)
    -   [merge data](#merge-data)
    -   [write files](#write-files)
-   [Make 3dLME bash script](#make-3dlme-bash-script)
    -   [Specify model](#specify-model)
    -   [Specify contrasts (glts)](#specify-contrasts-glts)
    -   [Specify data table (input files
        and design)](#specify-data-table-input-files-and-design)
    -   [Complete model](#complete-model)
-   [Run 3dLME model](#run-3dlme-model)
    -   [Dependencies](#dependencies)
    -   [Run model](#run-model)
        -   [1. In the terminal, the contents of the directory that
            holds that 3dLME bash
            script](#in-the-terminal-the-contents-of-the-directory-that-holds-that-3dlme-bash-script)
        -   [2. Change directories to the directory with `3dLME_all.sh`
            and execute the script. Pipe the output to
            `logs/3dLME_all.txt` and errors to
            `logs/3dLME_all_error.txt`](#change-directories-to-the-directory-with-3dlme_all.sh-and-execute-the-script.-pipe-the-output-to-logs3dlme_all.txt-and-errors-to-logs3dlme_all_error.txt)
        -   [3. Wait a while for the model to finish
            running](#wait-a-while-for-the-model-to-finish-running)
        -   [4. Check output file](#check-output-file)
        -   [5. Check results files in the output
            directory](#check-results-files-in-the-output-directory)
-   [View results in AFNI](#view-results-in-afni)
    -   [1. Open AFNI GUI](#open-afni-gui)
    -   [2. Select overlay by clicking on `Overlay` and choosing the
        model labeled
        `all`](#select-overlay-by-clicking-on-overlay-and-choosing-the-model-labeled-all)
    -   [3. Select contrast by clicking on `Olay` and `Thr` and
        selecting `self-other Z`
        in each.](#select-contrast-by-clicking-on-olay-and-thr-and-selecting-self-other-z-in-each.)
    -   [4. Select the p-value by right-clicking on
        `p=`](#select-the-p-value-by-right-clicking-on-p)
    -   [5. Select cluster forming threshold by clicking on
        `Clusterize`](#select-cluster-forming-threshold-by-clicking-on-clusterize)
-   [Convert AFNI files to nifti
    files](#convert-afni-files-to-nifti-files)
-   [View nifti files in R](#view-nifti-files-in-r)
-   [Helpful resources](#helpful-resources)

Make 3dLME data table
=====================

AFNI requires file information be in a [particular
format](https://afni.nimh.nih.gov/pub/dist/doc/program_help/3dLME.html).
`functional-workshop/code/RX_comparison/AFNI/make_3dLME_dataTable.Rmd`
is an example of a script that you could use to put your data into this
format.

This script takes first-level FX contrasts (each condition &gt; rest)
and age covariates to create the data table input for the 3dLME model.

load packages
-------------

    library(tidyverse)
    library(knitr)

load data
---------

    # load fx file names
    fxCons = data.frame(file = list.files('/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/')) 

    # print header
    fxCons %>%
      head(6) %>%
      kable(format = 'pandoc')

<table>
<thead>
<tr class="header">
<th align="left">file</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">s001_t1_con_0001.nii</td>
</tr>
<tr class="even">
<td align="left">s001_t1_con_0002.nii</td>
</tr>
<tr class="odd">
<td align="left">s001_t1_con_0003.nii</td>
</tr>
<tr class="even">
<td align="left">s001_t1_con_0004.nii</td>
</tr>
<tr class="odd">
<td align="left">s001_t2_con_0001.nii</td>
</tr>
<tr class="even">
<td align="left">s001_t2_con_0002.nii</td>
</tr>
</tbody>
</table>

    # load age
    covariates = read.csv('/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/covariates/age.csv')

    # print header
    covariates %>%
      head(6) %>%
      kable(format = 'pandoc')

<table>
<thead>
<tr class="header">
<th align="left">Subj</th>
<th align="right">wavenum</th>
<th align="right">age</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">s001</td>
<td align="right">1</td>
<td align="right">10.415301</td>
</tr>
<tr class="even">
<td align="left">s001</td>
<td align="right">2</td>
<td align="right">13.487671</td>
</tr>
<tr class="odd">
<td align="left">s002</td>
<td align="right">1</td>
<td align="right">10.831454</td>
</tr>
<tr class="even">
<td align="left">s003</td>
<td align="right">1</td>
<td align="right">10.538251</td>
</tr>
<tr class="odd">
<td align="left">s004</td>
<td align="right">1</td>
<td align="right">9.718617</td>
</tr>
<tr class="even">
<td align="left">s005</td>
<td align="right">1</td>
<td align="right">9.908084</td>
</tr>
</tbody>
</table>

tidy data
---------

    # center age and create quadratic term for age
    covariates = covariates %>%
      mutate(age_c = age-13,
             age_c2 = age_c^2) %>%
      select(Subj, wavenum, starts_with("age_c"))

    # extract condition information from contrast files
    fxCons = fxCons %>%
      extract(file, c("Subj","wavenum","con"), 
              regex = "(s[0-9]{3})_t([0-3]{1})_(con_[0-4]{4}).nii", 
              remove = FALSE) %>%
      mutate(domain = ifelse(con %in% c("con_0001", "con_0003"), "academic", "social"),
             target = ifelse(con %in% c("con_0001", "con_0002"), "self", "other"),
             InputFile = paste0('/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/',file),
             wavenum = as.integer(wavenum))

exclude subjects based on motion and number of timepoints
---------------------------------------------------------

    # exclude subjects based on motion
    motion.exclusions = c('s002_t1', 's004_t1', 's008_t1', 's011_t1', 's017_t1', 's026_t1', 's033_t2', 's034_t1', 's041_t1', 's044_t1', 's047_t1', 's051_t1', 's054_t1', 's057_t1', 's059_t1', 's061_t1', 's063_t1', 's070_t2', 's074_t1', 's074_t2', 's078_t1', 's084_t1', 's090_t2', 's090_t3', 's094_t1', 's094_t2', 's096_t1')
    included.motion = fxCons %>% filter(!grepl(paste(motion.exclusions,collapse="|"), file))

    # exclude all subjects that do not have all 3 timepoints
    inclusions.3Ts = c('s005', 's016', 's018', 's019', 's022', 's023', 's024', 's029', 's030', 's032', 's035', 's038', 's040', 's042', 's045', 's058', 's064', 's065', 's072', 's073', 's081', 's089')
    included.3Ts = fxCons %>% filter(grepl(paste(inclusions.3Ts, collapse="|"), Subj))

merge data
----------

    age.motion = left_join(included.motion, covariates, by = c("Subj", "wavenum")) %>%
      select(Subj, target, domain, starts_with("age_c"), InputFile) %>%
      filter(!is.na(age_c))

    age.3Ts = left_join(included.3Ts, covariates, by = c("Subj", "wavenum")) %>%
      select(Subj, target, domain, starts_with("age_c"), InputFile) %>%
      filter(!is.na(age_c))

    # print header
    age.motion %>%
      head(10) %>%
      kable(format = 'pandoc')

<table>
<thead>
<tr class="header">
<th align="left">Subj</th>
<th align="left">target</th>
<th align="left">domain</th>
<th align="right">age_c</th>
<th align="right">age_c2</th>
<th align="left">InputFile</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">s001</td>
<td align="left">self</td>
<td align="left">academic</td>
<td align="right">-2.5846995</td>
<td align="right">6.6806712</td>
<td align="left">/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s001_t1_con_0001.nii</td>
</tr>
<tr class="even">
<td align="left">s001</td>
<td align="left">self</td>
<td align="left">social</td>
<td align="right">-2.5846995</td>
<td align="right">6.6806712</td>
<td align="left">/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s001_t1_con_0002.nii</td>
</tr>
<tr class="odd">
<td align="left">s001</td>
<td align="left">other</td>
<td align="left">academic</td>
<td align="right">-2.5846995</td>
<td align="right">6.6806712</td>
<td align="left">/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s001_t1_con_0003.nii</td>
</tr>
<tr class="even">
<td align="left">s001</td>
<td align="left">other</td>
<td align="left">social</td>
<td align="right">-2.5846995</td>
<td align="right">6.6806712</td>
<td align="left">/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s001_t1_con_0004.nii</td>
</tr>
<tr class="odd">
<td align="left">s001</td>
<td align="left">self</td>
<td align="left">academic</td>
<td align="right">0.4876712</td>
<td align="right">0.2378232</td>
<td align="left">/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s001_t2_con_0001.nii</td>
</tr>
<tr class="even">
<td align="left">s001</td>
<td align="left">self</td>
<td align="left">social</td>
<td align="right">0.4876712</td>
<td align="right">0.2378232</td>
<td align="left">/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s001_t2_con_0002.nii</td>
</tr>
<tr class="odd">
<td align="left">s001</td>
<td align="left">other</td>
<td align="left">academic</td>
<td align="right">0.4876712</td>
<td align="right">0.2378232</td>
<td align="left">/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s001_t2_con_0003.nii</td>
</tr>
<tr class="even">
<td align="left">s001</td>
<td align="left">other</td>
<td align="left">social</td>
<td align="right">0.4876712</td>
<td align="right">0.2378232</td>
<td align="left">/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s001_t2_con_0004.nii</td>
</tr>
<tr class="odd">
<td align="left">s003</td>
<td align="left">self</td>
<td align="left">academic</td>
<td align="right">-2.4617486</td>
<td align="right">6.0602063</td>
<td align="left">/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s003_t1_con_0001.nii</td>
</tr>
<tr class="even">
<td align="left">s003</td>
<td align="left">self</td>
<td align="left">social</td>
<td align="right">-2.4617486</td>
<td align="right">6.0602063</td>
<td align="left">/Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s003_t1_con_0002.nii</td>
</tr>
</tbody>
</table>

write files
-----------

    write.table(age.motion, '/Volumes/psych-cog/dsnlab/MDC/functional-workshop/code/RX_comparison/AFNI/model_all.txt', sep = "\t", quote=FALSE, row.names = FALSE)
    write.table(age.3Ts, '/Volumes/psych-cog/dsnlab/MDC/functional-workshop/code/RX_comparison/AFNI/model_3Ts.txt', sep = "\t", quote=FALSE, row.names = FALSE)

Make 3dLME bash script
======================

To run the 3dLME model, you will need to create and execute a bash
script in which your model is specified.

Path to bash script:
`functional-workshop/code/RX_comparison/AFNI/3dLME_all.sh`

    #!/bin/bash
    . ~/.bashrc

    # Change directory to the model results folder
    cd /Volumes/psych-cog/dsnlab/MDC/functional-workshop/results/AFNI

    # Specify 3dLME model
    # AFNI documentation https://afni.nimh.nih.gov/pub/dist/doc/program_help/3dLME.html
    # Every line in the model must be followed by '\'
    #   - prefix = model name
    #   - jobs = number of parallel processors
    #   - model = model formula
    #   - resid = residual file name 
    #   - ranEff = random effects, 1 = intercept
    #   - SS_type = sum of squares type, 3 = marginal
    #   - qVars = quantitative variables
    #   - qVars = centering values for quantitative variables
    #   - mask = binarized group-level mask
    #   - num_glt = number of contrasts (i.e. general linear tests)
    #   - gltLabel k = contrast label for contrast k
    #   - gltCode k = contrast code for contrast k
    #   - datatable = data structure with a header

    3dLME -prefix all \
        -jobs 8 \
        -model  "target*domain*age_c+target*domain*age_c2" \
        -resid  all_residuals   \
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
        Subj    target  domain  age_c   age_c2  InputFile \
        s001    self    academic    -2.58469945 6.6806712468303 /Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s001_t1_con_0001.nii \
        s001    self    social  -2.58469945 6.6806712468303 /Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s001_t1_con_0002.nii \
        s001    other   academic    -2.58469945 6.6806712468303 /Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s001_t1_con_0003.nii \
        s001    other   social  -2.58469945 6.6806712468303 /Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s001_t1_con_0004.nii \
        s001    self    academic    0.48767123  0.237823228569713   /Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s001_t2_con_0001.nii \
        s001    self    social  0.48767123  0.237823228569713   /Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s001_t2_con_0002.nii \
        s001    other   academic    0.48767123  0.237823228569713   /Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s001_t2_con_0003.nii \
        s001    other   social  0.48767123  0.237823228569713   /Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s001_t2_con_0004.nii \
        s003    self    academic    -2.46174863 6.06020631730688    /Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s003_t1_con_0001.nii \
        s003    self    social  -2.46174863 6.06020631730688    /Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s003_t1_con_0002.nii \
    .
    .
    .
        s096    other   social  -0.12804102 0.0163945028026403  /Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s096_t2_con_0004.nii \

Specify model
-------------

-   prefix = model name
-   jobs = number of parallel processors
-   model = model formula
-   ranEff = random effects, 1 = intercept
-   SS\_type = sum of squares type, 3 = marginal
-   qVars = quantitative variables
-   qVars = centering values for quantitative variables
-   mask = binarized group-level mask
-   resid = residual file name

<!-- -->

    3dLME -prefix all \
        -jobs 8 \
        -model  "target*domain*age_c+target*domain*age_c2" \
        -ranEff "~1+age_c" \
        -SS_type 3 \
        -qVars "age_c,age_c2" \
        -qVarCenters "0,0" \
        -mask /Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/RX_mask/groupAverage_opt.nii \
        -resid  all_residuals   \

Specify contrasts (glts)
------------------------

-   num\_glt = number of contrasts (i.e. general linear tests)
-   gltLabel k = contrast label for contrast k
-   gltCode k = contrast code for contrast k

<!-- -->

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

Specify data table (input files and design)
-------------------------------------------

-   datatable = data structure with a header
-   format = subject, condition 1, condition 1, continuous variable 1,
    continuous variable 2, input file
-   Name requirements
-   subject ID column must be named `Subj`
-   file column must be named `InputFile`

<!-- -->

        -dataTable \
        Subj    target  domain  age_c   age_c2  InputFile \
        s001    self    academic    -2.58469945 6.6806712468303 /Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s001_t1_con_0001.nii \
        s001    self    social  -2.58469945 6.6806712468303 /Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s001_t1_con_0002.nii \
        s001    other   academic    -2.58469945 6.6806712468303 /Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s001_t1_con_0003.nii \
        s001    other   social  -2.58469945 6.6806712468303 /Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s001_t1_con_0004.nii \
        s001    self    academic    0.48767123  0.237823228569713   /Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s001_t2_con_0001.nii \
        s001    self    social  0.48767123  0.237823228569713   /Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s001_t2_con_0002.nii \
        s001    other   academic    0.48767123  0.237823228569713   /Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s001_t2_con_0003.nii \
        s001    other   social  0.48767123  0.237823228569713   /Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s001_t2_con_0004.nii \
        s003    self    academic    -2.46174863 6.06020631730688    /Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s003_t1_con_0001.nii \
        s003    self    social  -2.46174863 6.06020631730688    /Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s003_t1_con_0002.nii \
    .
    .
    .
        s096    other   social  -0.12804102 0.0163945028026403  /Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s096_t2_con_0004.nii \

Complete model
--------------

    3dLME -prefix all \
        -jobs 8 \
        -model  "target*domain*age_c+target*domain*age_c2" \
        -resid  all_residuals   \
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
        Subj    target  domain  age_c   age_c2  InputFile \
        s001    self    academic    -2.58469945 6.6806712468303 /Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s001_t1_con_0001.nii \
        s001    self    social  -2.58469945 6.6806712468303 /Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s001_t1_con_0002.nii \
        s001    other   academic    -2.58469945 6.6806712468303 /Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s001_t1_con_0003.nii \
        s001    other   social  -2.58469945 6.6806712468303 /Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s001_t1_con_0004.nii \
        s001    self    academic    0.48767123  0.237823228569713   /Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s001_t2_con_0001.nii \
        s001    self    social  0.48767123  0.237823228569713   /Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s001_t2_con_0002.nii \
        s001    other   academic    0.48767123  0.237823228569713   /Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s001_t2_con_0003.nii \
        s001    other   social  0.48767123  0.237823228569713   /Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s001_t2_con_0004.nii \
        s003    self    academic    -2.46174863 6.06020631730688    /Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s003_t1_con_0001.nii \
        s003    self    social  -2.46174863 6.06020631730688    /Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s003_t1_con_0002.nii \
    .
    .
    .
        s096    other   social  -0.12804102 0.0163945028026403  /Volumes/psych-cog/dsnlab/MDC/functional-workshop/data/FX_models/s096_t2_con_0004.nii \

Run 3dLME model
===============

Dependencies
------------

-   AFNI must be installed. Follow the instructions in the [AFNI
    installation
    guide](https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/background_install/install_instructs/index.html)
-   IF you're running the script locally, make sure the path to AFNI is
    in your bash environment `~/.bashrc`; if not, export the path to
    your local version of AFNI using
    `export PATH=$PATH:/Users/danicosme/AFNI_17.0.12/`
-   If you're running it on an HPC clustster, make sure AFNI is loaded
    in the script; replace `. ~/.bashrc` with `module load afni` or
    similar
-   3dLME runs using R. To ensure all required R packages are installed,
    execute this AFNI command: `sudo rPkgsInstall -pkgs ALL`

Run model
---------

#### 1. In the terminal, the contents of the directory that holds that 3dLME bash script

    echo /Volumes/psych-cog/dsnlab/MDC/functional-workshop/code/RX_comparison/AFNI
    ls -l /Volumes/psych-cog/dsnlab/MDC/functional-workshop/code/RX_comparison/AFNI

    ## /Volumes/psych-cog/dsnlab/MDC/functional-workshop/code/RX_comparison/AFNI
    ## total 496
    ## -rwx------  1 danicosme  staff  38616 Sep 12 16:26 3dLME_3Ts.sh
    ## -rwx------  1 danicosme  staff  76690 Sep 12 16:26 3dLME_all.sh
    ## -rwx------  1 danicosme  staff   1031 Sep  2 15:57 convert_AFNItoNIFTI.sh
    ## drwx------  1 danicosme  staff  16384 Sep 12 18:00 logs
    ## -rwx------  1 danicosme  staff   3087 Sep 12 16:23 make_3dLME_dataTable.Rmd
    ## -rwx------  1 danicosme  staff  35810 Sep 12 18:45 model_3Ts.txt
    ## -rwx------  1 danicosme  staff  73056 Sep 12 18:45 model_all.txt

#### 2. Change directories to the directory with `3dLME_all.sh` and execute the script. Pipe the output to `logs/3dLME_all.txt` and errors to `logs/3dLME_all_error.txt`

    cd /Volumes/psych-cog/dsnlab/MDC/functional-workshop/code/RX_comparison/AFNI
    bash 3dLME_all.sh > logs/3dLME_all.txt 2> logs/3dLME_all_error.txt

#### 3. Wait a while for the model to finish running

#### 4. Check output file

    more /Volumes/psych-cog/dsnlab/MDC/functional-workshop/code/RX_comparison/AFNI/logs/3dLME_all.txt

    ## Package nlme loaded successfully!
    ## 
    ## Package phia loaded successfully!
    ## 
    ## 
    ## ++++++++++++++++++++++++++++++++++++++++++++++++++++
    ## ***** Summary information of data structure *****
    ## 74 subjects :  s001 s003 s005 s006 s007 s008 s009 s010 s011 s014 s015 s016 s017 s018 s019 s020 s022 s023 s024 s025 s027 s028 s029 s030 s031 s032 s033 s034 s035 s036 s037 s038 s039 s040 s041 s042 s045 s046 s049 s051 s054 s055 s056 s057 s058 s059 s060 s062 s064 s065 s067 s068 s070 s071 s072 s073 s074 s075 s077 s078 s079 s080 s081 s082 s084 s085 s086 s089 s090 s092 s093 s094 s095 s096 
    ## 540 response values
    ## 2 levels for factor target : other self 
    ## 2 levels for factor domain : academic social 
    ## 540 centered values for numeric variable age_c : -2.584699 -2.584699 -2.584699 -2.584699 0.4876712 0.4876712 0.4876712 0.4876712 -2.461749 -2.461749 -2.461749 -2.461749 -3.091916 -3.091916 -3.091916 -3.091916 -0.02739726 -0.02739726 -0.02739726 -0.02739726 3.660274 3.660274 3.660274 3.660274 -2.598361 -2.598361 -2.598361 -2.598361 -2.674863 -2.674863 -2.674863 -2.674863 0.3260274 0.3260274 0.3260274 0.3260274 0.5616438 0.5616438 0.5616438 0.5616438 -3.459016 -3.459016 -3.459016 -3.459016 -0.339726 -0.339726 -0.339726 -0.339726 -2.644809 -2.644809 -2.644809 -2.644809 -0.07945205 -0.07945205 -0.07945205 -0.07945205 -3.086676 -3.086676 -3.086676 -3.086676 -3.24025 -3.24025 -3.24025 -3.24025 -2.508197 -2.508197 -2.508197 -2.508197 -0.4164384 -0.4164384 -0.4164384 -0.4164384 3.660274 3.660274 3.660274 3.660274 0.3424658 0.3424658 0.3424658 0.3424658 -3.187858 -3.187858 -3.187858 -3.187858 0.1013699 0.1013699 0.1013699 0.1013699 3.460274 3.460274 3.460274 3.460274 -2.743169 -2.743169 -2.743169 -2.743169 0.04657534 0.04657534 0.04657534 0.04657534 3.531507 3.531507 3.531507 3.531507 -2.991803 -2.991803 -2.991803 -2.991803 0.06849315 0.06849315 0.06849315 0.06849315 -3.215607 -3.215607 -3.215607 -3.215607 -0.3945205 -0.3945205 -0.3945205 -0.3945205 2.931507 2.931507 2.931507 2.931507 -3.292275 -3.292275 -3.292275 -3.292275 -0.1972603 -0.1972603 -0.1972603 -0.1972603 2.920548 2.920548 2.920548 2.920548 -3.144419 -3.144419 -3.144419 -3.144419 0.6834494 0.6834494 0.6834494 0.6834494 3.435616 3.435616 3.435616 3.435616 -3.09497 -3.09497 -3.09497 -3.09497 -2.385246 -2.385246 -2.385246 -2.385246 -3.043476 -3.043476 -3.043476 -3.043476 -2.939891 -2.939891 -2.939891 -2.939891 -0.07945205 -0.07945205 -0.07945205 -0.07945205 3.29863 3.29863 3.29863 3.29863 -3.513661 -3.513661 -3.513661 -3.513661 0.1775956 0.1775956 0.1775956 0.1775956 3.241096 3.241096 3.241096 3.241096 -3.043372 -3.043372 -3.043372 -3.043372 -3.459016 -3.459016 -3.459016 -3.459016 0.1885246 0.1885246 0.1885246 0.1885246 1.89863 1.89863 1.89863 1.89863 -3.448087 -3.448087 -3.448087 -3.448087 3.216438 3.216438 3.216438 3.216438 0.4535519 0.4535519 0.4535519 0.4535519 -3.210383 -3.210383 -3.210383 -3.210383 -0.2520548 -0.2520548 -0.2520548 -0.2520548 2.794521 2.794521 2.794521 2.794521 -2.606557 -2.606557 -2.606557 -2.606557 -3.139344 -3.139344 -3.139344 -3.139344 -2.445355 -2.445355 -2.445355 -2.445355 0.2657534 0.2657534 0.2657534 0.2657534 4.249315 4.249315 4.249315 4.249315 -2.505464 -2.505464 -2.505464 -2.505464 -3.167123 -3.167123 -3.167123 -3.167123 -0.3671233 -0.3671233 -0.3671233 -0.3671233 2.79726 2.79726 2.79726 2.79726 0.4398907 0.4398907 0.4398907 0.4398907 3.687671 3.687671 3.687671 3.687671 -2.728767 -2.728767 -2.728767 -2.728767 0.01369863 0.01369863 0.01369863 0.01369863 3.449315 3.449315 3.449315 3.449315 -3.229508 -3.229508 -3.229508 -3.229508 -0.194528 -0.194528 -0.194528 -0.194528 3.043836 3.043836 3.043836 3.043836 -3.049315 -3.049315 -3.049315 -3.049315 3.134247 3.134247 3.134247 3.134247 -2.89863 -2.89863 -2.89863 -2.89863 -0.2493151 -0.2493151 -0.2493151 -0.2493151 0.2459016 0.2459016 0.2459016 0.2459016 0.3852459 0.3852459 0.3852459 0.3852459 3.769167 3.769167 3.769167 3.769167 -2.956164 -2.956164 -2.956164 -2.956164 3.892469 3.892469 3.892469 3.892469 -2.50411 -2.50411 -2.50411 -2.50411 0.01917808 0.01917808 0.01917808 0.01917808 4.150685 4.150685 4.150685 4.150685 0.3743169 0.3743169 0.3743169 0.3743169 3.364384 3.364384 3.364384 3.364384 -3.191781 -3.191781 -3.191781 -3.191781 -0.04803503 -0.04803503 -0.04803503 -0.04803503 -2.49863 -2.49863 -2.49863 -2.49863 -3.189041 -3.189041 -3.189041 -3.189041 0.3232877 0.3232877 0.3232877 0.3232877 3.828745 3.828745 3.828745 3.828745 -2.446575 -2.446575 -2.446575 -2.446575 -0.2164384 -0.2164384 -0.2164384 -0.2164384 3.328767 3.328767 3.328767 3.328767 -3.057534 -3.057534 -3.057534 -3.057534 -3.227397 -3.227397 -3.227397 -3.227397 3.279452 3.279452 3.279452 3.279452 -2.460274 -2.460274 -2.460274 -2.460274 0.8907104 0.8907104 0.8907104 0.8907104 -2.534247 -2.534247 -2.534247 -2.534247 -0.3863014 -0.3863014 -0.3863014 -0.3863014 2.906849 2.906849 2.906849 2.906849 -2.876712 -2.876712 -2.876712 -2.876712 0.1120219 0.1120219 0.1120219 0.1120219 3.054795 3.054795 3.054795 3.054795 3.358904 3.358904 3.358904 3.358904 -2.49863 -2.49863 -2.49863 -2.49863 -2.531507 -2.531507 -2.531507 -2.531507 0.1803279 0.1803279 0.1803279 0.1803279 3.96365 3.96365 3.96365 3.96365 -2.723288 -2.723288 -2.723288 -2.723288 0.2213115 0.2213115 0.2213115 0.2213115 3.271233 3.271233 3.271233 3.271233 -2.758904 -2.758904 -2.758904 -2.758904 -0.6383562 -0.6383562 -0.6383562 -0.6383562 2.726027 2.726027 2.726027 2.726027 -3.126027 -3.126027 -3.126027 -3.126027 -0.1993188 -0.1993188 -0.1993188 -0.1993188 0.00821918 0.00821918 0.00821918 0.00821918 3.256831 3.256831 3.256831 3.256831 -2.876712 -2.876712 -2.876712 -2.876712 -2.550685 -2.550685 -2.550685 -2.550685 0.1721312 0.1721312 0.1721312 0.1721312 -2.805479 -2.805479 -2.805479 -2.805479 0.1639344 0.1639344 0.1639344 0.1639344 3.547182 3.547182 3.547182 3.547182 -3.117808 -3.117808 -3.117808 -3.117808 -3.167123 -3.167123 -3.167123 -3.167123 -0.2759563 -0.2759563 -0.2759563 -0.2759563 -3.270477 -3.270477 -3.270477 -3.270477 2.958904 2.958904 2.958904 2.958904 -3.254046 -3.254046 -3.254046 -3.254046 -0.128041 -0.128041 -0.128041 -0.128041 
    ## 540 centered values for numeric variable age_c2 : 6.680671 6.680671 6.680671 6.680671 0.2378232 0.2378232 0.2378232 0.2378232 6.060206 6.060206 6.060206 6.060206 9.559942 9.559942 9.559942 9.559942 0.0007506099 0.0007506099 0.0007506099 0.0007506099 13.39761 13.39761 13.39761 13.39761 6.751478 6.751478 6.751478 6.751478 7.154894 7.154894 7.154894 7.154894 0.1062939 0.1062939 0.1062939 0.1062939 0.3154438 0.3154438 0.3154438 0.3154438 11.96479 11.96479 11.96479 11.96479 0.1154138 0.1154138 0.1154138 0.1154138 6.995013 6.995013 6.995013 6.995013 0.006312628 0.006312628 0.006312628 0.006312628 9.527567 9.527567 9.527567 9.527567 10.49922 10.49922 10.49922 10.49922 6.291051 6.291051 6.291051 6.291051 0.1734209 0.1734209 0.1734209 0.1734209 13.39761 13.39761 13.39761 13.39761 0.1172828 0.1172828 0.1172828 0.1172828 10.16244 10.16244 10.16244 10.16244 0.01027585 0.01027585 0.01027585 0.01027585 11.9735 11.9735 11.9735 11.9735 7.524978 7.524978 7.524978 7.524978 0.002169262 0.002169262 0.002169262 0.002169262 12.47154 12.47154 12.47154 12.47154 8.950887 8.950887 8.950887 8.950887 0.004691312 0.004691312 0.004691312 0.004691312 10.34013 10.34013 10.34013 10.34013 0.1556465 0.1556465 0.1556465 0.1556465 8.593732 8.593732 8.593732 8.593732 10.83907 10.83907 10.83907 10.83907 0.03891161 0.03891161 0.03891161 0.03891161 8.5296 8.5296 8.5296 8.5296 9.887374 9.887374 9.887374 9.887374 0.467103 0.467103 0.467103 0.467103 11.80346 11.80346 11.80346 11.80346 9.578837 9.578837 9.578837 9.578837 5.689398 5.689398 5.689398 5.689398 9.262748 9.262748 9.262748 9.262748 8.642957 8.642957 8.642957 8.642957 0.006312628 0.006312628 0.006312628 0.006312628 10.88096 10.88096 10.88096 10.88096 12.34582 12.34582 12.34582 12.34582 0.03154021 0.03154021 0.03154021 0.03154021 10.5047 10.5047 10.5047 10.5047 9.26211 9.26211 9.26211 9.26211 11.96479 11.96479 11.96479 11.96479 0.03554152 0.03554152 0.03554152 0.03554152 3.604796 3.604796 3.604796 3.604796 11.88931 11.88931 11.88931 11.88931 10.34548 10.34548 10.34548 10.34548 0.2057093 0.2057093 0.2057093 0.2057093 10.30656 10.30656 10.30656 10.30656 0.06353162 0.06353162 0.06353162 0.06353162 7.809345 7.809345 7.809345 7.809345 6.794141 6.794141 6.794141 6.794141 9.855482 9.855482 9.855482 9.855482 5.979762 5.979762 5.979762 5.979762 0.07062488 0.07062488 0.07062488 0.07062488 18.05668 18.05668 18.05668 18.05668 6.277352 6.277352 6.277352 6.277352 10.03067 10.03067 10.03067 10.03067 0.1347795 0.1347795 0.1347795 0.1347795 7.824665 7.824665 7.824665 7.824665 0.1935038 0.1935038 0.1935038 0.1935038 13.59892 13.59892 13.59892 13.59892 7.44617 7.44617 7.44617 7.44617 0.0001876525 0.0001876525 0.0001876525 0.0001876525 11.89777 11.89777 11.89777 11.89777 10.42972 10.42972 10.42972 10.42972 0.03784115 0.03784115 0.03784115 0.03784115 9.264935 9.264935 9.264935 9.264935 9.298322 9.298322 9.298322 9.298322 9.823502 9.823502 9.823502 9.823502 8.402057 8.402057 8.402057 8.402057 0.062158 0.062158 0.062158 0.062158 0.06046762 0.06046762 0.06046762 0.06046762 0.1484144 0.1484144 0.1484144 0.1484144 14.20662 14.20662 14.20662 14.20662 8.738908 8.738908 8.738908 8.738908 15.15132 15.15132 15.15132 15.15132 6.270565 6.270565 6.270565 6.270565 0.0003677988 0.0003677988 0.0003677988 0.0003677988 17.22819 17.22819 17.22819 17.22819 0.1401132 0.1401132 0.1401132 0.1401132 11.31908 11.31908 11.31908 11.31908 10.18746 10.18746 10.18746 10.18746 0.002307364 0.002307364 0.002307364 0.002307364 6.243153 6.243153 6.243153 6.243153 10.16998 10.16998 10.16998 10.16998 0.1045149 0.1045149 0.1045149 0.1045149 14.65929 14.65929 14.65929 14.65929 5.985731 5.985731 5.985731 5.985731 0.04684556 0.04684556 0.04684556 0.04684556 11.08069 11.08069 11.08069 11.08069 9.348516 9.348516 9.348516 9.348516 10.41609 10.41609 10.41609 10.41609 10.75481 10.75481 10.75481 10.75481 6.052948 6.052948 6.052948 6.052948 0.793365 0.793365 0.793365 0.793365 6.422406 6.422406 6.422406 6.422406 0.1492287 0.1492287 0.1492287 0.1492287 8.449773 8.449773 8.449773 8.449773 8.275474 8.275474 8.275474 8.275474 0.0125489 0.0125489 0.0125489 0.0125489 9.33177 9.33177 9.33177 9.33177 11.28224 11.28224 11.28224 11.28224 6.243153 6.243153 6.243153 6.243153 6.408527 6.408527 6.408527 6.408527 0.03251814 0.03251814 0.03251814 0.03251814 15.71052 15.71052 15.71052 15.71052 7.416296 7.416296 7.416296 7.416296 0.04897877 0.04897877 0.04897877 0.04897877 10.70096 10.70096 10.70096 10.70096 7.611552 7.611552 7.611552 7.611552 0.4074986 0.4074986 0.4074986 0.4074986 7.431225 7.431225 7.431225 7.431225 9.772047 9.772047 9.772047 9.772047 0.03972799 0.03972799 0.03972799 0.03972799 6.755492e-05 6.755492e-05 6.755492e-05 6.755492e-05 10.60695 10.60695 10.60695 10.60695 8.275474 8.275474 8.275474 8.275474 6.505994 6.505994 6.505994 6.505994 0.02962913 0.02962913 0.02962913 0.02962913 7.870715 7.870715 7.870715 7.870715 0.0268745 0.0268745 0.0268745 0.0268745 12.5825 12.5825 12.5825 12.5825 9.720728 9.720728 9.720728 9.720728 10.03067 10.03067 10.03067 10.03067 0.07615187 0.07615187 0.07615187 0.07615187 10.69602 10.69602 10.69602 10.69602 8.755114 8.755114 8.755114 8.755114 10.58882 10.58882 10.58882 10.58882 0.0163945 0.0163945 0.0163945 0.0163945 
    ## 9 post hoc tests
    ## 
    ## Contingency tables of subject distributions among the categorical variables:
    ## 
    ## 
    ## Tabulation of subjects against all categorical variables
    ## ~~~~~~~~~~~~~~
    ## Subj vs target:
    ##       
    ##        other self
    ##   s001     4    4
    ##   s003     2    2
    ##   s005     6    6
    ##   s006     2    2
    ##   s007     4    4
    ##   s008     2    2
    ##   s009     4    4
    ##   s010     2    2
    ##   s011     2    2
    ##   s014     2    2
    ##   s015     2    2
    ##   s016     6    6
    ##   s017     2    2
    ##   s018     6    6
    ##   s019     6    6
    ##   s020     4    4
    ##   s022     6    6
    ##   s023     6    6
    ##   s024     6    6
    ##   s025     2    2
    ##   s027     2    2
    ##   s028     2    2
    ##   s029     6    6
    ##   s030     6    6
    ##   s031     2    2
    ##   s032     6    6
    ##   s033     4    4
    ##   s034     2    2
    ##   s035     6    6
    ##   s036     2    2
    ##   s037     2    2
    ##   s038     6    6
    ##   s039     2    2
    ##   s040     6    6
    ##   s041     4    4
    ##   s042     6    6
    ##   s045     6    6
    ##   s046     4    4
    ##   s049     2    2
    ##   s051     2    2
    ##   s054     2    2
    ##   s055     4    4
    ##   s056     2    2
    ##   s057     2    2
    ##   s058     6    6
    ##   s059     4    4
    ##   s060     4    4
    ##   s062     2    2
    ##   s064     6    6
    ##   s065     6    6
    ##   s067     2    2
    ##   s068     2    2
    ##   s070     2    2
    ##   s071     4    4
    ##   s072     6    6
    ##   s073     6    6
    ##   s074     2    2
    ##   s075     2    2
    ##   s077     2    2
    ##   s078     4    4
    ##   s079     2    2
    ##   s080     4    4
    ##   s081     6    6
    ##   s082     4    4
    ##   s084     4    4
    ##   s085     2    2
    ##   s086     4    4
    ##   s089     6    6
    ##   s090     2    2
    ##   s092     4    4
    ##   s093     2    2
    ##   s094     2    2
    ##   s095     2    2
    ##   s096     2    2
    ## 
    ## ~~~~~~~~~~~~~~
    ## Subj vs domain:
    ##       
    ##        academic social
    ##   s001        4      4
    ##   s003        2      2
    ##   s005        6      6
    ##   s006        2      2
    ##   s007        4      4
    ##   s008        2      2
    ##   s009        4      4
    ##   s010        2      2
    ##   s011        2      2
    ##   s014        2      2
    ##   s015        2      2
    ##   s016        6      6
    ##   s017        2      2
    ##   s018        6      6
    ##   s019        6      6
    ##   s020        4      4
    ##   s022        6      6
    ##   s023        6      6
    ##   s024        6      6
    ##   s025        2      2
    ##   s027        2      2
    ##   s028        2      2
    ##   s029        6      6
    ##   s030        6      6
    ##   s031        2      2
    ##   s032        6      6
    ##   s033        4      4
    ##   s034        2      2
    ##   s035        6      6
    ##   s036        2      2
    ##   s037        2      2
    ##   s038        6      6
    ##   s039        2      2
    ##   s040        6      6
    ##   s041        4      4
    ##   s042        6      6
    ##   s045        6      6
    ##   s046        4      4
    ##   s049        2      2
    ##   s051        2      2
    ##   s054        2      2
    ##   s055        4      4
    ##   s056        2      2
    ##   s057        2      2
    ##   s058        6      6
    ##   s059        4      4
    ##   s060        4      4
    ##   s062        2      2
    ##   s064        6      6
    ##   s065        6      6
    ##   s067        2      2
    ##   s068        2      2
    ##   s070        2      2
    ##   s071        4      4
    ##   s072        6      6
    ##   s073        6      6
    ##   s074        2      2
    ##   s075        2      2
    ##   s077        2      2
    ##   s078        4      4
    ##   s079        2      2
    ##   s080        4      4
    ##   s081        6      6
    ##   s082        4      4
    ##   s084        4      4
    ##   s085        2      2
    ##   s086        4      4
    ##   s089        6      6
    ##   s090        2      2
    ##   s092        4      4
    ##   s093        2      2
    ##   s094        2      2
    ##   s095        2      2
    ##   s096        2      2
    ## ***** End of data structure information *****
    ## ++++++++++++++++++++++++++++++++++++++++++++++++++++
    ## 
    ## Reading input files now...
    ## 
    ## Reading input files: Done!
    ## 
    ## If the program hangs here for more than, for example, half an hour,
    ## kill the process because the model specification or the GLT coding
    ## is likely inappropriate.
    ## 
    ## [1] "Great, test run passed at voxel (17, 31, 26)!"
    ## [1] "Start to compute 52 slices along Z axis. You can monitor the progress"
    ## [1] "and estimate the total run time as shown below."
    ## [1] "08/29/17 17:02:50.522"
    ## Package snow loaded successfully!
    ## 
    ## Z slice  1 done:  08/29/17 17:02:59.092 
    ## Z slice  2 done:  08/29/17 17:02:59.909 
    ## Z slice  3 done:  08/29/17 17:03:08.962 
    ## Z slice  4 done:  08/29/17 17:04:11.478 
    ## Z slice  5 done:  08/29/17 17:06:02.312 
    ## Z slice  6 done:  08/29/17 17:08:10.407 
    ## Z slice  7 done:  08/29/17 17:10:43.416 
    ## Z slice  8 done:  08/29/17 17:13:35.229 
    ## Z slice  9 done:  08/29/17 17:16:45.270 
    ## Z slice  10 done:  08/29/17 17:20:05.022 
    ## Z slice  11 done:  08/29/17 17:23:49.455 
    ## Z slice  12 done:  08/29/17 17:27:40.728 
    ## Z slice  13 done:  08/29/17 17:31:44.522 
    ## Z slice  14 done:  08/29/17 17:36:06.808 
    ## Z slice  15 done:  08/29/17 17:40:23.625 
    ## Z slice  16 done:  08/29/17 17:44:55.749 
    ## Z slice  17 done:  08/29/17 17:49:16.877 
    ## Z slice  18 done:  08/29/17 17:53:45.405 
    ## Z slice  19 done:  08/29/17 17:58:12.236 
    ## Z slice  20 done:  08/29/17 18:02:19.811 
    ## Z slice  21 done:  08/29/17 18:06:20.397 
    ## Z slice  22 done:  08/29/17 18:10:25.998 
    ## Z slice  23 done:  08/29/17 18:14:12.015 
    ## Z slice  24 done:  08/29/17 18:17:54.695 
    ## Z slice  25 done:  08/29/17 18:21:10.821 
    ## Z slice  26 done:  08/29/17 18:24:22.574 
    ## Z slice  27 done:  08/29/17 18:27:16.370 
    ## Z slice  28 done:  08/29/17 18:29:58.784 
    ## Z slice  29 done:  08/29/17 18:32:32.401 
    ## Z slice  30 done:  08/29/17 18:34:58.623 
    ## Z slice  31 done:  08/29/17 18:37:25.417 
    ## Z slice  32 done:  08/29/17 18:39:58.426 
    ## Z slice  33 done:  08/29/17 18:42:27.042 
    ## Z slice  34 done:  08/29/17 18:45:00.735 
    ## Z slice  35 done:  08/29/17 18:47:34.642 
    ## Z slice  36 done:  08/29/17 18:50:03.510 
    ## Z slice  37 done:  08/29/17 18:52:35.254 
    ## Z slice  38 done:  08/29/17 18:54:55.546 
    ## Z slice  39 done:  08/29/17 18:57:04.418 
    ## Z slice  40 done:  08/29/17 18:59:12.355 
    ## Z slice  41 done:  08/29/17 19:01:13.006 
    ## Z slice  42 done:  08/29/17 19:03:19.580 
    ## Z slice  43 done:  08/29/17 19:05:17.210 
    ## Z slice  44 done:  08/29/17 19:07:22.848 
    ## Z slice  45 done:  08/29/17 19:09:09.322 
    ## Z slice  46 done:  08/29/17 19:10:56.223 
    ## Z slice  47 done:  08/29/17 19:12:31.718 
    ## Z slice  48 done:  08/29/17 19:14:08.110 
    ## Z slice  49 done:  08/29/17 19:15:23.974 
    ## Z slice  50 done:  08/29/17 19:16:57.991 
    ## Z slice  51 done:  08/29/17 19:18:14.618 
    ## Z slice  52 done:  08/29/17 19:19:33.578 
    ## [1] "Congratulations! You've got an output all+tlrc"

#### 5. Check results files in the output directory

    ls -l /Volumes/psych-cog/dsnlab/MDC/functional-workshop/results/AFNI

    ## total 620168
    ## -rwx------  1 danicosme  staff   10417680 Aug 29 18:28 3Ts+tlrc.BRIK
    ## -rwx------  1 danicosme  staff      81412 Aug 29 18:28 3Ts+tlrc.HEAD
    ## -rwx------  1 danicosme  staff   91675584 Aug 29 18:28 3Ts_residuals+tlrc.BRIK
    ## -rwx------  1 danicosme  staff      53101 Aug 29 18:28 3Ts_residuals+tlrc.HEAD
    ## -rwx------  1 danicosme  staff       3782 Aug 30 17:45 3dFWHMx.1D
    ## -rwx------  1 danicosme  staff      17118 Aug 30 17:47 3dFWHMx.1D.png
    ## -rwx------  1 danicosme  staff   14442416 Sep 10  2015 MNI152_T1_1mm_brain.nii
    ## -rwx------  1 danicosme  staff     418328 Sep 12 18:25 age.self-other_3Ts.nii
    ## -rwx------  1 danicosme  staff     456040 Sep 12 18:25 age.self-other_all.nii
    ## -rwx------  1 danicosme  staff     418312 Sep 12 18:25 age2.self-other_3Ts.nii
    ## -rwx------  1 danicosme  staff     456040 Sep 12 18:25 age2.self-other_all.nii
    ## -rwx------  1 danicosme  staff   10417680 Aug 29 19:19 all+tlrc.BRIK
    ## -rwx------  1 danicosme  staff     120060 Aug 29 19:19 all+tlrc.HEAD
    ## -rwx------  1 danicosme  staff  187518240 Aug 29 19:20 all_residuals+tlrc.BRIK
    ## -rwx------  1 danicosme  staff     105202 Aug 29 19:19 all_residuals+tlrc.HEAD
    ## drwx------  1 danicosme  staff      16384 Sep 12 17:58 backup
    ## -rwx------  1 danicosme  staff     418136 Sep 12 18:25 self-other_3Ts.nii
    ## -rwx------  1 danicosme  staff     456168 Sep 12 18:25 self-other_all.nii

View results in AFNI
====================

#### 1. Open AFNI GUI

    cd /Volumes/psych-cog/dsnlab/MDC/functional-workshop/results/AFNI
    afni&

#### 2. Select overlay by clicking on `Overlay` and choosing the model labeled `all`

<img src="./select_overlay.png" width="750">

#### 3. Select contrast by clicking on `Olay` and `Thr` and selecting `self-other Z` in each.

-   Choosing the `Z` map will give the map of z-values, whereas the
    other map is the map of parameter estimates
-   `Thr` is the map that is used for thresholding.

<img src="./select_subbrick.png" width="750">

#### 4. Select the p-value by right-clicking on `p=`

-   If you have trouble entering values into the GUI, use
    `echo 'export DYLD_LIBRARY_PATH=/opt/X11/lib/flat_namespace' >> ~/.bashrc`

<img src="./select_pvalue.png" width="750">

#### 5. Select cluster forming threshold by clicking on `Clusterize`

<img src="./select_k.png" width="750">

Convert AFNI files to nifti files
=================================

Conversion script path:
`/Volumes/psych-cog/dsnlab/MDC/functional-workshop/code/RX_comparison/AFNI/convert_AFNItoNIFTI.sh`

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

View nifti files in R
=====================

[John Muschelli](https://github.com/muschellij2) has written a number of
wrappers to do neuroimaging and visualization in R. He also co-teaches a
[fabulous class on neurohacking in
R](https://www.coursera.org/learn/neurohacking) through Coursera.

    library(fslr)
    library(papayar)
    structural = readnii('/Volumes/psych-cog/dsnlab/MDC/functional-workshop/results/AFNI/MNI152_T1_1mm_brain.nii')
    contrast = readnii('/Volumes/psych-cog/dsnlab/MDC/functional-workshop/results/AFNI/self-other_all.nii')

    papaya(list(structural,contrast))

<img src="./papaya.png" width="750">

Helpful resources
=================

-   [AFNI installation
    guide](https://afni.nimh.nih.gov/pub/dist/doc/htmldoc/background_install/install_instructs/index.html)
-   [AFNI 3dLME help
    guide](https://afni.nimh.nih.gov/pub/dist/doc/program_help/3dLME.html)
-   [AFNI message
    board](https://afni.nimh.nih.gov/afni/community/board/)
