RProtoBufUtils
==============

This package provides some tools and utilities to serialize R objects to with protocol buffers. It builds on the [RProtoBuf](http://r-forge.r-project.org/projects/rprotobuf/) package, which interfaces to the official protocol buffers C++ library by Google.

The main advantage of serializing an object to a protocol buffer message, as opposed to native R serialization, is that protocol buffers is an inter-operable format that can be read/written by other programming languages. The main disadvantage is that some special R-specific object types are not supported and will get lost in the process (with a warning).

How it works
------------

Serializing an R object to protocol buffer message requires the design of two parts:

 - A .proto file which defines a schema for the structure of the message.
 - A mapping between (a class of) R objects to the specific proto message.

This package contains both some example .proto files designed for serializing R objects, as well as R code that will help with converting R data/objects to this format. Note that in order for a third party to unserialize a message, they will need both the serialized data as well as the specific proto file.

Example
--------

The `serialize_pb` function mimics native serializion and writes an R object to file or connection, in protobuf format. By default it uses the `rexp.proto` schema.

    msg <- tempfile();
    serialize_pb(iris, msg);
    obj <- unserialize_pb(msg);
    identical(iris, obj);


Proto schemas
-------------

By default `serialize_pb` uses [`rexp.proto`](https://github.com/jeroenooms/RProtoBufUtils/blob/master/inst/proto/dataframe.proto), which is [also used by the RHIPE project](https://www.datadr.org/doc/serialize.html) to serialize R objects for use with HADOOP. This proto is designed to be most general, and supports all standard S3 objects, like vectors, factors, lists, dataframes and any combination thereof. It also stores attributes and missing values. It does not however support some R specific constructs, like functions, environments, S4 classes, etc.

The [`rexp.proto`](https://github.com/jeroenooms/RProtoBufUtils/blob/master/inst/proto/rexp.proto) message definition is very general, but also pretty verbose. In the case of an application that only needs to serialize a certain class of objects, it might be wise to define a proto definition and mapper specifically for this class of objects. For example, the RProtoBufUtils package includes a [`dataframe.proto`](https://github.com/jeroenooms/RProtoBufUtils/blob/master/inst/proto/dataframe.proto) specifically for dataframes. This proto is a bit less general and might be more simple to use by 3rd parties when communicating a dataset. 

    msg <- tempfile();
    serialize_pb(iris, msg, proto="dataframe");
    obj <- unserialize_pb(msg, proto="dataframe");
    identical(iris, obj); 

Note, again, that one needs to communicate clearly with the consumer of the message which .proto was used to serialize the object. The serialized data can not be interpreted without the proper .proto file.

Unit Test
---------

The RProtoBuf package ships with a dataframe named `testdata` which contains all of the common vector types, including some missing values for each.

 - numeric (double)
 - integer
 - factor
 - character
 - Date
 - POSIXct (timestamp) 
 - complex
 - logical 

This dataset is used to test if it properly serializes and unserializes without loss of information or precision. This dataset is also useful for testing unserialization in another language. 

    #load data
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


Limitations
-----------

- For now the RProtoBuf package does not support any form of validation of the message. For example when the wrong proto file is specified during unserialization, no warning or error is given, but the output is useless. So for now it is up to the application/protocol designer to make sure .proto and message are communicated and validated somehow (e.g. with a checksum). 

- As mentioned above: because protocol buffers is a general purpose format, there is no straightfoward way of serializing object types specific to R (e.g. functions, environments, etc). However, these types of objects usually have little meaning outside of R in the first place. If you really want to serialize them, you can use something like `dput(obj)` or `serialize(obj, NULL)` to turn the object in a character string or raw vector, which are supported by protocol buffers.
