import dataframe_pb2;
cars = dataframe_pb2.Dataframe();

f = open("../messages/cars_dataframe.bin", "rb")
cars.ParseFromString(f.read())
f.close();

print(cars)