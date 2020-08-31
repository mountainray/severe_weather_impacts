# raw_us_storms%>% filter(propdmg>2000)
# ggplot(filter(us_storms2, state=="IL")) +
# 	geom_jitter(mapping = aes(x=yearx, y=propdmg, color = region, size=propdmg), show.legend = TRUE) +
# 	scale_x_continuous(breaks = seq(min(us_storms2$yearx),max(us_storms2$yearx), 5)) +
# 	scale_y_continuous(breaks = seq(0,2000,250))

# page 12 of detailed documentation...
# Alphabetical characters used to signify magnitude include “K” 
# for thousands, “M” for millions, and “B” for billions.
prop <- us_storms2%>%select(yearx, state, bgn_date, region, evtype, propdmg, propdmgexp, cropdmg, cropdmgexp)%>%
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

prop2<-prop%>% filter(newtotdmg>0) %>%
	group_by(evtype)%>%
	summarize(newtotdmg2=sum(newtotdmg), 
		  meantotdmg2=mean(newtotdmg), 
		  ntotdmg2=n()) %>% arrange(desc(newtotdmg2))
print(prop2,n=116)
count(prop2,evtype)
fivenum(prop2$meantotdmg2)
fivenum(prop$newtotdmg)

ggplot(prop2) +
	geom_jitter(mapping = aes(x=yearx, 
			      y=newtotdmg2, 
			      color=region, alpha=newtotdmg2)) + 
#	scale_y_continuous(limits = c(0,100000)) +
	facet_wrap(evtype)

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
