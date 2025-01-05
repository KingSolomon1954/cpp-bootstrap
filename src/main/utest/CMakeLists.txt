# -----------------------------------------------------------------
#
# CMakeLists file to compile unit tests
#
# -----------------------------------------------------------------

add_executable(RedFlame-ut
    utest-main.cpp
    RedFlameTest.cpp
    PropertiesTest.cpp
)

target_link_libraries(RedFlame-ut
    PRIVATE main
    PRIVATE doctest::doctest
)

doctest_discover_tests(RedFlame-ut)

# -----------------------------------------------------------------
