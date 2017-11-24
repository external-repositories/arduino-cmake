#=============================================================================#
# GENERATE_ARDUINO_LIBRARY
# [PUBLIC/USER]
# see documentation at README
#=============================================================================#
function(GENERATE_ARDUINO_LIBRARY INPUT_NAME)
    message(STATUS "Generating ${INPUT_NAME}")
    parse_generator_arguments(${INPUT_NAME} INPUT
            "NO_AUTOLIBS;MANUAL"                  # Options
            "BOARD;BOARD_CPU"                     # One Value Keywords
            "SRCS;HDRS;LIBS"                      # Multi Value Keywords
            ${ARGN})

    if (NOT INPUT_BOARD)
        set(INPUT_BOARD ${ARDUINO_DEFAULT_BOARD})
    endif ()
    if (NOT INPUT_MANUAL)
        set(INPUT_MANUAL FALSE)
    endif ()
    VALIDATE_VARIABLES_NOT_EMPTY(VARS INPUT_SRCS INPUT_BOARD MSG "must define for target ${INPUT_NAME}")

    _get_board_id(${INPUT_BOARD} "${INPUT_BOARD_CPU}" ${INPUT_NAME} BOARD_ID)

    set(ALL_LIBS)
    set(ALL_SRCS ${INPUT_SRCS} ${INPUT_HDRS})

    if (NOT INPUT_MANUAL)
        make_core_library(CORE_LIB ${BOARD_ID})
    endif ()

    find_arduino_libraries(LIB_NAMES TARGET_LIBS "${ALL_SRCS}" "")

    if (NOT ${INPUT_NO_AUTOLIBS})
        make_arduino_libraries(ALL_LIBS ${BOARD_ID} "" "${TARGET_LIBS}")
    endif ()

    list(APPEND ALL_LIBS ${CORE_LIB} ${INPUT_LIBS})

    add_library(${INPUT_NAME} ${ALL_SRCS})

    _set_board_compile_flags(${INPUT_NAME} ${BOARD_ID} ${TARGET_LIBS} ${INPUT_MANUAL})
    _set_board_link_flags(${INPUT_NAME} ${BOARD_ID} ${ALL_LIBS} "-lc -lm")
endfunction()
