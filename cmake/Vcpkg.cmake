
if(${PROJECT_NAME}_ENABLE_VCPKG)
  #
  # 如果 `vcpkg.cmake` (from https://github.com/microsoft/vcpkg) 不存在, 下载他.
  #
  if(NOT EXISTS "${CMAKE_BINARY_DIR}/vcpkg.cmake")
    message(
    STATUS
        "从 https://github.com/microsoft/vcpkg 下载 `vcpkg.cmake`..."
    )
    file(DOWNLOAD "https://github.com/microsoft/vcpkg/raw/master/scripts/buildsystems/vcpkg.cmake"
    "${CMAKE_BINARY_DIR}/vcpkg.cmake"
    )
    message(STATUS "Vcpkg config下载成功.")
  endif()

	if(${PROJECT_NAME}_VERBOSE_OUTPUT)
		set(VCPKG_VERBOSE ON)
	endif()
	set(CMAKE_TOOLCHAIN_FILE "${CMAKE_TOOLCHAIN_FILE}" "${CMAKE_BINARY_DIR}/vcpkg.cmake")
  message(STATUS "启用Vcpkg.")
endif()
