#This directory contain some example binary rprotobuf messages generated with R.
#You can use these to test reading them from within R or a foreign language.
#To reproduce them, install the R and the RProtoBufUtils package, and execute these lines.
library(RProtoBufUtils);
setwd("~/Desktop")
serialize_pb(cars, "cars_dataframe.bin", "dataframe")
serialize_pb(cars, "cars_rexp.bin", "rexp")

goog <- download_stocks("GOOG")
serialize_pb(goog, "goog_stocks.bin", "stocks")
serialize_pb(cars, "goog_dataframe.bin", "dataframe")
serialize_pb(cars, "goog_rexp.bin", "rexp")