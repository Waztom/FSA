#function to detect anomalies across all countries for a given point in time

anomaly_detection_all <- function(all_info, date1){

#creating a list of all the months - with current time dial set up the date is an integer, so this month list aids the selection step
all_months <- sort(unique(all_info$period_date))

#removing countries with fewer than 15 entries as the time decomposition doesn't work if there are limited entries. 
#selecting observations and columns of interest
df2 <- all_info %>%
  group_by(node) %>%
  filter(n() > 15) %>%
  select(period_date, ratio, node)

#time decomposition via stl and anomaly detection via iqr - we found these methods worked better than twitter and gesd. Adjust alpha to make the acceptable range broader/narrower. You can set the seasonal frequency to one year but we found this didnt work so well
#focusing on month of interest
#only selecting anomalous points
df2_analysed <- df2 %>%
  time_decompose(ratio, method = "stl") %>% anomalize(remainder, alpha = 0.5, method = "iqr") %>%
  filter(period_date == (all_months[date1])) %>% filter(anomaly == "Yes") %>% select(node, remainder, remainder_l1, remainder_l2)

#separating anomalies into those which are above the max limit and those which are below the minimum limit
a_high <- df2_analysed %>% filter(remainder < remainder_l1) %>% mutate(remainder_new = remainder - remainder_l1)
a_low  <- df2_analysed %>% filter(remainder > remainder_l2) %>% mutate(remainder_new = remainder - remainder_l2)

#combining and ranking countries based on deviation from their regular pattern
a_total <- rbind(a_high, a_low) %>% mutate(Deviation = abs(remainder_new)) %>% arrange(desc(Deviation)) %>% 
  select(node) %>% rename("Countries (greatest deviation from normal trend at top)" = node)

return(a_total)

}