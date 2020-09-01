set.seed(1234)
#sample_refnum_list <- as.data.frame(sample(raw_us_storms$refnum, 10000))
#sample_refnum_list <- as.data.frame(sample(raw_us_storms$refnum, .1 * nrow(raw_us_storms)))
sample_refnum_list <- as.data.frame(sample(raw_us_storms$refnum, 1 * nrow(raw_us_storms)))
names(sample_refnum_list) <- "refnum"
str(sample_refnum_list)

state_df <- data.frame(state.abb, state.region)
names(state_df) <- c("state", "region")
head(state_df)

yearx_cutoff <- 1995

nrow(filter(raw_us_storms, (propdmg > 0 | cropdmg > 0 | fatalities > 0 | injuries > 0) & as.numeric(word(word(bgn_date,1,sep = " "),3,sep = "/"))>=1995))

sample_us_storms <- inner_join(raw_us_storms, sample_refnum_list, by = "refnum") %>%
	filter(propdmg > 0 | cropdmg > 0 | fatalities > 0 | injuries > 0) %>%
	left_join(state_df, by = "state") %>%
	mutate(bgn_datex=mdy_hms(bgn_date),
	       end_datex=mdy_hms(end_date),
	       yearx=year(bgn_datex),
	       monthx=month(bgn_datex),
	       storm_seconds=end_datex-bgn_datex,
	       storm_days=as.duration(storm_seconds)) %>% 
	filter(yearx >= yearx_cutoff) %>%
	select(refnum, region, state__:evtype, end_date, 
	       bgn_datex, end_datex, yearx, monthx, storm_seconds, storm_days,
	       fatalities, injuries,
	       propdmg, propdmgexp,
	       cropdmg, cropdmgexp) %>%
	mutate(evtype_original = evtype) %>%
	mutate(evtype=str_trim(tolower(evtype), side = "both")) %>%
	mutate(newpropdmg=ifelse(toupper(propdmgexp)=="K",
				 propdmg*1000,ifelse(toupper(propdmgexp)=="M",
				 		    propdmg*1000000, ifelse(toupper(propdmgexp)=="B",
				 		    			propdmg*1000000000,propdmg)))) %>%
	mutate(newcropdmg=ifelse(toupper(cropdmgexp)=="K",
				 cropdmg*1000,ifelse(toupper(cropdmgexp)=="M",
				 		    cropdmg*1000000, ifelse(toupper(cropdmgexp)=="B",
				 		    			cropdmg*1000000000,cropdmg)))) %>%
	mutate(economic_damage=newpropdmg+newcropdmg,
	       health_damage=fatalities+injuries)
head(sample_us_storms)
str(sample_us_storms)
count(sample_us_storms,yearx)

max_words_evtype <- raw_us_storms%>%
	filter(propdmg > 0 | cropdmg > 0 | fatalities > 0 | injuries > 0) %>% 
	mutate(word_count=lengths(strsplit(str_trim(tolower(evtype), side = "both"), split = " ")))%>%
	summarize(max_words=max(word_count))
max_words_evtype

word1x <-c("astronomical","black","drifting","dry","dense",
"downburst","excessive","extreme","flash","gusty",
"hard","heavy","high","light","mixed",
"record","severe","southeast",
#"storm",
"strong","summary","torrential","urban","sml",
"wild","wintry")

word2x<-c("advisory","august","damage","emily","erin",
"high","mix","precip","roads","weather","weather/mix")

word3x<-c("and","28","precip")

word4x<-c("heavy")

words_to_remove <- c(word1x, word2x, word3x, word4x, "hvy")

modified_evtype <- raw_us_storms %>%
	filter(propdmg > 0 | cropdmg > 0 | fatalities > 0 | injuries > 0) %>%
	select(evtype) %>%
	distinct(evtype) %>%
	mutate(evtype_original = evtype) %>%
	mutate(evtype = str_trim(tolower(evtype), side = "both")) %>%
	mutate(evtype = gsub("/", " ", evtype)) %>%
	mutate(evtype = gsub("-", " ", evtype)) %>%
	mutate(
		word1 = word(evtype, 1),
		word2 = word(evtype, 2),
		word3 = word(evtype, 3),
		word4 = word(evtype, 4),
		word5 = word(evtype, 5)) %>%
	mutate(
		word1 = ifelse(is.na(word1) == TRUE, "", str_trim(tolower(word1), side = "both")),
		word2 = ifelse(is.na(word2) == TRUE, "", str_trim(tolower(word2), side = "both")),
		word3 = ifelse(is.na(word3) == TRUE, "", str_trim(tolower(word3), side = "both")),
		word4 = ifelse(is.na(word4) == TRUE, "", str_trim(tolower(word4), side = "both")),
		word5 = ifelse(is.na(word5) == TRUE, "", str_trim(tolower(word5), side = "both"))) %>%
	mutate(word1 = ifelse(word1 %in% words_to_remove, "", word1)) %>%
	mutate(word2 = ifelse(word2 %in% words_to_remove, "", word2)) %>%
	mutate(word3 = ifelse(word3 %in% words_to_remove, "", word3)) %>%
	mutate(word4 = ifelse(word4 %in% words_to_remove, "", word4)) %>%
	mutate(word5 = ifelse(word5 %in% words_to_remove, "", word5)) %>%
	mutate(new_event_words = str_c(word1, word2, word3, word4, word5, sep = " ")) %>%
	mutate(new_event_words2 = gsub("    ", " ", new_event_words)) %>%
	mutate(new_event_words3 = gsub("   ", " ", new_event_words2)) %>%
	mutate(new_event_words4 = gsub("  ", " ", new_event_words3)) %>% 
	mutate(evtype_modified=str_trim(new_event_words4, side = "both")) %>%
	select(evtype_original, evtype_modified) %>%
	mutate(hail = grepl("hail", evtype_modified)) %>%
	mutate(fld = grepl("fld", evtype_modified)) %>%
	mutate(flood = grepl("flood", evtype_modified)) %>%
	mutate(wind = grepl("wind", evtype_modified)) %>%
	mutate(thu = grepl("thu", evtype_modified)) %>%
	mutate(tst = grepl("tst", evtype_modified)) %>%
	mutate(lightning = grepl("lightning", evtype_modified)) %>%
	mutate(ice = grepl("ice", evtype_modified)) %>%
	mutate(snow = grepl("snow", evtype_modified)) %>%
	mutate(hurri = grepl("hurri", evtype_modified)) %>%
	mutate(torn = grepl("torn", evtype_modified)) %>%
	mutate(winter_storm = grepl("winter storm", evtype_modified))
head(modified_evtype, 20)
count(modified_evtype, hurri)

#yearx_cutoff <- 1995

us_storms_final <- sample_us_storms %>% 
	# filter((economic_damage>0 | health_damage>0) & yearx >= yearx_cutoff) %>%
#	filter(economic_damage>0 & yearx >= yearx_cutoff) %>%
	left_join(modified_evtype, by = "evtype_original") %>% 
#	mutate(new_event_words4=str_trim(new_event_words4, side = "both")) %>%
	mutate(evtype_modified_final=ifelse(hurri==TRUE, "hurricane",
				       ifelse(fld==TRUE | flood==TRUE, "flood",
				              ifelse(hail==TRUE, "thunderstorm hail",
				              ifelse(lightning==TRUE, "thunderstorm lightning",
				              ifelse((thu==TRUE | tst==TRUE) & wind==FALSE & lightning==FALSE, "thunderstorm",
				                     ifelse((thu==TRUE | tst==TRUE) & wind==TRUE, "thunderstorm wind",
				                            ifelse((thu==TRUE | tst==TRUE) 
				                                   #& wind==FALSE 
				                                   & lightning==TRUE, "thunderstorm lightning",
				                            ifelse(evtype_modified %in% c("forest fire", "forest fires", "wildfire"), 
				                                   "forest fire",
				                            ifelse(evtype_modified %in% c("snow", "blizzard", "snow sleet freezing rain","winter","winter storm"), 
				                                   "winter snow",
				                            evtype_modified))))))))))
str(us_storms_final)
us_storms_final%>%count(evtype, evtype_modified_final)

top_n_filter_e <- 10
top_n_filter_e <- 15
top_n_filter_h <- 15

top_harmful_economic_evtypes <- filter(us_storms_final, economic_damage>0) %>%
	group_by(evtype_modified_final)%>%
	summarize(economic_damage2=sum(economic_damage), 
		  mean_economic_damage2=mean(economic_damage), 
		  neconomic_damage2=n()) %>% 
	arrange(desc(economic_damage2))
#	arrange(desc(mean_economic_damage2))

#top_n_harmful_economic_events <- top_harmful_economic_evtypes[1:top_n_filter,"evtype_modified_final"]
top_n_harmful_economic_events <- top_harmful_economic_evtypes[1:top_n_filter_e,"evtype_modified_final"]
top_n_harmful_economic_events

top_harmful_health_evtypes <- filter(us_storms_final, health_damage>0) %>%
	group_by(evtype_modified_final)%>%
	summarize(health_damage2=sum(health_damage), 
		  mean_health_damage2=mean(health_damage), 
		  nhealth_damage2=n()) %>% 
	arrange(desc(health_damage2))
#	arrange(desc(mean_health_damage2))
sum(top_harmful_health_evtypes$health_damage2)
top_n_harmful_health_events <- top_harmful_health_evtypes[1:top_n_filter_h,c("evtype_modified_final","health_damage2")]
#top_n_harmful_health_events <- top_harmful_health_evtypes[1:15,"evtype_modified_final"]
top_n_harmful_health_events

economic <- filter(us_storms_final, economic_damage>0) %>%
#	filter(yearx>=1995)%>% 
	inner_join(top_n_harmful_economic_events, by = "evtype_modified_final") %>%
#	group_by(yearx, region, evtype_modified_final)%>%
	group_by(yearx, evtype_modified_final)%>%
#	group_by(new_event_words5)%>%
	summarize(economic_damage2=sum(economic_damage), 
		  mean_economic_damage2=mean(economic_damage), 
		  neconomic_damage2=n(),
		  xxxlog=log10(economic_damage2)) %>% 
	arrange(desc(economic_damage2))
#	arrange(desc(mean_economic_damage2))
print(economic,n=10)

nrow(filter(us_storms_final, health_damage>0))
health <- filter(us_storms_final, health_damage>0) %>%
#	filter(yearx>=1995)%>% 
	inner_join(top_n_harmful_health_events, by = "evtype_modified_final") %>%
#	group_by(yearx, region, evtype_modified_final)%>%
	group_by(yearx, evtype_modified_final)%>%
#	group_by(new_event_words5)%>%
	summarize(health_damage2=sum(health_damage), 
		  mean_health_damage2=mean(health_damage), 
		  nhealth_damage2=n(),
		  xxxlog=log10(health_damage2)) %>% ungroup %>%
	arrange(desc(health_damage2))
#	arrange(desc(mean_health_damage2))
nrow(health)
print(health,n=top_n_filter_h)

sum(economic$economic_damage2)/sum(sample_us_storms$economic_damage)
sum(health$health_damage2)/sum(sample_us_storms$health_damage)
sum(sample_us_storms$injuries)
sum(sample_us_storms$fatalities)
sum(raw_us_storms$injuries)
sum(raw_us_storms$fatalities)

filter(sample_us_storms, health_damage>0 & yearx>=yearx)%>%summarize(sumx=sum(injuries))


options(scipen = 5)

ggplot(economic) +
	geom_col(mapping = aes(x=yearx, 
#			      y=xxxlog, 
			      y=economic_damage2, 
			      fill=evtype_modified_final), alpha=.7) + 
	scale_y_log10() +
#	facet_wrap("evtype_modified_final")
	facet_wrap(vars("ice storm", "cold"))

ggplot(health) +
	geom_col(mapping = aes(x=yearx, 
#			      y=xxxlog, 
			      y=health_damage2, 
			      fill=evtype_modified_final), alpha=.7) + 
	scale_y_log10() +
	facet_wrap("evtype_modified_final")

