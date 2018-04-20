get_trade_attributes_si <- function(df){
  
  df$partner  <- as.character(df$partner)
  df$reporter <- as.character(df$reporter)
  
  world_imports_to    <- df %>% select(reporter,trade_value_usd) %>% group_by(reporter) %>% summarise_at(.vars = vars(trade_value_usd), .funs = sum) %>% rename(label=reporter)
  
  world_imports_from  <- df %>% select(partner,trade_value_usd) %>% group_by(partner) %>% summarise_at(.vars = vars(trade_value_usd), .funs = sum) %>% rename(label=partner)
  
  #Calculate attributes
  world_trade_att    <- full_join(world_imports_to, world_imports_from, by='label', stringsAsFactors = FALSE) %>% mutate_all(funs(replace(., is.na(.), 0))) %>% mutate(nett_trade =trade_value_usd.y-trade_value_usd.x)
  world_trade_att    <- world_trade_att %>% select(label, nett_trade)     
  
  return(world_trade_att)
      
}

