cmake_minimum_required(VERSION 3.16)
project(Roofline LANGUAGES CXX)

# gnu++17 (extensions activées) : GCC autorise alors la fusion a*b+c -> FMA par défaut.
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS ON)

# Les options d'optimisation viennent de la ligne de commande, pour pouvoir les comparer :
#   cmake -S . -B build-O2 -DCMAKE_BUILD_TYPE=None -DCMAKE_CXX_FLAGS="-O2"
#   cmake -S . -B build-O3 -DCMAKE_BUILD_TYPE=None -DCMAKE_CXX_FLAGS="-O3 -march=native"
# Sans rien préciser, on construit en Release (-O3).
if (NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CXX_FLAGS)
    set(CMAKE_BUILD_TYPE Release)
endif()

add_compile_options(-Wall -Wextra)

add_executable(kernels src/kernels.cpp)
