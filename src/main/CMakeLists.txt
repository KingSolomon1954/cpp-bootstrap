# --------------------------------------------------------
#
# CMakeLists file to compile myapp
#
# --------------------------------------------------------

find_package(cxxopts REQUIRED)
find_package(rang REQUIRED)

add_library(main STATIC
    src/CommandLine.cpp
    src/RedFlame.cpp
    src/Properties.cpp
)

target_include_directories(main
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
)

target_link_libraries(main
    PUBLIC gen
    PUBLIC codec
    PUBLIC cxxopts::cxxopts
    PUBLIC rang::rang
)

target_compile_options(main
    PUBLIC ${PROJ_COMPILE_OPTIONS}
)

target_compile_definitions(main
    PRIVATE $<$<CONFIG:Debug>:
    POCO_LOG_DEBUG=1
    _DEBUG=1
    >
)

add_executable(RedFlame
    src/main.cpp
)

target_link_libraries(RedFlame
    PRIVATE main
)

# --------------------------------------------------------
