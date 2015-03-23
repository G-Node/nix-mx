How to build NIX-MX on Windows
------------------------------

Follow these steps to set up the development environment for the NIX Matlab bindings under Windows32/64 for Matlab 32bit

**Dependencies**
- download and install Visual Studio 12
- make sure you have a fork of [NIX](https://github.com/G-Node/nix) and [NIX-MX](https://github.com/G-Node/nix-mx)
- get the latest [NIX Windows dependencies](https://projects.g-node.org/nix/), extract to [your path]\nix-dep\

**Build process for DEBUG build**
- start cmd (NOT powershell!), move to [your path]\nix; create "build" directory, move inside
- to set up dependencies path variables for NIX cmake, run:
	`[your path]\nix-dep\nixenv.bat`
- if working on a 32bit Windows, run:
	`cmake .. -G "Visual Studio 12"`
- if working on a 64bit Windows, run:
	`set PLATFORM=x64`
	`cmake .. -G "Visual Studio 12 Win64"`
- with Visual Studio open [your path]\nix\build\nix.sln

    NOTE! Visual Studio builds by default with configuration "Debug" and "32bit"! If some other build is required, set BUILD->ConfigurationManager->Active solution configuration!
- Build "ALL_BUILD"
- within the cmd shell move to [your path]\nix\build\Debug
- run again
	`[your path]\nix-dep\nixenv.bat`
- run
	`[your path]\nix\build\Debug\TestRunner.exe`
- within the cmd shell move to [your path]\nix-mx, create and move into "build" folder
- set the NIX root path;
	`set NIX_ROOT=[your path]/nix`

    IMPORTANT:
    - do not use quotes in cmd!
    - do not use backslashes, only slashes! e.g. c:/work/nix; c:\work\nix will not work!

- run again
	`[your path]\nix-dep\nixenv.bat`
- check, if the nix.dll library has been created in [your path]\nix\build\Debug
- if yes, open [your path]\nix-mx\cmake\FindNIX.cmake
- add "HINTS $ENV{NIX_ROOT}/build/Debug" to the "find_library(NIX_LIBRARY NAMES" statement
- if working on Windows 32bit, run
	`cmake .. -G "Visual Studio 12"`
- if working on Windows 64bit, run
	`cmake .. -G "Visual Studio 12 Win64"`
- with Visual Studio open [your path]\nix-mx\build\nix-mx.sln
- Build "ALL_BUILD"
- copy all of the following files into the [your path]\nix-mx\build folder; simply providing the directories to MatLab using "addpath" does not work

	from [your path]\nix-dep\[x86/x64]\hdf5-1.8.14\bin (path dependent on the Windows 32/64 bit version)
	
		`hdf5.dll, msvcp120.dll, msvcr120.dll, szip.dll, zlib.dll`
		
	from [your path]\nix\build\Debug
	
		`nix.dll`
		
	from [your path]\nix-mx\build\Debug
	
		`nix_mx.mexw32 or nix_mx.mexw64`
		
- get some NIX files from the [your path]\nix\build\ test folder and NIX away!


**Alternate build process for RELEASE build**

The build described above is for DEBUG which prevents the usage of msvcp120.dll and msvcr120.dll and requires the usage of msvcp120d.dll and msvcr120d.dll

To use the correct dlls, nix and nix-mx have to be built in RELEASE mode! For this:
- replace "Debug" with "Release" in the nixenv.bat, use this to setup environmental variables
- run cmake
- open sln, in Visual Studio set BUILD->ConfigurationManager->Active solution configuration to "Release" instead of "Debug"
- re-run TestRunner.exe in folder "Release" instead of "Debug"
- move to the [your path]\nix-mx\build folder
- re-run the modified nixenv.bat
- run

	`$env:NIX_ROOT="c:/work/nix"`
- open [your path]\nix-mx\cmake\FindNIX.cmake and add

	"HINTS $ENV{NIX_ROOT}/build/Release" to the "find_library(NIX_LIBRARY NAMES" statement
- run cmake
- open sln, in Visual Studio set BUILD->ConfigurationManager->Active solution configuration to "Release" instead of "Debug"
- setup the rest like in debug mode
