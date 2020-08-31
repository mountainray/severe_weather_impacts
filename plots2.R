# raw_us_storms%>% filter(propdmg>2000)
# ggplot(filter(us_storms2, state=="IL")) +
# 	geom_jitter(mapping = aes(x=yearx, y=propdmg, color = region, size=propdmg), show.legend = TRUE) +
# 	scale_x_continuous(breaks = seq(min(us_storms2$yearx),max(us_storms2$yearx), 5)) +
# 	scale_y_continuous(breaks = seq(0,2000,250))

# page 12 of detailed documentation...
# Alphabetical characters used to signify magnitude include “K” 
# for thousands, “M” for millions, and “B” for billions.
prop <- us_storms2%>%select(yearx, state, bgn_date, region, evtype, propdmg, propdmgexp, cropdmg, cropdmgexp)%>%
# mutate(evtype_temp=tolower(evtype)) %>% 
# mutate(evtype_new=ifelse(grepl("snow", evtype_temp)==TRUE,"snow", 
# ifelse(grepl("thu", evtype_temp)==TRUE,"tstm",
# ifelse(grepl("hurri", evtype_temp)==TRUE,"hurricane",
# ifelse(grepl("flood", evtype_temp)==TRUE,"flood",
# ifelse(grepl("fire", evtype_temp)==TRUE,"forest fire", evtype_temp)))))) %>%
	mutate(newpropdmg=ifelse(toupper(propdmgexp)=="K",
				 propdmg*1000,ifelse(toupper(propdmgexp)=="M",
				 		    propdmg*1000000, ifelse(toupper(propdmgexp)=="B",
				 		    			propdmg*1000000000,propdmg)))) %>%
	mutate(newcropdmg=ifelse(toupper(cropdmgexp)=="K",
				 cropdmg*1000,ifelse(toupper(cropdmgexp)=="M",
				 		    cropdmg*1000000, ifelse(toupper(cropdmgexp)=="B",
				 		    			cropdmg*1000000000,cropdmg)))) %>%
	mutate(newtotdmg=newpropdmg+newcropdmg)

count(raw_us_storms,toupper(cropdmgexp))

count(prop, is.na(newtotdmg), propdmgexp)
count(prop, is.na(region))
count(prop, is.na(yearx))
count(prop, (newtotdmg>100000))

ggplot(prop) +
	geom_jitter(mapping = aes(x=yearx, 
			      y=newtotdmg, 
			      color=region, alpha=newtotdmg)) + 
#	scale_y_continuous(limits = c(0,100000)) +
	facet_wrap(region~state)

prop2<-prop%>% left_join(x, by = c("evtype"="evtype_original")) %>% 
	filter(newtotdmg>0) %>%
# mutate(evtype_temp=tolower(evtype)) %>% 
# mutate(evtype_new=ifelse(grepl("snow", evtype_temp)==TRUE,"snow", 
# ifelse(grepl("thu", evtype_temp)==TRUE & grepl("wind", evtype_temp)==FALSE,"tstm",
# ifelse(grepl("thu", evtype_temp)==TRUE & grepl("wind", evtype_temp)==TRUE,"tstm wind",
# ifelse(grepl("hurri", evtype_temp)==TRUE,"hurricane",
# ifelse(grepl("wind", evtype_temp)==TRUE & evtype_new != "tstm wind","wind",
# ifelse(grepl("hail", evtype_temp)==TRUE,"hail",
# ifelse(grepl("ice", evtype_temp)==TRUE,"ice",
# ifelse(grepl("flood", evtype_temp)==TRUE,"flood",
# ifelse(grepl("fire", evtype_temp)==TRUE,"forest fire", evtype_temp)))))))))) %>%
	mutate(new_event_words4=str_trim(new_event_words4, side = "both")) %>%
	mutate(new_event_words5=ifelse(hurri==TRUE, "hurricane",
				       ifelse(fld==TRUE | flood==TRUE, "flood",
				              ifelse(hail==TRUE, "thunderstorm hail",
				              ifelse(lightning==TRUE, "thunderstorm lightning",
				              ifelse((thu==TRUE | tst==TRUE) & wind==FALSE & lightning==FALSE, "thunderstorm",
				                     ifelse((thu==TRUE | tst==TRUE) & wind==TRUE, "thunderstorm wind",
				                            ifelse((thu==TRUE | tst==TRUE) 
				                                   #& wind==FALSE 
				                                   & lightning==TRUE, "thunderstorm lightning",
				                            ifelse(new_event_words4 %in% c("forest fire", "forest fires", "wildfire"), 
				                                   "forest fire",
				                            ifelse(new_event_words4 %in% c("snow", "blizzard", "snow sleet freezing rain","winter","winter storm"), 
				                                   "winter snow",
				                            new_event_words4))))))))))
prop2%>%count(evtype, new_event_words5)
rolled<- prop2 %>% filter(yearx>=1995)%>%
#	group_by(yearx, region, new_event_words5)%>%
	group_by(new_event_words5)%>%
	summarize(newtotdmg2=sum(newtotdmg), 
		  meantotdmg2=mean(newtotdmg), 
		  ntotdmg2=n()) %>% 
	arrange(desc(newtotdmg2))
#	arrange(desc(meantotdmg2))
rolled<-rolled[1:10,1]
rolled
prop3<- prop2 %>%  filter(yearx>=1995)%>% inner_join(rolled, by = "new_event_words5") %>%
	group_by(yearx, region, new_event_words5)%>%
#	group_by(new_event_words5)%>%
	summarize(newtotdmg2=sum(newtotdmg), 
		  meantotdmg2=mean(newtotdmg), 
		  ntotdmg2=n(),xxxlog=log10(newtotdmg2)) %>% 
	arrange(desc(newtotdmg2))
#	arrange(desc(meantotdmg2))
print(prop3,n=116)
count(prop2,evtype)
fivenum(prop2$meantotdmg2)
fivenum(prop$newtotdmg)
options(scipen = 5)
ggplot(prop3) +
	geom_col(mapping = aes(x=yearx, 
#			      y=xxxlog, 
			      y=newtotdmg2, 
			      fill=new_event_words5), 
				  alpha=.7) + 
#	scale_y_continuous(breaks = seq(0,500000000,50000000), limits = c(0,100000000)) +
	scale_y_log10() +
	facet_wrap("new_event_words5")

ggplot(prop) + (mapping = aes(x=yearx, 
			      y=propdmg, 
			      fill=region
			      )) +
	geom_col(mapping = aes(), 
#		 group = "region",
		 show.legend = TRUE) + scale_y_continuous(limits = c(0,1000)) +
	geom_col(aes(y=newpropdmg), fill="black", alpha=.5)+
	facet_grid(~region)

# +
# 	scale_x_continuous(breaks = seq(min(us_storms2$yearx),max(us_storms2$yearx), 5)) +
# 	scale_y_continuous(breaks = seq(0,2000,250))
