get_data_API <- function(url="http://comtrade.un.org/api/get?"
                         ,maxrec
                         ,type="C"
                         ,freq
                         ,px="HS"
                         ,ps
                         ,r
                         ,p
                         ,rg="all"
                         ,cc="ALL"
                         ,fmt="json"
)
{
	token <- "yGa9ysvivTWUUteZVeQUY4rMsCRBcxGTkDbcFbL773EMywrn6cLEDgIq7Wg3vfwZbYkXyhGsblu0wjZjbiwc2EZC0kh/Zp8SmWsXansq3zNEG17gryZAZaRphkp1Mf95Zkjb3aMX/Rr/uAaiKLJbOOwkmv9X3NoA7TCDAA7Go8Y="

  string<- paste(url
                 ,"max=",maxrec,"&" #maximum no. of records returned
                 ,"type=",type,"&" #type of trade (c=commodities)
                 ,"freq=",freq,"&" #frequency
                 ,"px=",px,"&" #classification
                 ,"ps=",ps,"&" #time period
                 ,"r=",r,"&" #reporting area
                 ,"p=",p,"&" #partner country
                 ,"rg=",rg,"&" #trade flow
                 ,"cc=",cc,"&" #classification code
                 ,"token=",token,"&" #token
                 ,"fmt=",fmt        #Format
                 ,sep = ""
  )
  if(fmt == "csv") {
    raw.data<- read.csv(string,header=TRUE)
    return(list(validation=NULL, data=raw.data))
  } else {
    if(fmt == "json" ) {
      raw.data<- fromJSON(file=string)
      data<- raw.data$dataset
      validation<- unlist(raw.data$validation, recursive=TRUE)
      ndata<- NULL
      if(length(data)> 0) {
        var.names<- names(data[[1]])
        data<- as.data.frame(t( sapply(data,rbind)))
        ndata<- NULL
        for(i in 1:ncol(data)){
          data[sapply(data[,i],is.null),i]<- NA
          ndata<- cbind(ndata, unlist(data[,i]))
        }
        ndata<- as.data.frame(ndata)
        colnames(ndata)<- var.names
      }
      ss <- list(validation=validation,data =ndata)
      df <- data.frame(Reduce(rbind, ss))
      df <- df[complete.cases(df$pfCode),]
      return(df)
    }
  }
}

