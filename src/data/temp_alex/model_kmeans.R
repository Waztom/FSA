model_kmeans <- function(all_info, goal_country){

# Data for modelling: select a bunch of variables for k-means
mydata            <- all_info %>% select(month, degree_val, degree_net, ratio, bet_val, overall_flux, deg_in_wei, deg_out_wei)
list_of_countries <- all_info %>% select(node)
mydata_s          <- scale(mydata) # Data must be scaled!!

#ncmax <- 20
#wss <- (nrow(mydata_s)-1)*sum(apply(mydata_s,2,var))
#for (i in 2:ncmax) wss[i] <- sum(kmeans(mydata_s, centers=i)$withinss)
#plot(1:ncmax, wss, type="b", xlab="Number of Clusters", ylab="Within groups sum of squares")

### Add the cluster index to the data
# Ensure reproducibility
set.seed(42)
# Number of clusters I want
nc = 20
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

# Most often similar countries
(ddd <- as.data.frame(table(cbind(unlist(c2)))) %>% arrange(desc(Freq)))

return(ddd)

}
