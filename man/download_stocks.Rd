\name{download_stocks}
\alias{download_stocks}
\title{Download stock data}
\usage{
  download_stocks(symbol = "YHOO")
}
\arguments{
  \item{symbol}{Stock ticker symbol. Usually string of 3 or
  4 characters.}
}
\value{
  a data frame with class "stockdata"
}
\description{
  Functions downloads historical stock data from YAHOO
  finance and returns a data frame with a special class
  "stockdata". The output can be serialized to protocol
  buffer "stocks".
}

