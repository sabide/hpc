cmake_minimum_required(VERSION 3.16)

project(MatmulRooflineTiled LANGUAGES CXX)

# Version du standard C++
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Options de compilation (tu peux adapter selon le compilateur / la machine)
if (CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    add_compile_options(-O3 -march=native -Wall -Wextra -Wpedantic)
elseif (CMAKE_CXX_COMPILER_ID STREQUAL "Intel")
	add_compile_options(-O3 -xHost )
elseif (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    add_compile_options(/O2 /W4)
endif()

# Exécutables
add_executable(matmul_roofline matmul_roofline.cpp)
add_executable(matmul_tiled    matmul_tiled.cpp)

