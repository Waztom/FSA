get_model <- function(commodity){

if(commodity == "Cucumbers"){
  model <- cucumber_model
}else if(commodity == "Vanilla"){
  model <- vanilla_model
}else if(commodity == "Beer"){
  model <- beer_model
}else if(commodity == "Milk"){
  model <- milk_model
}else if(commodity == "Maple Syrup"){
  model <- maple_syrup_mode
}

return(model)
}
