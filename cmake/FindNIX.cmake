# - Try to find NIX
# Once done this will define
#  NIX_FOUND - System has NIX
#  NIX_INCLUDE_DIRS - The NIX include directories
#  NIX_LIBRARIES - The libraries needed to use NIX

# Support preference of static libs by adjusting CMAKE_FIND_LIBRARY_SUFFIXES
if(NIX_USE_STATIC_LIBS)
  set(_nix_ORIG_CMAKE_FIND_LIBRARY_SUFFIXES ${CMAKE_FIND_LIBRARY_SUFFIXES})
  if(WIN32)
    set(CMAKE_FIND_LIBRARY_SUFFIXES .lib .a ${CMAKE_FIND_LIBRARY_SUFFIXES})
  else()
    set(CMAKE_FIND_LIBRARY_SUFFIXES .a)
  endif()
endif()

find_path(NIX_INCLUDE_DIR nix.hpp
  HINTS /usr/local/include
  /usr/include
  $ENV{NIX_ROOT}/include
  PATH_SUFFIXES nix)

find_library(NIX_LIBRARY NAMES nix libnix nixio libnixio
  HINTS $ENV{NIX_ROOT}/build/Release
  HINTS $ENV{NIX_BUILD_DIR}
  HINTS ${NIX_INCLUDE_DIR}/../lib
  HINTS ${NIX_INCLUDE_DIR}/../build
  /usr/local/lib
  /usr/lib)

set(NIX_LIBRARIES ${NIX_LIBRARY})
set(NIX_INCLUDE_DIRS ${NIX_INCLUDE_DIR})

include(FindPackageHandleStandardArgs)
# handle the QUIETLY and REQUIRED arguments and set NIX_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args(NIX DEFAULT_MSG
  NIX_LIBRARY NIX_INCLUDE_DIR)

mark_as_advanced(NIX_INCLUDE_DIR NIX_LIBRARIES)

if(NIX_USE_STATIC_LIBS)
  if(NIX_FOUND)
    add_definitions(-DNIX_STATIC=1)
  endif()
  set(CMAKE_FIND_LIBRARY_SUFFIXES ${_nix_ORIG_CMAKE_FIND_LIBRARY_SUFFIXES})
endif()

