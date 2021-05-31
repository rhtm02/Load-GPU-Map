cmake_minimum_required(VERSION 3.19)
project(Load-GPU-Map CUDA)

set(CMAKE_CUDA_STANDARD 14)
INCLUDE_DIRECTORIES(include)
add_executable(Load-GPU-Map src/loadGpu.cu include/loadGpu.cuh include/dataType.cuh)

set_target_properties(
        Load-GPU-Map
        PROPERTIES
        CUDA_SEPARABLE_COMPILATION ON)
