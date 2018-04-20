get_model_nodes <- function(month_data,trade_attributes,country_ids){
  
  month_data[is.na(month_data)] <- 0 
  
  #Create nodes
  imports_to          <-  month_data %>% select(reporter) %>% rename(label = reporter) %>% distinct(label)
  imports_to$label    <-  as.character(imports_to$label)
  imports_from        <-  month_data %>% select(partner) %>% rename(label = partner) %>% distinct(label) 
  imports_from$label  <-  as.character(imports_from$label)
  nodes               <-  full_join(imports_to,imports_from, by = 'label')
    
  #Combine to form one list of country nodes
  nodes <- nodes %>% left_join(.,trade_attributes, by='label') %>% left_join(.,country_ids, by='label')
  nodes[is.na(nodes)] <- 0
  return(nodes) 
  }
  

