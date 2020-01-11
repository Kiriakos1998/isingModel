






sequential:
	gcc sequential.c -o sequential.o
V1: 
	nvcc V1.cu -o V1.o
V2:
	nvcc V2.cu -o V2.o
sequentialC:
	gcc seuqentialDataCollector.c -o seq.o
V1C: 
	nvcc V1DataCollector.cu -o V1C.o
V2C:
	nvcc V2DataCollector.cu -o V2C.o
