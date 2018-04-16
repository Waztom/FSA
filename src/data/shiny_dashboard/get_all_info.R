get_all_info <- function(commodity){

if(commodity == "Cucumbers"){
all_info <- all_info_cu
}else if(commodity == "Vanilla"){
all_info <- all_info_va
}

return(all_info)
}
