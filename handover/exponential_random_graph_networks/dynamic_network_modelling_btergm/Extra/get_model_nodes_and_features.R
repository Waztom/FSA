get_model_nodes_and_features <- function(trade.flow,month_data,month_features,country_ids){
  
  month_features        <- month_features %>% rename(label=node)
  month_features$label  <- as.character(month_features$label)
  month_features        <- month_features %>% select(label,c(4:16))
  
  month_data            <- month_data %>% mutate_all(funs(replace(., is.na(.), 0)))
  
  if (trade.flow == "Imports"){
    #Create nodes
    imports_to          <-  month_data %>% select(reporter) %>% rename(label = reporter) %>% distinct(label)
    imports_to$label    <-  as.character(imports_to$label)
    imports_from        <-  month_data %>% select(partner) %>% rename(label = partner) %>% distinct(label) 
    imports_from$label  <-  as.character(imports_from$label)
    nodes               <-  full_join(imports_to,imports_from, by = 'label')
  }
  else if (trade.flow == "Exports"){
    #Create nodes
    exports_from        <-  month_data %>% select(reporter) %>% rename(label = reporter) %>% distinct(label)
    exports_from$label  <-  as.character(exports_from$label)
    exports_to          <-  month_data %>% select(partner) %>% rename(label = partner) %>% distinct(label) 
    exports_to$label    <-  as.character(exports_to$label)
    nodes               <-  full_join(exports_from, exports_to, by = 'label')
  }
    
  #Combine to form one list of country nodes
  nodes <- nodes %>% left_join(.,month_features, by='label') %>% left_join(.,country_ids, by='label')
  nodes <- na.omit(nodes)
  return(nodes) 
  }
  

