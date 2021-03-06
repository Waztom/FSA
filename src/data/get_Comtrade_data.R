get_Comtrade_data <- function(from_period,to_period,df_columns,comcode,country){

# Convert function inputs to strings
from_period <- as.character(substitute(from_period))
to_period <- as.character(substitute(to_period))

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv,
                 dbname = "comtrade",
                 host = "data-science-pgsql-dev-01.c8kuuajkqmsb.eu-west-2.rds.amazonaws.com",
                 user = "trade_read",
                 password = "2fs@9!^43g")

if(df_columns == "default"){
   df_columns <- "period, trade_flow, reporter_code, reporter, partner_code, partner, commodity_code, netweight_kg, trade_value_usd"
}

sql_db_query <- paste(
  "SELECT ",df_columns,
  " FROM comtrade WHERE commodity_code ~ '^",comcode,"' AND period >=",
  from_period," AND period <=",to_period," AND partner_code=",country,sep="")

print(sql_db_query)

#print("Large cuppa?")
comtrade   <- dbGetQuery(con, sql_db_query)

return(comtrade = as.data.frame(comtrade))
on.exit(dbDisconnect(con))
on.exit(dbUnloadDriver(drv))
}
