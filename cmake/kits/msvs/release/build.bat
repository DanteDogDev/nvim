@echo off
if exist .\bin\release (
    cd .\bin\release\
    cmake --build . --config Release
    cd ..\..\ 
) else (
    echo The directory .\bin\release does not exist.
)
