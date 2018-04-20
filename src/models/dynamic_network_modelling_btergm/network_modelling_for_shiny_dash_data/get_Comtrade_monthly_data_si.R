get_Comtrade_monthly_data_si <- function(df){
  
  months <- df %>% select(period) %>% unique() %>% arrange(period)
  listofdfs <- list()
  
  for (i in 1:nrow(months)){
    month <- df %>% filter(period == months[[1]][i]) %>% select(period,reporter,partner,trade_value_usd)
    listofdfs[[i]] <- month
  }
  return(listofdfs)
}

