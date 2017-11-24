#=============================================================================#
# find_arduino_libraries
# [PRIVATE/INTERNAL]
#
# find_arduino_libraries(VAR_NAME SRCS ARDLIBS)
#
#      OUTPUT_LIB_NAMES - Variable name which will hold the list of found libraries names
#      OUTPUT_LIB_PATHS - Variable name which will hold the list of found libraries paths
#      SRCS     - Sources that will be analized
#      ARDLIBS  - Arduino libraries identified by name (e.g., Wire, SPI, Servo)
#
#     returns a list of paths to libraries found.
#
#  Finds all Arduino type libraries included in sources. Available libraries
#  are ${ARDUINO_SDK_PATH}/libraries and ${CMAKE_CURRENT_SOURCE_DIR}.
#
#  Also adds Arduino libraries specifically names in ALIBS.  We add ".h" to the
#  names and then process them just like the Arduino libraries found in the sources.
#
#  A Arduino library is a folder that has the same name as the include header.
#  For example, if we have a include "#include <LibraryName.h>" then the following
#  directory structure is considered a Arduino library:
#
#     LibraryName/
#          |- LibraryName.h
#          `- LibraryName.c
#
#  If such a directory is found then all sources within that directory are considred
#  to be part of that Arduino library.
#
#=============================================================================#
function(find_arduino_libraries OUTPUT_LIBS_NAME OUTPUT_LIBS_PATH SRCS ARDLIBS)
    set(ARDUINO_LIBS_PATH)
    set(ARDUINO_LIBS_NAME)

    message("*** find_arduino_libraries")
    if (ARDLIBS) # Libraries are known in advance, just find their absoltue paths

        foreach (LIB ${ARDLIBS})
            get_property(LIBRARY_SEARCH_PATH
                    DIRECTORY     # Property Scope
                    PROPERTY LINK_DIRECTORIES)

            foreach (LIB_SEARCH_PATH ${LIBRARY_SEARCH_PATH}
                    ${ARDUINO_LIBRARIES_PATH}
                    ${ARDUINO_PLATFORM_LIBRARIES_PATH} ${CMAKE_CURRENT_SOURCE_DIR}
                    ${CMAKE_CURRENT_SOURCE_DIR}/libraries)

                if (EXISTS ${LIB_SEARCH_PATH}/${LIB}/${LIB}.h)
                    list(APPEND ARDUINO_LIBS_PATH ${LIB_SEARCH_PATH}/${LIB})
                    list(APPEND ARDUINO_LIBS_NAME ${LIB})
                    break()
                endif ()
                if (EXISTS ${LIB_SEARCH_PATH}/${LIB}.h)
                    list(APPEND ARDUINO_LIBS_PATH ${LIB_SEARCH_PATH})
                    list(APPEND ARDUINO_LIBS_NAME ${LIB})
                    break()
                endif ()

                # Some libraries like Wire and SPI require building from source
                if (EXISTS ${LIB_SEARCH_PATH}/${LIB}/src/${LIB}.h)
                    list(APPEND ARDUINO_LIBS_PATH ${LIB_SEARCH_PATH}/${LIB}/src)
                    list(APPEND ARDUINO_LIBS_NAME ${LIB})
                    break()
                endif ()
                if (EXISTS ${LIB_SEARCH_PATH}/src/${LIB}.h)
                    list(APPEND ARDUINO_LIBS_PATH ${LIB_SEARCH_PATH}/src)
                    list(APPEND ARDUINO_LIBS_NAME ${LIB})
                    break()
                endif ()

            endforeach ()
        endforeach ()

    else ()
        message("*** find from souce")

        foreach (SRC ${SRCS})

            # Skipping generated files. They are, probably, not exist yet.
            # TODO: Maybe it's possible to skip only really nonexisting files,
            # but then it wiil be less deterministic.
            get_source_file_property(_srcfile_generated ${SRC} GENERATED)
            # Workaround for sketches, which are marked as generated
            get_source_file_property(_sketch_generated ${SRC} GENERATED_SKETCH)

            if (NOT ${_srcfile_generated} OR ${_sketch_generated})
                if (NOT (EXISTS ${SRC} OR
                        EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${SRC} OR
                        EXISTS ${CMAKE_CURRENT_BINARY_DIR}/${SRC}))
                    message(FATAL_ERROR "Invalid source file: ${SRC}")
                endif ()
                file(STRINGS ${SRC} SRC_CONTENTS)

                foreach (LIBNAME ${ARDLIBS})
                    list(APPEND SRC_CONTENTS "#include <${LIBNAME}.h>")
                endforeach ()

                foreach (SRC_LINE ${SRC_CONTENTS})
                    if ("${SRC_LINE}" MATCHES
                            "^[ \t]*#[ \t]*include[ \t]*[<\"]([^>\"]*)[>\"]")

                        get_filename_component(INCLUDE_NAME ${CMAKE_MATCH_1} NAME_WE)
                        get_property(LIBRARY_SEARCH_PATH
                                DIRECTORY     # Property Scope
                                PROPERTY LINK_DIRECTORIES)
                        foreach (LIB_SEARCH_PATH ${LIBRARY_SEARCH_PATH} ${ARDUINO_LIBRARIES_PATH} ${ARDUINO_PLATFORM_LIBRARIES_PATH} ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/libraries ${ARDUINO_EXTRA_LIBRARIES_PATH})
                            if (EXISTS ${LIB_SEARCH_PATH}/${INCLUDE_NAME}/${CMAKE_MATCH_1})
                                list(APPEND ARDUINO_LIBS_PATH ${LIB_SEARCH_PATH}/${INCLUDE_NAME})
                                list(APPEND ARDUINO_LIBS_NAME ${INCLUDE_NAME})
                                break()
                            endif ()
                            if (EXISTS ${LIB_SEARCH_PATH}/${CMAKE_MATCH_1})
                                list(APPEND ARDUINO_LIBS_PATH ${LIB_SEARCH_PATH})
                                list(APPEND ARDUINO_LIBS_NAME ${CMAKE_MATCH_1})
                                break()
                            endif ()

                            # Some libraries like Wire and SPI require building from source
                            if (EXISTS ${LIB_SEARCH_PATH}/${INCLUDE_NAME}/src/${CMAKE_MATCH_1})
                                list(APPEND ARDUINO_LIBS_PATH ${LIB_SEARCH_PATH}/${INCLUDE_NAME}/src)
                                list(APPEND ARDUINO_LIBS_NAME ${INCLUDE_NAME})
                                break()
                            endif ()
                            if (EXISTS ${LIB_SEARCH_PATH}/src/${CMAKE_MATCH_1})
                                list(APPEND ARDUINO_LIBS_PATH ${LIB_SEARCH_PATH}/src)
                                list(APPEND ARDUINO_LIBS_NAME ${CMAKE_MATCH_1})
                                break()
                            endif ()
                        endforeach ()

                    endif ()
                endforeach ()

            endif ()
        endforeach ()

    endif ()

    if (ARDUINO_LIBS_PATH)
        list(REMOVE_DUPLICATES ARDUINO_LIBS_PATH)
    endif ()
    if (ARDUINO_LIBS_NAME)
        list(REMOVE_DUPLICATES ARDUINO_LIBS_NAME)
    endif()

    message("*** names: ${ARDUINO_LIBS_NAME}")
    message("*** paths: ${ARDUINO_LIBS_PATH}")

    set(${OUTPUT_LIBS_PATH} ${ARDUINO_LIBS_PATH} PARENT_SCOPE)
    set(${OUTPUT_LIBS_NAME} ${ARDUINO_LIBS_NAME} PARENT_SCOPE)
endfunction()
