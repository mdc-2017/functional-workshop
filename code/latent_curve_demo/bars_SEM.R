###
# This script uses the sparse voxel data for the rew > neu contrasts as the basis for
# a linear latent curve model implemented in lavaan. I demonstrate exporting both model parameters
# and a few fit statistics. A real-world application would also need to grapple with model convergence issues,
# model comparison (e.g., linear versus quadratic), and model diagnostics.
#
# The dataset structure is:
#   <ID>/<visit_number>_<scan_date>/contrasts/<id>_<visit_number>_<scan_date>_stats+tlrc.HEAD
#   Example: 10783/1_20100330/contrasts/10783_1_20100330_stats+tlrc.HEAD
#
# Author: Michael Hallquist
# Dataset courtesy of the Laboratory for Neurocognitive Development (Director: Bea Luna)

setwd("~/flux_demo")
library(pacman)
p_load(tidyverse, reshape2, lavaan, gdata, pracma)

#used cached data if possible (saves run-time)
if (file.exists("group_voxel_sparse_14Sep2017.RData")) {
  load("group_voxel_sparse_14Sep2017.RData")
} else {
  source("read_glms.R")
}

#the imaging data are stored in sparse_data_intersection, which is visits x statistics x voxels
#at present, there are 397 visits, 3 statistics (B, t, and F), and 59325 voxels

#metadata contains all visit-level information
#here, we will use only age (time-varying) and sex (time-invariant)

#we now need to figure out how to index the data in terms of ids and ages
#SEM works with 'wide' format data in which repeated measurements for a person are stored on the columns 
str(metadata)

#for prototyping reshaping operations and understanding data structure
metadata$voxTest <- 1:nrow(metadata)

#add 'a' prefix to age by years for clarity in variable naming after reshaping
metadata <- metadata %>% mutate(
  age_yr_char=paste0("a", age_yr),
  female=ifelse(sex=="M", 0, 1)) #dummy code 0/1 sex variable

#reshape metadata to be by visit, columns v1-v4 (not currently used in analyses below; here for reference)
byvisit <- metadata %>% mutate(visit_number=paste0("v", visit_number)) %>%
  select(id, visit_number, voxTest) %>%
  spread(key=visit_number, value=voxTest)

#re-organize data by year (columns)
byyear <- metadata %>% 
  select(id, sex, age_yr_char, voxTest) %>% 
  spread(key=age_yr_char, value=voxTest)

#check the number of observations at each age
sapply(byyear, function(x) { sum(!is.na(x)) })

#now we need a very wide data structure... that may be pretty gosh-darn sparse but is okay
#in principle with FIML under missing by design. This is an ad hoc accelerated design (different starting ages).
nvox <- dim(sparse_data_intersection)[3]

#visualize your data! What are the properties of the dependent variable we're modeling?
#here is a random set of 49 betas
sampVox <- sample(1:dim(sparse_data_intersection)[3], size=49)

toplot <- reshape2::melt(sparse_data_intersection[,"rew_neu_GLT#0_Coef",sampVox])

ggplot(toplot, aes(x=value)) + geom_histogram(bins=12) + facet_wrap(~voxel, scales="free_x")

#Note the potent outliers, which are rare, but clearly evident across voxels.
#In a substantive analysis, we would pursue these to diagnose problems in specific datasets.
#For example, these outlying coefficients may be concentrated in just a few datasets and
#   may reflect a subject with motion artifacts or an error in model specification.

#For now, let's Winsorize at 2% (top and bottom) and see what it looks like
sparse_data_intersection <- apply(sparse_data_intersection, c(2,3), function(v) {
  psych::winsor(v, trim=0.02)
})

toplot <- reshape2::melt(sparse_data_intersection[,"rew_neu_GLT#0_Coef",sampVox])

#this is (much!) better -- approx. Gaussian distribution of activity
ggplot(toplot, aes(x=value)) + geom_histogram(bins=12) + facet_wrap(~voxel, scales="free_x")

#use the foreach + do packages for parallelism
library(doParallel)

#can scale up to the number of cores on a node (e.g., 40)
#for more parallel power, would suggest neuropointillist
clus <- makeCluster(8)
registerDoParallel(clus)

#names of dependent variables (activity by age)
#to help with model convergence, we will subset the data to a smaller age interval: 15-21
#the full interval was leading to nonconvergence in many cases (would need to do more intensive diagnostics)

#for full set
#ages <- sort(unique(metadata$age_yr))
#agevars <- grep("a\\d+", names(byyear), value=TRUE)

age_min <- 15
age_max <- 21
ages <- age_min:age_max
agevars <- paste0("a", ages)

age_center <- 18 #you choose this! this affects the interpretation of intercept (level of activity at *what age*)
linear_time_scores <- ages - age_center

#build lavaan model syntax (this does not vary by voxel, so should be left outside the voxel loop)
model_syntax <- paste(
  "i =~ ", paste0("1*", agevars, collapse=" + "),
  "s =~ ", paste0(linear_time_scores, "*", agevars, collapse=" + "),
  "i ~ female",
  sep="\n"
)

results <- foreach (v = 1:nvox, .packages = c("dplyr", "lavaan", "tidyr")) %dopar% {
  #add voxel values into metadata, then reshape for latent growth (wide)
  #ideally, the computation inside this for loop should be profiled for speed (since it runs so many times)
  df <- metadata %>% select(id, age_yr, age_yr_char, female) %>%
    bind_cols(data.frame(vox=sparse_data_intersection[,"rew_neu_GLT#0_Coef", v])) %>%
    filter(between(age_yr, age_min, age_max)) %>%
    select(id, female, age_yr_char, vox) %>% 
    spread(key=age_yr_char, value=vox)
  
  fitted_model <- tryCatch(growth(model=model_syntax, data=df, estimator="ML", missing="ml",
                             control=list(iter.max=5000, rel.tol=1e-4), verbose=FALSE),
                           error=function(e) { return(NULL) })
  
  if (!is.null(fitted_model)) {
    #reorganize model parameters into a data.frame with a numeric value and a unique name for AFNI (vname)
    parameters <- filter(parTable(fitted_model), free > 0) %>% select(lhs, op, rhs, est, se) %>%
      mutate(parname=paste0(lhs, op, rhs)) %>% select(-lhs, -op, -rhs) %>% mutate(z=est/se) %>%
      filter(!grepl("a.*~~a.*", parname)) %>% #drop error covariances for now
      reshape2::melt(id.var="parname") %>% 
      mutate(vname=paste(parname, variable, sep="_")) %>% arrange(vname)
  
    #flatten into a named vector of values  
    ret <- parameters$value
    names(ret) <- parameters$vname
    
    #add model fit statistics
    fitstats <- tryCatch(fitMeasures(fitted_model), error=function(e) { return(c())})
    retcoef <- c(ret, fitstats[c("chisq", "pvalue", "rmsea", "srmr", "cfi")])
  } else {
    retcoef <- c() #should make the return more consistent so that it is an empty named vector of the same form
  }
  
  retcoef #return named vector of all relevant statistics at each voxel
}

stopCluster(clus)

#now we need to put all of these statistics back onto the brain
#I would recommend moving toward neuropointillist to make this less laborious
#The code above shows how lavaan results can be saved into a vector of values per voxel.
#   This is compatible with the processVoxel approach of neuropointillist and could be adapted
#   to eliminate having to handle the file I/O and voxel loop.

#bind together statistics into rectangular data.frame
#fill non-overlapping columns (e.g., model nonconvergence with NA)
results <- do.call(bind_rows, results)

#drop standard errors for now (reduce number of sub-BRIKs in output)
results <- select(results, -contains("_se"))

#use the header from one subject's dataset as a starting place, then modify to suit our outputs
group_4d <- readAFNI("10128/1_20080925/contrasts/10128_1_20080925_stats+tlrc")

#put our statistics back into the 3d voxel cube, not the sparse vector of voxels
#use the mask indices to do this work
group_4d@.Data <- array(0, c(dim(group_4d)[1:3], ncol(results))) #initialize empty 4-D array using 3-D xyz size of original data
group_4d@DATASET_RANK=c(3L, as.integer(ncol(results)))
group_4d@TAXIS_NUMS=c(as.integer(ncol(results)), 0L)
group_4d@BRICK_LABS <- paste(make.names(names(results)), collapse="~") #naming of subbriks in output
group_4d@BRICK_TYPES=rep(3L, ncol(results)) #float storage for data
group_4d@IDCODE_STRING="lavaan_demo"

#tag z statistics so that the p-values are displayed in AFNI
#STATAUX of 5 is z-score ('fizt'), 0 is generic value
#for z, the syntax is subbrik, 5, 0 where 0 represents no ancillary statistical information (e.g., df)
group_4d@BRICK_STATAUX=gdata::unmatrix(cbind(grep("_z$", names(results)) - 1, 5, 0), byrow=TRUE)
group_4d@BRICK_FLOAT_FACS=rep(0, ncol(results)) #scaling factor should be zero for stats (readAFNI chokes without this)
group_4d@HISTORY_NOTE = ""

#tile maskIndices ncol(voxResults) times and add 4th dim col
maskIndices4d <- cbind(pracma::repmat(as.matrix(intersectmask[1:nrow(results),]), ncol(results), 1),
                       rep(1:ncol(results), each=nrow(results)))

#replace NAs with 0 so that AFNI displays things as expected (NAs are treated strangely)
results[is.na(results)] <- 0

#insert results into 4d array
group_4d[maskIndices4d] <- as.matrix(results)

#write AFNI statistics for lavaan to file
writeAFNI(group_4d, "lavaan_demo+tlrc")
