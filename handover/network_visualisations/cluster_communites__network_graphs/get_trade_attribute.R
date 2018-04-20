#Type is to calculate nett trade or flux as per Alex's definition (nett imports - nett exports)/(nett imports + nett exports)
get_trade_attribute <- function(df, type){
  
  df <- df %>% filter(trade_flow != "Re-imports" & trade_flow != "Re-exports" & reporter != "World" & reporter != "EU-27" & partner != "World" & partner != "EU-27")
  df$partner  <- as.character(df$partner)
  df$reporter <- as.character(df$reporter)
  
  world_imports_to    <- df %>% filter(trade_flow == "Imports") %>% select(reporter,trade_value_usd) %>% mutate(trade_value_usd=trade_value_usd) %>% group_by(reporter) %>% summarise(trade_value_usd = sum(trade_value_usd)) %>% rename(label=reporter)
  
  world_exports_from  <- df %>% filter(trade_flow == "Exports") %>% select(reporter,trade_value_usd) %>% group_by(reporter) %>% summarise(trade_value_usd = sum(trade_value_usd)) %>% rename(label=reporter)
  
  #Use to estimate trade from countries that do not report
  world_imports_from  <- df %>% filter(trade_flow == "Imports") %>% select(partner,trade_value_usd) %>% group_by(partner) %>% summarise(trade_value_usd = sum(trade_value_usd)) %>% rename(label=partner)
  
  world_exports_to    <- df %>% filter(trade_flow == "Exports") %>% select(partner,trade_value_usd) %>% mutate(trade_value_usd=trade_value_usd) %>% group_by(partner) %>% summarise(trade_value_usd = sum(trade_value_usd)) %>% rename(label=partner)
  
  if (type == "nett"){
    world_trade_nett_att    <- full_join(world_imports_to, world_imports_from, by='label', stringsAsFactors = FALSE) %>% full_join(., world_exports_from, by='label', stringsAsFactors = FALSE) %>% full_join(.,world_exports_to, by='label', stringsAsFactors = FALSE) %>% mutate_all(funs(replace(., is.na(.), 0))) %>% mutate(trade_attribute =((trade_value_usd.x+trade_value_usd.y.y)-(trade_value_usd.x.x + trade_value_usd.y))) %>%select(label,trade_attribute)
    return(world_trade_nett_att)
    } else if (type == "flux"){
    world_trade_flux_att    <- full_join(world_imports_to, world_imports_from, by='label', stringsAsFactors = FALSE) %>% full_join(., world_exports_from, by='label', stringsAsFactors = FALSE) %>% full_join(.,world_exports_to, by='label', stringsAsFactors = FALSE) %>% mutate_all(funs(replace(., is.na(.), 0))) %>% mutate(trade_attribute =((trade_value_usd.x+trade_value_usd.y.y)-(trade_value_usd.x.x + trade_value_usd.y))/((trade_value_usd.x+trade_value_usd.y.y)+(trade_value_usd.x.x + trade_value_usd.y))) %>%select(label,trade_attribute)
    return(world_trade_flux_att)
    } else if (type == "abs_nett"){
    world_trade_abs_nett    <- full_join(world_imports_to, world_imports_from, by='label', stringsAsFactors = FALSE) %>% full_join(., world_exports_from, by='label', stringsAsFactors = FALSE) %>% full_join(.,world_exports_to, by='label', stringsAsFactors = FALSE) %>% mutate_all(funs(replace(., is.na(.), 0))) %>% mutate(trade_attribute =as.numeric(abs(scale((trade_value_usd.x+trade_value_usd.y.y)-(trade_value_usd.x.x + trade_value_usd.y))))) %>%select(label,trade_attribute)
    return(world_trade_abs_nett)
    }
}

