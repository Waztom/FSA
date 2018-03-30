get_HMRC_data2 <- function(df_name,comcode){

# Convert function inputs to strings
df_name <- as.character(substitute(df_name))

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv,
                 dbname = "hmrc",
                 host = "data-science-pgsql-dev-01.c8kuuajkqmsb.eu-west-2.rds.amazonaws.com",
                 user = "trade_read",
                 password = "2fs@9!^43g")
sql_db_query <- paste("SELECT * FROM ",df_name," WHERE smk_comcode ~ '^",comcode,"'",sep='')
#sql_db_query <- paste("SELECT * FROM",df_name,"WHERE smk_comcode ~ '^",comcode,"'")
#print("Medium cuppa?")
requested_df   <- dbGetQuery(con, sql_db_query)

print(paste("SELECT * FROM ",df_name," WHERE comcode ~ '^",comcode,"'",sep=''))

return(requested_df = as.data.frame(requested_df))

on.exit(dbDisconnect(con))
on.exit(dbUnloadDriver(drv))
}

