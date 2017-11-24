#=============================================================================#
# make_arduino_library
# [PRIVATE/INTERNAL]
#
# make_arduino_library(OUTPUT_TARGET BOARD_ID LIB_NAME LIB_PATH)
#
#        OUTPUT_TARGET    - Vairable wich will hold the generated library names
#        BOARD_ID    - Board ID
#        LIB_NAME    - library name
#        LIB_PATH - library path
#
# Creates an Arduino library, with all it's library dependencies.
#
#      ${LIB_NAME}_RECURSE controls if the library will recurse
#      when looking for source files.
#
#=============================================================================#
function(make_arduino_library2 OUTPUT_TARGET BOARD_ID LIB_NAME LIB_PATH)

    set(TARGET_LIB_NAME ${BOARD_ID}_${LIB_NAME})

    if (NOT TARGET ${TARGET_LIB_NAME})

        # Detect if recursion is needed
        if (NOT DEFINED ${LIB_NAME}_RECURSE)
            set(${LIB_NAME}_RECURSE False)
        endif ()

        find_sources(LIB_SRCS ${LIB_PATH} ${${LIB_NAME}_RECURSE})
        if (LIB_SRCS)

            arduino_debug_msg("Generating Arduino ${LIB_NAME} library")
            add_library(${TARGET_LIB_NAME} STATIC ${LIB_SRCS})

            find_arduino_libraries(LIB_NAMES LIB_PATHS "${LIB_SRCS}" "")

            foreach (LIB_DEP ${LIB_PATHS})
                make_arduino_library(DEP_LIB_SRCS ${BOARD_ID} ${LIB_DEP} "${INCLUDE_PATHS}")
                list(APPEND LIB_TARGETS ${DEP_LIB_SRCS})
                list(APPEND LIB_INCLUDES ${DEP_LIB_SRCS_INCLUDES})
            endforeach ()

            if (LIB_INCLUDES)
                string(REPLACE ";" " " LIB_INCLUDES "${LIB_INCLUDES}")
            endif ()
            list(APPEND INCLUDE_PATHS ${LIB_INCLUDES})
            if (LIB_TARGETS)
                list(REMOVE_ITEM LIB_TARGETS ${TARGET_LIB_NAME})
            endif ()

            _set_board_compile_flags(${TARGET_LIB_NAME} ${BOARD_ID} "${INCLUDE_PATHS}" FALSE)
            _set_board_link_flags(${TARGET_LIB_NAME} ${BOARD_ID} ${BOARD_ID}_CORE ${LIB_TARGETS})

            list(APPEND LIB_TARGETS ${TARGET_LIB_NAME})

        endif ()
    endif ()

    set(${OUTPUT_TARGET} ${TARGET_LIB_NAME} PARENT_SCOPE)

endfunction()












#=============================================================================#
# make_arduino_library
# [PRIVATE/INTERNAL]
#
# make_arduino_library(VAR_NAME BOARD_ID LIB_PATH INCLUDE_PATHS)
#
#        VAR_NAME    - Vairable wich will hold the generated library names
#        BOARD_ID    - Board ID
#        LIB_PATH    - Path of the library
#        INCLUDE_PATHS - list of include paths
#
# Creates an Arduino library, with all it's library dependencies.
#
#      ${LIB_NAME}_RECURSE controls if the library will recurse
#      when looking for source files.
#
#=============================================================================#
function(make_arduino_library VAR_NAME BOARD_ID LIB_PATH INCLUDE_PATHS)

    string(REGEX REPLACE "/src/?$" "" LIB_PATH_STRIPPED ${LIB_PATH})
    get_filename_component(LIB_NAME ${LIB_PATH_STRIPPED} NAME)
    set(TARGET_LIB_NAME ${BOARD_ID}_${LIB_NAME})

    if (NOT TARGET ${TARGET_LIB_NAME})
        string(REGEX REPLACE ".*/" "" LIB_SHORT_NAME ${LIB_NAME})

        # Detect if recursion is needed
        if (NOT DEFINED ${LIB_SHORT_NAME}_RECURSE)
            set(${LIB_SHORT_NAME}_RECURSE False)
        endif ()

        find_sources(LIB_SRCS ${LIB_PATH} ${${LIB_SHORT_NAME}_RECURSE})
        if (LIB_SRCS)

            arduino_debug_msg("Generating Arduino ${LIB_NAME} library")
            add_library(${TARGET_LIB_NAME} STATIC ${LIB_SRCS})

            find_arduino_libraries(LIB_NAMES LIB_PATHS "${LIB_SRCS}" "")

            foreach (LIB_DEP ${LIB_PATHS})
                make_arduino_library(DEP_LIB_SRCS ${BOARD_ID} ${LIB_DEP} "${INCLUDE_PATHS}")
                list(APPEND LIB_TARGETS ${DEP_LIB_SRCS})
                list(APPEND LIB_INCLUDES ${DEP_LIB_SRCS_INCLUDES})
            endforeach ()

            if (LIB_INCLUDES)
                string(REPLACE ";" " " LIB_INCLUDES "${LIB_INCLUDES}")
            endif ()
            list(APPEND INCLUDE_PATHS ${LIB_INCLUDES})
            if (LIB_TARGETS)
                list(REMOVE_ITEM LIB_TARGETS ${TARGET_LIB_NAME})
            endif ()

            _set_board_compile_flags(${TARGET_LIB_NAME} ${BOARD_ID} "${INCLUDE_PATHS}" FALSE)
            _set_board_link_flags(${TARGET_LIB_NAME} ${BOARD_ID} ${BOARD_ID}_CORE ${LIB_TARGETS})

            list(APPEND LIB_TARGETS ${TARGET_LIB_NAME})

        endif ()
    else ()
        # Target already exists, skiping creating
        list(APPEND LIB_TARGETS ${TARGET_LIB_NAME})
    endif ()
    if (LIB_TARGETS)
        list(REMOVE_DUPLICATES LIB_TARGETS)
    endif ()
    set(${VAR_NAME} ${LIB_TARGETS} PARENT_SCOPE)
    set(${VAR_NAME}_INCLUDES ${LIB_INCLUDES} PARENT_SCOPE)

    message("***3 find libraries: ${LIB_TARGETS}")
    message("***3 find includes: ${LIB_INCLUDES}")

endfunction()

#=============================================================================#
# make_arduino_libraries
# [PRIVATE/INTERNAL]
#
# make_arduino_libraries(VAR_NAME BOARD_ID ARDLIBS INCLUDE_PATHS)
#
#        VAR_NAME    - Vairable wich will hold the generated library names
#        BOARD_ID    - Board ID
#        LIBS_NAME - list of libraries names
#        LIBS_PATH - list of include paths
#
# Finds and creates all dependency libraries based on sources.
#
#=============================================================================#
function(make_arduino_libraries VAR_NAME BOARD_ID LIBS_NAME LIBS_PATH)
    list(LENGTH LIBS_NAME LIBS_COUNT)
    math(EXPR LIBS_LAST_INDEX "${LIBS_COUNT} - 1")
    set(LIB_TARGETS)
    foreach(LIB_INDEX RANGE ${LIBS_LAST_INDEX})
        list(GET LIBS_NAME ${LIB_INDEX} LIB_NAME)
        list(GET LIBS_PATH ${LIB_INDEX} LIB_PATH)
        make_arduino_library2(TARGET ${BOARD_ID} ${LIB_NAME} ${LIB_PATH})
        list(APPEND LIB_TARGETS ${TARGET})
    endforeach()
    set(${VAR_NAME} ${LIB_TARGETS} PARENT_SCOPE)
endfunction()
