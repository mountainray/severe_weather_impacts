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

require(tidyverse)
require(lubridate)
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
raw_us_storms <- read.csv(raw_file_name, stringsAsFactors = FALSE)
head(raw_us_storms)
names(raw_us_storms) <- tolower(names(raw_names))
str(raw_us_storms)

nrow(raw_us_storms)
new_refnum <- as.data.frame(seq(1:nrow(raw_us_storms)))
names(new_refnum) <- "new_refnum"
head(new_refnum)

check_refnum <- raw_us_storms %>% select(refnum) %>% inner_join(new_refnum, by = c("refnum"="new_refnum"))
head(check_refnum)
nrow(raw_us_storms) == nrow(check_refnum)

set.seed(1234)
#sample_refnum_list <- as.data.frame(sample(raw_us_storms$refnum, 10000))
sample_refnum_list <- as.data.frame(sample(raw_us_storms$refnum, 1 * nrow(raw_us_storms)))
names(sample_refnum_list) <- "refnum"
head(sample_refnum_list)

distinct_evtype_lowercase <- distinct(raw_us_storms, tolower(evtype))

us_storms <- inner_join(raw_us_storms, sample_refnum_list, by = "refnum") %>%
	mutate(bgn_datex=mdy_hms(bgn_date),
	       end_datex=mdy_hms(end_date),
	       yearx=year(bgn_datex),
	       monthx=month(bgn_datex),
	       storm_seconds=end_datex-bgn_datex,
	       storm_days=as.duration(storm_seconds)) %>% 
	select(refnum, state__:evtype, end_date, 
	       bgn_datex, end_datex, yearx, monthx, storm_seconds, storm_days,
	       fatalities, injuries,
	       propdmg, propdmgexp,
	       cropdmg, cropdmgexp) %>%
	       
#str(us_storms)

distinct_evtype_modified <- distinct(raw_us_storms, evtype) %>% 
	mutate(evtypex=tolower(str_trim(evtype, side = "both"))) %>% 
	distinct(evtype, evtypex) %>% arrange(evtypex)

distinct_evtype_modified <- distinct(raw_us_storms, evtype)

all_no_impact <- filter(us_storms, propdmg==0 & cropdmg == 0 & fatalities ==0 & injuries == 0)
count(all_no_impact, evtype)


all_impact <- filter(us_storms, propdmg>0 | cropdmg > 0 | fatalities >0 | injuries > 0) %>% 
	mutate(evtype=tolower(evtype)) %>%
		count(evtype)
nrow(all_impact)

first_words <- all_impact %>% mutate(evtype_first_word=word(evtype,1)) %>% distinct(evtype_first_word)
first_words

all_impactx <- filter(us_storms, propdmg>0 | cropdmg > 0 | fatalities >0 | injuries > 0) %>% 
	mutate(
	evtype_original=evtype,
	evtype=tolower(evtype),
	evtype1=ifelse(word(evtype,1) %in% c("dense",
"excessive",
"extreme",
"gusty",
"heavy",
"high",
"light",
"record",
"severe",
"strong",
"urban/sml"), word(evtype,2,-1), evtype)) %>% 
	mutate(evtype1=gsub("thunderstorm", "tstm", evtype1)) %>%
	mutate(evtype1=gsub("tstrm", "tstm", evtype1)) %>%
count(evtype_original, evtype1)
count(all_impactx, evtype_original, evtype1)

all_impact2 <- 
	filter(us_storms, propdmg>0 | cropdmg > 0 | fatalities >0 | injuries > 0) %>% 
	mutate(	evtype_original=evtype,
		evtype=tolower(evtype),
evtype1=ifelse(word(evtype,1) %in% c("dense",
"excessive",
"extreme",
"gusty",
"heavy",
"high",
"light",
"record",
"severe",
"strong",
"urban/sml"), word(evtype,2,-1), evtype)) %>% 
	mutate(evtype1=gsub("thunderstorm", "tstm", evtype1)) %>%
	mutate(evtype1=gsub("tstrm", "tstm", evtype1)) %>%
#	mutate(evtype=tolower(evtype_original)) %>%
	mutate(evtype2=ifelse(evtype1 %in% c("cold", "cold/wind chill", "extreme cold"), "extreme cold/wind chill", evtype1)) %>%
	mutate(evtype2=ifelse(evtype1 %in% c("storm surge"), "coastal flood", evtype1)) %>%
# 	mutate(evtype2=ifelse(evtype1 %in% c("cold", "cold/wind chill", "extreme cold"), "extreme cold/wind chill", evtype1)) %>%
	mutate(evtype2=ifelse(evtype1 %in% c("flood","river flood","flooding", "flood/flash flood",
					     "urban/sml stream fld","flash flooding","flood/flash flood"),"flood", evtype1)) %>%
	mutate(evtype2=ifelse(evtype1 %in% c("hail 175"), "hail", evtype1)) %>%
	mutate(evtype2=ifelse(evtype1 %in% c("heat"), "heat wave", evtype1)) %>%
	mutate(evtype2=ifelse(evtype1 %in% c("high surf"), "heavy surf/high surf", evtype1)) %>%
	mutate(evtype2=ifelse(evtype1 %in% c("high winds"), "high wind", evtype1)) %>%
	mutate(evtype2=ifelse(evtype1 %in% c("hurricane emily","hurricane erin"), "hurricane", evtype1)) %>%
	mutate(evtype2=ifelse(evtype1 %in% c("ice roads"), "ice storm", evtype1)) %>%
	mutate(evtype2=ifelse(evtype1 %in% c("marine thunderstorm wind"), "marine tstm wind", evtype1)) %>%
	mutate(evtype2=ifelse(evtype1 %in% c("record snow", "heavy snow"), "excessive snow", evtype1)) %>%
	mutate(evtype2=ifelse(evtype1 %in% c("rip current"), "rip currents", evtype1)) %>%
	mutate(evtype2=ifelse(evtype1 %in% c("strong winds", "strong wind"), "high wind", evtype1)) %>%
	mutate(evtype2=ifelse(evtype1 %in% c("torrential rainfall"), "heavy rain", evtype1)) %>%
	mutate(evtype2=ifelse(evtype1 %in% c("thunderstorm winds", "thunderstorm wind", "thunderstorm wind", "severe thunderstorm"), "tstm wind", evtype1)) %>%
	mutate(evtype2=ifelse(evtype1 %in% c("tstrm wind/hail"), "hail", evtype1)) %>%
	mutate(evtype2=ifelse(evtype1 %in% c("wild/forest fire","forest fires"), "wildfire", evtype1)) %>%
	mutate(evtype2=ifelse(evtype1 %in% c("winter weather/mix", "winter weather", "snow/sleet/freezing rain"), "winter storm", evtype1)) %>%
	count(evtype_original, evtype1, evtype2)
nrow(all_impact2)
all_impact3<-all_impact2%>%count(evtype_original, evtype1, evtype2)

head(us_storms)
head(count(us_storms, storm_seconds))
head(count(us_storms, storm_days))

ggplot(filter(us_storms,storm_days>0)) +
	geom_freqpoly(mapping = aes(x=storm_days, color = evtype)) +
	scale_x_continuous(breaks = c(1:30*86400), labels = as.character(c(1:30)))

count(filter(us_storms,fatalities>0),evtype)
ggplot(filter(us_storms,fatalities>0)) +
	geom_freqpoly(mapping = aes(x=fatalities, color = evtype))


ggplot(filter(us_storms,injuries>0)) +
	geom_freqpoly(mapping = aes(x=injuries, color = evtype))

ggplot(filter(us_storms,propdmg>0)) +
	geom_freqpoly(mapping = aes(x=propdmg, color = evtype))

ggplot(filter(us_storms,cropdmg>0)) +
	geom_freqpoly(mapping = aes(x=cropdmg, color = evtype))

