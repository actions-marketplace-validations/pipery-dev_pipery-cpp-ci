cmake_minimum_required(VERSION 3.16)
project(pipery-cpp-failing-build LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(pipery-cpp-failing-build src/main.cpp)
