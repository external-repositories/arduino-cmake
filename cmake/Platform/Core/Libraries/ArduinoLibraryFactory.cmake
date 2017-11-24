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

            find_arduino_libraries(LIB_DEPS "${LIB_SRCS}" "")

            foreach (LIB_DEP ${LIB_DEPS})
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
#        ARDLIBS - list of libraries
#        INCLUDE_PATHS - list of include paths
#
# Finds and creates all dependency libraries based on sources.
#
#=============================================================================#
function(make_arduino_libraries VAR_NAME BOARD_ID ARDLIBS INCLUDE_PATHS)
    foreach (TARGET_LIB ${ARDLIBS})
        # Create static library instead of returning sources
        make_arduino_library(LIB_DEPS ${BOARD_ID} ${TARGET_LIB} "${INCLUDE_PATHS}")

        message("***2 find libraries: ${LIB_DEPS}")
        message("***2 find includes: ${${LIB_DEPS}_INCLUDES}")


        list(APPEND LIB_TARGETS ${LIB_DEPS})
        list(APPEND LIB_INCLUDES ${${LIB_DEPS}_INCLUDES})
    endforeach ()


    set(${VAR_NAME} ${LIB_TARGETS} PARENT_SCOPE)

    message("***1 find libraries: ${LIB_TARGETS}")
    message("***1 find includes: ${LIB_INCLUDES}")


endfunction()
