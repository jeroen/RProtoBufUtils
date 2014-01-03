

can_serialize_pb <- rexp_valid <- function(obj) {
  valid.types <- c("character",
                   "raw",
                   "double",
                   "complex",
                   "integer",
                   "list",
                   "logical",
                   "NULL")
  sm <- storage.mode(obj)
  if (sm %in% valid.types) {
    if (sm == "list") {
      if (any(! unlist(lapply(obj, rexp_valid)))) {
        return(FALSE)
      }
    }
  } else {
    return(FALSE)
  }
  attrib <- attributes(obj)
  if (is.null(attrib)) {
    return(TRUE)
  }
  if (rexp_valid(names(attrib))) {
    if (rexp_valid(unname(attrib))) {
      return(TRUE)
    }
  }
  return(FALSE)
}

rexp_obj <- function(obj){
	sm <- storage.mode(obj);
	msg <- switch(sm,
		"character" = rexp_string(obj),
		"raw" = rexp_raw(obj),
		"double" = rexp_double(obj),
		"complex" = rexp_complex(obj),
		"integer" = rexp_integer(obj),
		"list" = rexp_list(obj),
		"logical" = rexp_logical(obj),
		"NULL" = rexp_null(),
		{
			warning("Unsupported REXP:", sm); 
			rexp_null();
		}
	);	  
	attrib <- attributes(obj)
	msg$attrName <- names(attrib)
	msg$attrValue <- lapply(attrib, rexp_obj);
	
	#return out
	return(msg);
}

rexp_string <- function(obj){
	xvalue <- lapply(as.list(obj), function(x){
		new(pb(rexp.STRING), strval=x, isNA=is.na(x))			
	});
	new(pb(rexp.REXP), rclass = 0, stringValue=xvalue);
}

rexp_raw <- function(obj){
	new(pb(rexp.REXP), rclass= 1, rawValue = obj);
}

rexp_double <- function(obj){
	new(pb(rexp.REXP), rclass=2, realValue = obj);
}

rexp_complex <- function(obj){
	xvalue <- lapply(as.list(obj), function(x){
		new(pb(rexp.CMPLX), real=Re(x), imag=Im(x))			
	});	
	new(pb(rexp.REXP), rclass=3, complexValue = xvalue);
}

rexp_integer <- function(obj){
	new(pb(rexp.REXP), rclass=4, intValue = obj);
}

rexp_list <- function(obj){
	xobj <- lapply(obj, rexp_obj);
	new(pb(rexp.REXP), rclass=5, rexpValue = xobj);
}

rexp_logical <- function(obj){
	xobj <- as.integer(obj);
	xobj[is.na(obj)] <- 2;
	new(pb(rexp.REXP), rclass=6, booleanValue = xobj);
}

rexp_null <- function(){
	new(pb(rexp.REXP), rclass=7)
}

unrexp <- function(msg){
	stopifnot(is(msg, "Message"));
	stopifnot(msg@type == "rexp.REXP");
	
	myrexp <- as.list(msg);
	xobj <- switch(as.character(myrexp$rclass),
		"0" = unrexp_string(myrexp),
		"1" = unrexp_raw(myrexp),
		"2" = unrexp_double(myrexp),
		"3" = unrexp_complex(myrexp),
		"4" = unrexp_integer(myrexp),
		"5" = unrexp_list(myrexp),
		"6" = unrexp_logical(myrexp),
		"7" = unrexp_null()
	);
	if(length(myrexp$attrValue) > 0){
		attrib <- lapply(myrexp$attrValue, unrexp);
		names(attrib) <- myrexp$attrName;
		attributes(xobj) <- attrib;
	}
	return(xobj);
}

unrexp_string <- function(myrexp){
	mystring <- unlist(lapply(myrexp$stringValue, "[[", "strval"));
	isNA <- unlist(lapply(myrexp$stringValue, "[[", "isNA"));
	mystring[isNA] <- NA;
	return(mystring);
}

unrexp_raw <- function(myrexp){
	return(myrexp$rawValue);
}

unrexp_double <- function(myrexp){
	return(myrexp$realValue);
}

unrexp_complex <- function(myrexp){
	 xvalue <- lapply(myrexp$complexValue, function(x){
		complex(real=x$real, imaginary=x$imag);		
	});
	return(unlist(xvalue));
}

unrexp_integer <- function(myrexp){
	return(myrexp$intValue);
}

unrexp_list <- function(myrexp){
	lapply(myrexp$rexpValue, unrexp);
}

unrexp_logical <- function(myrexp){
	xvalue <- myrexp$booleanValue;
	xvalue[xvalue==2] <- NA;
	xvalue <- as.logical(xvalue);
	return(xvalue)
}

unrexp_null <- function(){
	return(NULL)
}
