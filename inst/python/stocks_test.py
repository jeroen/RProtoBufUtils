import stocks_pb2;
stockdata = stocks_pb2.data();

f = open("../messages/goog.bin", "rb")
stockdata.ParseFromString(f.read())
f.close();

print(stockdata)