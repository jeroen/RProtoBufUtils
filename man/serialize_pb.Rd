\name{serialize_pb}
\alias{serialize_pb}
\alias{unserialize_pb}
\title{Serializes R object to Protocol Buffer Message.}
\usage{
  serialize_pb(object, connection,
    proto = c("rexp", "dataframe", "stocks"), ...)
}
\arguments{
  \item{object}{R object to serialize}

  \item{connection}{an open connection or (for 'serialize')
  'NULL' or (for 'unserialize') a raw vector (see
  'Details').}

  \item{...}{arguments passed on to serialize()}
}
\value{
  For 'serialize', 'NULL' unless 'connection = NULL', when
  the result is returned in a raw vector.
}
\description{
  This function serializes an arbitrary R object to a
  general purpose protobuf message. Note that for a 3rd
  party client to read the object, it needs to have the
  rexp.proto file, which is included in the package
  installation "proto" directory.
}
\details{
  This function serializes R objects to a general purpose
  protobuf message that was designed exactly for this
  purpose. The .proto schema is borrowed from the RHIPE
  project, which uses protocol buffers to serialize R
  objects for use with HADOOP. One can find the proto file
  at this location:

  system.file(package="RProtoBufUtils", "proto/rexp.proto")

  In order for a third party to unserialize the message,
  they will need both the serialized data and the
  rexp.proto file.

  Note that for now only regular S3 data objects will be
  serialized. Special object like functions, expressions,
  formulas, environments, S4 classes, etc are skipped with
  a warning. However, missing values, attributes and
  numeric precision will be preserved.
}
\examples{
msg <- tempfile();
serialize_pb(iris, msg);
obj <- unserialize_pb(msg);
identical(iris, obj);
}

