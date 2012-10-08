#data frame
data(testdata)

#test rexp.proto
msg <- tempfile();
serialize_pb(testdata, msg, proto="rexp");
obj <- unserialize_pb(msg, proto="rexp");
identical(testdata, obj);

#test dataframe.proto
msg <- tempfile();
serialize_pb(testdata, msg, proto="dataframe");
obj <- unserialize_pb(msg, proto="dataframe");
identical(testdata, obj);
