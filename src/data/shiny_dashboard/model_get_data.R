model_get_data <- function(csv_file_name){

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
si <- Imports %>% select(period,reporter,partner,trade_value_usd) %>%
                  mutate(origin = as.character(partner)) %>%
                  mutate(destin = as.character(reporter)) %>% 
                  select(-reporter,-partner)

month_list <- sort(unique(si$period))
i <- 1
j <- 1
mylist <- list() #create an empty list to store the node data
numc   <- list() #create an empty list to store the # of countries per period
for (cur_month in month_list){
  sity <- si %>% filter(period == cur_month) %>% transform(trade_value_usd  = as.numeric(trade_value_usd))
  origin_country <- unique(sity$origin)
  destin_country <- unique(sity$destin)
  all_country    <- union(origin_country,destin_country)
  numc[[j]] <- length(all_country)
  j <- j + 1
#
  for (cur_count in all_country) {
  
    for_origin <- sity %>% filter(origin==cur_count) %>% summarize(a1 = sum(trade_value_usd),
                                                                   b1 = n(),
                                                                   c1 = mean(trade_value_usd),
                                                                   d1 = max(trade_value_usd))

    for_destin <- sity %>% filter(destin==cur_count) %>% summarize(a2 = sum(trade_value_usd),
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
net_flux <- net_flux %>% transform(X3  = as.integer(X3))  %>% rename( deg_out_wei = X3)
net_flux <- net_flux %>% transform(X4  = as.numeric(X4))  %>% rename( tot_out_wei = X4)
net_flux <- net_flux %>% transform(X5  = as.numeric(X5))  %>% rename( ave_out_wei = X5)
net_flux <- net_flux %>% transform(X6  = as.numeric(X6))  %>% rename( max_out_wei = X6)
net_flux <- net_flux %>% transform(X7  = as.integer(X7))  %>% rename( deg_in_wei  = X7)
net_flux <- net_flux %>% transform(X8  = as.numeric(X8))  %>% rename( tot_in_wei  = X8)
net_flux <- net_flux %>% transform(X9  = as.numeric(X9))  %>% rename( ave_in_wei  = X9)
net_flux <- net_flux %>% transform(X10 = as.numeric(X10)) %>% rename( max_in_wei  = X10)

net_flux <- net_flux %>% mutate(ratio = (tot_in_wei-tot_out_wei)/(tot_in_wei + tot_out_wei))

numc_per_period <- list("period" = month_list, "country_num" = unlist(numc))
numc_per_period <- as.data.frame(numc_per_period) %>% mutate(period_date = ymd(paste(as.character(period),"01")))

time_history <- sort(unique(si$period))

i <- 1
dat1 <- integer(1)
dat2 <- integer(1)
dat3 <- integer(1)
dat4 <- numeric(1)
dat5 <- integer(1)
dat6 <- character(1)
dat7 <- character(1)

for (cur_time in time_history){
  netdf1 <- si %>% filter(period == cur_time) %>% select(origin,destin,trade_value_usd)
  sources1 <-      netdf1 %>% distinct(origin) %>% rename(label = origin)
  destinations1 <- netdf1 %>% distinct(destin) %>% rename(label = destin)
  per_route1 <- netdf1 %>% group_by(origin,destin) %>% summarise(weight = sum(trade_value_usd)/1e6) %>% ungroup()
  nodes1 <- full_join(sources1,destinations1,by="label")
  nodes1 <- nodes1 %>% rowid_to_column("id")
  edges1 <- per_route1 %>% left_join(nodes1,by=c("origin" = "label")) %>% rename(from = id)
  edges1 <- edges1     %>% left_join(nodes1,by=c("destin" = "label")) %>% rename(to   = id)
  edges1 <- select(edges1,from,to,weight)
  g <- tbl_graph(nodes = nodes1, edges = edges1, directed = TRUE)
    degree_val  <- degree(g)
    bet_val     <- betweenness(g)
    tri_no      <- count_triangles(g)
#    eigen_val   <- eigen_centrality(g, weights = NA)
    eigen_val   <- eigen_centrality(g)
    undirected_network <- tbl_graph(nodes = nodes1, edges = edges1, directed = FALSE)
    communities <- edge.betweenness.community(undirected_network)
    net_groups  <- membership(communities)
    #
    all_country <- unique(nodes1$label)
    for (cur_country in all_country){
      this_one <- nodes1[nodes1$label==cur_country,1]######
      dat1[i] <- degree_val[this_one]
      dat2[i] <- bet_val[this_one]
      dat3[i] <- tri_no[this_one]
      dat4[i] <- eigen_val$vector[this_one]
      dat5[i] <- net_groups[this_one]
      dat6[i] <- cur_country
      dat7[i] <- cur_time
      i <- i + 1
  }
#
}

dfs <- list("degree_val" = dat1, "bet_val" = dat2, "tri_no" = dat3, "eigen_val" = dat4, "net_group" = dat5, "node" = dat6, "period" = dat7)
metrics <- as.data.frame(dfs)

all_info <- full_join(net_flux,metrics,by=c("node","period"))
all_info[is.nan(all_info$ave_in_wei),]$max_in_wei   = 0
all_info[is.nan(all_info$ave_out_wei),]$max_out_wei = 0
all_info[is.nan(all_info$ave_in_wei),]$ave_in_wei   = 0
all_info[is.nan(all_info$ave_out_wei),]$ave_out_wei = 0

all_info <- all_info %>% group_by(period) %>%
  mutate(tot_in_wei_n = tot_in_wei/mean(tot_in_wei)) %>%
  mutate(tot_out_wei_n = tot_out_wei/mean(tot_out_wei)) %>%
  mutate(period_date = ymd(paste(as.character(period),"01",sep=""))) %>%
  mutate(degree_net = deg_out_wei - deg_in_wei) %>%
  mutate(overall_flux = tot_out_wei + tot_in_wei) %>%
  mutate(month = month(period_date)) %>%
  ungroup()

return(all_info)

}
