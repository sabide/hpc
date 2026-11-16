cmake_minimum_required(VERSION 3.16)
project(Ondes LANGUAGES C Fortran)

# Les options d'optimisation viennent de la ligne de commande, pour pouvoir les comparer :
#   cmake -S . -B build-O0 -DCMAKE_BUILD_TYPE=None -DCMAKE_C_FLAGS="-O0" -DCMAKE_Fortran_FLAGS="-O0"
#   cmake -S . -B build-O3 -DCMAKE_BUILD_TYPE=None -DCMAKE_C_FLAGS="-O3" -DCMAKE_Fortran_FLAGS="-O3"
# Sans rien préciser, on construit en Release (-O3).
if (NOT CMAKE_BUILD_TYPE AND NOT CMAKE_C_FLAGS AND NOT CMAKE_Fortran_FLAGS)
    set(CMAKE_BUILD_TYPE Release)
endif()

add_executable(waves_c src/waves_1d.c)
target_link_libraries(waves_c PRIVATE m)
set_target_properties(waves_c PROPERTIES C_STANDARD 99)

add_executable(waves_f src/waves_1d.f90)
add_executable(tube_2d src/tube_2d.F90)
add_executable(loop_order src/loop_order.c)
set_target_properties(loop_order PROPERTIES C_STANDARD 99)
