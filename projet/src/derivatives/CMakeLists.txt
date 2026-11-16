cmake_minimum_required(VERSION 3.15)
project(eval_derivatives Fortran)

# Spécifier le compilateur MPI Intel
set(CMAKE_Fortran_COMPILER mpiifx)

# Définition des chemins vers decomp2d
set(DECOMP2D_DIR /home/sabide/local/projet/decomp2d)
set(DECOMP2D_INCLUDE_DIR ${DECOMP2D_DIR}/include)
set(DECOMP2D_LIB_DIR ${DECOMP2D_DIR}/lib64)

# Ajouter les options du compilateur si nécessaire
add_compile_options(-O3 -Wall)

# Ajouter l'exécutable
add_executable(eval_derivatives eval_derivatives.f90)

# Inclure les fichiers d'en-tête de decomp2d
target_include_directories(eval_derivatives PRIVATE ${DECOMP2D_INCLUDE_DIR})

# Lier la bibliothèque decomp2d
target_link_directories(eval_derivatives PRIVATE ${DECOMP2D_LIB_DIR})
target_link_libraries(eval_derivatives PRIVATE decomp2d)
