cmake_minimum_required(VERSION 3.16)
project(pipery-cpp-failing-tests LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(pipery-cpp-failing-tests src/main.cpp)

enable_testing()
add_test(NAME failing-smoke COMMAND pipery-cpp-failing-tests)
