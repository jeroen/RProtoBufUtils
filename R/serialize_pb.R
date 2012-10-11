#' Serializes R object to Protocol Buffer Message.
#' 
#' This function serializes an arbitrary R object to a general purpose protobuf message. 
#' Note that for a 3rd party client to read the object, it needs to have the rexp.proto file, 
#' which is included in the package installation "proto" directory.
#' 
#' This function serializes R objects to a general purpose protobuf message 
#' that was designed exactly for this purpose. The .proto schema is borrowed from
#' the RHIPE project, which uses protocol buffers to serialize R objects for use with
#' HADOOP. One can find the proto file at this location: 
#' 
#' system.file(package="RProtoBufUtils", "proto/rexp.proto") 
#' 
#' In order for a third party to unserialize the message, they will need both the serialized
#' data and the rexp.proto file.
#' 
#' Note that for now only regular S3 data objects will be serialized. Special object like 
#' functions, expressions, formulas, environments, S4 classes, etc are skipped with a 
#' warning. However, missing values, attributes and numeric precision will be preserved. 
#'  
#' @param object R object to serialize
#' @param connection an open connection or (for 'serialize') 'NULL' or (for 'unserialize') a raw vector (see 'Details').
#' @param ... arguments passed on to serialize()
#' @return For 'serialize', 'NULL' unless 'connection = NULL', when the result is returned in a raw vector.
#' @aliases unserialize_pb
#' @export unserialize_pb
#' @export
#' @examples msg <- tempfile();
#' serialize_pb(iris, msg);
#' obj <- unserialize_pb(msg);
#' identical(iris, obj);
#' 
serialize_pb <- function(object, connection, proto=c("rexp", "dataframe", "stocks"), ...){

	#limited set of proto's
	proto <- match.arg(proto);

	#convert object to protobuf message
	msg <- switch(proto,
		"rexp" = rexp_obj(object),
		"dataframe" = dataframe_obj(object),
		"stocks" = stocks_obj(object),
		stop("Invalid proto")
	);
	
	#serialize the message
	serialize(msg, connection=connection, ...);
}

unserialize_pb <- function(connection, proto=c("rexp", "dataframe")){
	
	#limited set of proto's
	proto <- match.arg(proto);
	
	#convert object to protobuf message
	obj <- switch(proto,
		"rexp" = unrexp(RProtoBuf::read(pb(rexp.REXP), connection)),
		"dataframe" = from.pb(RProtoBuf::read(pb(dataframe.Dataframe), connection)),
		stop("Invalid proto")
	);	
	return(obj);

}