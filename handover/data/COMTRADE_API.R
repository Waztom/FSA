#Use example: Rscript COMTRADE_API.R --year0 2010 --yeare 2010 --month0 3 --monthe 6 --com1 0706
library(optparse)
library(rjson)
library(tidyverse)
library(comtradr)
library(ggplot2)

option_list = list(
make_option(c("-a", "--year0"),     default=2010,   type='integer',   help="Start year"),
make_option(c("-b", "--yeare"),     default=2010,   type='integer',   help="End year"),
make_option(c("-c", "--month0"),    default=1,      type='integer',   help="Start month"),
make_option(c("-d", "--monthe"),    default=2,      type='integer',   help="End month"),
make_option(c("-e", "--com1"),      default="1006", type='character', help="Commodity 1"),
make_option(c("-f", "--com2"),      default=NA,     type='character', help="Commodity 2"),
make_option(c("-g", "--com3"),      default=NA,     type='character', help="Commodity 3"),
make_option(c("-i", "--com4"),      default=NA,     type='character', help="Commodity 4"),
make_option(c("-j", "--com5"),      default=NA,     type='character', help="Commodity 5"),
make_option(c("-k", "--com6"),      default=NA,     type='character', help="Commodity 6"),
make_option(c("-m", "--com7"),      default=NA,     type='character', help="Commodity 7")
  )

opt = parse_args(OptionParser(option_list=option_list))

uu          <- c(opt$com1,opt$com2,opt$com3,opt$com4,opt$com5,opt$com6,opt$com7)
commodities <- uu[!is.na(uu)]

year0 <- opt$year0
mont0 <- opt$month0
yeare <- opt$yeare
monte <- opt$monthe
comco <- commodities

outputfile <- paste(sprintf("%02d", mont0),year0,'-',sprintf("%02d", monte),yeare,'_',paste(comco, collapse = '_'),'.RData',sep="")
print(outputfile)

FSA_token <- "yGa9ysvivTWUUteZVeQUY4rMsCRBcxGTkDbcFbL773EMywrn6cLEDgIq7Wg3vfwZbYkXyhGsblu0wjZjbiwc2EZC0kh/Zp8SmWsXansq3zNEG17gryZAZaRphkp1Mf95Zkjb3aMX/Rr/uAaiKLJbOOwkmv9X3NoA7TCDAA7Go8Y="
ct_register_token(FSA_token)

maxm <- 5
nmon <- (yeare - year0)*12 + monte - mont0 + 1
pass <- as.integer(ceiling(nmon / maxm))
lagm <- (pass * maxm)-nmon
monte <- monte + lagm
nmon <- (yeare - year0)*12 + monte - mont0 + 1


mydf = data.frame()
mm <- mont0
yy <- year0
for(i in seq(from=1, to=nmon, by=maxm)){
  mmf <- sprintf("%02d", mm)
  d0  <- paste(yy,'-',mmf,sep="")
  mm  <- mm + maxm
  if(mm>12){
    yy <- yy + 1
    mm <- mm-12
           }
  yx <- yy
  mx <- mm-1
  if(mx<1){
    mx <- mx + 12
    yx<-yx-1
          }
  mxf <- sprintf("%02d", mx)
  de <- paste(yx,'-',mxf,sep="")
  print(paste('Querying period: ',d0,de))
tmp <- ct_search("All", "All", trade_direction = c("imports","exports"), freq = c("monthly"),
start_date = d0, end_date = de, commod_codes = comco,
max_rec = NULL, type = c("goods"),
url = "https://comtrade.un.org/api/get?")
mydf <- rbind(mydf,tmp)
}

#ignore <- list('World', 'EU-27', 'Other Asia, nes', 'Other Europe, nes', 'Areas, nes')
ignore <- c('World', 'EU-27', 'Other Asia, nes', 'Other Europe, nes', 'Areas, nes')

dff <- mydf %>%
       select(period,trade_flow_code,trade_flow,reporter,partner,netweight_kg,trade_value_usd,year,commodity,commodity_code)

df  <- rename(dff, net_weight_kg   = netweight_kg) %>%
       mutate(period_date = as.Date(paste0(as.character(period), '01'), format='%Y%m%d')) %>%
       mutate(year_date = as.Date(paste0(as.character(year), '0101'), format='%Y%m%d'))

cc  <- df[!(df$partner %in% ignore) ,]
cc  <- df[!(df$reporter %in% ignore) ,]

# Saving on object in RData format
save(cc, file = outputfile)
