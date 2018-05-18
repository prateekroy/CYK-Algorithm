# Build tools
TARGET ?= run
NVCC = nvcc
CXX = g++
GPUOBJS = cyk.o btree.o rule.o cykParser.o table.o bp.o main.o

# make and compile
$(TARGET):$(GPUOBJS)
	$(NVCC) -o $(TARGET) $(GPUOBJS) 

cykParser.o: cykParser.cu
	$(NVCC) --std=c++11 -c cykParser.cu

cyk.o: cyk.cpp
	$(CXX) --std=c++11 -c cyk.cpp

btree.o: btree.cpp
	$(CXX) --std=c++11 -c btree.cpp

rule.o: rule.cpp
	$(CXX) --std=c++11 -c rule.cpp

table.o: table.cpp
	$(CXX) --std=c++11 -c table.cpp

bp.o: bp.cpp
	$(CXX) --std=c++11 -c bp.cpp

main.o: main.cpp
	$(CXX) --std=c++11 -c main.cpp

.PHONY: clean
clean:
	$(RM) $(TARGET) $(GPUOBJS)
