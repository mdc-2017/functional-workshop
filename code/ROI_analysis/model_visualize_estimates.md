-   [ROIs from the [Craddock et al. (2012) parcellation
    atlas](http://ccraddock.github.io/cluster_roi/atlases.html)](#rois-from-the-craddock-et-al.-2012-parcellation-atlas)
-   [Extract mean parameter
    estimates](#extract-mean-parameter-estimates)
-   [Load packages](#load-packages)
-   [Load data](#load-data)
-   [Tidy data](#tidy-data)
    -   [Specify your variables names and
        levels](#specify-your-variables-names-and-levels)
-   [Merge data, add age to the data frame and
    center](#merge-data-add-age-to-the-data-frame-and-center)
-   [Remove missing data to run LME
    models](#remove-missing-data-to-run-lme-models)
-   [Run LME models within parcel 292 and
    compare](#run-lme-models-within-parcel-292-and-compare)
    -   [Linear effect of age, random intercepts
        only](#linear-effect-of-age-random-intercepts-only)
    -   [Linear effect of age, random intercepts and age
        slopes](#linear-effect-of-age-random-intercepts-and-age-slopes)
    -   [Compare models](#compare-models)
-   [Visualize raw data](#visualize-raw-data)
    -   [Plot fitted curves for parcels 292 and
        116](#plot-fitted-curves-for-parcels-292-and-116)
        -   [Main effect of target](#main-effect-of-target)
        -   [Interaction between target and
            domain](#interaction-between-target-and-domain)
    -   [Plot LOESS curves for parcels 292 and
        116](#plot-loess-curves-for-parcels-292-and-116)
        -   [Main effect of target](#main-effect-of-target-1)
        -   [Interaction between target and
            domain](#interaction-between-target-and-domain-1)
-   [Visualize predicted values from
    model.1](#visualize-predicted-values-from-model.1)
    -   [Plot fitted curves for parcels 292 and
        116](#plot-fitted-curves-for-parcels-292-and-116-1)
        -   [Main effect of target](#main-effect-of-target-2)
        -   [Interaction between target and
            domain](#interaction-between-target-and-domain-2)
-   [Visualize predicted values from
    model.2](#visualize-predicted-values-from-model.2)
    -   [Plot fitted curves for parcels 292 and
        116](#plot-fitted-curves-for-parcels-292-and-116-2)
        -   [Main effect of target](#main-effect-of-target-3)
        -   [Interaction between target and
            domain](#interaction-between-target-and-domain-3)

ROIs from the [Craddock et al. (2012) parcellation atlas](http://ccraddock.github.io/cluster_roi/atlases.html)
==============================================================================================================

Mean parameter estimates were extracted from parcel 292 and 116. The
parcellation atlas can be found in
`functional-workshop/data/ROIs/craddock_all.nii.gz`. This atlas has
multiple volumes within the 4D file, and we extracted from the K=400
atlas, which is the 31st volume in AFNI (index = 0 in AFNI).

<img src="parcel_116_292_edited.png" width="750">

Extract mean parameter estimates
================================

Run bash script to calculate mean parameter estimates for each subject,
wave, and condition contrast (condition &gt; rest) within each ROI using
AFNI `3dmaskave`.

Path to bash script:
`functional-workshop/code/ROI_analysis/extract_parameterEstimates.sh`

Dependencies:  
\* AFNI must be installed  
\* Path to AFNI script must be in your `~/.bashrc` file

    #!/bin/bash
    . ~/.bashrc

    # This script extracts mean parameter estimates and SDs within an ROI or parcel
    # from subject FX condition contrasts (condition > rest) for each wave. Output is 
    # saved as a text file in the output directory.

    # Set paths and variables
    # ------------------------------------------------------------------------------------------
    # paths

    con_dir='./data/FX_models' #fx contrast directory
    atlas_dir='./data/ROIs' #roi/parcellation atlas directory 
    output_dir='./results/ROI_analysis' #roi/parcellation output directory
    rx_model='./results/AFNI/all+tlrc' #rx model (for atlas alignment only)

    # variables
    subjects=`cat ./data/subject_list.txt`
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

The output will be saved in a text file
`functional-workshop/results/ROI_analysis/parameterEstimates.txt`

    # set mirror from which to download packages
    osuRepo = 'http://ftp.osuosl.org/pub/cran/'

    if(!require(knitr)){
      install.packages('knitr',repos=osuRepo)
    }
    if(!require(dplyr)){
      install.packages('dplyr',repos=osuRepo)
    }

    read.table('../../results/ROI_analysis/parameterEstimates.txt', sep = "", fill = TRUE, stringsAsFactors=FALSE) %>%
      head(10) %>%
      kable(format = 'pandoc', digits = 2)

<table>
<thead>
<tr class="header">
<th align="left">V1</th>
<th align="left">V2</th>
<th align="left">V3</th>
<th align="right">V4</th>
<th align="right">V5</th>
<th align="right">V6</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">s001</td>
<td align="left">t1</td>
<td align="left">con_0001</td>
<td align="right">116</td>
<td align="right">-0.59</td>
<td align="right">0.27</td>
</tr>
<tr class="even">
<td align="left">s001</td>
<td align="left">t1</td>
<td align="left">con_0001</td>
<td align="right">292</td>
<td align="right">-0.33</td>
<td align="right">0.33</td>
</tr>
<tr class="odd">
<td align="left">s001</td>
<td align="left">t1</td>
<td align="left">con_0002</td>
<td align="right">116</td>
<td align="right">-0.02</td>
<td align="right">0.34</td>
</tr>
<tr class="even">
<td align="left">s001</td>
<td align="left">t1</td>
<td align="left">con_0002</td>
<td align="right">292</td>
<td align="right">-0.01</td>
<td align="right">0.39</td>
</tr>
<tr class="odd">
<td align="left">s001</td>
<td align="left">t1</td>
<td align="left">con_0003</td>
<td align="right">116</td>
<td align="right">-0.59</td>
<td align="right">0.33</td>
</tr>
<tr class="even">
<td align="left">s001</td>
<td align="left">t1</td>
<td align="left">con_0003</td>
<td align="right">292</td>
<td align="right">-0.28</td>
<td align="right">0.40</td>
</tr>
<tr class="odd">
<td align="left">s001</td>
<td align="left">t1</td>
<td align="left">con_0004</td>
<td align="right">116</td>
<td align="right">-0.10</td>
<td align="right">0.31</td>
</tr>
<tr class="even">
<td align="left">s001</td>
<td align="left">t1</td>
<td align="left">con_0004</td>
<td align="right">292</td>
<td align="right">-0.05</td>
<td align="right">0.37</td>
</tr>
<tr class="odd">
<td align="left">s001</td>
<td align="left">t2</td>
<td align="left">con_0001</td>
<td align="right">116</td>
<td align="right">-0.66</td>
<td align="right">0.31</td>
</tr>
<tr class="even">
<td align="left">s001</td>
<td align="left">t2</td>
<td align="left">con_0001</td>
<td align="right">292</td>
<td align="right">-0.47</td>
<td align="right">0.28</td>
</tr>
</tbody>
</table>

Load packages
=============

    if(!require(tidyr)){
      install.packages('tidyr',repos=osuRepo)
    }
    if(!require(ggplot2)){
      install.packages('ggplot2',repos=osuRepo)
    }
    if(!require(lme4)){
      install.packages('lme4',repos=osuRepo)
    }
    if(!require(lmerTest)){
      install.packages('lmerTest',repos=osuRepo)
    }
    if(!require(wesanderson)){
      install.packages('wesanderson',repos=osuRepo)
    }
    if(!require(rmarkdown)){
      install.packages('rmarkdown',repos=osuRepo)
      }

Load data
=========

    # load parameter estimate delimited .txt file
    data = read.table('../../results/ROI_analysis/parameterEstimates.txt', sep = " ", fill = TRUE, stringsAsFactors=FALSE)

    # load age covariates and rename variables
    age = read.csv('../../data/covariates/age.csv') %>%
      rename("subjectID" = Subj,
             "wave" = wavenum)

Tidy data
=========

Specify your variables names and levels
---------------------------------------

    # tidy raw data
    data1 = data %>% 
      # rename variables
      rename('subjectID' = V1,
             'wave' = V2,
             'con' = V3,
             'parcellation' = V4,
             'beta' = V5,
             'sd' = V6) %>%
      # convert con file names to condition names
      mutate(target = ifelse(con %in% c('con_0001', 'con_0002'), 'self', 'other'), 
             domain = ifelse(con %in% c('con_0001', 'con_0003'), 'academic', 'social'), 
      # change data type to factor
             parcellation = as.factor(parcellation),
             target = as.factor(target),
             domain = as.factor(domain)) %>%
      # change to integer
      extract(wave, 'wave', 't([0-3]{1})') %>%
      mutate(wave = as.integer(wave))

Merge data, add age to the data frame and center
================================================

    #Take every row in `age` that matches values in `data1` columns 'subjectID' and 'wave'
    merged = left_join(data1, age, by = c('subjectID', 'wave')) %>%
      mutate(age_c = age-mean(age, na.rm=TRUE))

    # print data frame header
    merged %>%
      head(16) %>%
      kable(format = 'pandoc', digits = 2)

<table>
<thead>
<tr class="header">
<th align="left">subjectID</th>
<th align="right">wave</th>
<th align="left">con</th>
<th align="left">parcellation</th>
<th align="right">beta</th>
<th align="right">sd</th>
<th align="left">target</th>
<th align="left">domain</th>
<th align="right">age</th>
<th align="right">age_c</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left">s001</td>
<td align="right">1</td>
<td align="left">con_0001</td>
<td align="left">116</td>
<td align="right">-0.59</td>
<td align="right">0.27</td>
<td align="left">self</td>
<td align="left">academic</td>
<td align="right">10.42</td>
<td align="right">-2.09</td>
</tr>
<tr class="even">
<td align="left">s001</td>
<td align="right">1</td>
<td align="left">con_0001</td>
<td align="left">292</td>
<td align="right">-0.33</td>
<td align="right">0.33</td>
<td align="left">self</td>
<td align="left">academic</td>
<td align="right">10.42</td>
<td align="right">-2.09</td>
</tr>
<tr class="odd">
<td align="left">s001</td>
<td align="right">1</td>
<td align="left">con_0002</td>
<td align="left">116</td>
<td align="right">-0.02</td>
<td align="right">0.34</td>
<td align="left">self</td>
<td align="left">social</td>
<td align="right">10.42</td>
<td align="right">-2.09</td>
</tr>
<tr class="even">
<td align="left">s001</td>
<td align="right">1</td>
<td align="left">con_0002</td>
<td align="left">292</td>
<td align="right">-0.01</td>
<td align="right">0.39</td>
<td align="left">self</td>
<td align="left">social</td>
<td align="right">10.42</td>
<td align="right">-2.09</td>
</tr>
<tr class="odd">
<td align="left">s001</td>
<td align="right">1</td>
<td align="left">con_0003</td>
<td align="left">116</td>
<td align="right">-0.59</td>
<td align="right">0.33</td>
<td align="left">other</td>
<td align="left">academic</td>
<td align="right">10.42</td>
<td align="right">-2.09</td>
</tr>
<tr class="even">
<td align="left">s001</td>
<td align="right">1</td>
<td align="left">con_0003</td>
<td align="left">292</td>
<td align="right">-0.28</td>
<td align="right">0.40</td>
<td align="left">other</td>
<td align="left">academic</td>
<td align="right">10.42</td>
<td align="right">-2.09</td>
</tr>
<tr class="odd">
<td align="left">s001</td>
<td align="right">1</td>
<td align="left">con_0004</td>
<td align="left">116</td>
<td align="right">-0.10</td>
<td align="right">0.31</td>
<td align="left">other</td>
<td align="left">social</td>
<td align="right">10.42</td>
<td align="right">-2.09</td>
</tr>
<tr class="even">
<td align="left">s001</td>
<td align="right">1</td>
<td align="left">con_0004</td>
<td align="left">292</td>
<td align="right">-0.05</td>
<td align="right">0.37</td>
<td align="left">other</td>
<td align="left">social</td>
<td align="right">10.42</td>
<td align="right">-2.09</td>
</tr>
<tr class="odd">
<td align="left">s001</td>
<td align="right">2</td>
<td align="left">con_0001</td>
<td align="left">116</td>
<td align="right">-0.66</td>
<td align="right">0.31</td>
<td align="left">self</td>
<td align="left">academic</td>
<td align="right">13.49</td>
<td align="right">0.98</td>
</tr>
<tr class="even">
<td align="left">s001</td>
<td align="right">2</td>
<td align="left">con_0001</td>
<td align="left">292</td>
<td align="right">-0.47</td>
<td align="right">0.28</td>
<td align="left">self</td>
<td align="left">academic</td>
<td align="right">13.49</td>
<td align="right">0.98</td>
</tr>
<tr class="odd">
<td align="left">s001</td>
<td align="right">2</td>
<td align="left">con_0002</td>
<td align="left">116</td>
<td align="right">-0.35</td>
<td align="right">0.34</td>
<td align="left">self</td>
<td align="left">social</td>
<td align="right">13.49</td>
<td align="right">0.98</td>
</tr>
<tr class="even">
<td align="left">s001</td>
<td align="right">2</td>
<td align="left">con_0002</td>
<td align="left">292</td>
<td align="right">-0.14</td>
<td align="right">0.42</td>
<td align="left">self</td>
<td align="left">social</td>
<td align="right">13.49</td>
<td align="right">0.98</td>
</tr>
<tr class="odd">
<td align="left">s001</td>
<td align="right">2</td>
<td align="left">con_0003</td>
<td align="left">116</td>
<td align="right">-0.58</td>
<td align="right">0.40</td>
<td align="left">other</td>
<td align="left">academic</td>
<td align="right">13.49</td>
<td align="right">0.98</td>
</tr>
<tr class="even">
<td align="left">s001</td>
<td align="right">2</td>
<td align="left">con_0003</td>
<td align="left">292</td>
<td align="right">-0.54</td>
<td align="right">0.27</td>
<td align="left">other</td>
<td align="left">academic</td>
<td align="right">13.49</td>
<td align="right">0.98</td>
</tr>
<tr class="odd">
<td align="left">s001</td>
<td align="right">2</td>
<td align="left">con_0004</td>
<td align="left">116</td>
<td align="right">-0.30</td>
<td align="right">0.27</td>
<td align="left">other</td>
<td align="left">social</td>
<td align="right">13.49</td>
<td align="right">0.98</td>
</tr>
<tr class="even">
<td align="left">s001</td>
<td align="right">2</td>
<td align="left">con_0004</td>
<td align="left">292</td>
<td align="right">-0.28</td>
<td align="right">0.27</td>
<td align="left">other</td>
<td align="left">social</td>
<td align="right">13.49</td>
<td align="right">0.98</td>
</tr>
</tbody>
</table>

Remove missing data to run LME models
=====================================

Note here we're only removing rows where participants have no data.
We're keeping all available data from participants whether or not they
have data at all waves.

    data.complete = merged %>%
      na.omit(.)

    # print number of rows
    cat('rows in raw data frame: ', nrow(merged))

    ## rows in raw data frame:  1944

    cat('\nrows in available data frame: ', nrow(data.complete))

    ## 
    ## rows in available data frame:  1296

Run LME models within parcel 292 and compare
============================================

Regress parameter estimates on task conditions (target and domain) and
age within parcel 292.

Linear effect of age, random intercepts only
--------------------------------------------

    model.1 = lmer(beta ~ target*domain*age_c + (1 | subjectID), 
                   data=filter(data.complete, parcellation == 292)) #filter gets us just the rows from parcel 292
    summary(model.1)

    ## Linear mixed model fit by REML t-tests use Satterthwaite approximations
    ##   to degrees of freedom [lmerMod]
    ## Formula: beta ~ target * domain * age_c + (1 | subjectID)
    ##    Data: filter(data.complete, parcellation == 292)
    ## 
    ## REML criterion at convergence: 1106.1
    ## 
    ## Scaled residuals: 
    ##     Min      1Q  Median      3Q     Max 
    ## -4.0561 -0.4861  0.0324  0.4626  4.3648 
    ## 
    ## Random effects:
    ##  Groups    Name        Variance Std.Dev.
    ##  subjectID (Intercept) 0.1008   0.3175  
    ##  Residual              0.2582   0.5082  
    ## Number of obs: 648, groups:  subjectID, 81
    ## 
    ## Fixed effects:
    ##                                Estimate Std. Error        df t value
    ## (Intercept)                    -0.07709    0.05422 199.40000  -1.422
    ## targetself                      0.03147    0.05663 554.60000   0.556
    ## domainsocial                    0.09379    0.05663 554.60000   1.656
    ## age_c                          -0.03904    0.01658 584.80000  -2.354
    ## targetself:domainsocial         0.09714    0.08008 554.60000   1.213
    ## targetself:age_c                0.06418    0.02278 554.60000   2.817
    ## domainsocial:age_c              0.02990    0.02278 554.60000   1.312
    ## targetself:domainsocial:age_c  -0.06094    0.03222 554.60000  -1.891
    ##                               Pr(>|t|)   
    ## (Intercept)                    0.15660   
    ## targetself                     0.57861   
    ## domainsocial                   0.09824 . 
    ## age_c                          0.01889 * 
    ## targetself:domainsocial        0.22563   
    ## targetself:age_c               0.00502 **
    ## domainsocial:age_c             0.19000   
    ## targetself:domainsocial:age_c  0.05911 . 
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## Correlation of Fixed Effects:
    ##             (Intr) trgtsl dmnscl age_c  trgts: trgt:_ dmns:_
    ## targetself  -0.522                                          
    ## domainsocil -0.522  0.500                                   
    ## age_c        0.092 -0.052 -0.052                            
    ## trgtslf:dmn  0.369 -0.707 -0.707  0.037                     
    ## trgtslf:g_c -0.040  0.076  0.038 -0.687 -0.054              
    ## domnscl:g_c -0.040  0.038  0.076 -0.687 -0.054  0.500       
    ## trgtslf:d:_  0.028 -0.054 -0.054  0.486  0.076 -0.707 -0.707

Linear effect of age, random intercepts and age slopes
------------------------------------------------------

    model.2 = lmer(beta ~ target*domain*age_c + (1 + age_c | subjectID), data=filter(data.complete, parcellation == 292))
    summary(model.2)

    ## Linear mixed model fit by REML t-tests use Satterthwaite approximations
    ##   to degrees of freedom [lmerMod]
    ## Formula: beta ~ target * domain * age_c + (1 + age_c | subjectID)
    ##    Data: filter(data.complete, parcellation == 292)
    ## 
    ## REML criterion at convergence: 1101.3
    ## 
    ## Scaled residuals: 
    ##     Min      1Q  Median      3Q     Max 
    ## -3.8144 -0.4814  0.0320  0.4554  4.3703 
    ## 
    ## Random effects:
    ##  Groups    Name        Variance Std.Dev. Corr 
    ##  subjectID (Intercept) 0.092839 0.30469       
    ##            age_c       0.001157 0.03402  -0.60
    ##  Residual              0.252104 0.50210       
    ## Number of obs: 648, groups:  subjectID, 81
    ## 
    ## Fixed effects:
    ##                                Estimate Std. Error        df t value
    ## (Intercept)                    -0.07347    0.05281 204.40000  -1.391
    ## targetself                      0.03147    0.05595 516.30000   0.562
    ## domainsocial                    0.09379    0.05595 516.30000   1.676
    ## age_c                          -0.03807    0.01680 307.30000  -2.266
    ## targetself:domainsocial         0.09714    0.07913 516.30000   1.228
    ## targetself:age_c                0.06418    0.02251 516.30000   2.851
    ## domainsocial:age_c              0.02990    0.02251 516.30000   1.328
    ## targetself:domainsocial:age_c  -0.06094    0.03184 516.30000  -1.914
    ##                               Pr(>|t|)   
    ## (Intercept)                    0.16569   
    ## targetself                     0.57405   
    ## domainsocial                   0.09429 . 
    ## age_c                          0.02412 * 
    ## targetself:domainsocial        0.22013   
    ## targetself:age_c               0.00453 **
    ## domainsocial:age_c             0.18475   
    ## targetself:domainsocial:age_c  0.05617 . 
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## Correlation of Fixed Effects:
    ##             (Intr) trgtsl dmnscl age_c  trgts: trgt:_ dmns:_
    ## targetself  -0.530                                          
    ## domainsocil -0.530  0.500                                   
    ## age_c       -0.003 -0.051 -0.051                            
    ## trgtslf:dmn  0.375 -0.707 -0.707  0.036                     
    ## trgtslf:g_c -0.040  0.076  0.038 -0.670 -0.054              
    ## domnscl:g_c -0.040  0.038  0.076 -0.670 -0.054  0.500       
    ## trgtslf:d:_  0.028 -0.054 -0.054  0.474  0.076 -0.707 -0.707

Compare models
--------------

**model.1:** `beta ~ target * domain * age_c + (1 | subjectID)`

**model.2:** `beta ~ target * domain * age_c + (1 + age_c | subjectID)`

    #Note we set refit = FALSE below. We don't need to refit using ML instead of REML because we're
    #comparing models with different random effects. If we kept the random effects the same and 
    #changed the fixed effects, sat by adding a covariate to the model, we would want to 
    #refit using ML. See ?anova.merMod for more info.
    anova(model.1, model.2, refit = FALSE) %>%
      `row.names<-`(c('model.1', 'model.2')) %>%
      kable(digits = 2)

<table>
<thead>
<tr class="header">
<th></th>
<th align="right">Df</th>
<th align="right">AIC</th>
<th align="right">BIC</th>
<th align="right">logLik</th>
<th align="right">deviance</th>
<th align="right">Chisq</th>
<th align="right">Chi Df</th>
<th align="right">Pr(&gt;Chisq)</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>model.1</td>
<td align="right">10</td>
<td align="right">1126.12</td>
<td align="right">1170.86</td>
<td align="right">-553.06</td>
<td align="right">1106.12</td>
<td align="right">NA</td>
<td align="right">NA</td>
<td align="right">NA</td>
</tr>
<tr class="even">
<td>model.2</td>
<td align="right">12</td>
<td align="right">1125.27</td>
<td align="right">1178.96</td>
<td align="right">-550.64</td>
<td align="right">1101.27</td>
<td align="right">4.84</td>
<td align="right">2</td>
<td align="right">0.09</td>
</tr>
</tbody>
</table>

Adding age as a random effect does not significantly improve the model
fit. Note that though the AIC is lower for model.2, it is only slightly
so, and BIC favors the simpler model.

Visualize raw data
==================

    # set color palette
    palette = wes_palette("Zissou", 2, type = "continuous")

Plot fitted curves for parcels 292 and 116
------------------------------------------

### Main effect of target

The light colored points are first-level model parameter estimates for
each participant, at each wave, for each condition in the 2x2
target-by-domain design. Light colored lines connect data points within
the same participant and design cell (e.g., participant s001
Self-Academic). Best fit lines are estimated using ordinary least
squares linear regression.

    ggplot(data.complete, aes(x = age, 
                              y = beta, 
                              group = interaction(subjectID, target, domain), 
                              color = target)) +
      geom_point(size = .5, alpha = .1) + 
      geom_line(alpha = .1) + 
      geom_line(aes(group=target), size = 1.5, stat = 'smooth', method = 'lm', formula = y ~ poly(x,2)) + 
      facet_wrap(~parcellation, ncol = 2) +
      geom_hline(yintercept = 0, color = 'gray') +
      scale_color_manual(breaks = c('self', 'other'), values = c(self=palette[2], other=palette[1])) +
      scale_x_continuous(breaks=c(10,13,16)) +
      coord_cartesian(ylim=c(-1,1)) +
      theme_minimal(base_size = 18)

![](model_visualize_estimates_files/figure-markdown_strict/raw%20fitted%20main%20effect-1.png)

### Interaction between target and domain

    ggplot(data.complete, aes(x = age, 
                              y = beta, 
                              group = interaction(subjectID, target, domain), 
                              color = target, 
                              linetype = domain)) +
      geom_point(size = .5, alpha = .1) + 
      geom_line(alpha = .1) + 
      geom_line(aes(group=interaction(target,domain)), size = 1.5, stat = 'smooth', method = 'lm', formula = y ~ poly(x,2)) + 
      facet_wrap(~parcellation, ncol = 2) +
      geom_hline(yintercept = 0, color = 'gray')+
      scale_color_manual(breaks = c('self', 'other'), values = c(self=palette[2], other=palette[1]))+
      scale_x_continuous(breaks=c(10,13,16)) +
      coord_cartesian(ylim=c(-1,1)) +
      theme_minimal(base_size = 18)

![](model_visualize_estimates_files/figure-markdown_strict/raw%20fitted%20interaction-1.png)

Plot LOESS curves for parcels 292 and 116
-----------------------------------------

### Main effect of target

    ggplot(data.complete, aes(x = age, 
                              y = beta, 
                              group = interaction(subjectID, target, domain), 
                              color = target, 
                              linetype = domain)) +
      geom_point(size = .5, alpha = .1) + 
      geom_line(alpha = .1) + 
      geom_line(aes(group=target), size = 1.5, stat = 'smooth', method = 'loess', span=1) + #play with span to get more or less complex curves
      facet_wrap(~parcellation, ncol = 2) +
      geom_hline(yintercept = 0, color = 'gray')+
      scale_color_manual(breaks = c('self', 'other'), values = c(self=palette[2], other=palette[1]))+
      scale_x_continuous(breaks=c(10,13,16)) +
      coord_cartesian(ylim=c(-1,1)) +
      theme_minimal(base_size = 18)

![](model_visualize_estimates_files/figure-markdown_strict/raw%20LOESS%20main%20effect-1.png)

### Interaction between target and domain

    ggplot(data.complete, aes(x = age, 
                              y = beta, 
                              group = interaction(subjectID, target, domain), 
                              color = target, 
                              linetype = domain)) +
      geom_point(size = .5, alpha = .1) + 
      geom_line(alpha = .1) + 
      geom_line(aes(group=interaction(target,domain)), size = 1.5, stat = 'smooth', method = 'loess', span = 1) + 
      facet_wrap(~parcellation, ncol = 2) +
      geom_hline(yintercept = 0, color = 'gray')+
      scale_color_manual(breaks = c('self', 'other'), values = c(self=palette[2], other=palette[1]))+
      scale_x_continuous(breaks=c(10,13,16)) +
      coord_cartesian(ylim=c(-1,1)) +
      theme_minimal(base_size = 18)

![](model_visualize_estimates_files/figure-markdown_strict/raw%20LOESS%20interaction-1.png)

Visualize predicted values from model.1
=======================================

Linear effect of age, random intercepts only

**model.1:** `beta ~ target * domain * age_c + (1 | subjectID)`

Plot fitted curves for parcels 292 and 116
------------------------------------------

We'd probably prefer to see fitted curves from the LME model we ran,
rather than a OLS regression. To do this, we need to get the model
predicted values for the fixed effects, as well as for every
participant's deviation as captured by our random effect terms.

    # extract random effects formula from model.1 and reconstruct it to use with the `predict` function
    REFormulaString = as.character(findbars(model.1@call$formula)[[1]])
    REFormula = as.formula(paste0('~(', REFormulaString[[2]], REFormulaString[[1]], REFormulaString[[3]], ')'))

    # get expected values for each observation based on model.1
    data.complete$expected.1 <- predict(model.1, newdata = data.complete, re.form=REFormula) # different estimates per participant
    data.complete$expected_mean.1 <- predict(model.1, newdata = data.complete, re.form=NA) # the group expectation, as described by the fixed effect

### Main effect of target

Notice that the slopes for each factor level (Self, Other) are parallel.
This is because participant estimates were only unconstrained to differ
in their intercept.

    ggplot(data.complete, aes(x = age, 
                              y = expected.1, 
                              group = interaction(subjectID, target, domain), 
                              color = target)) +
      geom_point(size = .5, alpha = .1) + 
      geom_line(alpha = .2) + 
      geom_line(aes(y = expected_mean.1, group=target), size = 1.5, stat = 'smooth', method = 'lm', formula = y ~ poly(x,2)) + 
      facet_wrap(~parcellation, ncol = 2) +
      geom_hline(yintercept = 0, color = 'gray') +
      scale_color_manual(breaks = c('self', 'other'), values = c(self=palette[2], other=palette[1])) +
      scale_x_continuous(breaks=c(10,13,16)) +
      coord_cartesian(ylim=c(-1,1)) +
      theme_minimal(base_size = 18)

![](model_visualize_estimates_files/figure-markdown_strict/predicted%20main%20effect%20model.1-1.png)

### Interaction between target and domain

    ggplot(data.complete, aes(x = age, 
                              y = expected.1, 
                              group = interaction(subjectID, target, domain), 
                              color = target, 
                              linetype = domain)) +
      geom_point(size = .5, alpha = .1) + 
      geom_line(alpha = .1) + 
      geom_line(aes(y = expected_mean.1, group=interaction(target,domain)), size = 1.5, stat = 'smooth', method = 'lm', formula = y ~ poly(x,2)) + 
      facet_wrap(~parcellation, ncol = 2) +
      geom_hline(yintercept = 0, color = 'gray')+
      scale_color_manual(breaks = c('self', 'other'), values = c(self=palette[2], other=palette[1]))+
      scale_x_continuous(breaks=c(10,13,16)) +
      coord_cartesian(ylim=c(-1,1)) +
      theme_minimal(base_size = 18)

![](model_visualize_estimates_files/figure-markdown_strict/predicted%20interaction%20model.1-1.png)

Visualize predicted values from model.2
=======================================

Linear effect of age, random intercepts and age slopes

**model.2:** `beta ~ target * domain * age_c + (1 + age_c | subjectID)`

Plot fitted curves for parcels 292 and 116
------------------------------------------

    # extract random effects formula from model.2 and reconstruct it to use with the `predict` function
    REFormulaString = as.character(findbars(model.2@call$formula)[[1]])
    REFormula = as.formula(paste0('~(', REFormulaString[[2]], REFormulaString[[1]], REFormulaString[[3]], ')'))

    # get expected values for each observation based on model.2
    data.complete$expected.2 <- predict(model.2, newdata = data.complete, re.form=REFormula)
    data.complete$expected_mean.2 <- predict(model.2, newdata = data.complete, re.form=NA)

### Main effect of target

Now that we're plotting model predicted values from a model with both
random intercepts and slopes we can see that the per-participant slopes
are not longer exactly parallel. However, visual inspection does reveal
that there is not much deviation from the parellel slopes we saw above.
This is consistent with the results from the model comparison, above.

    ggplot(data.complete, aes(x = age, 
                              y = expected.2, 
                              group = interaction(subjectID, target, domain), 
                              color = target)) +
      geom_point(size = .5, alpha = .1) + 
      geom_line(alpha = .2) + 
      geom_line(aes(y = expected_mean.2, group=target), size = 1.5, stat = 'smooth', method = 'lm', formula = y ~ poly(x,2)) + 
      facet_wrap(~parcellation, ncol = 2) +
      geom_hline(yintercept = 0, color = 'gray') +
      scale_color_manual(breaks = c('self', 'other'), values = c(self=palette[2], other=palette[1])) +
      scale_x_continuous(breaks=c(10,13,16)) +
      coord_cartesian(ylim=c(-1,1)) +
      theme_minimal(base_size = 18)

![](model_visualize_estimates_files/figure-markdown_strict/predicted%20main%20effect%20model.2-1.png)

### Interaction between target and domain

    ggplot(data.complete, aes(x = age, 
                              y = expected.2, 
                              group = interaction(subjectID, target, domain), 
                              color = target, 
                              linetype = domain)) +
      geom_point(size = .5, alpha = .1) + 
      geom_line(alpha = .1) + 
      geom_line(aes(y = expected_mean.2, group=interaction(target,domain)), size = 1.5, stat = 'smooth', method = 'lm', formula = y ~ poly(x,2)) + 
      facet_wrap(~parcellation, ncol = 2) +
      geom_hline(yintercept = 0, color = 'gray')+
      scale_color_manual(breaks = c('self', 'other'), values = c(self=palette[2], other=palette[1]))+
      scale_x_continuous(breaks=c(10,13,16)) +
      coord_cartesian(ylim=c(-1,1)) +
      theme_minimal(base_size = 18)

![](model_visualize_estimates_files/figure-markdown_strict/predicted%20interaction%20model.2-1.png)
