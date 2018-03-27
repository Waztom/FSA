import_export <- function(partner_id,com_id){

source("get_Comtrade_data.R")
stime <- Sys.time()
xx_is_partner  <- get_Comtrade_data(201401,201601,"default",com_id,as.character(partner_id))
uk_is_partner  <- get_Comtrade_data(201401,201601,"default",com_id,"826")
etime <- Sys.time()
(etime-stime)

#print(names(xx_is_partner))

#In case the same 'product' comes under several commodity codes, add them together:
##For instance: different chicken cuts have different commodity codes.
xx_is_partner  <- xx_is_partner %>%
                  group_by(trade_flow,reporter,period,reporter_code) %>%
                  summarize(net_weight_kg   = sum(netweight_kg),
                  trade_value_usd = sum(trade_value_usd)) %>% ungroup()
uk_is_partner  <- uk_is_partner %>%
                  group_by(trade_flow,reporter,period,reporter_code) %>%
                  summarize(net_weight_kg   = sum(netweight_kg),
                  trade_value_usd = sum(trade_value_usd)) %>% ungroup()

#Get the price in usd per kilogram
xx_is_partner  <- xx_is_partner  %>% mutate(price_usd_kg = trade_value_usd/net_weight_kg)
uk_is_partner  <- uk_is_partner  %>% mutate(price_usd_kg = trade_value_usd/net_weight_kg)

#Refurbish the date
xx_is_partner  <- xx_is_partner %>%
                  mutate(period_date = ymd(paste(period,"01",sep="")))
uk_is_partner  <- uk_is_partner %>%
                  mutate(period_date = ymd(paste(period,"01",sep="")))

#Clean the data by removing incomplete cases
#Use simpler nomenclature for each data frame
xx_is_partner <- xx_is_partner[complete.cases(xx_is_partner),]
uk_is_partner <- uk_is_partner[complete.cases(xx_is_partner),]

uk_is_importer <- xx_is_partner %>% filter(reporter=="United Kingdom") %>%
                                    filter(trade_flow=="Imports")
xx_is_exporter <- uk_is_partner %>% filter(reporter_code==partner_id) %>%
                                    filter(trade_flow=="Exports")

merging <- inner_join(uk_is_importer %>% select(-reporter,-period),
                      xx_is_exporter %>% select(-reporter,-period),
                      by="period_date") %>%
                      mutate(i2e_weight =   net_weight_kg.x / net_weight_kg.y,
                             i2e_value  = trade_value_usd.x / trade_value_usd.y,
                             i2e_price  =    price_usd_kg.x / price_usd_kg.y)
p <- ggplot(merging,aes(x=period_date)) + geom_line(aes(y = i2e_weight)) + geom_point(aes(y = i2e_weight)) +
  labs(x="Period",y="A_to_B_imports / B_to_A_exports ratio",title="A=United Kingdom, B=XXXX")

return(p)

}

