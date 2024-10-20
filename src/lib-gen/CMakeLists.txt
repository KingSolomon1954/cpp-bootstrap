# -----------------------------------------------------------------
#
# CMakeLists file to compile library
#
# -----------------------------------------------------------------

add_library(gen STATIC
    src/BuildInfo.cpp
    src/StringUtils.cpp
)

# Some files are auto-generated in the _build folder, for example
# BuildInfoDefs.h, so we need to add binary folder to include path
target_include_directories(gen
    PUBLIC  ${CMAKE_CURRENT_SOURCE_DIR}/include
    PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/include
)

target_compile_definitions(gen
    PRIVATE $<$<CONFIG:Debug>:
    POCO_LOG_DEBUG=1
    _DEBUG=1
    >
)

include(buildinfodefs)
  
# -----------------------------------------------------------------
