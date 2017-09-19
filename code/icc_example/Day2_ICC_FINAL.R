##############################################################################
##       Quick calculation of ICC after running  lme                        ##
##       By Megan Herting                                                   ##
##############################################################################

##Clear Environment
rm(list=ls())

##Turn off scientific notation
options(scipen=999)

##Run all necessary functional workshop scripts to create/load data.complete

## Load required packages 
packages <- c("ICC", "psych", "ggplot2", "nlme", "Hmisc", "multilevel", "lme4", "MuMIn","tidyr","dplyr")
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(packages, rownames(installed.packages())))  
}
lapply(packages, library, character.only = TRUE)


##Resource: MLM_R%20(1).pdf

##Load the data
data = read.table('results/ROI_analysis/parameterEstimates.txt', sep = " ", fill = TRUE, stringsAsFactors=FALSE)

# load age covariates and rename variables
age = read.csv('data/covariates/age.csv') %>%
  rename("subjectID" = Subj,
         "wave" = wavenum)
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

#Take every row in `age` that matches values in `data1` columns 'subjectID' and 'wave'
merged = left_join(data1, age, by = c('subjectID', 'wave')) %>%
  mutate(age_c = age-mean(age, na.rm=TRUE))

data.complete = merged %>%
  na.omit(.)

##Check which parcels are available
unique(data.complete$parcellation)

##Fitting with lme with nlme for brain region "292"
ICC_model.1 = lme(beta ~ 1, random=~1 | subjectID, data=filter(data.complete, parcellation == 292))
summary(ICC_model.1)

##See fixed effect and variance
print(summary(ICC_model.1))

##VarCorr() can be applied to a model to display a matrix of variance estimates and standard deviations for the two variance components in the model. 
##We're interested in comparing the amount of variance between each subject, i.e., (Intercept) variance, as compared
##to the total variance, (Intercept) + Residual
VarCorr(ICC_model.1)
varests=as.numeric(VarCorr(ICC_model.1)[1:2]) 
ICC.1 <- varests[1]/sum(varests)
ICC.1

##Fitting with lme with nlme for brain region "380"
ICC_model.2 = lme(beta ~ 1, random=~1 | subjectID, data=filter(data.complete, parcellation == 116))
summary(ICC_model.2)

##See fixed effect and variance
print(summary(ICC_model.2))

##VarCorr() can be applied to a model to display a matrix of variance estimates and standard deviations for the two variance components in the model. 
VarCorr(ICC_model.2)
varests=as.numeric(VarCorr(ICC_model.2)[1:2]) 
ICC.2 <- varests[1]/sum(varests)
ICC.2


##Or create a function and use it on 1000s of models!
ICClme <- function(out) {
  varests <- as.numeric(VarCorr(out)[1:2])
  return(paste("ICC =", varests[1]/sum(varests)))
}

lapply(list(ICC_model.1, ICC_model.2), ICClme)
