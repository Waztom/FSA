get_model_edges <- function(nodes,month_data){
  
  nodes <- nodes %>% select(id,label)
  month_data$partner  <- as.character(month_data$partner)
  month_data$reporter <- as.character(month_data$reporter)

  #Create edges
  edges <-  month_data %>% left_join(nodes, by = c("reporter" = "label")) %>% rename(to = id) %>% left_join(nodes, by = c("partner"  = "label")) %>% rename(from = id) 

  #Create edge attributes
  #edges <- mutate(edges, width_trade_value = sqrt(trade_value_usd/200000))
  #edges <- mutate(edges, width_netweight_kg = sqrt(netweight_kg/500000))
edges <- na.omit(edges)
edges <- select(edges, from, to, trade_value_usd)
  
  #Clear up edges
  #edges <- edges %>% filter(from!=to)
  edges <- edges %>% group_by(from, to) %>% summarise_at(.vars = vars(trade_value_usd), .funs = sum)
  
  return(edges)

}

