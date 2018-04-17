get_ad <- function(commodity){

if(commodity == "Cucumbers"){
  ad <- ad_cu
}else if(commodity == "Vanilla"){
  ad <- ad_va
}else if(commodity == "Beer"){
  ad <- ad_be
}else if(commodity == "Milk"){
  ad <- ad_mi
}else if(commodity == "Maple Syrup"){
  ad <- ad_ms
}

return(ad)
}
