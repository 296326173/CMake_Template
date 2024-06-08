cmake_minimum_required(VERSION 3.20.0)

#
# 项目详情
#

project(
  "Project"
  VERSION 0.1.0
  LANGUAGES CXX
)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_EXTENSIONS ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
message(STATUS "CPP标准：${CMAKE_CXX_STANDARD}")

#
# 设置项目选项
#
include(cmake/StandardSettings.cmake)
include(cmake/StaticAnalyzers.cmake)
include(cmake/Utils.cmake)
# 若没选择构建类型,就默认debug模型
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "Debug")
endif()
message(STATUS "启动CMAKE项目：${PROJECT_NAME},版本：${PROJECT_VERSION}...\n")

# 这将允许在Linux和Windows - MSCV环境中使用相同的_DEBUG宏,易于调试特定的代码.
if (UNIX)
    add_compile_options("$<$<CONFIG:DEBUG>:-D_DEBUG>")
endif (UNIX)


#
# 设置备选名称
#
if(${PROJECT_NAME}_USE_ALT_NAMES)
  string(TOLOWER ${PROJECT_NAME} PROJECT_NAME_LOWERCASE)
  string(TOUPPER ${PROJECT_NAME} PROJECT_NAME_UPPERCASE)
else()
  set(PROJECT_NAME_LOWERCASE ${PROJECT_NAME})
  set(PROJECT_NAME_UPPERCASE ${PROJECT_NAME})
endif()

#
# 防止在源目录中构建
#
if(PROJECT_SOURCE_DIR STREQUAL PROJECT_BINARY_DIR)
  message(FATAL_ERROR "不允许在源目录构建,请创建一个新目录(称为build目录)并从那里运行CMake.\n")
endif()

#
# 启用包管理器
# 
include(cmake/Conan.cmake)
include(cmake/Vcpkg.cmake)

#
# Create library, setup header and source files
# 创建库、设置头文件和源文件

# 查找所有头文件和源文件
include(cmake/SourcesAndHeaders.cmake)

# 如果开启了${PROJECT_NAME}_BUILD_EXECUTABLE
# 那么构建并生成可执行文件
if(${PROJECT_NAME}_BUILD_EXECUTABLE)
  message(STATUS "{开启构建可执行文件}")
  add_executable(${PROJECT_NAME} ${exe_sources})
  # 如果开启详细输出,那么就输出所有的source文件
  if(${PROJECT_NAME}_VERBOSE_OUTPUT)
    verbose_message("发现如下源文件：")
    foreach(source IN LISTS exe_sources)
      verbose_message("* ${source}")
    endforeach()
  endif()
  # 如果开启单元测试
  if(${PROJECT_NAME}_ENABLE_UNIT_TESTING)
    add_library(${PROJECT_NAME}_LIB ${headers} ${sources})

    if(${PROJECT_NAME}_VERBOSE_OUTPUT)
      verbose_message("发现如下头文件：")
      foreach(header IN LISTS headers)
        verbose_message("* ${header}")
      endforeach()
    endif()
  endif()
elseif(${PROJECT_NAME}_BUILD_HEADERS_ONLY)
  add_library(${PROJECT_NAME} INTERFACE)

  if(${PROJECT_NAME}_VERBOSE_OUTPUT)
    verbose_message("发现如下头文件：")
    foreach(header IN LIST headers)
      verbose_message("* ${header}")
    endforeach()
  endif()
else() #如果是只构建库,那么构建即可
  add_library(
    ${PROJECT_NAME}
    ${headers}
    ${sources}
  )
  
  if(${PROJECT_NAME}_VERBOSE_OUTPUT)
    verbose_message("发现如下源文件：")
    foreach(source IN LISTS sources)
      verbose_message("* ${source}")
    endforeach()
    verbose_message("发现如下头文件：")
    foreach(header IN LISTS headers)
      verbose_message("* ${header}")
    endforeach()
  endif()
endif()

set_target_properties(
  ${PROJECT_NAME}
  PROPERTIES
  # 动态库目录
  ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib/${CMAKE_BUILD_TYPE}"
  # 静态库目录
  LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib/${CMAKE_BUILD_TYPE}"
  # 可执行文件目录
  RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin/${CMAKE_BUILD_TYPE}"
  
)
# 如果项目设置为构建可执行文件和执行单元测试
if(${PROJECT_NAME}_BUILD_EXECUTABLE AND ${PROJECT_NAME}_ENABLE_UNIT_TESTING)
  # 设置库的输出目录是在build/lib/[debug or relese]/下
  # message(STATUS "同时启动了单元测试和构建可执行文件.")
  set_target_properties(
    ${PROJECT_NAME}_LIB
    PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib/${CMAKE_BUILD_TYPE}"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib/${CMAKE_BUILD_TYPE}"
    OUTPUT_NAME ${PROJECT_NAME}
  )
endif()

message(STATUS "添加了所有头文件和源文件.\n")

#
# 设定项目标准和警告 Cpp20
#
if(${PROJECT_NAME}_BUILD_HEADERS_ONLY)
  target_compile_features(${PROJECT_NAME} INTERFACE cxx_std_20)
else()
  target_compile_features(${PROJECT_NAME} PUBLIC cxx_std_20)

  if(${PROJECT_NAME}_BUILD_EXECUTABLE AND ${PROJECT_NAME}_ENABLE_UNIT_TESTING)
    target_compile_features(${PROJECT_NAME}_LIB PUBLIC cxx_std_20)
  endif()
endif()
include(cmake/CompilerWarnings.cmake)
set_project_warnings(${PROJECT_NAME})

verbose_message("应用编译器警告.使用标准Cpp ${CMAKE_CXX_STANDARD}.\n")

#
# Enable Doxygen
#

# include(cmake/Doxygen.cmake)

#
# Model project dependencies
#
# 
# 识别并链接项目使用的特定package
#find_package(package_name package_version REQUIRED package_type [other_options])
# target_link_libraries(
#   ${PROJECT_NAME}
#   PUBLIC
  #  dependency1 ...
#  PRIVATE
  #  dependency2 ...
  #  ${PROJECT_NAME}_PROJECT_OPTIONS
  #  ${PROJECT_NAME}_PROJECT_WARNINGS
# )
#if(${PROJECT_NAME}_BUILD_EXECUTABLE AND ${PROJECT_NAME}_ENABLE_UNIT_TESTING)
#  target_link_libraries(
#    ${PROJECT_NAME}_LIB
#    PUBLIC
#      dependency1 ...
#  )
#endif()

# 对于Windows,有必要链接到多线程库.
# 根据项目其余依赖项的链接方式,可能需要将该行更改为与库静态链接。
# 具体操作如下:
# set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
#
#在Linux和Mac上,这个变量被忽略,如果出现任何问题,试着把它注释出来,让CMake决定如何与它链接.
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")

verbose_message("成功添加了所有依赖项并对其进行了链接.")

#
# Set the build/user include directories
# 设置build的时候的include目录
# 也就是target_include_directories

# 允许在src下使用头文件,但仅限于 utilities
if(${PROJECT_NAME}_BUILD_HEADERS_ONLY)
  target_include_directories(
    ${PROJECT_NAME}
    INTERFACE
    # 安装前缀<prefix>/include/
    $<INSTALL_INTERFACE:include>
    # 构建前缀
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
  )
else()
  target_include_directories(
    ${PROJECT_NAME}
    PUBLIC
    $<INSTALL_INTERFACE:include>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
  )
  if(${PROJECT_NAME}_BUILD_EXECUTABLE AND ${PROJECT_NAME}_ENABLE_UNIT_TESTING)
    target_include_directories(
      ${PROJECT_NAME}_LIB
      PUBLIC
      $<INSTALL_INTERFACE:include>
      $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
      PRIVATE
      ${CMAKE_CURRENT_SOURCE_DIR}/src
    )
  endif()
endif()

message(STATUS "完成了包含目录的设置.")

# 1
# 为库提供别名
# 
if(${PROJECT_NAME}_BUILD_EXECUTABLE)
  add_executable(${PROJECT_NAME}::${PROJECT_NAME} ALIAS ${PROJECT_NAME})
else()
  add_library(${PROJECT_NAME}::${PROJECT_NAME} ALIAS ${PROJECT_NAME})
endif()

verbose_message("项目现在的别名为 ${PROJECT_NAME}::${PROJECT_NAME}.\n")

#
# 使用'clang-format'目标来格式化项目 
# (i.e: cmake --build build --target clang-format)
add_clang_format_target()

#
# Install library for easy downstream inclusion
# 安装库以方便下游包含

include(GNUInstallDirs)
install(
  TARGETS
  ${PROJECT_NAME}
  EXPORT
  ${PROJECT_NAME}Targets
  LIBRARY DESTINATION
  ${CMAKE_INSTALL_LIBDIR}
  RUNTIME DESTINATION
  ${CMAKE_INSTALL_BINDIR}
  ARCHIVE DESTINATION
  ${CMAKE_INSTALL_LIBDIR}
  INCLUDES DESTINATION
  include
  PUBLIC_HEADER DESTINATION
  include
)

install(
  EXPORT
  ${PROJECT_NAME}Targets
  FILE
  ${PROJECT_NAME}Targets.cmake
  NAMESPACE
  ${PROJECT_NAME}::
  DESTINATION
  ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}
)

#
# Add version header
# 添加版本头

configure_file(
  ${CMAKE_CURRENT_LIST_DIR}/cmake/version.hpp.in
  include/${PROJECT_NAME_LOWERCASE}/version.hpp
  @ONLY
)

install(
  FILES
  ${CMAKE_CURRENT_BINARY_DIR}/include/${PROJECT_NAME_LOWERCASE}/version.hpp
  DESTINATION
  include/${PROJECT_NAME_LOWERCASE}
)

#
# 安装`include`目录
#

install(
  DIRECTORY
  include/${PROJECT_NAME_LOWERCASE}
  DESTINATION
  include
)

verbose_message("安装目标已成功构建. 命令： `cmake --build <build_directory> --target install --config <build_config>`.")

#
# Quick `ConfigVersion.cmake` creation
#

include(CMakePackageConfigHelpers)
write_basic_package_version_file(
  ${PROJECT_NAME}ConfigVersion.cmake
  VERSION
  ${PROJECT_VERSION}
  COMPATIBILITY
  SameMajorVersion
)

configure_package_config_file(
  ${CMAKE_CURRENT_LIST_DIR}/cmake/${PROJECT_NAME}Config.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake
  INSTALL_DESTINATION
  ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}
)

install(
  FILES
  ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake
  ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake
  DESTINATION
  ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}
)

#
# Generate export header if specified
#

if(${PROJECT_NAME}_GENERATE_EXPORT_HEADER)
  include(GenerateExportHeader)
  generate_export_header(${PROJECT_NAME})
  install(
    FILES
    ${PROJECT_BINARY_DIR}/${PROJECT_NAME_LOWERCASE}_export.h
    DESTINATION
    include
  )

  message(STATUS "生成了导出头文件 `${PROJECT_NAME_LOWERCASE}_export.h` 并安装了它.")
endif()

message(STATUS "完成了安装包的构建要求.\n")

#
# 单元测试设置
#
if(${PROJECT_NAME}_ENABLE_UNIT_TESTING)
  enable_testing()
  message(STATUS "开启单元测试,目录在test文件夹.")
  foreach(v ${test_sources})
    message(STATUS ${v})
  endforeach(v ${})
  add_subdirectory(test)
endif()
