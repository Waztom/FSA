get_network_model<-function(world_data,from,to){

source('get_Comtrade_monthly_data.R')
source('get_country_ids.R')
source('get_model_edges.R')
source('get_model_nodes.R')
source('get_trade_attributes.R')

period_list               <- list() #List of months
net_list                  <- list() #Find network objects by index eg. net_list[[24]]

#Get data into months stored in list
world_monthly_data <- get_Comtrade_monthly_data(world_data)

#get unique ID for each country - use for nodes and edges later, prevent renaming of country with different ID each time loop runs
country_ids <-get_country_ids(world_data)

for (i in world_monthly_data){
  #Get some node attributes - we can definitely look more into this, Alex/Janis may have some ideas to include more node attributes
  month_trade_attributes  <- get_trade_attributes(i)
  
  #Get nodes and edges for model. reminder - NA generatedinvalid factor level     message result of get_model_nodes call, need to see what is casuing this and fix 
  nodes_model             <- get_model_nodes(trade.flow, month_data = i, month_trade_attributes,country_ids)
  edges_model             <- get_model_edges(nodes_model,month_data = i)
  
  #Edges for network object
  only_edges             <- edges_model %>% select(c(2,1))
  
  #Create network object
  net <- network(only_edges, matrix.type = "edgelist", directed = T)
  
  #Add edge attributes
  net <- set.edge.attribute(net,"trade_value_width",edges_model$width_trade_value)
  net <- set.edge.attribute(net, "trade_weight_width", edges_model$width_netweight_kg)
  
  #Add some node attributes 
  net <- set.vertex.attribute(net, "nett_trade",nodes_model$nett_trade)
  net <- set.vertex.attribute(net, "trade_flux",nodes_model$trade_flux)
  net <- set.vertex.attribute(net, "trade_value",nodes_model$trade_value)
  net <- set.vertex.attribute(net,"nett_weight",nodes_model$nett_weight)
  net <- set.vertex.attribute(net, "trade_weight_value",nodes_model$trade_weight_value)
  
  #capture period
  month               <- unique(i$period)
  
  #Append features to respective lists
  period_list   <- list.append(period_list, month)
  net_list      <- list.append(net_list, net)
  
}

#Combine lists into dataframe
period_summary <- do.call(rbind, Map(data.frame, period=period_list))

#Convert period to date type
period_summary <- period_summary %>% mutate(period = paste0(period,"01")) %>% mutate(period = as.Date(period, "%Y%m%d"))

#Try simplified covariate model without temporal component
model.1c <- btergm(net_list ~ edges + mutual + transitiveties + twopath + nodeicov("trade_flux") + nodecov("trade_value") + absdiff("trade_value") + isolates, R = 50, parallel = "snow",  ncpus = 2)

prob_vector <- vector()
#Loop through to get probability over time
for (time in 1:nrow(period_summary)){
  prob_values  <- interpret(model.1c, type = "node", i = c(from), j = c(to,33), t = time)
  prob_dat <- as.data.frame(prob_values,col.names = 1,2,3)
  prob_vector[time] <- prob_dat[[3,1]]
}

plot_prob   <-plot(period_summary$period,prob_vector)

return()

}


