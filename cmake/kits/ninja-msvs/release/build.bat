@echo off
if exist .\bin\release (
    cd .\bin\debug\
    cmake --build . --config Release
    cd ..\..\ 
) else (
    echo The directory .\bin\Release does not exist.
)
