get_nett_trade <- function(df){
  
  df <- df %>% filter(trade_flow != "Re-imports" & trade_flow != "Re-exports" & reporter != "World" & reporter != "EU-27" & partner != "World" & partner != "EU-27")
  df$partner  <- as.character(df$partner)
  df$reporter <- as.character(df$reporter)
  
  world_imports_to    <- df %>% filter(trade_flow == "Imports") %>% select(reporter,trade_value_usd) %>% mutate(trade_value_usd=trade_value_usd*-1) %>% group_by(reporter) %>% summarise(trade_value_usd = sum(trade_value_usd)) %>% rename(label=reporter)

  world_imports_from  <- df %>% filter(trade_flow == "Imports") %>% select(partner,trade_value_usd) %>% group_by(partner) %>% summarise(trade_value_usd = sum(trade_value_usd)) %>% rename(label=partner)
  
  world_exports_from  <- df %>% filter(trade_flow == "Exports") %>% select(reporter,trade_value_usd) %>% group_by(reporter) %>% summarise(trade_value_usd = sum(trade_value_usd)) %>% rename(label=reporter)
  
  world_exports_to    <- df %>% filter(trade_flow == "Exports") %>% select(partner,trade_value_usd) %>% mutate(trade_value_usd=trade_value_usd*-1) %>% group_by(partner) %>% summarise(trade_value_usd = sum(trade_value_usd)) %>% rename(label=partner)
  
  world_trade_nett    <- full_join(world_imports_to, world_imports_from, by='label', stringsAsFactors = FALSE) %>% full_join(., world_exports_from, by='label', stringsAsFactors = FALSE) %>% full_join(.,world_exports_to, by='label', stringsAsFactors = FALSE) %>% mutate_all(funs(replace(., is.na(.), 0))) %>% mutate(nett_trade =trade_value_usd.x+trade_value_usd.y+trade_value_usd.x.x+trade_value_usd.y.y) %>%select(label,nett_trade)
  
  return(world_trade_nett)
}

