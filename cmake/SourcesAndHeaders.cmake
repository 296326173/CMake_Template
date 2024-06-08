# set(sources
#     src/project/tmp.cpp
# )

# for each "example/x.cpp", generate target "x"
# file(GLOB_RECURSE all_examples *.cpp)
# foreach(v ${all_examples})
#     string(REGEX MATCH "example/.*" relative_path ${v})
#     # message(${relative_path})
#     string(REGEX REPLACE "example/" "" target_name ${relative_path})
#     string(REGEX REPLACE ".cpp" "" target_name ${target_name})

#     add_executable(${target_name} ${v})
# endforeach()
# 

file(GLOB_RECURSE sources src/project/*.cpp)

set(exe_sources
		# src/main.cpp
    main.cpp
	${sources}
)

file(GLOB_RECURSE headers include/project/*.hpp)

# set(headers1
#     include/project/tmp.hpp
#     include/project/Core/core.hpp
# )

file(GLOB_RECURSE test_sources test/src/*.cpp)

# 正则表达式过滤，只显示test/src/*.cpp
# set(test_sources
#   src/tmp_test.cpp
# )
