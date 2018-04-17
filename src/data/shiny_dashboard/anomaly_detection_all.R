#function to detect anomalies across all countries see function TBC for an individual country

anomaly_detection_all <- function(all_info, date1){
  
  all_months <- sort(unique(all_info$period_date))

df2 <- all_info %>%
  group_by(node) %>%
  filter(n() > 15) %>%
  select(period_date, ratio, node)

df2_analysed <- df2 %>%
  time_decompose(ratio, method = "stl") %>% anomalize(remainder, alpha = 0.5, method = "iqr") %>%
  filter(period_date == (all_months[date1])) %>% filter(anomaly == "Yes") %>% select(node, remainder, remainder_l1, remainder_l2)

a_high <- df2_analysed %>% filter(remainder < remainder_l1) %>% mutate(remainder_new = remainder - remainder_l1)
a_low  <- df2_analysed %>% filter(remainder > remainder_l2) %>% mutate(remainder_new = remainder - remainder_l2)

a_total <- rbind(a_high, a_low) %>% mutate(Deviation = abs(remainder_new)) %>% arrange(desc(Deviation)) %>% 
  select(node, Deviation) %>% rename(Country = node)

return(a_total)

}