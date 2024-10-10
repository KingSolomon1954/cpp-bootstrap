include(version-vars)
include(setup-build-bin-lib-dirs)
include(setup-path-to-generators)
include(disable-ctest-targets)
include(show-project)

# Set up for unit testing
#   Unit tests are kept separate from production code.
#   Unconditionally compile unit tests along with each build.
include(doctest)
find_package(doctest REQUIRED)
include(CTest)       # Include CMake's test runner
enable_testing()     # Add a CMake target called "test" to run unit tests

include(coverage)

# Hack. Move file to correct location - workaround Conan bug
if (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/CMakeUserPresets.json)
    file(RENAME ${CMAKE_CURRENT_SOURCE_DIR}/CMakeUserPresets.json
       ${CMAKE_CURRENT_BINARY_DIR}/generators/CMakeUserPresets.json)
endif()
