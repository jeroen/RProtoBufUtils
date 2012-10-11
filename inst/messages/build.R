#This directory contain some example binary rprotobuf messages generated with R.
#You can use these to test reading them from within R or a foreign language.
#To reproduce them, install the R and the RProtoBufUtils package, and execute these lines.
library(RProtoBufUtils);
setwd("~/Desktop")

#serialize using the most general 'rexp' definition.
serialize_pb(cars, "msg_rexp.bin", "rexp")

#serialize using the 'dataframe' definition.
serialize_pb(iris, "msg_dataframe.bin", "dataframe")

#serialize using the 'stocks' definition, specifically for stocks data
google <- download_stocks("GOOG")
serialize_pb(google, "msg_stocks.bin", "stocks")

#stocks data is a dataframe, so this would also work:
serialize_pb(cars, "newmsg_dataframe.bin", "dataframe")
serialize_pb(cars, "newmsg_rexp.bin", "rexp")