network_model <- function(si,date1,country_from,country_to){

#Get country ids
df <- si
df  <- df %>% rename(reporter=destin) %>% rename(partner=origin)
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

#Find country id
country_from_id <- country_id %>% filter(label==country_from)
country_from_id <- country_from_id[[1]][1]

country_to_id <- country_id %>% filter(label==country_to)
country_to_id <- country_to_id[[1]][1]

#Get probability of link
prob <- interpret(cucumber_model, type = "tie", i = country_from_id, j = country_to_id, t = date1+12 )
prob <- as.character(prob)
return(prob)

}
