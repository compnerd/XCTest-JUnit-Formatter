
add_library(JUnitFormatter
  JUnitFormatter.swift)
target_link_libraries(JUnitFormatter PRIVATE
  Foundation
  XCTest)

get_swift_host_arch(swift_arch)
install(TARGETS JUnitFormatter
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
install(FILES
  ${CMAKE_CURRENT_BINARY_DIR}/JUnitFormatter.swiftdoc
  ${CMAKE_CURRENT_BINARY_DIR}/JUnitFormatter.swiftmodule
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/swift$<$<NOT:$<BOOL:${BUILD_SHARED_LIBS}>>:_static>/$<LOWER_CASE:${CMAKE_SYSTEM_NAME}>/${swift_arch})


