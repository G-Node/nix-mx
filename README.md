About NIX-MX
-------------

The *NIX-MX* project is an extension to [NIX](https://github.com/G-Node/nix) and provides Matlab bindings for *NIX*.


Development Status
------------------

The *NIX-MX* project has been developed and tested solely under Windows 32 and Windows 64 and is in a beta stage of development. Specifically all of the features of NIX have been implemented and unit tests for all of the methods exist and pass, but extensive testing and some refactoring of existing code has to be done as of yet.


Getting Started (Windows 32/64)
-------------------------------

**Quick start packages, Beta-Release 1.1.0**

The [quick start packages](https://github.com/G-Node/nix-mx/releases) are compiled under Windows 32/64 and contain all dlls, binary and Matlab files required to use NIX-MX with the respective Windows OS.
The included *NIX* dll is a [stable release 1.3.2 build](https://github.com/G-Node/nix/releases/tag/1.3.2) . To use the packages, unzip them into a folder of your choice and run the `startup.m` script from the root folder. Do not change the file/folder structure.

The Windows 32 package contains:
- HDF5 dlls (Release 1.8.14)
- NIX dll (stable release 1.3.2 build, compiled using BOOST 1.57.0 and CPPUNIT 1.13.2)
- NIX-MX (Beta-Release 1.3.0, 10.02.2017)

The Windows 64 package contains:
- HDF5 dlls (Release 1.8.14)
- NIX dll (stable release 1.3.2 build, compiled using BOOST 1.57.0 and CPPUNIT 1.13.2)
- NIX-MX (Beta-Release 1.3.0, 10.02.2017)

NOTE: there was a small bugfix in examples/Primer.m after the latest release. If you want to use this small tutorial, please replace examples/Primer.m in your extracted quick start package with the corresponding file from the master branch.

**Build NIX-MX under Windows**

To build NIX-MX under Windows please follow the guide provided at [WinBuild.md](https://github.com/G-Node/nix-mx/blob/master/WinBuild.md)


Getting Started (macOS)
-------------------------------

**Quick start packages, Beta-Release 1.4.0**

The quick start packages (https://github.com/G-Node/nix-mx/releases)
are compiled under macOS Sierra using Matlab 2016b and contain the compiled mex files, nix m-files, tests, and a startup.m script. To use nix-mx unzip the file and run the startup.m script in MATLAB. This simply adds the current folder containing the mex files to the MATLAB path. Do not change the file/folder structure.


In order to have it working the respective NIX C++ library must be installed on the system. The easiest way is using homebrew `brew install nixio`

Once this is done, you may want to test it. Go to the MATLAB command line, change into the nix-mx folder and execute:

`>>RunTests`

This will execute a bunch of tests, there may be warnings but no test should fail.

**Build NIX-MX under macOS**

To build NIX-MX under macOS please follow the guide provided at [MacOSBuild.md](https://github.com/G-Node/nix-mx/blob/master/MacOSBuild.md)
