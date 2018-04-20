#function to build a network graph
build_network <- function(si,date1,threshold){

#setting threshold for network graph - to manage the complexity. e.g. 0.75 would set to tp 25% of trade based on value
threshold <- 1-threshold/100

#create list of months enable month selection from dashboard
all_months <- sort(unique(si$period))

#calculatiing import, export, net and a_ratio for all countries
#assigning shape depending on a_ratio
#assigning size (value) based on overall trade
si1 <- si %>% filter(period == all_months[date1])
total_exports <- si1 %>% group_by (origin) %>% summarize(total_export = sum(trade_value_usd)) %>% rename(label = origin)
total_imports <- si1 %>% group_by (destin) %>% summarize(total_import = sum(trade_value_usd)) %>% rename(label = destin)
tmp <- full_join(total_imports, total_exports, by = "label") %>% replace_na(list(total_export=0, total_import=0))
tmp <- tmp %>%   mutate(overall_flux = total_import + total_export) %>% 
                 mutate(a_ratio = (total_import - total_export)/overall_flux) %>%
#                 mutate(value   = log10(total_import+total_export)) %>%
                 mutate(value = 10 * (overall_flux - min(overall_flux))/(max(overall_flux)-min(overall_flux)) + 1) %>%         
                 mutate(shape   = ifelse(a_ratio > 0.33, "dot", ifelse(a_ratio < -0.33, "triangle", "square")))

#selecting countries with trade above threshold
tmp <- tmp %>% filter(quantile(total_export + total_import, threshold) < total_export + total_import)

#creating node table
nodes <- tmp   %>% select(label)
nodes <- nodes %>% rowid_to_column("id")

#Create edges table
#assigining size (width) based on trade value
edges <-  si1 %>% inner_join(nodes, by = c("destin" = "label"))  %>% rename(to   = id) %>%
  inner_join(nodes, by = c("origin"  = "label")) %>% rename(from = id) %>%
  mutate(width =  20 * (trade_value_usd - min(trade_value_usd)) / (max(trade_value_usd)-min(trade_value_usd)) + 1) %>%
  select(from, to, width)

#working out assignment to communities for each node
undirected_network <- tbl_graph(nodes = nodes, edges = edges, directed = FALSE)
communities        <- edge.betweenness.community(undirected_network)
grouping           <- membership(communities)

#adding group, details to node list. The group is currently not selected but if added would be defined by colour
nodes_groups_shape_size <- nodes %>% mutate (group = grouping) %>% inner_join(tmp,by="label") %>% select(id, label, value, shape)


#Creation of network
Network <- visNetwork(nodes_groups_shape_size, edges, width = "150%") %>% 
  visIgraphLayout(layout = "layout_with_fr", randomSeed = 10000) %>%
  visEdges(arrows = "to", color=list(color="#a7d8de", background ="#eaebe6", highlight="#68a0b0")) %>%
  visNodes(font=list(size=20), shadow = TRUE, scaling=list(min=10, max = 30), color=list(background = "#68a0b0", highlight = "#82919a")) %>%
  visOptions(highlightNearest = list(enabled = TRUE, degree=list(to=1, from=1), algorithm="hierarchical"), 
    nodesIdSelection = TRUE, clickToUse=TRUE) %>%
  visInteraction(navigationButtons = TRUE) %>%
  visLegend(addNodes = list(
    list(label = "Distributor", shape = "square"),
    list(label = "Consumer",    shape = "dot"),
    list(label = "Producer",    shape = "triangle")
  ),
  useGroups = FALSE, zoom = FALSE, width=0.2)

#alternative layouts to try
#layout.davidson.harel
#layout_in_cicle

#add this to pick group colours:
#visGroups(groupname = "1", color = "orange") %>%
  #visGroups(groupname = "2", color = "lightblue") %>%
  #visGroups(groupname = "3", color = "pink") %>%
  #visGroups(groupname = "4", color = "grey") %>%
  #visGroups(groupname = "5", color = "lightgreen") %>%
  #visGroups(groupname = "6", color = "purple") 

return(Network)

}


