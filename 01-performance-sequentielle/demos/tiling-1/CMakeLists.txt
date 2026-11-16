cmake_minimum_required(VERSION 3.16)

project(MatmulRooflineTiled LANGUAGES CXX)

# Démos du module 01-performance-sequentielle : produit matrice-matrice, roofline, tiling.
# Voir README.md. Le TP associé (puissance crête, boucles, options, roofline) est dans
# ../../tp/01-roofline.

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS ON)   # gnu++17 : GCC peut alors fusionner a*b+c en FMA

if (NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CXX_FLAGS)
    set(CMAKE_BUILD_TYPE Release)
endif()

include(CheckCXXCompilerFlag)

# Options de compilation (à adapter selon le compilateur / la machine)
if (CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    add_compile_options(-Wall -Wextra -Wpedantic)
    # Exploiter les instructions de la machine de compilation (AVX2, AVX-512, FMA...).
    # -march=native n'existe pas partout (certains GCC sur ARM) : repli sur -mcpu=native.
    check_cxx_compiler_flag(-march=native HAS_MARCH_NATIVE)
    if (HAS_MARCH_NATIVE)
        add_compile_options(-march=native)
    else()
        check_cxx_compiler_flag(-mcpu=native HAS_MCPU_NATIVE)
        if (HAS_MCPU_NATIVE)
            add_compile_options(-mcpu=native)
        endif()
    endif()
elseif (CMAKE_CXX_COMPILER_ID STREQUAL "Intel" OR CMAKE_CXX_COMPILER_ID STREQUAL "IntelLLVM")
    add_compile_options(-O3 -xHost)
elseif (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    add_compile_options(/O2 /W4)
endif()

# Exécutables
add_executable(matmul_roofline matmul_roofline.cpp)
add_executable(matmul_tiled    matmul_tiled.cpp)
