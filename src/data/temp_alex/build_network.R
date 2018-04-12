build_network <- function(csv_file_name, time_start, time_end){

# Read the csv file for a commodity
df <- read.csv(file=csv_file_name, header=TRUE)

# Clean the missing data
df <- df[complete.cases(df),]

# Prepare data
guys_2_remove <- c("EU-27","Areas, nes","Other Europe, nes","Other Africa, nes",
                   "Other Asia, nes","World")
df2 <- df %>% filter(!as.character(partner)  %in% guys_2_remove) %>%
              filter(!as.character(reporter) %in% guys_2_remove)
df2 <- df2 %>% mutate(period_date = ymd(paste(as.character(period),"01",sep=""))) %>%
               mutate(year        = as.integer(str_sub(period,1,4))) %>%
               mutate(month       = as.integer(str_sub(period,5,6))) %>%
               mutate(price_usd_kg= trade_value_usd/netweight_kg)
Imports <- df2 %>% filter(trade_flow == "Imports") %>% select(-trade_flow)
si <- Imports %>% select(period_date,reporter,partner,trade_value_usd) %>%
                  mutate(origin = as.character(partner)) %>%
                  mutate(destin = as.character(reporter)) %>% 
                  select(-reporter,-partner)

#Select time line in month
si_month <- si %>% filter(period_date < time_end & period_date >= time_start) 

#cut out trade with value less than 3rd quantile value
si_third <- si_month %>% 
  filter(quantile(trade_value_usd, 0.9)<trade_value_usd)

#Create nodes 
imports_from <- si_third %>% select(origin) %>% rename(label = origin) %>% distinct(label)
imports_to <- si_third %>% select(destin) %>% rename(label = destin) %>% distinct(label)
##Combine to form one list of country nodes
nodes <- full_join(imports_from,imports_to, by = 'label')
nodes <- arrange(nodes,label)
##Add ID column. 
nodes <- nodes %>% rowid_to_column("id")

#Create edges table
edges <-  si_third %>% left_join(nodes, by = c("destin" = "label")) %>% 
  rename(to = id) %>%
  left_join(nodes, by = c("origin"  = "label"))%>%
  rename(from = id) %>%
  mutate(width =  log(trade_value_usd/1000)) %>%
  select(from, to, width)


#working out assignment to communities - plan to swap to kmeans but stick to something we have working for now
undirected_network <- tbl_graph(nodes = nodes, edges = edges, directed = FALSE)
communities <- edge.betweenness.community(undirected_network)
grouping <- membership(communities)

#creating total exports and imports for each node
total_exports<- si_third %>%
  group_by (origin)  %>%
  summarize(total_export = sum(trade_value_usd)) %>%
  rename(label = origin)
total_imports <- si_third %>%
  group_by (destin) %>%
  summarize(total_import = sum(trade_value_usd)) %>%
  rename(label = destin)

#adding features to nodes
nodes_groups_shape_size <- nodes %>% 
  mutate (group = grouping) %>%
  left_join(total_imports, by = "label") %>%
  left_join(total_exports, by = "label") %>%
  replace_na(list(total_export=0, total_import=0)) %>%
  mutate(a_ratio = (total_import - total_export)/(total_import+total_export)) %>%
  mutate(value = abs(a_ratio)) %>%
  mutate(shape = ifelse(a_ratio >0.5, "dot", ifelse(a_ratio >-0.5, "triangle", "square"))) %>%
  select(id, label, group, value, shape)


#Creation of network
Network <- visNetwork(nodes_groups_shape_size, edges) %>% 
  visIgraphLayout(layout = "layout.davidson.harel", randomSeed = 10000) %>%
  visEdges(arrows = "to",
           color=list(inherit=TRUE)) %>%
  visNodes(font=list(size=40), shadow = TRUE, scaling=list(min=10, max = 50)) %>%
  visOptions(selectedBy = "group",
    highlightNearest = list(enabled = TRUE, degree=list(to=1, from=1), algorithm="hierarchical"), 
    nodesIdSelection = TRUE, clickToUse=TRUE) %>%
  visInteraction(navigationButtons = TRUE) %>%
  visLegend(addNodes = list(
    list(label = "Importer", shape = "square"),
    list(label = "Exporter", shape = "dot"),
    list(label = "Distributer", shape = "triangle")
  ),
  useGroups = FALSE, zoom = FALSE)


return(Network)

}
