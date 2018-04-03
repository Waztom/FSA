get_network_links <- function(trade.flow,starting_node,trade_threshold,df){
  
  df$partner  <- as.character(df$partner)
  df$reporter <- as.character(df$reporter)
  
  all_data <- df %>% filter(trade_flow == trade.flow & trade_value_usd > trade_threshold & reporter != starting_node)
  df_trade <- df %>% filter(trade_flow == trade.flow & trade_value_usd > trade_threshold & reporter == starting_node) 
  uk_partners <- df_trade %>% select(partner) %>% unique() 
  
  partner_ext <- data.frame()

    for (i in uk_partners$partner){
      partner_trade <- all_data %>% filter(reporter == i)
      df_trade <- rbind(df_trade, partner_trade)
      add_partners <- partner_trade %>% select(partner)
      partner_ext <- rbind(partner_ext, add_partners) 
    }
   
  partner_ext <- partner_ext %>% unique()

while (T){
  partner_ext_test <- nrow(partner_ext)
   for (i in partner_ext$partner){
     partner_trade <- all_data %>% filter(reporter == i)
     df_trade <- rbind(df_trade, partner_trade)
     add_partners <- partner_trade %>% select(partner)
     partner_ext <- rbind(partner_ext, add_partners)
   }
  partner_ext <- partner_ext %>% unique()
  if (nrow(partner_ext) == partner_ext_test){
    break
  }
}
   
   df_trade <- df_trade %>% unique()
   
  return(df_trade)
}

