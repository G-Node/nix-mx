SET NIX_DEP=c:\work\nix-dep
SET NIX_ROOT=c:\work\nix
SET NIX_MX_ROOT=c:\work\nix-mx
REM Use only build types "Release" or "Debug"
SET BUILD_TYPE=Release

IF NOT %BUILD_TYPE% == Release (IF NOT %BUILD_TYPE% == Debug (ECHO Please use only Release or Debug as BUILD_TYPE))
IF NOT %BUILD_TYPE% == Release (IF NOT %BUILD_TYPE% == Debug (EXIT /b))
REM Set NIX_BUILD_DIR for nix-mx FindNIX.cmake
SET NIX_BUILD_DIR=%NIX_ROOT%\build\%BUILD_TYPE%

IF %BUILD_TYPE% == Debug (CALL %NIX_DEP%\nixenv.bat Debug) ELSE (CALL %NIX_DEP%\nixenv.bat)

IF NOT EXIST %NIX_ROOT%\build (MKDIR %NIX_ROOT%\build)
CD %NIX_ROOT%\build
REM Clean up build folder to ensure clean build.
DEL * /S /Q
RD /S /Q "CMakeFiles" "Testing" "Debug" "Release" "nix-tool.dir" "x64" "TestRunner.dir" "nix.dir"

IF %PROCESSOR_ARCHITECTURE% == x86 ( cmake .. -G "Visual Studio 12") ELSE (cmake .. -G "Visual Studio 12 Win64")

REM Start %NIX_ROOT%\build\nix.sln
cmake --build . --config %CONFIGURATION% --target nix

%NIX_BUILD_DIR%\TestRunner.exe

IF NOT EXIST %NIX_MX_ROOT%\build (MKDIR %NIX_MX_ROOT%\build)
CD %NIX_MX_ROOT%\build
REM Clean up build folder to ensure clean build.
DEL * /S /Q
RD /S /Q "CMakeFiles" "Debug" "nix_mx.dir" "Release" "Win32" "x64"

COPY %NIX_BUILD_DIR%\nix.dll %NIX_MX_ROOT%\build\ /Y
COPY %HDF5_BASE%\bin\hdf5.dll %NIX_MX_ROOT%\build\ /Y
COPY %HDF5_BASE%\bin\msvcp120.dll %NIX_MX_ROOT%\build\ /Y
COPY %HDF5_BASE%\bin\msvcr120.dll %NIX_MX_ROOT%\build\ /Y
COPY %HDF5_BASE%\bin\szip.dll %NIX_MX_ROOT%\build\ /Y
COPY %HDF5_BASE%\bin\zlib.dll %NIX_MX_ROOT%\build\ /Y

IF %PROCESSOR_ARCHITECTURE% == x86 (cmake .. -G "Visual Studio 12") ELSE (cmake .. -G "Visual Studio 12 Win64")

cmake --build . --config %CONFIGURATION%

COPY %NIX_MX_ROOT%\build\%BUILD_TYPE%\nix_mx.mexw* %NIX_MX_ROOT%\build\ /Y

CD %NIX_MX_ROOT%

Start %NIX_MX_ROOT%\startup.m
