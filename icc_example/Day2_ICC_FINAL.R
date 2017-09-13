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
packages <- c("ICC", "psych", "ggplot2", "nlme", "Hmisc", "multilevel", "lme4", "MuMIn")
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(packages, rownames(installed.packages())))  
}
lapply(packages, library, character.only = TRUE)


##Resource: MLM_R%20(1).pdf


##Fitting with lme with nlme for brain region "66"
ICC_model.1 = lme(beta ~ wave, random=~1 | subjectID, data=filter(data.complete, parcellation == 66))
summary(ICC_model.1)

##See fixed effect and variance
print(summary(ICC_model.1))

##VarCorr() can be applied to a model to display a matrix of variance estimates and standard deviations for the two variance components in the model. 
VarCorr(ICC_model.1)
varests=as.numeric(VarCorr(ICC_model.1)[1:2]) 
ICC.1 <- varests[1]/sum(varests)
ICC.1

##Fitting with lme with nlme for brain region "380"
ICC_model.2 = lme(beta ~ wave, random=~1 | subjectID, data=filter(data.complete, parcellation == 380))
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
