get_Comtrade_monthly_data <- function(df){
  
  df <- df %>% filter(trade_flow != "Re-imports" & trade_flow != "Re-exports" & reporter != "World" & reporter != "EU-27" & partner != "World" & partner != "EU-27")
  
  months <- df %>% select(period) %>% unique() %>% arrange(period)
  listofdfs <- list()
  
  for (i in 1:nrow(months)){
    month <- df %>% filter(period == months[[1]][i]) %>% select(period,trade_flow,reporter,partner,netweight_kg,trade_value_usd)
    listofdfs[[i]] <- month
  }
  return(listofdfs)
}

