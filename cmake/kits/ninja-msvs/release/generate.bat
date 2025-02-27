REM @echo off
mkdir .\bin\release
cd .\bin\release\
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
cmake ../../ -G "Ninja" -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_COMPILER="clang-cl.exe" -DCMAKE_CXX_COMPILER="clang-cl.exe"
move compile_commands.json ../../
cd ../../
