# -----------------------------------------------------------------
#
# CMakeLists file to compile library
#
# -----------------------------------------------------------------

add_library(lib-codec STATIC
    src/CodecFast.cpp
    src/CodecSlow.cpp
    src/EnumChannelDirection.cpp
)

target_include_directories(lib-codec
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
)

target_link_libraries(lib-codec
    PUBLIC lib-gen
    PUBLIC ${CONAN_LIBS}
)

target_compile_definitions(lib-codec
    PRIVATE $<$<CONFIG:Debug>:
    POCO_LOG_DEBUG=1
    _DEBUG=1
    >
)

# -----------------------------------------------------------------
