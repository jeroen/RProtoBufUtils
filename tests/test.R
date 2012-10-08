test <- data.frame(num=rnorm(10));
test$int <- as.integer(-4:5);
test$factor <- sample(iris$Species,10);
test$char <- paste("foo", 1:10)
test$date <- as.Date(Sys.time()) - 1:10;
test$time <- Sys.time() - 1:10;
test$complex <- complex(re=rnorm(10), im=rnorm(10))
test$bool <- as.logical(rbinom(10, 1, .5))
for(i in 1:50) test[sample(nrow(test),1), sample(names(test),1)] <- NA
test[10,] <- NA;

#test without serializing
identical(test, from.pb(as.pb(test)))

#test with serializing
msg <- tempfile()
as.pb(test)$serialize(msg)
obj <- from.pb(read(pb(Dataframe), msg));
identical(test, obj)
