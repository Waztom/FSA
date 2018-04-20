get_all_info <- function(commodity){

if(commodity == "Cucumbers"){
  all_info <- all_info_cu
}else if(commodity == "Vanilla"){
  all_info <- all_info_va
}else if(commodity == "Beer"){
  all_info <- all_info_be
}else if(commodity == "Milk"){
  all_info <- all_info_mi
}else if(commodity == "Maple Syrup"){
  all_info <- all_info_ms
}

return(all_info)
}
