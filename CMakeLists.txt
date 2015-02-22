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

# The computing environment

if($ENV{CI})
  find_package(Octave REQUIRED)
else()
  find_package(MATLAB REQUIRED)
endif()

if(OCTAVE_FOUND)
  add_definitions(-DMATLAB_MEX_FILE)
  set(CE_PACKAGE "GNU Octave")
  set(CE_VERSION "${OCTAVE_VERSION_STRING}")
  set(CE_INCDIR ${OCTAVE_INCLUDE_DIRS})
  set(CE_LIBRARIES ${OCTAVE_LIBRARIES})
  set(CE_EXTENSION oct)
endif()

IF(MATLAB_FOUND)
  MESSAGE(STATUS "Matlab found at ${MATLAB_INCLUDE_DIR}")
  add_definitions(-DMATLAB_MEX_FILE)
  set(CE_PACKAGE "Matlab")
  set(CE_VERSION "${MATLAB_VERSION}")
  set(CE_INCDIR ${MATLAB_INCLUDE_DIR})
  set(CE_LIBRARIES ${MATLAB_LIBRARIES})
  set(CE_EXTENSION ${MATLAB_MEXEXT})
ENDIF(MATLAB_FOUND)

if(NOT CE_PACKAGE)
  MESSAGE(FATAL_ERROR "
  No computing environment found!
  Install GNU Octave (or MathWorks MATLAB).")
endif()

find_package(NIX REQUIRED)

include_directories(${CE_INCDIR} ${NIX_INCLUDE_DIR} "src" "src/utils")

file(GLOB_RECURSE SOURCE_FILES src/*.cc)
file(GLOB_RECURSE INCLUDE_FILES src/*.h)

if(NOT WIN32)
  set(LIBTYPE SHARED)
else()
  set(LIBTYPE MODULE)
endif()

add_library(nix_mx ${LIBTYPE} nix_mx.cc ${SOURCE_FILES} ${INCLUDE_FILES})

target_link_libraries(nix_mx ${CE_LIBRARIES} ${NIX_LIBRARIES})
set_target_properties(nix_mx PROPERTIES
		              VERSION ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}
		              SOVERSION ${VERSION_ABI})
set_target_properties(nix_mx PROPERTIES PREFIX "")
set_target_properties(nix_mx PROPERTIES SUFFIX .${CE_EXTENSION})

if(WIN32)
  SET_TARGET_PROPERTIES(nix_mx PROPERTIES LINK_FLAGS "/export:mexFunction")
endif()

if(DEBUG_GLUE)
   add_definitions(-DDEBUG_GLUE=1)
endif()

MESSAGE(STATUS "=====================")
MESSAGE(STATUS "Computing environment")
MESSAGE(STATUS "  Package: ${CE_PACKAGE}")
MESSAGE(STATUS "  Version: ${CE_VERSION}")
MESSAGE(STATUS "  Module : ${CE_EXTENSION}")
MESSAGE(STATUS "=====================")
