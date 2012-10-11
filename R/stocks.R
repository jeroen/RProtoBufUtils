#' Download stock data
#' 
#' Functions downloads historical stock data from YAHOO finance and returns a data frame
#' with a special class "stockdata". The output can be serialized to protocol buffer "stocks".
#'  
#' @param symbol Stock ticker symbol. Usually string of 3 or 4 characters.
#' @return a data frame with class "stockdata" 
#' @export
download_stocks <- function(symbol="YHOO"){
  url <- paste(
    "http://ichart.finance.yahoo.com/table.csv?s=", symbol, 
    "&a=00&b=01&c=2012&d=01&e=00&f=2020&g=d&ignore=.csv",
    sep = ""
  );
  mydata <- read.csv(url)
  mydata$Date <- as.Date(mydata$Date);
  attr(mydata, "symbol") <- symbol;
  class(mydata) <- c("stockdata", class(mydata));
  return(mydata);
}

stocks_obj <- function(mydata){
  #validate
  stopifnot(is(mydata, "stockdata"));
  
  #create records
  recordlist <- list();
  for(i in 1:nrow(mydata)){
    recordlist[[i]] <- new(stocks.record,
        Date = new(stocks.Date, value=as.character(mydata[i, "Date"])),
        Open = mydata[i, "Open"],
        Close = mydata[i, "Close"],
        Low = mydata[i, "Low"],
        High = mydata[i, "High"],
        Volume = mydata[i, "Volume"]
    );                            
  }
  
  new(stocks.data,
      symbol=attr(mydata, "symbol"),
      days=recordlist
  );  
}
