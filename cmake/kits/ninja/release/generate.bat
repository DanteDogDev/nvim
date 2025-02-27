@echo off
mkdir .\bin\release
cd .\bin\release\
cmake ../../ -G "Ninja" -DCMAKE_BUILD_TYPE=Release
move compile_commands.json ../../
cd ../../
