###
# This script imports GLM statistics from single-subject, single-visit models
# run using 3dDeconvolve. The results is a sparse storage format of subjects x statistics x voxels.
# This format is both better for RAM overhead (don't store non-brain voxels) and easier to parallelize.
#
# The dataset structure is:
#   <ID>/<visit_number>_<scan_date>/contrasts/<id>_<visit_number>_<scan_date>_stats+tlrc.HEAD
#   Example: 10783/1_20100330/contrasts/10783_1_20100330_stats+tlrc.HEAD
#
# Author: Michael Hallquist
# Dataset courtesy of the Laboratory for Neurocognitive Development (Director: Bea Luna)

library(pacman)
p_load(oro.nifti, tidyverse, abind) #load/install packages

basedir <- "~/flux_demo" #set this to where the raw data are stored
setwd(basedir)

#identify all raw datasets
glm_stats <- sub("\\.HEAD$", "", list.files(path=basedir, pattern=".*_stats\\+tlrc\\.HEAD", recursive=TRUE, full.names=FALSE))

#extract data from file names (i.e., id, scan_date, and visit_number)
id <- sub("^(\\d+)/.*", "\\1", glm_stats, perl=TRUE)
scan_date <- as.Date(sub("^\\d+/[123]_(\\d+)/contrasts.*", "\\1", glm_stats, perl=TRUE), format="%Y%m%d")
visit_number <- sub("^\\d+/([1-9])+_\\d+/contrasts.*", "\\1", glm_stats, perl=TRUE)
today <- format(Sys.Date(), "%d%b%Y") #today's date, used for labeling files

#build data.frame of file information
file_info <- data.frame(file=glm_stats, id=id, scan_date=scan_date, visit_number=visit_number, row_number=1:length(id), stringsAsFactors = FALSE)

#Read in separate meta data containin age and sex of participants
#Rename columns and convert date into explicit date type
#Note that date and id initially import as an integers.
metadata_full <- read.table("ageSex.txt", header=TRUE, stringsAsFactors = FALSE) %>%
  rename(id=luna, scan_date=date) %>%
  mutate(
    scan_date=as.Date(as.character(scan_date), format="%Y%m%d"), 
    id=as.character(id),
    age_yr=round(age)) %>% #round to even years for 'wide' format latent curve modeling
  distinct() #there is one duplicated entry for 10758 -- drop to avoid flaky behavior downstream

#for now, we are doing an 'inner join,' meaning we require both scan data and metadata
metadata <- inner_join(file_info, metadata_full, by=c("id", "scan_date")) %>%
  filter(visit_number < 4) %>% #only one person with 4 visits -- cannot analyze them in a visit-wise analysis
  arrange(id, visit_number) %>% #order data frame to promote clarity
  filter(!(id == "10594" & scan_date=="2008-09-12")) #this is the person mentioned below who has horrible missingness wrt group mask

#there are some subjects who have scan data, but no metadata, and vice versa
#we should document these and work with RAs in the Luna lab diagnose the problem
#subjects with metadata, but no scan data
nostats <- anti_join(metadata_full, file_info, by=c("id", "scan_date"))
write.csv(nostats, file=paste0("missing_statistics", today, ".csv"))

#subjects with scan data, but no metadata
nometadata <- anti_join(file_info, metadata_full, by=c("id", "scan_date"))
write.csv(nometadata, file=paste0("missing_metadata", today, ".csv"))

#next, we can examine the number of people who have data for each visit
xtabs(~visit_number, metadata)

#id-level info of visits
xtabs(~visit_number + id, metadata)

#We want a reasonable number of observations at each age to avoid 
#imprecise estimates (and potentially high leverage) at the edge of the age interval
table(metadata$age_yr)

#we see that there are only:
#  4 10yo
#  3 27yo
#  1 29yo

#this may be something for a sensitivity analysis (does it matter if we include/exclude?)
#for now, we will restrict to the age range of 11-26, inclusive
metadata <- filter(metadata, between(age_yr, 11, 26))

#function to read in a single dataset
#use ... to pass through any metadata columns from file_info
readdf <- function(file, ...) { #id, scan_date, visit_number
  require(oro.nifti)
  s <- readAFNI(file)
  briklabs <- strsplit(s@BRICK_LABS, "~")[[1]]
  rew_neu <- grep("rew_neu_GLT", briklabs) #retain only rew > neu contrast
  s <- s[,,,rew_neu] #only retain sub-briks of interest
  dimnames(s)[[4]] <- briklabs[rew_neu]
  
  #define a mask based on non-zero values of the rew_neu_GLT_Coef brik
  mask <- data.frame(which(s[,,,1] != 0, arr.ind=TRUE))
  return(list(s=s, mask=mask, ...)) #id=id, scan_date=scan_date, visit_number=visit_number, mask=mask
}

#if you're on a parallel file system, you can use the multidplyr package to speed up data import
data_list <- pmap(metadata, readdf)
names(data_list) <- paste(metadata$id, metadata$scan_date, sep="_") #tag the datset with id and scan_date to identify each list element

#obtain a list of all masks (non-zero values)
masks <- lapply(data_list, "[[", "mask")

#reshape voxelwise to 5-D array: subjects, x, y, z, brik
all_data <- abind(lapply(data_list, "[[", "s"), along=0)

rm(data_list) #cleanup up full data list to reduce RAM overhead

#use dplyr intersection and union functions to find mask indices in common
#intersection
intersectmask <- Reduce(function(...) { intersect(...) }, masks)

#union
unionmask <- Reduce(function(...) { union(...) }, masks)

#look at subjects who are missing data compared to the union
#this often helps to flag QA problems
metadata$mask_missing <- sapply(masks, function(m, group) { 
  nrow(suppressMessages(anti_join(group, m))) }, unionmask)

ggplot(metadata, aes(x=mask_missing)) + geom_histogram(bins=12)

#there was one subject with a ridiculous number of missing voxels (now excluded above)
#he/she is reducing coverage in the group mask, so is dropped above pending further diagnostics
filter(metadata, mask_missing > 10000) #this should return 0 rows now that 10594 is dropped above

#Convert into a sparse storage format with a vector of voxel values
#Apply over subjects (1st dimension) and brik/statistic (5th dimension)
#  and only retain the vector of voxels in the intersection mask.
#The output of this will be voxels, subjects, statistics.
#This throws away all voxels outside the mask so that we don't have to store them in memory
sparse_data_intersection <- apply(all_data, c(1, 5), function(v3d) { v3d[as.matrix(intersectmask)] })

rm(all_data) #cleanup 5-D array

#reshape to subjects, statistics, voxels and label for clarity
sparse_data_intersection <- aperm(sparse_data_intersection, c(2,3,1))
dimnames(sparse_data_intersection)[[3]] <- paste0("vox", 1:dim(sparse_data_intersection)[3])
names(dimnames(sparse_data_intersection)) <- c("id_date", "statistic", "voxel")

#save snapshot of group data for analysis
save(sparse_data_intersection, unionmask, intersectmask, metadata, 
     file=paste0("group_voxel_sparse_", today, ".RData"))