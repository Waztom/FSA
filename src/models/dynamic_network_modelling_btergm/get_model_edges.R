get_model_edges <- function(trade.flow,nodes,month_data){
  
  nodes <- nodes %>% select(id,label)
  month_data$partner  <- as.character(month_data$partner)
  month_data$reporter <- as.character(month_data$reporter)
  
  if (trade.flow == "Imports"){
    #Create edges
    edges <-  month_data %>% left_join(nodes, by = c("reporter" = "label")) %>% rename(to = id) %>% left_join(nodes, by = c("partner"  = "label")) %>% rename(from = id) 
    }
  else if (trade.flow == "Exports"){
    #Create edges
    edges <-  month_data %>% left_join(nodes, by = c("reporter" = "label")) %>% rename(from = id) %>% left_join(nodes, by = c("partner"  = "label")) %>% rename(to = id) 
    }

  edges <- mutate(edges, width_trade_value = sqrt(trade_value_usd/200000))
  edges <- mutate(edges, width_netweight_kg = sqrt(netweight_kg/500000))
  edges <- na.omit(edges)
  edges <- select(edges, from, to, width_trade_value,width_netweight_kg)
  return(edges)

}

