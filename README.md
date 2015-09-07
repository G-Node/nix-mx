About NIX-MX
-------------

The *NIX-MX* project is an extension to [NIX] (https://github.com/G-Node/nix) and provides Matlab bindings for *NIX*.


Development Status
------------------

The *NIX-MX* project has been developed and tested solely under Windows 32 and Windows 64 and is in an alpha stage of development. Specifically all of the features of NIX have been implemented and unit tests for all of the methods exist and pass, but extensive testing and some refactoring of existing code has to be done as of yet.


Getting Started (Windows 32/64)
-------------------------------

**Quick start packages, Pre-Release 1.01**

The [quick start packages] (https://github.com/G-Node/nix-mx/releases/tag/v1.01-Pre-Release) are compiled under Windows 32/64 and contain all dlls, binary and Matlab files required to use NIX-MX with the respective Windows OS.
To use the packages, unzip them into a folder of your choice and run the `startup.m` script from the root folder. Do not change the file/folder structure.

The Windows 32 package contains:
- HDF5 dlls (Release 1.8.14)
- NIX dll (build commit f357124d0ec5028d4574e4f5816cca7b8d7c9e8b, compiled using BOOST 1.57.0 and CPPUNIT 1.13.2)
- NIX-MX (Pre-Release 1.01, 22.06.2015)

The Windows 64 package contains:
- HDF5 dlls (Release 1.8.14)
- NIX dll (build commit f357124d0ec5028d4574e4f5816cca7b8d7c9e8b, compiled using BOOST 1.57.0 and CPPUNIT 1.13.2)
- NIX-MX (Pre-Release 1.01, 22.06.2015)


**Build NIX-MX under Windows**

To build NIX-MX under Windows please follow the guide provided at [WinBuild.md](https://github.com/G-Node/nix-mx/blob/master/WinBuild.md)


Getting Started (Ubuntu 14.04)
------------------------------

_Dependencies_

In order to build the NIX-MX library a recent C++11 compatible compiler is needed (g++ >= 4.8, clang >= 3.4)
as well as the build tool CMake (>= 2.8.9). Further nix-mx depends on the following third party libraries:

- [NIX](https://github.com/G-Node/nix) (version 1.8.13 or higher)
- MATLAB (version R2011a) or OCTAVE (version 3.8.0)

_Instructions_

```bash
# clone NIX-MX
git clone https://github.com/G-Node/nix-mx
cd nix-mx

# make a build dir and build nix-mx
mkdir build
cd build
cmake ..
make all
```

This will generate the `nix_mx.mexa64` (or 32 on the 32-bit arch.) file. This file, together with the `nix+` package (located in the root of the repository) have to be added to the MATLAB path:

```
addpath('<path_to_the_mex_file>')
addpath('<path_to_the_nix+_package>')
```

_Note!_

MATLAB is usually shipped with built-in `boost` and `HDF5` libraries, which may be of different versions from the ones that were used when compiling NIX. This results in errors and program crash. The workaround is to remove some built-in MATLAB libraries (usually they are older versions than the system ones) and symlink the ones that were used to build NIX. For example, for MATLAB R2011a 64-bit:

```
cd $MATLAB_HOME/bin/glnxa64

mv libhdf5.so.6 /tmp
mv libhdf5_hl.so.6 /tmp
mv libboost_regex.so.1.40.0 /tmp

ln -s /usr/lib/x86_64-linux-gnu/libhdf5.so libhdf5.so.6
ln -s /usr/lib/x86_64-linux-gnu/libhdf5_hl.so libhdf5_hl.so.6
ln -s /usr/lib/x86_64-linux-gnu/libboost_regex.so libboost_regex.so.1.40.0
```

After that the library can be normally used.
