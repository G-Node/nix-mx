How to build NIX-MX on MacOS
----------------------------

To compile NIX-MX for MaOS for your MATLAB Version follow these steps:

**Dependencies**
- you have to have a woring build environment including a c/c++ compiler
- install the nix c++ libraries (e.g. via homebrew `brew install nixio`)
to build it from source please visit [NIX](https://github.com/G-Node/nix).
- install cmake and the boost libraries (e.g. via homebrew `brew install boost; brew install cmake`

- clone the nix-mx repository ''''git clone https://github.com/g-node/nix-mx.git''''
- change into the directory and create a build subfolder: `mkdir build`
- change into the build folder and configure the build: `cd build; cmake ..`
- compile nix-mx: `make -j`
- you may want to create a zip archive by: `make macOS_zip`
- move the zip file to your preferred installation folder and extract it there

