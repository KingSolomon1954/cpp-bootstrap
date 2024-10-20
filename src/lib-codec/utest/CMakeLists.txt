# -----------------------------------------------------------------
#
# CMakeLists file to compile unit tests
#
# -----------------------------------------------------------------

add_executable(codec-ut
    utest-codec-main.cpp
    CodecFastTest.cpp
    CodecSlowTest.cpp
    EnumChannelDirectionTest.cpp
)

target_link_libraries(codec-ut
    PRIVATE codec
    PRIVATE doctest::doctest
)

doctest_discover_tests(codec-ut)

# -----------------------------------------------------------------
