How to build NIX-MX on Windows
------------------------------

Follow these steps to set up the development environment for the NIX Matlab bindings under Windows32/64 for Matlab 32/64bit

**Dependencies**
- download and install Visual Studio 12
- make sure you have a clone of [NIX](https://github.com/G-Node/nix) and [NIX-MX](https://github.com/G-Node/nix-mx)
- get the latest [NIX Windows dependencies](https://projects.g-node.org/nix/), extract to [your path]/nix-dep/

**Build process**
- open [your path]/nix-mx/win_build.bat with an editor of your choice.
- adjust the first three lines of the batch file to the corresponding directories on your system (NIX_DEP, NIX_ROOT, NIX_MX_ROOT).
- NOTE: If you need the "Debug" instead of the "Release" build, change the corresponding line in the batch file.
- start cmd (NOT powershell!)
- run [your path]/nix-mx/win_build.bat


**Step by step build process**

If you want to build nix-mx step by step use the following guidelines:

***Build process for "Release" build***

1. start cmd (NOT powershell!), move to [your path]/nix; create "build" directory, move inside.
2. to set up dependencies path variables for NIX cmake, build type Release, run:
	`[your path]/nix-dep/nixenv.bat`
3. if working on a 32bit Windows, run:
	`cmake .. -G "Visual Studio 12"`
4. if working on a 64bit Windows, run:
	`cmake .. -G "Visual Studio 12 Win64"`
5. with Visual Studio open [your path]/nix/build/nix.sln
	IMPORTANT NOTE! Visual Studio builds by default with configuration "Debug" and "32bit"!
6. If some other build is required (in our case we need at least configuration "Release"), set BUILD->ConfigurationManager->Active solution configuration!
7. Build "ALL_BUILD".
8. within the cmd shell move to [your path]/nix/build/Release.
9. run
	`[your path]/nix/build/Release/TestRunner.exe`
10. within the cmd shell move to [your path]/nix-mx, create and move into "build" folder.
11. set the NIX root path;
	`set NIX_ROOT=[your path]/nix`

    IMPORTANT:
    - do not use quotes in cmd!
    - do not use backslashes, only slashes! e.g. c:/work/nix; c:\work\nix will not work!

12. check, if the nix.dll library has been created in [your path]/nix/build/Release
13. if yes, run
	`SET NIX_BUILD_DIR=%NIX_ROOT%/build/Release`
	
14. if working on Windows 32bit, run
	`cmake .. -G "Visual Studio 12"`
15. if working on Windows 64bit, run
	`cmake .. -G "Visual Studio 12 Win64"`
16. with Visual Studio open [your path]/nix-mx/build/nix-mx.sln.
17. Set BUILD->ConfigurationManager->Active solution configuration to Release and the correct bit version!
18. Build "ALL_BUILD".
19. copy all of the following files into the [your path]/nix-mx/build folder; simply providing the directories to MatLab using "addpath" does not work.

	from [your path]/nix-dep/[x86/x64]/hdf5-1.8.14/bin (path dependent on the Windows 32/64 bit version)
	
		`hdf5.dll, msvcp120.dll, msvcr120.dll, szip.dll, zlib.dll`
		
	from [your path]/nix/build/Release
	
		`nix.dll`
		
	from [your path]/nix-mx/build/Release
	
		`nix_mx.mexw32 or nix_mx.mexw64`
		
20. get some NIX files from the [your path]/nix/build/ test folder and NIX away!


***Alternate build process for "Debug" build***

The build described above is for "Release" which requires the usage of msvcp120d.dll and msvcr120d.dll and prevents the usage of msvcp120.dll and msvcr120.dll.

To use the hdf5 debug dlls, nix and nix-mx have to be built with build type "Debug"! For this change the following steps in the guideline above:
- Step 0. Delete everything from the nix/build and nix-mx/build directories.
- Step 2. setup the environmental variables by using:
	`[your path]/nix-dep/nixenv.bat Debug`
- Step 6. open nix sln, in Visual Studio set BUILD->ConfigurationManager->Active solution configuration to "Debug" instead of "Release".
- Step 8. re-run TestRunner.exe in folder "Debug" instead of "Release".
- Step 12. check, if the nix.dll library has been created in [your path]/nix/build/Debug.
- Step 13. run
	`SET NIX_BUILD_DIR=%NIX_ROOT%/build/Debug`
- Step 16. open nix-mx sln, in Visual Studio set BUILD->ConfigurationManager->Active solution configuration to "Debug" instead of "Release".
- Step 19. copy all of the following files into the [your path]/nix-mx/build folder; simply providing the directories to MatLab using "addpath" does not work.

	from [your path]/nix-dep/[x86/x64]/hdf5-1.8.14/bin (path dependent on the Windows 32/64 bit version)
	
		`hdf5.dll, msvcp120.dll, msvcr120.dll, szip.dll, zlib.dll`
		
	from [your path]/nix/build/Debug
	
		`nix.dll`
		
	from [your path]/nix-mx/build/Debug
	
		`nix_mx.mexw32 or nix_mx.mexw64`
