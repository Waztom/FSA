get_data_SQL <- function(result){

  drv <- dbDriver("PostgreSQL")

   con <- dbConnect(drv,
                  dbname = "comtrade",
                  host = "data-science-pgsql-dev-01.c8kuuajkqmsb.eu-west-2.rds.amazonaws.com",
                  user = "trade_read",
                  password = "2fs@9!^43g")
  (tab <- dbListTables(con))
   
  comtrade_db <- tbl(con, 'comtrade')
  result <- comtrade_db %>% group_by(period) %>% tally()

  result <- result %>% collect()

}
