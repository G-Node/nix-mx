# How to build NIX-MX on macOS


## To compile NIX-MX for macOS for your MATLAB Version follow these steps

- You have to have a working build environment including a C++ compiler.
- Install the NIX C++ libraries via [homebrew](https://brew.sh):
- By default nix-mx builds a statically linked package.

```bash
# 1. install the statically linked nix c++ library
brew tap g-node/pkg
brew install g-node/pkg/nixio-static

# 2. install dependencies
brew install cmake
brew install boost

# 3. clone the nix-mx repository
git clone https://github.com/G-Node/nix-mx.git .

cd nix-mx
mkdir build
cd build

# 4. configure the build using cmake
cmake ..

# 5. build the package
make

# 6. create a zip file
make macOS_zip
```

- Move the zip file to your preferred installation folder and extract it there.
- Start MATLAB and navigate within MATLAB to this location.
- We may run the `startup.m` script that adds the installation folder to the MATLAB search path.
- Test if everything worked by calling the tests `RunTest`. There may be warnings but none of the tests should fail.

## Optional: If you prefer a dynamically linked package use

```bash
# 1. install the dynamically linked nix c++ library
 brew tap g-node/pkg
 brew install g-node/pkg/nixio

# follow steps 2 and 3 from above

# 4. configure the build for dynamic linking
cmake .. -DBUILD_STATIC=OFF

# follow steps 5 through 6 and install the package as described above
```

- To build the NIX C++ libraries from source please refer to the [NIX repository](https://github.com/G-Node/nix) for details.
