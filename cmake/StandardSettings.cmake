#
# 项目设置
# as
option(${PROJECT_NAME}_BUILD_EXECUTABLE "将项目构建为可执行文件,而不是库." ON)
option(${PROJECT_NAME}_BUILD_HEADERS_ONLY "将项目构建为仅头文件库." OFF)
option(${PROJECT_NAME}_USE_ALT_NAMES "为项目使用替代名称,例如将include目录命名为全小写." ON)

#
# 编译器设置
#
option(${PROJECT_NAME}_WARNINGS_AS_ERRORS "将编译器警告视为错误." OFF)

#
# 包管理器
# 当前支持: Conan, Vcpkg.
option(${PROJECT_NAME}_ENABLE_CONAN "为此项目启用Conan包管理器." OFF)
option(${PROJECT_NAME}_ENABLE_VCPKG "为此项目启用Vcpkg包管理器." OFF)

#
# 单元测试
# 当前支持: GoogleTest, Catch2.
option(${PROJECT_NAME}_ENABLE_UNIT_TESTING "为项目启用单元测试 (从'test'子文件夹)." ON)
option(${PROJECT_NAME}_USE_GTEST "使用GoogleTest项目创建单元测试." ON)
option(${PROJECT_NAME}_USE_GOOGLE_MOCK "使用GoogleMock项目扩展单元测试。." ON)
option(${PROJECT_NAME}_USE_CATCH2 "使用Catch2项目创建单元测试." OFF)

#1
# 静态分析程序
# 当前支持: Clang-Tidy, Cppcheck.
option(${PROJECT_NAME}_ENABLE_CLANG_TIDY "使用Clang-Tidy启用静态分析." OFF)
option(${PROJECT_NAME}_ENABLE_CPPCHECK "使用Cppcheck启用静态分析." OFF)

#
# Code coverage  
# 代码覆盖率
option(${PROJECT_NAME}_ENABLE_CODE_COVERAGE "通过GCC启用代码覆盖率." ON)

#
# Doxygen
#
option(${PROJECT_NAME}_ENABLE_DOXYGEN "启用源代码的doxygen文档构建." OFF)

# 
# 杂项选择
#
# 用于基于clang的工具生成compile_commands.json
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
option(${PROJECT_NAME}_VERBOSE_OUTPUT "启用详细输出，以便更好地理解所采取的每个步骤." ON)
option(${PROJECT_NAME}_GENERATE_EXPORT_HEADER "创建一个包含所有导出符号的' project_export.h '文件." OFF)

# 在构建共享库时导出所有符号
if(BUILD_SHARED_LIBS)
  set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS OFF)
  set(CMAKE_CXX_VISIBILITY_PRESET hidden)
  set(CMAKE_VISIBILITY_INLINES_HIDDEN 1)
endif()

option(${PROJECT_NAME}_ENABLE_LTO "启用程序间优化，即链接时间优化(LTO)." ON)
if(${PROJECT_NAME}_ENABLE_LTO)
  include(CheckIPOSupported)
  check_ipo_supported(RESULT result OUTPUT output)
  if(result)
    set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)
    message(STATUS "启用程序间优化，即链接时间优化(LTO).")
  else()
    message(SEND_ERROR "不支持IPO: ${output}.")
  endif()
endif()


option(${PROJECT_NAME}_ENABLE_CCACHE "启用Ccache,以加快rebuild时间." OFF)
find_program(CCACHE_FOUND ccache)
if(CCACHE_FOUND)
  set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE ccache)
  set_property(GLOBAL PROPERTY RULE_LAUNCH_LINK ccache)
endif()

option(${PROJECT_NAME}_ENABLE_ASAN "启用地址清除功能以检测内存错误." OFF)
if(${PROJECT_NAME}_ENABLE_ASAN)
    add_compile_options(-fsanitize=address)
    add_link_options(-fsanitize=address)
    message("启用地址清除功能以检测内存错误.")
# else()
    # message("启用地址清除功能失败.")
endif()

