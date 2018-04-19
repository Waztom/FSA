 model_linear <- function(all_info,x1,x2,x4,x5,x6,x7){

# # Model assessment via bootstrapping
# # Scale the _overall_flux_ in \$US into _overall_flux_busd_ in billions of \$US
# linmodel <- all_info %>% mutate(overall_flux_busd = overall_flux/1e9) %>%
#                          select(overall_flux_busd, deg_in_wei, deg_out_wei, degree_net, bet_val, tri_no, eigen_val, ratio)
# slm <- nrow(linmodel)
# # Make a functin for strapping that returns the linear model coefficients
# boot.fn = function(data,index){
# return (coef(lm(overall_flux_busd ~ .,data = linmodel, subset = index)))
# }

#print(boot(linmodel, boot.fn, 1000))
#summary(lm(overall_flux_busd~., data=linmodel))$coef


   
linmodel <- all_info %>% mutate(overall_flux_busd = overall_flux/1e9) %>%
            select(overall_flux_busd, deg_in_wei, deg_out_wei, degree_net, bet_val, tri_no, eigen_val, ratio)
lm.best <- lm(overall_flux_busd ~
              poly(deg_in_wei,2) +
              poly(deg_out_wei,3) +
              poly(degree_net,2) +
              poly(bet_val,3) +
              poly(tri_no,3) +
              poly(eigen_val,3) +
              ratio,
              data = linmodel)
summary(lm.best)

regfit.full = regsubsets(overall_flux_busd~
              poly(deg_in_wei,2) +
              poly(deg_out_wei,3) +
              poly(degree_net,2) +
              poly(bet_val,3) +
              poly(tri_no,3) +
              poly(eigen_val,3) +
              ratio,
              linmodel,nvmax=19)
(reg.summary <- summary(regfit.full))
rsq <- reg.summary$rsq
rsq <- rowid_to_column(as.data.frame(rsq))
p1 <- ggplot(rsq,aes(x=rowid,y=rsq)) + geom_point() + geom_line() + labs(x="Number of variables", y="R^2",
                                                                    title="Variable selection analysis")
querydata <- data.frame(
deg_in_wei  = x1,
deg_out_wei = x2,
degree_net  = x2-x1,
bet_val     = x4,
tri_no      = x5,
eigen_val   = x6,
ratio       = x7
)

#nnn <- sample(1:nrow(all_info),1,replace = T)
##ran_row <- all_info[nnn,]
##ran_row <- ran_row %>% mutate(overall_flux_musd = overall_flux_usd/1e6) %>% select(node, period, overall_flux_musd)

predd <- predict(lm.best,querydata,type ="response")

return(data_lm <- list("lm_fit" = lm.best$r.squared, "lm_prediction" = 1000 * predd, "lm_plot" = p1))
}
