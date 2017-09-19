How to build NIX-MX on macOS
----------------------------

To compile NIX-MX for macOS for your MATLAB Version follow these steps:

**Dependencies**

- You have to have a working build environment including a C++ compiler
- Install the nix C++ libraries (e.g. via homebrew `brew install nixio`) to build it from source please visit [NIX](https://github.com/G-Node/nix)
- Install cmake and the boost libraries (e.g. via homebrew `brew install boost; brew install cmake`
- Clone the nix-mx repository `git clone https://github.com/g-node/nix-mx.git`
- Change into the directory and create a build subfolder: `mkdir build`
- Change into the build folder and configure the build: `cd build; cmake ..`
- Compile nix-mx: `make`
- You may want to create a zip archive by: `make macOS_zip`
- Move the zip file to your preferred installation folder and extract it there

