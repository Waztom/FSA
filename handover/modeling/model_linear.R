model_linear <- function(node_data){

maxp <- 1
lm.basic <- lm(overall_flux_n ~ 
                 poly(max_influx_n,maxp) +
                 poly(max_outflux_n,maxp) +
                 poly(ratio,maxp) +
                 poly(links_tot,maxp) +
                 poly(betweeness,maxp) +
                 poly(eigen,maxp) +
                 poly(links_net,maxp),
                 data = node_data)
lm.basic.sum <- summary(lm.basic)

regfit.basic = regsubsets(overall_flux_n ~
                            poly(max_influx_n,maxp) +
                            poly(max_outflux_n,maxp) +
                            poly(ratio,maxp) +
                            poly(links_tot,maxp) +
                            poly(betweeness,maxp) +
                            poly(eigen,maxp) +
                            poly(links_net,maxp),
                            node_data,nvmax=9)
lm.basic.reg <- summary(regfit.basic)

maxp <- 2
lm.square <- lm(overall_flux_n ~ 
               poly(max_influx_n,maxp) +
               poly(max_outflux_n,maxp) +
               poly(ratio,maxp) +
               poly(links_tot,maxp) +
               poly(betweeness,maxp) +
               poly(eigen,maxp) +
               poly(links_net,maxp),
               data = node_data)
lm.square.sum <- summary(lm.square)

regfit.square = regsubsets(overall_flux_n ~
                             poly(max_influx_n,maxp) +
                             poly(max_outflux_n,maxp) +
                             poly(ratio,maxp) +
                             poly(links_tot,maxp) +
                             poly(betweeness,maxp) +
                             poly(eigen,maxp) +
                             poly(links_net,maxp),
                             node_data,nvmax=18)
lm.square.reg <- reg.summary <- summary(regfit.square)

maxp <- 3
lm.cubic <- lm(overall_flux_n ~ 
               poly(max_influx_n,maxp) +
               poly(max_outflux_n,maxp) +
               poly(ratio,maxp) +
               poly(links_tot,maxp) +
               poly(betweeness,maxp) +
               poly(eigen,maxp) +
               poly(links_net,maxp),
               data = node_data)
lm.cubic.sum <- summary(lm.cubic)

regfit.cubic = regsubsets(overall_flux_n ~
                            poly(max_influx_n,maxp) +
                            poly(max_outflux_n,maxp) +
                            poly(ratio,maxp) +
                            poly(links_tot,maxp) +
                            poly(betweeness,maxp) +
                            poly(eigen,maxp) +
                            poly(links_net,maxp),
                            node_data,nvmax=27)
lm.cubic.reg <- summary(regfit.cubic)

## Make a functin for strapping that returns the linear model coefficients
#boot.fn = function(data,index){
##return(coef(lm(overall_flux_n ~ .,data = linmodel, subset = index)))
#return(coef(lm(overall_flux_n ~ .,data = linmodel[index,])))
#}
#
#print(boot(linmodel, boot.fn, 100))
#return(summary(lm(overall_flux_n~., data=linmodel))$coef)
#}

lm.results <- list(lm.basic.sum,lm.basic.reg,lm.square.sum,lm.square.reg,lm.cubic.sum,lm.cubic.reg)

return(lm.results)
}