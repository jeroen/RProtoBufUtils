dataframe_obj <- function(x, ...){
	if(!is(x, "data.frame")){
		stop("Object is not a dataframe.")
	} else {
		return(as.pb(x, ...))
	}
}

as.pb <- function (x, ...){ 
	UseMethod("as.pb");	
}

as.pb.logical <- function(x, name, index, ...){
	xvalue <- as.integer(x);
	xvalue[is.na(xvalue)] <- 2;
	#create proto buffer
	buf <- new(pb(dataframe.Logical),
		value=xvalue
	);
	if(!missing(name)) buf$name <- name;
	if(!missing(index)) buf$index <- index;
	return(buf);
}

from.pb_Logical <- function(x){
	stopifnot(x@type == "dataframe.Logical");
	xvalue <- x$value;
	xvalue[xvalue==2] <- NA;
	xvalue <- as.logical(xvalue);
	return(xvalue);
}

as.pb.complex <- function(x, name, index, ...){
	xreal <- Re(x);
	ximaginary <- Im(x);

	buf <- new(pb(dataframe.Complex),
		real=xreal,
		imaginary=ximaginary
	);
	if(!missing(name)) buf$name <- name;
	if(!missing(index)) buf$index <- index;
	return(buf);
}

from.pb_Complex <- function(x){
	stopifnot(x@type == "dataframe.Complex");
	xreal <- x$real;
	ximaginary <- x$imaginary;
	
	
	if(x$has("NA_VALUE")){
		NA_VALUE <- x$NA_VALUE;
		xreal[xreal == NA_VALUE] <- NA;
		ximaginary[ximaginary == NA_VALUE] <- NA;
	}
	return(complex(re=xreal, im=ximaginary))
}


as.pb.numeric <- function(x, name, index, ...){
	#create proto buffer
	buf <- new(pb(dataframe.Numeric),
		value=x
	);
	if(!missing(name)) buf$name <- name;
	if(!missing(index)) buf$index <- index;	
	return(buf);	
}

from.pb_Numeric <- function(x){
	stopifnot(x@type == "dataframe.Numeric");
	xvalue <- x$value;
	if(x$has("NA_VALUE")){
		NA_VALUE <- x$NA_VALUE;
		xvalue[xvalue == NA_VALUE] <- NA;
	}
	return(xvalue)
}

as.pb.integer <- function(x, name, index, ...){
	#create proto buffer
	buf <- new(pb(dataframe.Integer),
			value=x
	);
	if(!missing(name)) buf$name <- name;
	if(!missing(index)) buf$index <- index;	
	return(buf);	
}

from.pb_Integer <- function(x){
	stopifnot(x@type == "dataframe.Integer");
	xvalue <- x$value;
	if(x$has("NA_VALUE")){
		NA_VALUE <- x$NA_VALUE;
		xvalue[xvalue == NA_VALUE] <- NA;
	}
	return(xvalue)
}


as.pb.factor <- function(x, name, index, ...){
	NA_VALUE <- 0;
	xlabels <- levels(x); #R terminology is terribly confusing here
	xlevels <- 1:length(xlabels)
	xvalue <- unclass(x);
	xvalue[is.na(xvalue)] <- NA_VALUE;
	xordered <- is.ordered(x);
	
	#create proto buffer
	buf <- new(pb(dataframe.Factor),
		levels = xlevels,
		labels = xlabels,
		value = xvalue,
		ordered = xordered,
		NA_VALUE = NA_VALUE
	);
	if(!missing(name)) buf$name <- name;
	if(!missing(index)) buf$index <- index;	
	return(buf);	
}


from.pb_Factor <- function(x){
	stopifnot(x@type == "dataframe.Factor");
	xvalue <- x$value;
	xlevels <- x$levels;
	xlabels <- x$labels;
	xordered <- x$ordered;
	
	if(x$has("NA_VALUE")){
		NA_VALUE <- x$NA_VALUE;
		xvalue[xvalue == NA_VALUE] <- NA;
	}
	
	factor(xvalue, levels=xlevels, labels=xlabels, ordered=xordered)
}

as.pb.character <- function(x, name, index, ...){
	NA_VALUE <- "NA";
	xvalue <- as.character(x);
	xvalue[is.na(xvalue)] <- NA_VALUE;
	#create proto buffer
	buf <- new(pb(dataframe.Character),
		value=xvalue,
		NA_VALUE = NA_VALUE
	);
	if(!missing(name)) buf$name <- name;
	if(!missing(index)) buf$index <- index;	
	return(buf);	
}

from.pb_Character <- function(x){
	stopifnot(x@type == "dataframe.Character");
	
	xvalue <- x$value;
	if(x$has("NA_VALUE")){
		NA_VALUE <- x$NA_VALUE;
		xvalue[xvalue == NA_VALUE] <- NA;
	}
	return(xvalue);	
}

as.pb.POSIXt <- function(x, name, index, ...){
	NA_VALUE = 0;
	x <- as.POSIXct(x);
	xvalue <- unclass(x);
	xvalue[is.na(xvalue)] <- NA_VALUE;
	buf <- new(pb(dataframe.POSIXt),
		value=xvalue,
		NA_VALUE = NA_VALUE
	)
	if(!missing(name)) buf$name <- name;
	if(!missing(index)) buf$index <- index;	
	if(!is.null(tzone <- attr(x, "tzone"))){
		buf$tzone <- tzone;
	}

	return(buf);	
}

from.pb_POSIXt <- function(x){
	stopifnot(x@type == "dataframe.POSIXt");
	
	xvalue <- x$value
	if(x$has("NA_VALUE")){
		NA_VALUE <- x$NA_VALUE;
		xvalue[xvalue == NA_VALUE] <- NA;
	}
	
	if(x$has("tzone")){
		xvalue <- structure(xvalue, class=c("POSIXct", "POSIXt"), tzone=x$tzone)
	} else {
		xvalue <- structure(xvalue, class=c("POSIXct", "POSIXt"))
	}
	return(xvalue);
}


as.pb.Date <- function(x, name, index, ...){
	NA_VALUE <- "0000-00-00";
	xvalue <- as.character(x);
	xvalue[is.na(xvalue)] <- NA_VALUE;	
	buf <- new(pb(dataframe.Date),
		value=xvalue,
		NA_VALUE = NA_VALUE
	)	
	if(!missing(name)) buf$name <- name;
	if(!missing(index)) buf$index <- index;	
	return(buf);	
}

from.pb_Date <- function(x){
	stopifnot(x@type == "dataframe.Date");
	xvalue <- x$value;
	if(x$has("NA_VALUE")){
		NA_VALUE <- x$NA_VALUE;
		xvalue[xvalue == NA_VALUE] <- NA;
	}	
	return(as.Date(xvalue));
}	

unp <- function(x){
	#remove package name (everything before first dot)
	unlist(lapply(lapply(strsplit(x, ".", fixed=T), tail, -1), paste, collapse="."))
}

as.pb.data.frame <- function(x, ...){
	mycols <- list(
		Numeric = list(),
		Integer = list(),
		Factor = list(),
		POSIXt = list(),
		Character = list(),
		Date = list(),
		Logical = list(),
		Complex = list()
	);	
	for(i in 1:length(x)){
		buf <- as.pb(x[[i]], index=i, name=names(x[i]));
		mycols[[unp(buf@type)]] <- append(mycols[[unp(buf@type)]], buf)
	}
	do.call("new", c(list(Class=pb(dataframe.Dataframe)), mycols))
}

from.pb <- function(x, ...){
	#validate
	stopifnot(is(x, "Message"));
	
	#manual dispatch depending on msg type
	switch(x@type,
		"dataframe.Dataframe" = from.pb_Dataframe(x, ...),
		"dataframe.Numeric" = from.pb_Numeric(x, ...),
		"dataframe.Integer" = from.pb_Integer(x, ...),
		"dataframe.Factor" = from.pb_Factor(x, ...),
		"dataframe.Date" = from.pb_Date(x, ...),
		"dataframe.Character" = from.pb_Character(x, ...),
		"dataframe.Logical" = from.pb_Logical(x, ...),
		"dataframe.POSIXt" = from.pb_POSIXt(x, ...),
		"dataframe.Complex" = from.pb_Complex(x, ...),
		stop("No from.pb for type: ", x@type)
	)	
}

from.pb_Dataframe <- function(x, ...){
	stopifnot(x@type == "dataframe.Dataframe");
	
	#we use as.list for now. Not sure how to directly get it from the buffer
	buffer <- as.list(x);
	output <- list();
	
	#use type specific readers
	mycolumns <- unlist(as.list(buffer), recursive=FALSE);
	colnames <- unlist(lapply(mycolumns, "[[", "name"))
	indexlist <-  order(unlist(lapply(mycolumns, "[[", "index")))
	stopifnot(length(mycolumns) == length(indexlist));
	
	#convert all colums to a list
	output <- list()
	for(i in 1:length(mycolumns)){
		output[[i]] <- from.pb(mycolumns[[i]])
	}
	
	#resort by index
	output <- output[indexlist];
	
	#create df
	output <- as.data.frame(output, stringsAsFactors=FALSE);
	names(output) <- colnames[indexlist];
	return(output);
}


