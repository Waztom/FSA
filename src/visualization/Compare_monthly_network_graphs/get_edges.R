get_edges <- function(trade.flow,nodes,df){
  
  if (trade.flow == "Imports"){
    #Create edges
    edges <-  df %>% left_join(nodes, by = c("reporter" = "label")) %>% rename(to = id) %>% left_join(nodes, by = c("partner"  = "label")) %>% rename(from = id) 
    }
  else if (trade.flow == "Exports"){
    #Create edges
    edges <-  df %>% left_join(nodes, by = c("reporter" = "label")) %>% rename(from = id) %>% left_join(nodes, by = c("partner"  = "label")) %>% rename(to = id) 
    }

  edges <- mutate(edges, width = sqrt(trade_value_usd/200000)) 
  edges <- select(edges, from, to, width)
  return(edges)

}

