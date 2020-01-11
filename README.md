This is a simulation of an ising mode. First we have a sequential implementation and then two parallels. Both of them use cuda buta the first one has 1 thread/moment while the second one more moments per thread
Sequential V1 and V2 prove correct behavior of the program. While the othre files V1DataCollector, sequentialDataCollector and V2DataCollector are responsible for collecting data.
