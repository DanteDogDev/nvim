@echo off
mkdir .\bin\release
cd .\bin\release\
cmake ../../ -G "Visual Studio 17 2022" -DCMAKE_BUILD_TYPE=Release
cd ../../
