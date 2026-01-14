cmake_minimum_required(VERSION 3.20.0)
project(Demo)


set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
  find_package(MLIR REQUIRED CONFIG)

  message(STATUS "Using MLIRConfig.cmake in: ${MLIR_DIR}")
  message(STATUS "Using LLVMConfig.cmake in: ${LLVM_DIR}")

  set(LLVM_RUNTIME_OUTPUT_INTDIR ${CMAKE_BINARY_DIR}/bin)
  set(LLVM_LIBRARY_OUTPUT_INTDIR ${CMAKE_BINARY_DIR}/lib)
  set(MLIR_BINARY_DIR ${CMAKE_BINARY_DIR})

  list(APPEND CMAKE_MODULE_PATH "${MLIR_CMAKE_DIR}")
  list(APPEND CMAKE_MODULE_PATH "${LLVM_CMAKE_DIR}")

  include(TableGen)
  include(AddLLVM)
  include(AddMLIR)
  include(HandleLLVMOptions)
else()
  # Build via external projects mechanism
  set(MLIR_MAIN_SRC_DIR ${LLVM_MAIN_SRC_DIR}/../mlir)
  set(MLIR_INCLUDE_DIR ${MLIR_MAIN_SRC_DIR}/include)
  set(MLIR_GENERATED_INCLUDE_DIR ${LLVM_BINARY_DIR}/tools/mlir/include)
  set(MLIR_INCLUDE_DIRS "${MLIR_INCLUDE_DIR};${MLIR_GENERATED_INCLUDE_DIR}")
endif()


include_directories(${CMAKE_BINARY_DIR})
include_directories(${CMAKE_SOURCE_DIR})

include_directories(${LLVM_INCLUDE_DIRS})
include_directories(${MLIR_INCLUDE_DIRS})
link_directories(${LLVM_BUILD_LIBRARY_DIR})
add_definitions(${LLVM_DEFINITIONS})

get_property(dialect_libs GLOBAL PROPERTY MLIR_DIALECT_LIBS)
get_property(extension_libs GLOBAL PROPERTY MLIR_EXTENSION_LIBS)

# add_compile_options(-fsanitize=address)
# add_link_options(-fsanitize=address)

# add_compile_options(-fsanitize=undefined)
# add_link_options(-fsanitize=undefined)

add_subdirectory(dialect)

set(NO_RTTI "-fno-rtti")
add_definitions(${NO_RTTI})


add_mlir_conversion_library(MPIToLLVMConversion
  conversions/MPIToLLVM.cc

  ADDITIONAL_HEADER_DIRS
    ${MLIR_MAIN_INCLUDE_DIR}/mlir/Conversion/MPIToLLVM


  LINK_LIBS PUBLIC
    MLIRDLTIDialect
    MLIRLLVMCommonConversion
    MLIRLLVMDialect
    MLIRMPIDialect
)

target_include_directories(MPIToLLVMConversion
  PRIVATE
    ${LLVM_BUILD_MAIN_INCLUDE_DIR}
    ${MLIR_MAIN_INCLUDE_DIR}                         # MLIR source includes
    ${LLVM_BUILD_DIR}/tools/mlir/include             # generated MLIR headers
)



# Add executable and link it with the parser library
add_llvm_executable(dhir-opt main.cc libs/avialDialect.cc libs/avialOps.cc libs/utils.cc DEPENDS MLIRAvialDialectIncGen)
target_link_libraries(dhir-opt 

PRIVATE
        ${dialect_libs}
        #MLIRMPIToLLVM
        MPIToLLVMConversion
        MLIRSCFToOpenMP
        MLIRAnalysis
        MLIRIR
        MLIRParser
        MLIRSupport
        MLIRMPIDialect
        MLIROpenMPToLLVM
        MLIRSCFToGPU
        MLIRGPUToLLVMIRTranslation
        MLIRBuiltinToLLVMIRTranslation 
        MLIRLLVMToLLVMIRTranslation
    )