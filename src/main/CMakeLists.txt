# --------------------------------------------------------
#
# CMakeLists file to compile myapp
#
# --------------------------------------------------------

add_library(main STATIC
    src/RedFlame.cpp
    src/Properties.cpp
)

target_include_directories(main
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
)

target_link_libraries(main
    PUBLIC lib-gen
    PUBLIC lib-codec
    PUBLIC ${CONAN_LIBS}
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

add_executable(redflame
    src/main.cpp
)

target_link_libraries(redflame
    PRIVATE main
)

# --------------------------------------------------------
