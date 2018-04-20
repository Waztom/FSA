get_country_ids <- function(df){
  
  df <- df %>% filter(trade_flow != "Re-imports" & trade_flow != "Re-exports" & reporter != "World" & reporter != "EU-27" & partner != "World" & partner != "EU-27")
  df$partner  <- as.character(df$partner)
  df$reporter <- as.character(df$reporter)
  
  country_reporter        <-  df %>% select(reporter) %>% rename(label = reporter) %>% distinct(label)
  country_reporter$label  <-  as.character(country_reporter$label)
  country_partner         <-  df %>% select(partner) %>% rename(label = partner) %>% distinct(label) 
  country_partner$label   <-  as.character(country_partner $label)
  country_id              <-  full_join(country_reporter,country_partner, by = 'label')
  
  #List alphabetically
  country_id <- arrange(country_id,label)
  #Add ID column. 
  country_id <- country_id %>% rowid_to_column("id")
  return(country_id) 
  }
  

