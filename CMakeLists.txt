
cmake_minimum_required(VERSION 3.15.1)

list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake/modules)

project(JUnitFormatter
  LANGUAGES Swift
  VERSION 0.1)

include(GNUInstallDirs)
include(SwiftSupport)

if(NOT CMAKE_SYSTEM_NAME STREQUAL Darwin)
  find_package(Foundation CONFIG REQUIRED)
  find_package(XCTest CONFIG REQUIRED)
endif()

add_subdirectory(Source)

