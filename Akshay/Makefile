
TARGET ?= run
SRC_DIRS ?= ./
INC_DIRS = 

CC := icc
SRCS := $(shell find $(SRC_DIRS) -name '*.cpp' -or -name '*.c' -or -name '*.s')
OBJS := $(addsuffix .o,$(basename $(SRCS)))
DEPS := $(OBJS:.o=.d)
CXXFLAGS=-g -std=c++11 -Wall -pedantic

INC_DIRS ?= $(shell find $(SRC_DIRS) -type d)
INC_FLAGS := $(addprefix -I,$(INC_DIRS))

CPPFLAGS ?= $(INC_FLAGS) -MMD -MP
CXX = icc

LOADLIBES := 

$(TARGET): $(OBJS)
	$(CC) $(LDFLAGS) $(OBJS) $(INC_FLAGS) -o $@ $(LOADLIBES) $(LDLIBS)

.PHONY: clean
clean:
	$(RM) $(TARGET) $(OBJS) $(DEPS)

-include $(DEPS)
