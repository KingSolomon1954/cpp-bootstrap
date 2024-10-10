if(CMAKE_BUILD_TYPE STREQUAL "Debug")
  option(COVERAGE "Enable code coverage report" OFF)

  if(COVERAGE)
    set(Coverage_JUNIT_OUTPUT "report.xml" CACHE STRING "Filename where test report is stored" )
    include(${PROJECT_TOP}/tools/cmake/CodeCoverage.cmake)
    set(Coverage_LCOV_ARGS "-b ${PROJECT_SOURCE_DIR}")
    
    if(NOT COVERAGE_EXCLUDES)
      set(COVERAGE_EXCLUDES "")
    endif()
  
    list(APPEND COVERAGE_EXCLUDES "/usr/include/*" "/usr/local/include/*" "/opt/rh/*" "/root/*"
      "${CMAKE_CURRENT_BINARY_DIR}/*" "${PROJECT_SOURCE_DIR}/main/utest/*" "${PROJECT_SOURCE_DIR}/lib-gen/utest/*"
      "${PROJECT_SOURCE_DIR}/lib-codec/utest/*"
      )
    append_coverage_compiler_flags()
    setup_target_for_coverage_lcov(NAME coverage EXECUTABLE ${CMAKE_CTEST_COMMAND})
  endif()
else()
  add_custom_target(coverage
    COMMAND echo "Not available. Only available with Debug build."
    )
endif()
