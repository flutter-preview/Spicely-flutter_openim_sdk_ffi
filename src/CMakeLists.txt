# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(flutter_openim_sdk_ffi_library VERSION 0.0.1 LANGUAGES C)

add_library(flutter_openim_sdk_ffi SHARED
  "flutter_openim_sdk_ffi.c"
)

set_target_properties(flutter_openim_sdk_ffi PROPERTIES
  PUBLIC_HEADER flutter_openim_sdk_ffi.h
  OUTPUT_NAME "flutter_openim_sdk_ffi"
)

target_compile_definitions(flutter_openim_sdk_ffi PUBLIC DART_SHARED_LIB)

# 添加合并操作
add_custom_command(TARGET flutter_openim_sdk_ffi POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy
           "${CMAKE_CURRENT_SOURCE_DIR}/../windows/openim_sdk_ffi.dll"
           $<TARGET_FILE_DIR:flutter_openim_sdk_ffi>
  COMMENT "Copying openim_sdk_ffi.dll to output directory"
)