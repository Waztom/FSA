model_linear <- function(all_info){

# Model assessment via bootstrapping
# Scale the _overall_flux_ in \$US into _overall_flux_busd_ in billions of \$US
linmodel <- all_info %>% mutate(overall_flux_busd = overall_flux/1e9) %>% select(overall_flux_busd,degree_val,bet_val,eigen_val)
slm <- nrow(linmodel)
# Make a functin for strapping that returns the linear model coefficients
boot.fn = function(data,index){
return (coef(lm(overall_flux_busd ~ .,data = linmodel, subset = index)))
}

#print(boot(linmodel, boot.fn, 1000))
#summary(lm(overall_flux_busd~., data=linmodel))$coef

linmodel <- all_info %>% mutate(overall_flux_busd = overall_flux/1e9) %>%
            select(overall_flux_busd, deg_in_wei, deg_out_wei, degree_net, bet_val, tri_no, eigen_val, net_group)
lm.best <- lm(overall_flux_busd ~
              poly(deg_in_wei,2) +
              poly(deg_out_wei,3) +
              poly(degree_net,2) +
              poly(bet_val,3) +
              poly(tri_no,3) +
              poly(eigen_val,3) +
              net_group,
              data = linmodel)
summary(lm.best)
regfit.full = regsubsets(overall_flux_busd~poly(deg_in_wei,2) +
              poly(deg_out_wei,3) +
              poly(degree_net,2) +
              poly(bet_val,3) +
              poly(tri_no,3) +
              poly(eigen_val,3) +
              net_group,
              linmodel,nvmax=19)
(reg.summary <- summary(regfit.full))
rsq <- reg.summary$rsq
rsq <- rowid_to_column(as.data.frame(rsq))
#ggplot(rsq,aes(x=rowid,y=rsq)) + geom_point() + geom_line() + labs("Number of variables", y="R^2",
#                                                                 title="Varaible selection analysis",
#                                                                 subtitle="EIGENVALUE WITHOUT WEIGHTED-EDGES")

return(lm.best)
}
