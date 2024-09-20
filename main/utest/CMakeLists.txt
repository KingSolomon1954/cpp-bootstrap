# -----------------------------------------------------------------
#
# CMakeLists file to compile unit tests
#
# -----------------------------------------------------------------

add_executable(redflame-ut
    utest-main.cpp
    RedFlameTest.cpp
    PropertiesTest.cpp
)

target_link_libraries(redflame-ut
    PRIVATE main
    PRIVATE doctest::doctest
)

doctest_discover_tests(redflame-ut)

# -----------------------------------------------------------------
