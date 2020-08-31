count(us_storms, state__, state)
count(distinct(us_storms, state__,state))
filter(us_storms, state=="AN")       
count(us_storms, yearx)

hist((filter(us_storms, propdmg<300 & yearx<1995)%>%count(propdmg))$propdmg)
ggplot(us_storms) +
	geom_bar(mapping = aes(x=yearx)) +
	scale_x_continuous(breaks = seq(min(us_storms$yearx), max(us_storms$yearx), 5))

check_non_us_50_states <- us_storms%>%mutate(us_state_50_flag=state %in% state.abb)%>%
	filter(us_state_50_flag==FALSE) %>%
	count(us_state_50_flag, evtype)
check_non_us_50_states

state_df <- data.frame(state.abb, state.region)
names(state_df) <- c("state", "region")
head(state_df)

us_storms2 <- us_storms%>%left_join(state_df) %>% mutate(totdmg=propdmg+cropdmg)

ggplot(us_storms2) +
	geom_bar(mapping = aes(x=yearx, fill=region)) +
	facet_grid("region")

ggplot(us_storms2) +
	geom_col(mapping = aes(x=yearx, y=propdmg, fill = region)) +
	facet_grid("region")

ggplot(us_storms2) +
	geom_col(mapping = aes(x=yearx, y=cropdmg, fill = region)) +
	facet_grid("region")

ggplot(us_storms2) +
	geom_col(mapping = aes(x=yearx, y=totdmg, fill = region)) +
	facet_grid("region")

ggplot(us_storms2) +
#	geom_jitter(mapping = aes(y=fatalities, x=yearx, color = region, alpha=fatalities), show.legend = FALSE) +
	geom_col(mapping = aes(x=yearx, y=injuries, fill = region), show.legend = FALSE) +
#	geom_line(mapping=aes(x=yearx,y=injuries, color=region)) +
	scale_x_continuous(breaks = seq(min(us_storms2$yearx),max(us_storms2$yearx), 5)) +
	# scale_y_continuous(limits = c(0,200)) +
	scale_y_continuous(breaks = seq(0,100,10)) +
	theme_dark() +
	facet_grid("region")

ggplot(us_storms2) +
#	geom_jitter(mapping = aes(y=fatalities, x=yearx, color = region, alpha=fatalities), show.legend = FALSE) +
	geom_col(mapping = aes(x=yearx, y=fatalities, fill = region), show.legend = FALSE) +
	scale_x_continuous(breaks = seq(min(us_storms2$yearx),max(us_storms2$yearx), 5)) +
#	theme_dark() +
	facet_grid("region")

#range(filter(us_storms2, totdmg<quantile(totdmg, .9999))$totdmg)
ggplot(us_storms2) +
	geom_jitter(mapping = aes(x=yearx, y=propdmg, color = region, size=propdmg), show.legend = TRUE) +
	scale_x_continuous(breaks = seq(min(us_storms2$yearx),max(us_storms2$yearx), 5)) +
	scale_y_continuous(breaks = seq(0,2000,250)) +
#	theme_dark() +
	facet_grid("region")

