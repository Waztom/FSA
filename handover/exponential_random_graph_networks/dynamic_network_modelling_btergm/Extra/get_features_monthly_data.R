get_features_monthly_data <- function(df){
  
  months <- df %>% select(period) %>% unique() %>% arrange(period)
  data <- df
  listofdfs <- list()
  intial <- 1
  
  for (i in 1:(nrow(months)-1)){
    time_start <- months$period[i]
    time_end <- months$period[intial+i]
    month <- data %>% filter(period < time_end & period >= time_start)   
    listofdfs[[i]] <- month
  }
  return(listofdfs)
}

