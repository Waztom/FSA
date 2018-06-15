model_linear <- function(node_data){

maxregvar <- 6
  
maxp <- 1
lm.basic <- lm(overall_flux_n ~ 
                 poly(ratio,maxp) +
                 poly(links_tot,maxp) +
                 poly(links_net,maxp) +
                 poly(between,maxp) +
                 poly(triangles,maxp) +
                 poly(eigen_w,maxp) +
                 poly(eigen_u,maxp) +
                 poly(net_group,maxp) +
                 poly(max_influx_n,maxp) +
                 poly(max_outflux_n,maxp) +
                 poly(ave_influx_n) +
                 poly(ave_outflux_n),
                 data = node_data)
lm.basic.sum <- summary(lm.basic)

regfit.basic = regsubsets(overall_flux_n ~
                            poly(ratio,maxp) +
                            poly(links_tot,maxp) +
                            poly(links_net,maxp) +
                            poly(between,maxp) +
                            poly(triangles,maxp) +
                            poly(eigen_w,maxp) +
                            poly(eigen_u,maxp) +
                            poly(net_group,maxp) +
                            poly(max_influx_n,maxp) +
                            poly(max_outflux_n,maxp) +
                            poly(ave_influx_n) +
                            poly(ave_outflux_n),
                            node_data,nvmax=maxregvar)
lm.basic.reg <- summary(regfit.basic)

maxp <- 2
lm.square <- lm(overall_flux_n ~ 
                  poly(ratio,maxp) +
                  poly(links_tot,maxp) +
                  poly(links_net,maxp) +
                  poly(between,maxp) +
                  poly(triangles,maxp) +
                  poly(eigen_w,maxp) +
                  poly(eigen_u,maxp) +
                  poly(net_group,maxp) +
                  poly(max_influx_n,maxp) +
                  poly(max_outflux_n,maxp) +
                  poly(ave_influx_n) +
                  poly(ave_outflux_n),
               data = node_data)
lm.square.sum <- summary(lm.square)

regfit.square = regsubsets(overall_flux_n ~
                             poly(ratio,maxp) +
                             poly(links_tot,maxp) +
                             poly(links_net,maxp) +
                             poly(between,maxp) +
                             poly(triangles,maxp) +
                             poly(eigen_w,maxp) +
                             poly(eigen_u,maxp) +
                             poly(net_group,maxp) +
                             poly(max_influx_n,maxp) +
                             poly(max_outflux_n,maxp) +
                             poly(ave_influx_n) +
                             poly(ave_outflux_n),
                             node_data,nvmax=maxregvar)
lm.square.reg <- reg.summary <- summary(regfit.square)

maxp <- 3
lm.cubic <- lm(overall_flux_n ~ 
                 poly(ratio,maxp) +
                 poly(links_tot,maxp) +
                 poly(links_net,maxp) +
                 poly(between,maxp) +
                 poly(triangles,maxp) +
                 poly(eigen_w,maxp) +
                 poly(eigen_u,maxp) +
                 poly(net_group,maxp) +
                 poly(max_influx_n,maxp) +
                 poly(max_outflux_n,maxp) +
                 poly(ave_influx_n) +
                 poly(ave_outflux_n),
               data = node_data)
lm.cubic.sum <- summary(lm.cubic)

regfit.cubic = regsubsets(overall_flux_n ~
                            poly(ratio,maxp) +
                            poly(links_tot,maxp) +
                            poly(links_net,maxp) +
                            poly(between,maxp) +
                            poly(triangles,maxp) +
                            poly(eigen_w,maxp) +
                            poly(eigen_u,maxp) +
                            poly(net_group,maxp) +
                            poly(max_influx_n,maxp) +
                            poly(max_outflux_n,maxp) +
                            poly(ave_influx_n) +
                            poly(ave_outflux_n),
                            node_data,nvmax=maxregvar)
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


#lm.results <- list(lm.basic.sum,lm.basic.reg,lm.square.sum,lm.square.reg,lm.cubic.sum,lm.cubic.reg)
lm.results <- list(lm.basic,lm.basic.reg,lm.square,lm.square.reg,lm.cubic,lm.cubic.reg)

return(lm.results)
}