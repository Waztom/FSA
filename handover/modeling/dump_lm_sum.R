dump_lm_sum <- function(pathname,filename,summary){

route <- paste(pathname,filename,sep="")
sink(route)
print(summary)
sink()

return()
}
