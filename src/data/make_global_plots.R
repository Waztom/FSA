make_global_plots <- function(mydata_i){

source("get_outliers.R")

mydata_i_uk    <- mydata_i %>% filter(reporter=="United Kingdom")
mydata_i_world <- mydata_i %>% group_by(period_date) %>%
                summarize(world_net_weight_kg   = sum(net_weight_kg),
                          world_trade_value_usd = sum(trade_value_usd)) %>%
                mutate(world_price_usd_kg = world_trade_value_usd/world_net_weight_kg)
mydata_global  <- full_join(mydata_i_uk,mydata_i_world,by="period_date") %>%
                mutate(uk_to_world_trade  = 100 * trade_value_usd/world_trade_value_usd,
                       uk_to_world_weight = 100 * net_weight_kg/world_net_weight_kg)
tmp1 <- mydata_global %>% select(period_date,price_usd_kg,world_price_usd_kg) %>%
                        rename(uk_price_usd_kg="price_usd_kg") %>%
                        gather("scope", "price_usd", 2:3)
p <- ggplot(data=tmp1) + geom_line(mapping=aes(x=period_date,y=price_usd,group=scope,color=scope)) +
                    geom_point(mapping=aes(x=period_date,y=price_usd,group=scope,color=scope))


dat <- mydata_i %>% tibble::rownames_to_column(var="outlier") %>%
       group_by(period_date) %>%
       mutate(is_outlier=ifelse(get_outliers(price_usd_kg), reporter, NA))

q <- ggplot(dat, aes(y=price_usd_kg, x=period_date,group=period_date)) +
     geom_boxplot(data=dat) + geom_text(aes(label=is_outlier),na.rm=TRUE,nudge_y=0.5,angle=45,size=3) +
     geom_point(data=mydata_i_uk,mapping = aes(x=period_date,y=price_usd_kg),color="red",size=4)
return(list(p,q))
}







