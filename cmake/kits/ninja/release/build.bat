@echo off
if exist .\bin\release (
    cd .\bin\release\
    cmake --build .
    cd ..\..\ 
) else (
    echo The directory .\bin\release does not exist.
)
