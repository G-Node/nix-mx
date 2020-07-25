# How to build NIX-MX on macOS

To compile NIX-MX for macOS for your MATLAB Version follow these steps:


- You have to have a working build environment including a C++ compiler.
- Install the NIX C++ libraries via [homebrew](https://brew.sh):

```bash
 brew tap g-node/pkg
 brew install g-node/pkg/nixio
 ````

- To build the NIX C++ libraries from source please refer to the [NIX repository](https://github.com/G-Node/nix) for details.
- Install cmake and the boost libraries (e.g. via homebrew `brew install boost; brew install cmake`.
- Clone the nix-mx repository `git clone https://github.com/g-node/nix-mx.git`.
- Change into the directory and create a build subfolder: `mkdir build`.
- Change into the build folder and configure the build: `cd build; cmake ..`. By default cmake will try to find the static NIX library. If this is not found use `cmake .. -DBUILD_STATIC=OFF` instead.
- Compile nix-mx: `make`.
- You may want to create a zip archive by: `make macOS_zip`.
- Move the zip file to your preferred installation folder and extract it there.
- Start MATLAB and navigate within MATLAB to this location.
- We may run the `startup.m` script that adds the installation folder to the MATLAB search path.
- Test if everything worked by calling the tests `RunTest`. There may be warnings but none of the tests should fail.
