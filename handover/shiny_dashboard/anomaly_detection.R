anomaly_detection <- function(all_info, ad_country){
  
df2 <- all_info %>% group_by(node) %>% filter(n() > 15) %>% select(period_date, ratio, node) %>% filter(node == ad_country) %>% ungroup()
  
#time decomposition via stl and anomaly detection via iqr  
df2_analysed <- df2 %>% time_decompose(ratio, method = "stl") %>% anomalize(remainder, alpha = 0.5, method = "iqr") 

#create list of anomalous data points  
df2_anomalies <- df2_analysed %>% filter(anomaly == "Yes")

#Recomposing time
anomaly_recomposed <- df2_analysed %>% time_recompose()
#Create graph with anomalies detected
anomaly_plot <- plot_anomalies(anomaly_recomposed, time_recomposed = TRUE, ncol=3, color_no = "darkgreen", color_yes = "green", alpha_ribbon = 1) + ylim(c(-1 ,1 )) + labs(labs(x="Time", y="Producer                                      Distributor                                      Consumer")) + theme(axis.text=element_text(size=12),
                                                                                                                                                                                                                                                                    axis.title=element_text(size=14,face="bold"), legend.text=element_text(size=14), legend.title=element_text(size=14))

return(anomaly_plot)

}
