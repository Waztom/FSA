#function to detect anomalies across all countries see function TBC for an individual country

anomaly_detection_all <- function(all_info_csv_file_name){
  
# Read the all info csv file for a commodity
df <- read.csv(file=all_info_csv_file_name, header=TRUE)

# Prepare data for time decomposition 
##selecting countries which have enough observations for time decomposition to work
##selecting columns of interest
df2 <- df %>% 
  group_by(node) %>% 
  filter(n() > 15) %>%
  select(period_date, ratio, node)
  
#time decomposition via stl and anomaly detection via iqr  
df2_analysed <- df2 %>% 
    time_decompose(ratio, method = "stl") %>% anomalize(remainder, alpha = 0.5, method = "iqr") 

#create list of anomalous data points  
df2_anomalies <- df2_analysed %>% filter(anomaly == "Yes")

return(df2_anomalies)

}
