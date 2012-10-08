pb <- function(name){
	descriptor <- deparse(substitute(name));
	if(!exists(descriptor, "RProtoBuf:DescriptorPool")){
		stop("No ProtoBuf Descriptor for: ", descriptor);
	};
	get(descriptor, "RProtoBuf:DescriptorPool");
}