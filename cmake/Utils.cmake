#
# Print a message only if the `VERBOSE_OUTPUT` option is on
# 仅当' VERBOSE_OUTPUT '选项打开时打印消息
#

function(verbose_message content)
    if(${PROJECT_NAME}_VERBOSE_OUTPUT)
		message(STATUS ${content})
    endif()
endfunction()

#
# 添加一个目标，使用'clang-format'来格式化项目 
# (i.e: cmake --build build --target clang-format)

function(add_clang_format_target)
    if(NOT ${PROJECT_NAME}_CLANG_FORMAT_BINARY)
			find_program(${PROJECT_NAME}_CLANG_FORMAT_BINARY clang-format)
    endif()

    if(${PROJECT_NAME}_CLANG_FORMAT_BINARY)
			if(${PROJECT_NAME}_BUILD_EXECUTABLE)
				add_custom_target(clang-format
						COMMAND ${${PROJECT_NAME}_CLANG_FORMAT_BINARY}
						-i ${exe_sources} ${headers}
						WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})
			elseif(${PROJECT_NAME}_BUILD_HEADERS_ONLY)
				add_custom_target(clang-format
						COMMAND ${${PROJECT_NAME}_CLANG_FORMAT_BINARY}
						-i ${headers}
						WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})
			else()
				add_custom_target(clang-format
						COMMAND ${${PROJECT_NAME}_CLANG_FORMAT_BINARY}
						-i ${sources} ${headers}
						WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})
			endif()

			message(STATUS "使用`clang-format`目标来格式化项目 (i.e: cmake --build build --target clang-format).\n")
    endif()
endfunction()
# 