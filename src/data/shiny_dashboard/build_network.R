#### Changes in this version:
#.......Definition of Producer/Distributor/Consumer has been corrected: before, Spain was a consumer according to shape legend.
#.......The ratio (and therefore the P/D/C classification) is now independent of the threshold.
#.......Limit 0.33 instead of 0.5 for classification.
#.......The node size, set by value, was determined by abs(ratio). This leads to strange results with distributors beeing always small.
#       This has been corrected: size is now determined by total trade.
#.......log replaced by log10 and other minor scaling fixes.

build_network <- function(si,date1,threshold){

all_months <- sort(unique(si$period))
  
si1 <- si %>% filter(period == all_months[date1])
total_exports <- si1 %>% group_by (origin) %>% summarize(total_export = sum(trade_value_usd)) %>% rename(label = origin)
total_imports <- si1 %>% group_by (destin) %>% summarize(total_import = sum(trade_value_usd)) %>% rename(label = destin)
tmp <- full_join(total_imports, total_exports, by = "label") %>% replace_na(list(total_export=0, total_import=0))
tmp <- tmp %>%   mutate(a_ratio = (total_import - total_export)/(total_import+total_export)) %>%
  mutate(value   = log10(total_import+total_export)) %>%
  mutate(shape   = ifelse(a_ratio > 0.33, "dot", ifelse(a_ratio < -0.33, "triangle", "square")))

#Now the selection!!
tmp <- tmp %>% filter(quantile(total_export + total_import, threshold) < total_export + total_import)

nodes <- tmp   %>% select(label)
nodes <- nodes %>% rowid_to_column("id")

#Create edges table
edges <-  si1 %>% inner_join(nodes, by = c("destin" = "label"))  %>% rename(to   = id) %>%
  inner_join(nodes, by = c("origin"  = "label")) %>% rename(from = id) %>%
  mutate(width =  log10(trade_value_usd)) %>% select(from, to, width)

#working out assignment to communities - plan to swap to kmeans but stick to something we have working for now
undirected_network <- tbl_graph(nodes = nodes, edges = edges, directed = FALSE)
communities        <- edge.betweenness.community(undirected_network)
grouping           <- membership(communities)

nodes_groups_shape_size <- nodes %>% mutate (group = grouping) %>% inner_join(tmp,by="label") %>% select(id, label, group, value, shape)

##Select time line in month
# si_month <- si %>% filter(period == all_months[date1])
# #cut out trade with value less than 3rd quantile value
# si_third <- si_month %>%
#   filter(quantile(trade_value_usd, threshold)<trade_value_usd)
# 
# #Create nodes
# imports_from <- si_third %>% select(origin) %>% rename(label = origin) %>% distinct(label)
# imports_to <- si_third %>% select(destin) %>% rename(label = destin) %>% distinct(label)
# ##Combine to form one list of country nodes
# nodes <- full_join(imports_from,imports_to, by = 'label')
# nodes <- arrange(nodes,label)
# ##Add ID column.
# nodes <- nodes %>% rowid_to_column("id")
# 
# #Create edges table
# edges <-  si_third %>% left_join(nodes, by = c("destin" = "label")) %>%
#   rename(to = id) %>%
#   left_join(nodes, by = c("origin"  = "label"))%>%
#   rename(from = id) %>%
#   mutate(width =  log(trade_value_usd/1000)) %>%
#   select(from, to, width)
# 
# 
# #working out assignment to communities - plan to swap to kmeans but stick to something we have working for now
# undirected_network <- tbl_graph(nodes = nodes, edges = edges, directed = FALSE)
# communities <- edge.betweenness.community(undirected_network)
# grouping <- membership(communities)
# 
# #creating total exports and imports for each node
# total_exports<- si_third %>%
#   group_by (origin)  %>%
#   summarize(total_export = sum(trade_value_usd)) %>%
#   rename(label = origin)
# total_imports <- si_third %>%
#   group_by (destin) %>%
#   summarize(total_import = sum(trade_value_usd)) %>%
#   rename(label = destin)
# 
# #adding features to nodes
# nodes_groups_shape_size <- nodes %>%
#   mutate (group = grouping) %>%
#   left_join(total_imports, by = "label") %>%
#   left_join(total_exports, by = "label") %>%
#   replace_na(list(total_export=0, total_import=0)) %>%
#   mutate(a_ratio = (total_import - total_export)/(total_import+total_export)) %>%
#   mutate(value = abs(a_ratio)) %>%
#   mutate(shape = ifelse(a_ratio > 0.33, "dot", ifelse(a_ratio < -0.33, "triangle", "square"))) %>%
#   select(id, label, group, value, shape)


#Creation of network
Network <- visNetwork(nodes_groups_shape_size, edges) %>% 
  visIgraphLayout(layout = "layout.davidson.harel", randomSeed = 10000) %>%
  visEdges(arrows = "to", color=list(inherit=TRUE)) %>%
  visNodes(font=list(size=40), shadow = TRUE, scaling=list(min=10, max = 50)) %>%
  visOptions(selectedBy = "group", highlightNearest = list(enabled = TRUE, degree=list(to=1, from=1), algorithm="hierarchical"), 
    nodesIdSelection = TRUE, clickToUse=TRUE) %>%
  visInteraction(navigationButtons = TRUE) %>%
  visLegend(addNodes = list(
    list(label = "Distributor", shape = "square"),
    list(label = "Consumer",    shape = "dot"),
    list(label = "Producer",    shape = "triangle")
  ),
  useGroups = FALSE, zoom = FALSE)

#nodes <- data.frame(id = 1:3)
#edges <- data.frame(from = c(1,2), to = c(1,3))
#Network <- visNetwork(nodes, edges)

return(Network)

}
