# cmake fragment to setup version variables.
# Reads version information from the 'version' file
# expected in the repo root folder.

file(STRINGS "${CMAKE_CURRENT_SOURCE_DIR}/version" VERSION_TRIPLET)
string(REGEX REPLACE "([0-9]+)\\.[0-9]+\\.[0-9]+.*" "\\1" PROJECT_VERSION_MAJOR ${VERSION_TRIPLET})
string(REGEX REPLACE "[0-9]+\\.([0-9]+)\\.[0-9]+.*" "\\1" PROJECT_VERSION_MINOR ${VERSION_TRIPLET})
string(REGEX REPLACE "[0-9]+\\.[0-9]+\\.([0-9]+).*" "\\1" PROJECT_VERSION_PATCH ${VERSION_TRIPLET})

# message(STATUS "PROJECT MAJOR := ${PROJECT_VERSION_MAJOR}")
# message(STATUS "PROJECT MINOR := ${PROJECT_VERSION_MINOR}")
# message(STATUS "PROJECT PATCH := ${PROJECT_VERSION_PATCH}")
# message(STATUS "CMAKE_SOURCE_DIR := ${CMAKE_SOURCE_DIR}")
# message(STATUS "CMAKE_BINARY_DIR := ${CMAKE_BINARY_DIR}")
