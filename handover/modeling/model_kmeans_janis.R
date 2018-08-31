model_kmeans_janis <- function(node_data, goal_country,maxl){

  kmeansdata <- node_data %>% select(
    node,
    period,
    overall_flux_n, 
    ratio,
    links_net,
    between,
    eigen_w
  )
  
  kmeansdata <- kmeansdata %>% mutate(countrytime = paste(as.character(node),as.character(period),sep='_')) %>%
                               select(-node,-period)
  row.names(kmeansdata) <- kmeansdata$countrytime
  kmeansdata <- kmeansdata %>% select(-countrytime)
  
  list_of_countries <-node_data %>% select(node)
  
  set.seed(42) #Ensure reproducibility
  ncmax  <- 40    #Pick a cluster number.

  wss <- (nrow(kmeansdata)-1)*sum(apply(kmeansdata,2,var))
  for (i in 2:ncmax) wss[i] <- sum(kmeans(kmeansdata, centers=i, iter.max = 25)$withinss)
  pl1 <- plot(1:ncmax, log10(wss), type="b", xlab="Number of Clusters", ylab="Within groups sum of squares")
  
  #Automatically determine optimum number of clusters: very slowwwwww
  #d_clust <- Mclust(as.matrix(kmeansdata), G=15:ncmax)
  #m.best <- dim(d_clust$z)[2]
  #cat("model-based optimal number of clusters:", m.best, "\n")
  #pl2 <- plot(d_clust)
  
  set.seed(42) #Ensure reproducibility
  nc <- 25
  fit <- kmeans(kmeansdata, nc, iter.max = 25) #K-means
  aggregate(kmeansdata,by=list(fit$cluster),FUN=mean)
  kmeansres <- data.frame(node_data, fit$cluster) %>% rename(cluster = fit.cluster)
  
  # For a given country and a period, find the most `similar' countries according to cluster classification
  all_periods <- sort(unique(kmeansres$period))
  #print(all_periods)
  i <- 0
  c1 <- character(1)
  c2 <- list()
  for (goal_period in all_periods){
    tmp <- kmeansres %>% filter(node == goal_country) %>% filter(period == goal_period)
    if(nrow(tmp)>0){
      the_cluster <- tmp$cluster
      partners <- kmeansres %>% filter(cluster == the_cluster) %>% filter(period == goal_period)
      partners <- unique(partners$node)
      partners <- setdiff(partners,goal_country)
      #print(partners)
      i <- i + 1 
      c1[i]   <- goal_period
      c2[[i]] <- unlist(partners)
    }
  }
  
  # Most often similar countries
  ddd <- as.data.frame(table(cbind(unlist(c2)))) %>% arrange(desc(Freq))
  
  simlist <- as.character(ddd[1:min(maxl,length(ddd$Var1)),1])

  ans <- list(kmeansres,simlist,pl1)
  

return(ans)

}
