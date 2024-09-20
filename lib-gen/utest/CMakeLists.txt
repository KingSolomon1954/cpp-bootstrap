# -----------------------------------------------------------------
#
# CMakeLists file to compile unit tests
#
# -----------------------------------------------------------------

add_executable(lib-gen-ut
    utest-lib-gen.cpp
    BuildInfoTest.cpp
    StringUtilsTest.cpp
)

target_link_libraries(lib-gen-ut
    PRIVATE lib-gen
    PRIVATE doctest::doctest
)

doctest_discover_tests(lib-gen-ut)

# -----------------------------------------------------------------
