@echo off
mkdir .\bin\debug
cd .\bin\debug\
cmake ../../ -G "Visual Studio 17 2022" -DCMAKE_BUILD_TYPE=Debug
cd ../../
