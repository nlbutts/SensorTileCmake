# SensorTileCmake
A Cmake build project for ST SensorTile

# Overview
This project is intended to create a CMake environment for the ST SensorTile dev kit. ST has example projects and files for various IDEs.
I'm a bit of a purist and would rather use CMake and whatever editor I want. 

This could use more work, but right now I build two libraries: driver, middleware, and one application. The include paths are a bit 
much and need to be paired down, but ST likes to have a lot of include dependencies.
There is a dependency on your embedded toolchain. The CMake system expects you to provide a toolchain file. An example is included 
in the toolchain directory.  

# Building
```
mkdir build
cd build
cmake -DCMAKE_TOOLCHAIN_FILE=../toolchain/arm_embedded_toolchain.txt ..
make -j99
```
