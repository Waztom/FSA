#Returns scaled nett trade and nett weight and flux (Alex's definition)
get_trade_attributes <- function(df){
  
  df <- df %>% filter(trade_flow != "Re-imports" & trade_flow != "Re-exports" & reporter != "World" & reporter != "EU-27" & partner != "World" & partner != "EU-27")
  df$partner  <- as.character(df$partner)
  df$reporter <- as.character(df$reporter)
  
  world_imports_to    <- df %>% filter(trade_flow == "Imports") %>% select(reporter,trade_value_usd,netweight_kg) %>% group_by(reporter) %>% summarise_at(.vars = vars(netweight_kg, trade_value_usd), .funs = sum) %>% rename(label=reporter)
  
  world_exports_from  <- df %>% filter(trade_flow == "Exports") %>% select(reporter,trade_value_usd,netweight_kg) %>% group_by(reporter) %>% summarise_at(.vars = vars(netweight_kg, trade_value_usd), .funs = sum) %>% rename(label=reporter)
  
  #Use to estimate trade from countries that do not report
  world_imports_from  <- df %>% filter(trade_flow == "Imports") %>% select(partner,trade_value_usd,netweight_kg) %>% group_by(partner) %>% summarise_at(.vars = vars(netweight_kg, trade_value_usd), .funs = sum) %>% rename(label=partner)
  
  world_exports_to    <- df %>% filter(trade_flow == "Exports") %>% select(partner,trade_value_usd,netweight_kg) %>% group_by(partner) %>% summarise_at(.vars = vars(netweight_kg, trade_value_usd), .funs = sum) %>% rename(label=partner)
  
  world_trade_att    <- full_join(world_imports_to, world_imports_from, by='label', stringsAsFactors = FALSE) %>% full_join(., world_exports_from, by='label', stringsAsFactors = FALSE) %>% full_join(.,world_exports_to, by='label', stringsAsFactors = FALSE) %>% mutate_all(funs(replace(., is.na(.), 0))) %>% mutate(nett_trade =as.numeric(scale(((trade_value_usd.x+trade_value_usd.y.y)-(trade_value_usd.x.x + trade_value_usd.y))))) 
  world_trade_att    <- world_trade_att %>% mutate(trade_flux =((trade_value_usd.x + trade_value_usd.y.y)-(trade_value_usd.x.x + trade_value_usd.y))/((trade_value_usd.x+trade_value_usd.y.y)+(trade_value_usd.x.x + trade_value_usd.y))) 
  world_trade_att    <- world_trade_att %>% mutate(trade_value =as.numeric(scale(((trade_value_usd.x + trade_value_usd.y.y)))))  
  world_trade_att    <- world_trade_att %>% mutate(nett_weight=as.numeric(scale(((netweight_kg.x + netweight_kg.y.y)-(netweight_kg.x.x + netweight_kg.y)))))
  world_trade_att    <- world_trade_att %>% mutate(trade_weight_value =as.numeric(scale(((netweight_kg.x + netweight_kg.y.y)))))
  
  
  world_trade_att    <- world_trade_att %>% select(label, nett_trade,trade_flux, trade_value, nett_weight,trade_weight_value)     
  return(world_trade_att)
      
}

