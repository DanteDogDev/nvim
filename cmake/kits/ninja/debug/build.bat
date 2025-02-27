@echo off
if exist .\bin\debug (
    cd .\bin\debug\
    cmake --build .
    cd ..\..\ 
) else (
    echo The directory .\bin\debug does not exist.
)
