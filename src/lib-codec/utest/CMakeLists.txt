# -----------------------------------------------------------------
#
# CMakeLists file to compile unit tests
#
# -----------------------------------------------------------------

add_executable(lib-codec-ut
    utest-lib-codec.cpp
    CodecFastTest.cpp
    CodecSlowTest.cpp
    EnumChannelDirectionTest.cpp
)

target_link_libraries(lib-codec-ut
    PRIVATE lib-codec
    PRIVATE doctest::doctest
)

doctest_discover_tests(lib-codec-ut)

# -----------------------------------------------------------------
