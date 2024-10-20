# -----------------------------------------------------------------
#
# CMakeLists file to compile unit tests
#
# -----------------------------------------------------------------

add_executable(gen-ut
    utest-gen-main.cpp
    BuildInfoTest.cpp
    StringUtilsTest.cpp
)

target_link_libraries(gen-ut
    PRIVATE gen
    PRIVATE doctest::doctest
)

doctest_discover_tests(gen-ut)

# -----------------------------------------------------------------
