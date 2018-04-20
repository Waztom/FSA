get_si <- function(commodity){

if(commodity == "Cucumbers"){
  si <- si_cu
}else if(commodity == "Vanilla"){
  si <- si_va
}else if(commodity == "Beer"){
  si <- si_be
}else if(commodity == "Milk"){
  si <- si_mi
}else if(commodity == "Maple Syrup"){
  si <- si_ms
}

return(si)
}
