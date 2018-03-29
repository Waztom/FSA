get_HMRC_aux_data <- function(){

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv,
                 dbname = "hmrc",
                 host = "data-science-pgsql-dev-01.c8kuuajkqmsb.eu-west-2.rds.amazonaws.com",
                 user = "trade_read",
                 password = "2fs@9!^43g")

#print("No cuppa")
comcode    <- dbGetQuery(con, "SELECT * from comcode")
port       <- dbGetQuery(con, "SELECT * from port")
country    <- dbGetQuery(con, "SELECT * from country")

ss <- list(comcode = as.data.frame(comcode), port = as.data.frame(port), country = as.data.frame(country))

return(ss)
on.exit(dbDisconnect(con))
on.exit(dbUnloadDriver(drv))
}

