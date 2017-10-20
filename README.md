About NIX-MX
-------------

The *NIX-MX* project is an extension to [NIX](https://github.com/G-Node/nix) and provides 
Matlab bindings for *NIX*.


Development Status
------------------

The *NIX-MX* project has been developed and tested under Windows 32 and Windows 64 and can 
easily be built under MacOS. Specifically all of the features of NIX v1.4.1 have been 
implemented and tests for all of the methods exist and pass.


Getting Started (Windows 32/64)
-------------------------------

**Quick start packages, Release 1.4.1**

The [quick start packages](https://github.com/G-Node/nix-mx/releases) are compiled under 
Windows 32/64 and contain all binary and Matlab files required to use NIX-MX with 
the respective Windows OS.
The included *NIX* library is a [stable release 1.4.1 build](https://github.com/G-Node/nix/releases/tag/1.4.1). 
To use the packages, unzip them into a folder of your choice and run the `startup.m` 
script from the root folder. Do not change the file/folder structure.

The Windows 64 package contains:
- NIX library (stable release 1.4.1 build, compiled using BOOST 1.57.0, CPPUNIT 1.13.2 and HDF 1.10.1)
- NIX-MX (Release 1.4.1)

The Windows 32 package contains:
- NIX library (stable release 1.4.1 build, compiled using BOOST 1.57.0, CPPUNIT 1.13.2 and HDF 1.10.1)
- NIX-MX (Release 1.4.1)

**Build NIX-MX under Windows**

To build NIX-MX under Windows please follow the guide provided at [WinBuild.md](https://github.com/G-Node/nix-mx/blob/master/WinBuild.md). 
For an automated build, you can also use the `win_build.bat` script after you have read 
the build guide and set up all required paths and repositories accordingly.


Getting Started (macOS)
-------------------------------

**Quick start packages, Release 1.4.1**

The quick start packages (https://github.com/G-Node/nix-mx/releases)
are compiled under macOS Sierra using Matlab 2016b and contain the compiled mex files, 
nix m-files, tests, and a `startup.m` script. To use nix-mx unzip the file and run the 
`startup.m` script in MATLAB. This simply adds the current folder containing the mex 
files to the MATLAB path. Do not change the file/folder structure.


In order to have it working the respective NIX C++ library must be installed on the 
system. The easiest way is using homebrew `brew install nixio`

Once this is done, you may want to test it. Go to the MATLAB command line, change into 
the nix-mx folder and execute:

`>>RunTests`

This will execute a bunch of tests, there may be warnings but no test should fail.

**Build NIX-MX under macOS**

To build NIX-MX under macOS please follow the guide provided at [MacOSBuild.md](https://github.com/G-Node/nix-mx/blob/master/MacOSBuild.md)
