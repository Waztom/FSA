#function to detect anomalies for an individual country

anomaly_detection_individual <- function(all_info_csv_file_name, country){
  
# Read the all info csv file for a commodity
df <- read.csv(file=all_info_csv_file_name, header=TRUE)

# Prepare data for time decomposition 
##selecting countries which have enough observations for time decomposition to work
##selecting columns of interest
df2 <- df %>% 
  group_by(node) %>% 
  filter(n() > 15) %>%
  select(period_date, ratio, node) %>%
  filter(node == country) %>%
  ungroup
  
#time decomposition via stl and anomaly detection via iqr  
df2_analysed <- df2 %>% 
    time_decompose(ratio, method = "stl") %>% anomalize(remainder, alpha = 0.5, method = "iqr") 

#create list of anomalous data points  
df2_anomalies <- df2_analysed %>% filter(anomaly == "Yes")

#Create graph with anomalies detected
anomaly_plot <- df2_analysed %>% time_recompose() %>%
                plot_anomalies(time_recomposed = TRUE, ncol=3, color_no = "purple", color_yes = "orange", alpha_ribbon = 1)

return(list(df2_anomalies, anomaly_plot))

}
