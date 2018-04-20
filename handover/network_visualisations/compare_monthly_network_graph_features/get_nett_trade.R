#The acuracy of this is affected by how well a country reports trade data
#Countries that report well will yield an accurate value
get_nett_trade <- function(df){
  
  df <- df %>% filter(trade_flow != "Re-imports" & trade_flow != "Re-exports" & reporter != "World" & reporter != "EU-27" & partner != "World" & partner != "EU-27")
  df$partner  <- as.character(df$partner)
  df$reporter <- as.character(df$reporter)
  
  world_imports_to    <- df %>% filter(trade_flow == "Imports") %>% select(reporter,trade_value_usd) %>% mutate(trade_value_usd=trade_value_usd) %>% group_by(reporter) %>% summarise(trade_value_usd = sum(trade_value_usd)) %>% rename(label=reporter)

  world_imports_from  <- df %>% filter(trade_flow == "Imports") %>% select(partner,trade_value_usd) %>% group_by(partner) %>% summarise(trade_value_usd = sum(trade_value_usd)) %>% rename(label=partner)
  
  world_trade_nett    <- full_join(world_imports_to, world_imports_from, by='label', stringsAsFactors = FALSE) %>% mutate_all(funs(replace(., is.na(.), 0))) %>% mutate(nett_trade = trade_value_usd.y-trade_value_usd.x) %>% select(label,nett_trade)
  
  return(world_trade_nett)
}

