anomaly_detection <- function(all_info, ad_country){
  
df2 <- all_info %>% group_by(node) %>% filter(n() > 15) %>% select(period_date, ratio, node) %>% filter(node == ad_country) %>% ungroup()
  
#time decomposition via stl and anomaly detection via iqr  
df2_analysed <- df2 %>% time_decompose(ratio, method = "stl") %>% anomalize(remainder, alpha = 0.5, method = "iqr") 

#create list of anomalous data points  
df2_anomalies <- df2_analysed %>% filter(anomaly == "Yes")

#Create graph with anomalies detected
anomaly_plot <- df2_analysed %>% time_recompose() %>%
                plot_anomalies(time_recomposed = TRUE, ncol=3, color_no = "purple", color_yes = "orange", alpha_ribbon = 1)

return(ad_plot)

}
