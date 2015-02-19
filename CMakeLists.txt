cmake_minimum_required(VERSION 2.8.4)
project(nix_mx CXX)

set(VERSION_MAJOR 0)
set(VERSION_MINOR 1)
set(VERSION_PATCH 0)

set(VERSION_ABI   1)

### include local modules
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake")

if(NOT WIN32)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -pedantic -Wunreachable-code")

  set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS} -O0 -ggdb3")
  set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS} -O2")
endif()

#packages

find_package(Boost 1.49.0 REQUIRED)
include_directories(${Boost_INCLUDE_DIR})

find_package(MATLAB REQUIRED)
IF(MATLAB_FOUND)
  MESSAGE(STATUS "Matlab found at ${MATLAB_INCLUDE_DIR}")
ELSE(MATLAB_FOUND)
  MESSAGE(FATAL_ERROR "Matlab not found")
ENDIF(MATLAB_FOUND)

find_package(NIX REQUIRED)

include_directories(${MATLAB_INCLUDE_DIR} ${NIX_INCLUDE_DIR} "src" "src/utils")

file(GLOB_RECURSE SOURCE_FILES "." "*.cc" "*.cpp")
file(GLOB_RECURSE INCLUDE_FILES "." "*.h" "*.hpp")

if(NOT WIN32)
  set(LIBTYPE SHARED)
else()
  set(LIBTYPE MODULE)
endif()

add_library(nix_mx ${LIBTYPE} ${SOURCE_FILES} ${INCLUDE_FILES})

target_link_libraries(nix_mx ${MATLAB_LIBRARIES} ${NIX_LIBRARIES})
set_target_properties(nix_mx PROPERTIES
		              VERSION ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}
		              SOVERSION ${VERSION_ABI})
set_target_properties(nix_mx PROPERTIES PREFIX "")
set_target_properties(nix_mx PROPERTIES SUFFIX .${MATLAB_MEXEXT})

if(WIN32)
SET_TARGET_PROPERTIES(nix_mx PROPERTIES LINK_FLAGS "/export:mexFunction")
endif()

add_definitions(-DMATLAB_MEX_FILE)

MESSAGE(STATUS "===============================")
MESSAGE(STATUS "Matlab version: ${MATLAB_VERSION}")
MESSAGE(STATUS "Matlab     ext: ${MATLAB_MEXEXT}")
MESSAGE(STATUS "===============================")
