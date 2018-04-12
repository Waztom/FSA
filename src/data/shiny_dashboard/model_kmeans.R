model_kmeans <- function(all_info){

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

return(results)

}
