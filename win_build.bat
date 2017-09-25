@ECHO off
SET MATLAB_BINARY=c:\work\MATLAB_R2011a\bin
REM Latest dependencies at https://projects.g-node.org/nix/
SET NIX_DEP=c:\work\nix-dep
REM clone nix source from https://github.com/G-Node/nix
SET NIX_ROOT=c:\work\nix
SET NIX_MX_ROOT=c:\work\nix-mx
SET HDF5_VERSION_DIR=hdf5-1.10.1

IF NOT EXIST cmake (
	ECHO Require a valid installation of cmake.
	EXIT /b
)

IF NOT EXIST %NIX_DEP% (
	ECHO Please provide the nix dependency directory.
	EXIT /b
)

IF NOT EXIST %NIX_ROOT% (
	ECHO Please provide valid nix root directory.
	EXIT /b
)

IF NOT EXIST %NIX_MX_ROOT% (
	ECHO Please provide valid nix-mx root directory.
	EXIT /b
)

ECHO Use only build types "Release" or "Debug"
IF "%1" == "Debug" (SET BUILD_TYPE=Debug)
IF "%BUILD_TYPE%" == "" (SET BUILD_TYPE=Release)

IF NOT %BUILD_TYPE% == Release (IF NOT %BUILD_TYPE% == Debug (ECHO Only Release or Debug are supported build types))
IF NOT %BUILD_TYPE% == Release (IF NOT %BUILD_TYPE% == Debug (EXIT /b))

ECHO --------------------------------------------------------------------------
ECHO Setting up environment ...
ECHO --------------------------------------------------------------------------

IF "%PLATFORM%" == "" (IF %PROCESSOR_ARCHITECTURE% == x86 (SET PLATFORM=x86) ELSE (SET PLATFORM=x64))
ECHO Platform: %PLATFORM% (%BUILD_TYPE%)

SET BASE=%NIX_DEP%\%PLATFORM%\%BUILD_TYPE%

SET CPPUNIT_INCLUDE_DIR=%BASE%\cppunit-1.13.2\include
SET PATH=%PATH%;%CPPUNIT_INCLUDE_DIR%

SET HDF5_BASE=%NIX_DEP%\%PLATFORM%\%HDF5_VERSION_DIR%
SET HDF5_DIR=%HDF5_BASE%\cmake
SET PATH=%PATH%;%HDF5_BASE%\bin

SET BOOST_ROOT=%BASE%\boost-1.57.0
SET BOOST_INCLUDEDIR=%BOOST_ROOT%\include\boost-1_57

ECHO CPPUNIT_INCLUDE_DIR=%CPPUNIT_INCLUDE_DIR%
IF EXIST %CPPUNIT_INCLUDE_DIR% (ECHO cppunit OK) ElSE (EXIT /b)
ECHO HDF5_DIR=%HDF5_DIR%
IF EXIST %HDF5_DIR% (ECHO hdf5 OK) ELSE (EXIT /b)
ECHO BOOST_INCLUDEDIR=%BOOST_INCLUDEDIR%
IF EXIST %BOOST_ROOT% (ECHO boost OK) ELSE (EXIT /b)

ECHO --------------------------------------------------------------------------
ECHO Setting up nix build ...
ECHO --------------------------------------------------------------------------
SET NIX_BUILD_DIR=%NIX_ROOT%\build\%BUILD_TYPE%

IF NOT EXIST %NIX_ROOT%\build (MKDIR %NIX_ROOT%\build)
CD %NIX_ROOT%\build
REM Clean up build folder to ensure clean build.
DEL * /S /Q
RD /S /Q "CMakeFiles" "Testing" "Debug" "Release" "nix-tool.dir" "x64" "TestRunner.dir" "nix.dir"

IF %PROCESSOR_ARCHITECTURE% == x86 ( cmake .. -DBUILD_STATIC=ON -G "Visual Studio 12") ELSE (cmake .. -DBUILD_STATIC=ON -G "Visual Studio 12 Win64")

ECHO --------------------------------------------------------------------------
ECHO Building nix via %NIX_ROOT%\build\nix.sln ...
ECHO --------------------------------------------------------------------------
cmake --build . --config %BUILD_TYPE% --target nix

IF %ERRORLEVEL% == 1 (EXIT /b)

ECHO --------------------------------------------------------------------------
ECHO Building nix testrunner ...
ECHO --------------------------------------------------------------------------
cmake --build . --config %BUILD_TYPE% --target testrunner

IF %ERRORLEVEL% == 1 (EXIT /b)

ECHO --------------------------------------------------------------------------
ECHO Building nix-tool ...
ECHO --------------------------------------------------------------------------
cmake --build . --config %BUILD_TYPE% --target nix-tool

IF %ERRORLEVEL% == 1 (EXIT /b)

ECHO --------------------------------------------------------------------------
ECHO Testing nix ...
ECHO --------------------------------------------------------------------------
%NIX_BUILD_DIR%\TestRunner.exe

IF %ERRORLEVEL% == 1 (EXIT /b)

REM nix-mx requires nixversion file in ../nix/include/nix
IF EXIST %NIX_ROOT%\build\include\nix\nixversion.hpp (
	COPY %NIX_ROOT%\build\include\nix\nixversion.hpp %NIX_ROOT%\include\nix\
)

ECHO --------------------------------------------------------------------------
ECHO Setting up nix-mx build ...
ECHO --------------------------------------------------------------------------
IF NOT EXIST %NIX_MX_ROOT%\build (MKDIR %NIX_MX_ROOT%\build)
CD %NIX_MX_ROOT%\build
REM Clean up build folder to ensure clean build.
DEL * /S /Q
RD /S /Q "CMakeFiles" "Debug" "nix_mx.dir" "Release" "Win32" "x64"

IF %PROCESSOR_ARCHITECTURE% == x86 (cmake .. -G "Visual Studio 12") ELSE (cmake .. -G "Visual Studio 12 Win64")

ECHO --------------------------------------------------------------------------
ECHO Building nix-mx via %NIX_MX_ROOT%\build\nix-mx.sln ...
ECHO --------------------------------------------------------------------------
cmake --build . --config %BUILD_TYPE%

IF %ERRORLEVEL% == 1 (EXIT /b)

REM Copying required nix-mx.mex file to nix-mx root folder
COPY %NIX_MX_ROOT%\build\%BUILD_TYPE%\nix_mx.mexw* %NIX_MX_ROOT%\ /Y
REM Provide nix-tool as well for validation and content display
COPY %NIX_ROOT%\build\%BUILD_TYPE%\nix-tool.exe %NIX_MX_ROOT%\ /Y

CD %NIX_MX_ROOT%

ECHO --------------------------------------------------------------------------
ECHO Running nix-mx tests ...
ECHO --------------------------------------------------------------------------
SET PATH=%PATH%;%MATLAB_BINARY%
SET TEST_LOG=nix-mx-build.log~
matlab -wait -nodesktop -nosplash -logfile %TEST_LOG% -r startuptests

IF %ERRORLEVEL% == 1 (
	TYPE %TEST_LOG%
	ECHO --------------------------------------------------------------------------
	ECHO Matlab tests failed, check details above.
	ECHO --------------------------------------------------------------------------
) ELSE (
	ECHO --------------------------------------------------------------------------
	ECHO Build complete, all tests passed!
	ECHO Use "startup.m" to start your nix-mx experience!
	ECHO --------------------------------------------------------------------------
)

DEL %TEST_LOG%
