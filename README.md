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
