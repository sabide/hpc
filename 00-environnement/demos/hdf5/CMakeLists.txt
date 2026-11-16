cmake_minimum_required(VERSION 3.12)
project(Export3DFieldHDF5 Fortran)


set(HDF5_ROOT "/home/sabide/etu_local/hdf5/") 
find_package(HDF5 REQUIRED COMPONENTS Fortran HL)

# Ensure the required variables are set
if(NOT HDF5_FOUND)
    message(FATAL_ERROR "HDF5 not found. Please provide HDF5_ROOT.")
endif()

include_directories(${HDF5_INCLUDE_DIRS})
add_executable(export_3d_hdf5 export_hdf5.f90)
target_link_libraries(export_3d_hdf5 PRIVATE ${HDF5_LIBRARIES})




