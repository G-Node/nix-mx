About NIX-MX
-------------

The *NIX-MX* project is an extension to [NIX] (https://github.com/G-Node/nix) and provides Matlab bindings for *NIX*.


Development Status
------------------

The *NIX-MX* project has been developed and tested solely under Windows 32 and Windows 64 and is in a beta stage of development. Specifically all of the features of NIX have been implemented and unit tests for all of the methods exist and pass, but extensive testing and some refactoring of existing code has to be done as of yet.


Getting Started (Windows 32/64)
-------------------------------

**Quick start packages, Beta-Release 1.1.0**

The [quick start packages] (https://github.com/G-Node/nix-mx/releases) are compiled under Windows 32/64 and contain all dlls, binary and Matlab files required to use NIX-MX with the respective Windows OS.
The included *NIX* dll is a [stable release 1.1.0 build] (https://github.com/G-Node/nix/releases/tag/1.1.0) . To use the packages, unzip them into a folder of your choice and run the `startup.m` script from the root folder. Do not change the file/folder structure.

The Windows 32 package contains:
- HDF5 dlls (Release 1.8.14)
- NIX dll (stable release 1.1.0 build, compiled using BOOST 1.57.0 and CPPUNIT 1.13.2)
- NIX-MX (Beta-Release 1.1.0, 26.01.2016)

The Windows 64 package contains:
- HDF5 dlls (Release 1.8.14)
- NIX dll (stable release 1.1.0 build, compiled using BOOST 1.57.0 and CPPUNIT 1.13.2)
- NIX-MX (Beta-Release 1.1.0, 26.01.2016)


**Build NIX-MX under Windows**

To build NIX-MX under Windows please follow the guide provided at [WinBuild.md](https://github.com/G-Node/nix-mx/blob/master/WinBuild.md)
