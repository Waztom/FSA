model_kmeans <- function(all_info, nc, goal_country){

# Data for modelling: select a bunch of variables for k-means
mydata            <- all_info %>% select(month, degree_val, degree_net, ratio, bet_val, overall_flux, deg_in_wei, deg_out_wei)
list_of_countries <- all_info %>% select(node)
mydata_s          <- scale(mydata) # Data must be scaled!!

### Add the cluster index to the data
# Ensure reproducibility
set.seed(42)

ncmax <- 25
wss <- (nrow(mydata_s)-1)*sum(apply(mydata_s,2,var))
for (i in 2:ncmax) wss[i] <- sum(kmeans(mydata_s, centers=i)$withinss)
#plot(1:ncmax, wss, type="b", xlab="Number of Clusters", ylab="Within groups sum of squares")
km_data     <- data.frame(a=c(1:ncmax),b=wss)
single_clus <- data.frame(a=nc,b=wss[nc])
km_plot     <- ggplot(NULL) + geom_point(data=km_data,    aes(x=a,y=b),size=4) +
                              geom_point(data=single_clus,aes(x=a,y=b),size=10,color="red",alpha=0.5) +
                              labs(x="Number of clusters",y="Within groups sum of squares")

# Number of clusters I want
#nc = 20
# K-Means Cluster Analysis
fit <- kmeans(mydata_s, nc) # 5 cluster solution
# get cluster means
aggregate(mydata_s,by=list(fit$cluster),FUN=mean)
# append cluster assignment
results   <- data.frame(all_info, fit$cluster) %>% rename(cluster = fit.cluster)

# For a given country and a period, find the most `similar' countries according to cluster classification
all_periods <- sort(unique(results$period))
i <- 1
c1 <- character(1)
c2 <- list()
for (goal_period in all_periods){
tmp <- results %>% filter(node == goal_country) %>% filter(period == goal_period)
the_cluster <- tmp$cluster
partners <- results %>% filter(cluster == the_cluster) %>% filter(period == goal_period)
partners <- unique(partners$node)
partners <- setdiff(partners,goal_country)
#print(partners)
c1[i]   <- goal_period
c2[[i]] <- unlist(partners)
i <- i + 1 
}

#c3 <- unlist(c2)
#c3 <- c3[1:min(5,length(c2))]

# Most often similar countries
ddd <- as.data.frame(table(cbind(unlist(c2)))) %>% arrange(desc(Freq))
#ddd <- table(cbind(c3))
#ddd <- ddd[order(ddd,decreasing = F)]

if(nrow(ddd) == 0){
  ddd <- data.frame(Empty = c("There is no very close countries for this one"))
}else{
  ddd <- ddd[1:min(5,nrow(ddd)),]
}

#ddd <- ddd %>% select(Var1) %>% rename(Candidate = Var1)
#ddd <- as.data.frame.table(ddd)

return(km_list <- list("km_plot" = km_plot, "ddd" = ddd))

}
