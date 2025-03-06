cmake_minimum_required(VERSION 3.30)
project(${PROJECT})

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# include_directories(inc) # AE only
file(GLOB_RECURSE SRC CONFIGURE_DEPENDS
    "src/*.cpp"
    "src/*.hpp"
    "src/*.c"
    "src/*.h"
)
# target_link_directories(${PROJECT} PUBLIC lib) # AE only
# target_link_libraries(${PROJECT} PUBLIC aecore) # AE only

add_executable(${PROJECT}
    ${SRC}
)
