#!/usr/bin/env Rscript
library("optparse")
library("dplyr")
library("tidyverse")
library("lubridate")
library("igraph")
library("tidygraph")

option_list = list(
  make_option(c("-f", "--file"), type="character", default=NULL,
              help="dataset file name", metavar="character")
);

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);
filename = opt$file

edge_data <- read.csv(file=filename, header=TRUE, sep=",")

month_list <- sort(unique(edge_data$period))

i <- 1
j <- 1
mylist <- list() #create an empty list to store the node data
numc   <- list() #create an empty list to store the # of countries per period

for (cur_month in month_list){
  temp           <- edge_data %>% filter(period == cur_month) %>% transform(trade_value_usd  = as.numeric(trade_value_usd))
  origin_country <- unique(temp$origin)
  destin_country <- unique(temp$destin)
  all_country    <- union(origin_country,destin_country)
  numc[[j]]      <- length(all_country)
  j <- j + 1
#
  for (cur_count in all_country) {
    for_origin <- temp %>% filter(origin==cur_count) %>% summarize(a1 = sum(trade_value_usd),
                                                                   b1 = n(),
                                                                   c1 = mean(trade_value_usd),
                                                                   d1 = max(trade_value_usd))
    for_destin <- temp %>% filter(destin==cur_count) %>% summarize(a2 = sum(trade_value_usd),
                                                                   b2 = n(),
                                                                   c2 = mean(trade_value_usd),
                                                                   d2 = max(trade_value_usd))
    vec <- list(10) #preallocate a vector. Shouldn't be a character but this is all I can do in R. Fix it later.
    #
    vec[1] <- cur_count
    vec[2] <- cur_month
    vec[3] <- for_origin$b1
    vec[4] <- for_origin$a1
    vec[5] <- for_origin$c1
    vec[6] <- for_origin$d1
    vec[7] <- for_destin$b2
    vec[8] <- for_destin$a2
    vec[9] <- for_destin$c2
    vec[10]<- for_destin$d2
    mylist[[i]] <- unlist(vec) #put all vectors in the list
    i <- i + 1
  }
}

#
i <- i - 1
#
net_flux <- do.call("rbind",mylist)
net_flux <- data.frame(matrix(unlist(net_flux), nrow=i, byrow=F),stringsAsFactors = FALSE)

net_flux <- net_flux %>% rename(node   = X1)
net_flux <- net_flux %>% rename(period = X2)
net_flux <- net_flux %>% transform(X3  = as.integer(X3))  %>% rename( links_out   = X3)
net_flux <- net_flux %>% transform(X4  = as.numeric(X4))  %>% rename( tot_outflux = X4)
net_flux <- net_flux %>% transform(X5  = as.numeric(X5))  %>% rename( ave_outflux = X5)
net_flux <- net_flux %>% transform(X6  = as.numeric(X6))  %>% rename( max_outflux = X6)
net_flux <- net_flux %>% transform(X7  = as.integer(X7))  %>% rename( links_in    = X7)
net_flux <- net_flux %>% transform(X8  = as.numeric(X8))  %>% rename( tot_influx  = X8)
net_flux <- net_flux %>% transform(X9  = as.numeric(X9))  %>% rename( ave_influx  = X9)
net_flux <- net_flux %>% transform(X10 = as.numeric(X10)) %>% rename( max_influx  = X10)

net_flux <- net_flux %>% mutate(ratio = (tot_influx-tot_outflux)/(tot_influx + tot_outflux))

numc_per_period <- list("period" = month_list, "country_num" = unlist(numc))
numc_per_period <- as.data.frame(numc_per_period) %>% mutate(period_date = ymd(paste(as.character(period),"01")))

time_history <- sort(unique(edge_data$period))

i <- 1
dat1 <- integer(1)
dat2 <- integer(1)
dat3 <- integer(1)
dat4 <- numeric(1)
dat5 <- integer(1)
dat6 <- character(1)
dat7 <- character(1)

#Strictly positive
edge_data <- edge_data %>% filter(trade_value_usd > 0)

for (cur_time in time_history){
  netdf1        <- edge_data %>% filter(period == cur_time) %>% select(origin,destin,trade_value_usd)
  sources1      <- netdf1    %>% distinct(origin)           %>% rename(label     = origin)
  destinations1 <- netdf1    %>% distinct(destin)           %>% rename(label     = destin)
  per_route1    <- netdf1    %>% group_by(origin,destin)    %>% summarise(weight = sum(trade_value_usd)/1e6) %>% ungroup()

  nodes1 <- full_join(sources1,destinations1,by="label")
  nodes1 <- nodes1 %>% rowid_to_column("id")
  edges1 <- per_route1 %>% left_join(nodes1,by=c("origin" = "label")) %>% rename(from = id)
  edges1 <- edges1     %>% left_join(nodes1,by=c("destin" = "label")) %>% rename(to   = id)
  edges1 <- select(edges1,from,to,weight)
  g <- tbl_graph(nodes = nodes1, edges = edges1, directed = TRUE)
    links_tot  <- degree(g)
    between    <- betweenness(g)
    triangles  <- count_triangles(g)
#    eigen_u    <- eigen_centrality(g, weights = NA) #Unweighted eigenvalue
    eigen_w    <- eigen_centrality(g)
    undirected_network <- tbl_graph(nodes = nodes1, edges = edges1, directed = FALSE)
    communities <- edge.betweenness.community(undirected_network)
    net_groups  <- membership(communities)
    #
    all_country <- unique(nodes1$label)
    for (cur_country in all_country){
      this_one <- nodes1[nodes1$label==cur_country,1]######
      dat1[i] <- links_tot[this_one]
      dat2[i] <- between[this_one]
      dat3[i] <- triangles[this_one]
      dat4[i] <- eigen_w$vector[this_one]
      dat5[i] <- net_groups[this_one]
      dat6[i] <- cur_country
      dat7[i] <- cur_time
#      dat8[i] <- eigen_u$vector[this_one]
      i <- i + 1
  }
#
}

dfs <- list("links_tot" = dat1, "between" = dat2, "triangles" = dat3, "eigen_w" = dat4, "net_group" = dat5, "node" = dat6, "period" = dat7)
metrics <- as.data.frame(dfs)

node_data <- full_join(net_flux,metrics,by=c("node","period"))
node_data[is.nan(node_data$ave_influx),]$max_influx   = 0
node_data[is.nan(node_data$ave_outflux),]$max_outflux = 0
node_data[is.nan(node_data$ave_influx),]$ave_influx   = 0
node_data[is.nan(node_data$ave_outflux),]$ave_outflux = 0

node_data <- node_data %>% group_by(period) %>%
  mutate(tot_influx_n  = tot_influx /mean(tot_influx)) %>%
  mutate(tot_outflux_n = tot_outflux/mean(tot_outflux)) %>%
  mutate(ave_influx_n  = ave_influx /mean(ave_influx)) %>%
  mutate(ave_outflux_n = ave_outflux/mean(ave_outflux)) %>%
  mutate(max_influx_n  = max_influx /mean(max_influx)) %>%
  mutate(max_outflux_n = max_outflux/mean(max_outflux)) %>%
  mutate(period_date   = ymd(paste(as.character(period),"01",sep=""))) %>%
  mutate(links_net     = links_in - links_out) %>%
  mutate(overall_flux  = tot_outflux + tot_influx) %>%
  mutate(overall_flux_n= tot_outflux_n + tot_influx_n) %>%
  mutate(month         = month(period_date)) %>%
  ungroup()

#Double check
node_data <- node_data[complete.cases(node_data),]

data <- list("node_data" = node_data, "edge_data" = edge_data)

rdataname <- c("all_data_", substr(filename, 1, nchar(filename)-4), '.RData')

save(data, file = paste(rdataname, collapse="_"))
#save(data, file = paste(rdataname, collapse= NULL))
