model_kmeans <- function(node_data, goal_country,maxl){

  kmeansdata <- node_data %>% select(
    overall_flux_n, 
    ratio,
    links_tot,
    links_net,
    between,
    triangles,
    eigen_w,
    eigen_u,
    net_group,
    max_influx_n,
    max_outflux_n,
    ave_influx_n,
    ave_outflux_n
  )
  list_of_countries <-node_data %>% select(node)
  
  set.seed(42) #Ensure reproducibility
  nc  <- 20    #Pick a cluster number. TODO: pick it automatically
  fit <- kmeans(kmeansdata, nc, iter.max = 25) #K-means
  aggregate(kmeansdata,by=list(fit$cluster),FUN=mean)
  kmeansres <- data.frame(node_data, fit$cluster) %>% rename(cluster = fit.cluster)
  
  # For a given country and a period, find the most `similar' countries according to cluster classification
  all_periods <- sort(unique(kmeansres$period))
  i <- 1
  c1 <- character(1)
  c2 <- list()
  for (goal_period in all_periods){
    tmp <- kmeansres %>% filter(node == goal_country) %>% filter(period == goal_period)
    the_cluster <- tmp$cluster
    partners <- kmeansres %>% filter(cluster == the_cluster) %>% filter(period == goal_period)
    partners <- unique(partners$node)
    partners <- setdiff(partners,goal_country)
    #print(partners)
    c1[i]   <- goal_period
    c2[[i]] <- unlist(partners)
    i <- i + 1 
  }
  
  # Most often similar countries
  ddd <- as.data.frame(table(cbind(unlist(c2)))) %>% arrange(desc(Freq))
  
  ddd <- as.character(ddd[1:min(maxl,length(ddd$Var1)),1])
  
return(ddd)

}
