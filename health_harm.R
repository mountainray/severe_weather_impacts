set.seed(1234)
sample_refnum_list <- as.data.frame(sample(raw_us_storms$refnum, 10000))
names(sample_refnum_list) <- "refnum"
head(sample_refnum_list)

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
	       cropdmg, cropdmgexp)
	       
state_df <- data.frame(state.abb, state.region)
names(state_df) <- c("state", "region")
head(state_df)

us_storms2 <- us_storms%>%left_join(state_df) %>% mutate(totdmg=propdmg+cropdmg)

raw_us_storms%>%
	filter(propdmg > 0 | cropdmg > 0 | fatalities > 0 | injuries > 0) %>% 
	mutate(word_count=lengths(strsplit(str_trim(evtype, side = "both"), split = " ")))%>%
	summarize(max_words=max(word_count))

word1x <-c("astronomical","black","drifting","dry",
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

x <- raw_us_storms %>%
	filter(propdmg > 0 | cropdmg > 0 | fatalities > 0 | injuries > 0) %>%
	select(evtype) %>%
	distinct(evtype) %>%
	mutate(evtype_original = evtype) %>%
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
	mutate(new_event_words = str_c(word1, word2, word3, word4, word5, sep = " ")) %>%
	mutate(new_event_words2 = gsub("    ", " ", new_event_words)) %>%
	mutate(new_event_words3 = gsub("   ", " ", new_event_words2)) %>%
	mutate(new_event_words4 = gsub("  ", " ", new_event_words3)) %>% select(evtype_original, new_event_words4) %>%
	mutate(hail = grepl("hail", new_event_words4)) %>%
	mutate(fld = grepl("fld", new_event_words4)) %>%
	mutate(flood = grepl("flood", new_event_words4)) %>%
	mutate(wind = grepl("wind", new_event_words4)) %>%
	mutate(thu = grepl("thu", new_event_words4)) %>%
	mutate(tst = grepl("tst", new_event_words4)) %>%
	mutate(lightning = grepl("lightning", new_event_words4)) %>%
	mutate(ice = grepl("ice", new_event_words4)) %>%
	mutate(snow = grepl("snow", new_event_words4)) %>%
	mutate(hurri = grepl("hurri", new_event_words4)) %>%
	mutate(torn = grepl("torn", new_event_words4)) %>%
	mutate(winter_storm = grepl("winter storm", new_event_words4))
head(x, 20)

