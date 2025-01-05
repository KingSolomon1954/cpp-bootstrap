# --------------------------------------------------------
#
# King Solomon Project: C++ Bootstrap
#
# File: CMakeLists.txt
#
# Copyright (c) 2024 KingSolomon1954
#
# SPDX-License-Identifier: MIT
#
# --------------------------------------------------------

cmake_minimum_required(VERSION 3.20)

project("RedFlame"
    DESCRIPTION "A high intensity software flame"
)
  
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

set(PROJ_COMPILE_OPTIONS
    -Wall -Wextra -Werror -Werror=format-security
    -fstack-protector-strong
    -O3
)

set(PROJECT_TOP ${PROJECT_SOURCE_DIR}/..)

list(APPEND CMAKE_MODULE_PATH
    ${PROJECT_TOP}/tools/cmake
)

include(gen)

add_subdirectory(lib-gen)
add_subdirectory(lib-gen/utest)
add_subdirectory(lib-codec)
add_subdirectory(lib-codec/utest)
add_subdirectory(main)
add_subdirectory(main/utest)

# -----------------------------------------------------------------
