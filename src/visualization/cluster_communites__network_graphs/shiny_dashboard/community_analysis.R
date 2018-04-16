community_analysis <- function(si,date1,threshold,type){

all_months <- sort(unique(si$period))

si1 <- si %>% filter(period == all_months[date1])
total_exports <- si1 %>% group_by (origin) %>% summarize(total_export = sum(trade_value_usd)) %>% rename(label = origin)
total_imports <- si1 %>% group_by (destin) %>% summarize(total_import = sum(trade_value_usd)) %>% rename(label = destin)

tmp <- full_join(total_imports, total_exports, by = "label") %>% replace_na(list(total_export=0, total_import=0))

tmp <- tmp %>%   mutate(overall_flux = total_import + total_export) %>% 
                 mutate(a_ratio = (total_import - total_export)/overall_flux) %>%
                 mutate(value = 10 * (overall_flux - min(overall_flux))/(max(overall_flux)-min(overall_flux)) + 1) 

#Now the selection!!
tmp <- tmp %>% filter(quantile(total_export + total_import, threshold) < total_export + total_import)

#Create nodes table
nodes <- tmp   %>% select(label,value)
nodes <- nodes %>% rowid_to_column("id")

#Create edges table
edges <-  si1 %>% inner_join(nodes, by = c("destin" = "label"))  %>% rename(to = id) %>%
  inner_join(nodes, by = c("origin"  = "label")) %>% rename(from = id) 

#Get country names again
#Need to do some conversions to get from "from/to id" to name of country again
edges<-edges %>% rename(id=to) %>% left_join(nodes,edges,by="id") %>% select(from,label,trade_value_usd) %>%
  rename(id=from) %>% left_join(nodes,edges,by="id") %>% mutate(weight = scale(trade_value_usd)) %>% select(label.y,label.x,weight)

#Create linked community object using linkcomm and clustering by edges
lc <- getLinkCommunities(edges, directed =T, plot = FALSE)

#Creation of plots
if (type == "members"){
members <- plot(lc, type = "members")
return(members)
} else if (type == "cluster"){
cluster_relatedness <- getClusterRelatedness(lc)
return(cluster_relatedness)
}

}
