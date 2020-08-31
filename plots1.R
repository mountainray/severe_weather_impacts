count(us_storms, state__, state)
count(distinct(us_storms, state__,state))
filter(us_storms, state=="AN")       
count(us_storms, yearx)
ggplot(us_storms) +
	geom_bar(mapping = aes(x=yearx))

check_non_us_50_states <- us_storms%>%mutate(us_state_50_flag=state %in% state.abb)%>%
	filter(us_state_50_flag==FALSE) %>%
	count(us_state_50_flag, evtype)


state_df <- data.frame(state.abb, state.region)
names(state_df) <- c("state", "region")
head(state_df)

us_storms2 <- us_storms%>%left_join(state_df) %>% mutate(totdmg=propdmg+cropdmg)

ggplot(us_storms2) +
	geom_bar(mapping = aes(x=yearx, fill=region)) +
	facet_grid("region")

ggplot(us_storms2) +
	geom_col(mapping = aes(y=propdmg, x=yearx, fill = region)) +
	facet_grid("region")

ggplot(us_storms2) +
	geom_col(mapping = aes(y=cropdmg, x=yearx, fill = region)) +
	facet_grid("region")

ggplot(us_storms2) +
	geom_col(mapping = aes(y=totdmg, x=yearx, fill = region)) +
	facet_grid("region")

ggplot(us_storms2) +
#	geom_jitter(mapping = aes(y=fatalities, x=yearx, color = region, alpha=fatalities), show.legend = FALSE) +
	geom_col(mapping = aes(y=injuries, x=yearx, fill = region), show.legend = FALSE) +
#	geom_line(mapping=aes(x=yearx,y=injuries, color=region)) +
	scale_x_continuous(breaks = seq(min(us_storms2$yearx),max(us_storms2$yearx), 5)) +
	# scale_y_continuous(limits = c(0,200)) +
	scale_y_continuous(breaks = seq(0,100,10)) +
	theme_dark() +
	facet_grid("region")

ggplot(us_storms2) +
#	geom_jitter(mapping = aes(y=fatalities, x=yearx, color = region, alpha=fatalities), show.legend = FALSE) +
	geom_col(mapping = aes(y=fatalities, x=yearx, fill = region), show.legend = FALSE) +
	scale_x_continuous(breaks = seq(min(us_storms2$yearx),max(us_storms2$yearx), 5)) +
	theme_dark() +
	facet_grid("region")

ggplot(us_storms2) +
	geom_jitter(mapping = aes(y=totdmg, x=yearx, color = region, alpha=totdmg), show.legend = FALSE) +
	scale_x_continuous(breaks = seq(min(us_storms2$yearx),max(us_storms2$yearx), 5)) +
	theme_dark() +
	facet_grid("region")

