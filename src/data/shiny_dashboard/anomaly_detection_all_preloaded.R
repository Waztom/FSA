#function to detect anomalies across all countries see function TBC for an individual country

anomaly_detection_all_preloaded <- function(ad, date1){
  
  all_months <- sort(unique(ad$period_date))

df2 <- ad %>%
  filter(period_date == (all_months[date1])) %>% filter(anomaly == "Yes") %>% select(node, remainder, remainder_l1, remainder_l2)

a_high <- df2 %>% filter(remainder < remainder_l1) %>% mutate(remainder_new = remainder - remainder_l1)
a_low  <- df2 %>% filter(remainder > remainder_l2) %>% mutate(remainder_new = remainder - remainder_l2)

a_total <- rbind(a_high, a_low) %>% mutate(Deviation = abs(remainder_new)) %>% arrange(desc(Deviation)) %>% 
  select(node) %>% rename("Countries (greatest deviation from normal trend at top)" = node)

return(a_total)

}
