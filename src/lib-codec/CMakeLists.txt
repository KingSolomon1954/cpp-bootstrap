# -----------------------------------------------------------------
#
# CMakeLists file to compile library
#
# -----------------------------------------------------------------

add_library(codec STATIC
    src/CodecFast.cpp
    src/CodecSlow.cpp
    src/EnumChannelDirection.cpp
)

target_include_directories(codec
    PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include
)

target_link_libraries(codec
    PUBLIC gen
)

target_compile_definitions(codec
    PRIVATE $<$<CONFIG:Debug>:
    POCO_LOG_DEBUG=1
    _DEBUG=1
    >
)

# -----------------------------------------------------------------
