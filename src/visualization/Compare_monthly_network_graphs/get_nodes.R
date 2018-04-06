get_nodes <- function(trade.flow,month_links,month_nett_trade){
  
  if (trade.flow == "Imports"){
    #Create nodes
    imports_to          <-  month_links %>% select(reporter) %>% rename(label = reporter) %>% distinct(label)
    imports_to$label    <-  as.character(imports_to$label)
    imports_from        <-  month_links %>% select(partner) %>% rename(label = partner) %>% distinct(label) 
    imports_from$label  <-  as.character(imports_from$label)
    nodes               <-  full_join(imports_to,imports_from, by = 'label')
  }
  else if (trade.flow == "Exports"){
    #Create nodes
    exports_from        <-  month_links %>% select(reporter) %>% rename(label = reporter) %>% distinct(label)
    exports_from$label  <-  as.character(exports_from$label)
    exports_to          <-  month_links %>% select(partner) %>% rename(label = partner) %>% distinct(label) 
    exports_to$label    <-  as.character(exports_to$label)
    nodes               <-  full_join(exports_from, exports_to, by = 'label')
  }
    
  #Combine to form one list of country nodes
  nodes <- nodes %>% left_join(.,month_nett_trade, by='label')
  nodes <- arrange(nodes,nett_trade)
  #Add ID column. 
  nodes <- nodes %>% rowid_to_column("id")
  return(nodes) 
  }
  

