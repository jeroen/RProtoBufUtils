#!/bin/sh

### How to compile .proto definitions to Python pb2 modules
#
# The .proto files are in the dir inst/proto of the source package.
# If RProtoBufUtils has been installed in the standard debian/ubuntu location you can find them in:
# /usr/local/lib/R/site-library/RProtoBufUtils/proto

#For now we download the proto files from github:
wget https://raw.github.com/jeroenooms/RProtoBufUtils/master/inst/proto/dataframe.proto
wget https://raw.github.com/jeroenooms/RProtoBufUtils/master/inst/proto/rexp.proto
wget https://raw.github.com/jeroenooms/RProtoBufUtils/master/inst/proto/stocks.proto

#To compile the proto files to Python modules, use:
protoc dataframe.proto --python_out=${HOME}/Desktop
protoc rexp.proto --python_out=${HOME}/Desktop
protoc stocks.proto --python_out=${HOME}/Desktop
