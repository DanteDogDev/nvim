@echo off
mkdir .\bin\debug
cd .\bin\debug\
cmake ../../ -G "Ninja" -DCMAKE_BUILD_TYPE=Debug
move compile_commands.json ../../
cd ../../
