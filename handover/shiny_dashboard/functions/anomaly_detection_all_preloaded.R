#running anomaly detection for all months is slow so this function references pre-calculated anomalies for visualisation in the dashboard

anomaly_detection_all_preloaded <- function(ad, date1){

  #creating a list of all the months - with current time dial set up the date is an integer, so this month list aids the selection step
all_months <- sort(unique(ad$period_date))

#selecting time period of interest and focusing on anomalous points
df2 <- ad %>%
  filter(period_date == (all_months[date1])) %>% filter(anomaly == "Yes") %>% select(node, remainder, remainder_l1, remainder_l2)

#separating anomalies into those which are above the max limit and those which are below the minimum limit
a_high <- df2 %>% filter(remainder < remainder_l1) %>% mutate(remainder_new = remainder - remainder_l1)
a_low  <- df2 %>% filter(remainder > remainder_l2) %>% mutate(remainder_new = remainder - remainder_l2)

#combining and ranking countries based on deviation from their regular pattern
a_total <- rbind(a_high, a_low) %>% mutate(Deviation = abs(remainder_new)) %>% arrange(desc(Deviation)) %>% 
  select(node) %>% rename("Countries (greatest deviation from normal trend at top)" = node)

return(a_total)

}
