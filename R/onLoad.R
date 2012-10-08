#' @import RProtoBuf
.onLoad <- function(libname, pkgname){
	readProtoFiles(package=pkgname, lib.loc=libname);
}