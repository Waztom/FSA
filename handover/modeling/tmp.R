library(RPostgreSQL)
library(tidyverse)
library(dbplyr)
library(rjson)
library(DBI)
library(lubridate)
library(tibble)
library(ggplot2)
library(stringr)
library(gridExtra)
library(network)
library(ggraph)
library(visNetwork)
library(networkD3)
library(igraph)
library(tidygraph)
library(cluster)
library(fpc)
library(plotly)
library(cluster)
library(factoextra)
library(anomalize)
library(boot)
library(leaps)

pathname <- '/home/alex/S2DS/FSA/handover/data/'
filename <- 'all_data__210500_201601-201602_total_dump_.RData'
route <- paste(pathname,filename,sep='')
load(route)

node_data <- data$node_data#all_info
edge_data <- data$edge_data#si

source("/home/alex/S2DS/FSA/handover/modeling/build_network.R")

build_network(edge_data,1,50)
