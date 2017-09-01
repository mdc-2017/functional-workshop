# This script outputs the mean and median of the individual level acf estimates from second level RX residuals. 
# The decision to use the mean versus the median is up to the researcher and might be based on the 
# usual considerations (e.g., examining the distribution and/or presence of outliers). 

suppressWarnings(suppressMessages(library(dplyr)))

# load data
residual_file = commandArgs(trailingOnly = TRUE)[1]
residuals = read.table(residual_file)

# print first 6 lines of residuals file
cat('residuals file head:\n')
cat('-----------------------------------------------------\n')
head(residuals)

# remove FWHM values (i.e. take even acf rows and ignore odd fwhm values)
residuals.acf=residuals[(seq(2,to=nrow(residuals),by=2)),] 

# calculate means for each acf parameter
means = residuals.acf %>% summarize(mean1 = mean(V1, na.rm=TRUE), 
                                    mean2 = mean(V2, na.rm=TRUE), 
                                    mean3 = mean(V3, na.rm=TRUE))
medians = residuals.acf %>% summarize(median1 = median(V1, na.rm=TRUE), 
                                      median2 = median(V2, na.rm=TRUE), 
                                      median3 = median(V3, na.rm=TRUE))

# print means and medians
cat('\n 3dClustSim inputs:\n')
cat('-----------------------------------------------------\n')
cat('mean input for 3dClustSim: ', round(means[[1]],6), ' ', round(means[[2]],6), ' ', round(means[[3]],6), '\n')
cat('median input for 3dClustSim: ', round(medians[[1]],6), ' ', round(medians[[2]],6), ' ', round(medians[[3]],6), '\n')
