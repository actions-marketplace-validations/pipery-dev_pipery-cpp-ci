CXX ?= g++
CXXFLAGS ?= -std=c++17 -Wall -Wextra -Werror

.PHONY: all test clean

all: build/pipery-make

build/pipery-make: src/main.cpp
	mkdir -p build
	$(CXX) $(CXXFLAGS) -o $@ $<

test: all
	./build/pipery-make

clean:
	rm -rf build dist
