# initial code to read and do some eda...

# Obtain the raw data from this website (get_the_source)

# load required packages, check if they exist first
# this needs a better solution...
# if (max(grepl("tidyverse", installed.packages()[, 1])) == FALSE)
# 	{install.packages("tidyverse")}
# require(tidyverse)
# install.packages("R.utils")
# library(R.utils)
#remove.packages("tidyverse")

# File naming details.
raw_link <- "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2FStormData.csv.bz2"
raw_zip_file_name <- "StormData.csv.bz2"
raw_file_name <- "StormData.csv"

# Get the file if necessary.
ifelse(file.exists(raw_zip_file_name) == FALSE,
       download.file(raw_link, raw_zip_file_name),
       "file exists...you are good to go")

# Make .csv available to examine raw data.
# The data in the beginning looks simple, but later in the raw file very large 
# text items, including large blank space are observed.
ifelse(file.exists(raw_file_name) == FALSE,
       bunzip2(raw_zip_file_name),
       "StormData.csv exists")

raw_names <- read.csv(raw_file_name, header=TRUE, nrows = 1)
raw_storms <- read.csv(raw_file_name)
names(raw_storms) <- tolower(names(raw_names))

nrow(raw_storms)
set.seed(1234)
sample_refnum_list <- as.data.frame(sample(raw_storms$refnum, 1000))
#sample_refnum_list <- as.data.frame(sample(raw_storms$refnum, .05 * nrow(raw_storms)))
names(sample_refnum_list) <- "refnum"
head(sample_refnum_list)
storms <- inner_join(raw_storms, sample_refnum_list, by = "refnum") %>% 
	select(state__:evtype, end_date, refnum) %>%
	mutate(bgn_datex=as.Date(word(bgn_date,1,sep = " "), "%d/%M/%Y"),
	       end_datex=as.Date(word(end_date,1,sep = " "), "%d/%M/%Y")) %>%
	mutate(yearx=format(as.Date(bgn_datex), "%Y"),
	       monthx=format(as.Date(bgn_datex), "%m"),
	       dayx=format(as.Date(bgn_datex), "%d"),
	       length_storm_days=end_datex-bgn_datex)
head(storms)
count(storms, length_storm_days)
count(storms, yearx)
str(storms)

#view(raw_storms)
#str(raw_storms)
head(raw_storms)

nrow(raw_storms)
raw_storms[902297,]
# count(raw_storms, STATE__)
# count(months (as.Date(raw_storms$BGN_DATE, "%m/%d/%Y %H:%M:%S")))

# x<-raw_storms$REFNUM
# y<-seq(1:nrow(raw_storms))
# min(x-y)=max(x-y)

# raw_storms[188267,]%>%select(STATE__:EVTYPE, REFNUM)%>%filter(REFNUM!=lag(REFNUM+1))%>%head(100)
# 
# ggplot(raw_storms, mapping = aes(x=as.Date(BGN_DATE, "%m/%d/%Y %H:%M:%S"), y=REFNUM)) +
# 	geom_jitter(alpha=.5)
	

