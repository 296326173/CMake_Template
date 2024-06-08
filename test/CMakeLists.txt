
cmake_minimum_required(VERSION 3.20)

#
# Project details
#

project(
  ${CMAKE_PROJECT_NAME}Tests
  LANGUAGES CXX
)

verbose_message("添加单元测试在${CMAKE_PROJECT_NAME}Tests...")
# 
foreach(file ${test_sources})
  string(REGEX REPLACE "(.*/)([a-zA-Z0-9_ ]+)(\.cpp)" "\\2" test_name ${file}) 
  # message(STATUS "test_name:")
  # message(STATUS ${test_name})
  add_executable(${test_name}_Tests ${file})

  #
  # Set the compiler standard
  #

  target_compile_features(${test_name}_Tests PUBLIC cxx_std_20)

  #
  # Setup code coverage if enabled
  #

  if (${CMAKE_PROJECT_NAME}_ENABLE_CODE_COVERAGE)
    target_compile_options(${CMAKE_PROJECT_NAME} PUBLIC -O0 -g -fprofile-arcs -ftest-coverage)
    target_link_options(${CMAKE_PROJECT_NAME} PUBLIC -fprofile-arcs -ftest-coverage)
    verbose_message("{代码覆盖是由GCC提供的.}")
  endif()

  #
  # 加载所需的单元测试框架
  #
  # 目前支持: GoogleTest (and GoogleMock), Catch2.

  if(${CMAKE_PROJECT_NAME}_BUILD_EXECUTABLE)
    set(${CMAKE_PROJECT_NAME}_TEST_LIB ${CMAKE_PROJECT_NAME}_LIB)
  else()
    set(${CMAKE_PROJECT_NAME}_TEST_LIB ${CMAKE_PROJECT_NAME})
  endif()

  if(${CMAKE_PROJECT_NAME}_USE_GTEST)
    find_package(GTest REQUIRED)
    if(NOT GTest_FOUND)
      message(FATAL_ERROR "找不到GoogleTest")
    endif()
    if(${CMAKE_PROJECT_NAME}_USE_GOOGLE_MOCK)
      set(GOOGLE_MOCK_LIBRARIES GTest::gmock GTest::gmock_main)
    endif()
    target_link_libraries(
      ${test_name}_Tests
      PUBLIC
        GTest::GTest
        GTest::Main
        ${GOOGLE_MOCK_LIBRARIES}
        ${${CMAKE_PROJECT_NAME}_TEST_LIB}
    )
  elseif(${CMAKE_PROJECT_NAME}_USE_CATCH2)
    find_package(Catch2 REQUIRED)
    if(NOT Catch2_FOUND)
      message(FATAL_ERROR "找不到Catch2")
    endif()
    target_link_libraries(
      ${test_name}_Tests
      PUBLIC
        Catch2::Catch2
        ${${CMAKE_PROJECT_NAME}_TEST_LIB}
    )
  else()
    message(FATAL_ERROR "未知的测试库。请使用`target_link_libraries`设置所需的单元测试库.")  
  endif()

  #
  # 添加单元测试
  #

  add_test(
    NAME
      ${test_name}
    COMMAND
      ${test_name}_Tests
  )
endforeach()

message(STATUS "为${CMAKE_PROJECT_NAME}成功添加单元测试.")
