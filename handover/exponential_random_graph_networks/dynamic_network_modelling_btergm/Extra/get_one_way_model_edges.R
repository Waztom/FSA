get_one_way_model_edges <- function(model_edges){

edges_model <- edges_model %>% select(from,to,trade_value_usd)

for (i in 1:nrow(edges_model)){
  from_test <-edges_model[[1]][i] 
  to_test   <-edges_model[[2]][i]
  for (f in i:nrow(edges_model)){
    if (f == nrow(edges_model)){break
    }
    tryCatch({
    if (from_test == edges_model[[2]][f] & to_test == edges_model[[1]][f]){
        test_diff <- edges_model[[3]][i]-edges_model[[3]][f]
      if (test_diff > 0){
        edges_model[[3]][i] <- test_diff 
        edges_model <- edges_model[-c(f), ] 
      }
      else if (test_diff < 0){
        edges_model[[1]][i] <- edges_model[[2]][f]
        edges_model[[2]][i] <- edges_model[[1]][f]
        edges_model[[3]][i] <- abs(test_diff)
        edges_model <- edges_model[-c(f), ]
    } 
      }else {
    }}, error=function(e){})
  }
  }

return(edges_model)
}
