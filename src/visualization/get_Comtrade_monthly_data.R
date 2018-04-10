get_Comtrade_monthly_data <- function(df){
  
  df <- df %>% filter(trade_flow != "Re-imports" & trade_flow != "Re-exports" & reporter != "World" & reporter != "EU-27" & partner != "World" & partner != "EU-27")
  
  months <- df %>% select(period) %>% unique() %>% arrange(period)
  data <- df
  listofdfs <- list()
  intial <- 1
  
  for (i in 1:(nrow(months)-1)){
    time_start <- months$period[i]
    time_end <- months$period[intial+i]
    month <- data %>% filter(period < time_end & period >= time_start) %>% select(period,trade_flow,reporter,partner,netweight_kg,trade_value_usd) 
    listofdfs[[i]] <- month
  }
  return(listofdfs)
}

