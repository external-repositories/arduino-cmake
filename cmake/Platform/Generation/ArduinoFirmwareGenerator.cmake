#=============================================================================#
# GENERATE_ARDUINO_FIRMWARE
# [PUBLIC/USER]
# see documentation at README
#=============================================================================#
function(GENERATE_ARDUINO_FIRMWARE INPUT_NAME)
    message(STATUS "Generating ${INPUT_NAME}")
    parse_generator_arguments(${INPUT_NAME} INPUT
            "NO_AUTOLIBS;MANUAL"                     # Options
            "BOARD;BOARD_CPU;PORT;SKETCH;PROGRAMMER" # One Value Keywords
            "SERIAL;SRCS;HDRS;LIBS;ARDLIBS;AFLAGS"   # Multi Value Keywords
            ${ARGN})

    if (NOT INPUT_BOARD)
        set(INPUT_BOARD ${ARDUINO_DEFAULT_BOARD})
    endif ()
    if (NOT INPUT_PORT)
        set(INPUT_PORT ${ARDUINO_DEFAULT_PORT})
    endif ()
    if (NOT INPUT_SERIAL)
        set(INPUT_SERIAL ${ARDUINO_DEFAULT_SERIAL})
    endif ()
    if (NOT INPUT_PROGRAMMER)
        set(INPUT_PROGRAMMER ${ARDUINO_DEFAULT_PROGRAMMER})
    endif ()
    if (NOT INPUT_MANUAL)
        set(INPUT_MANUAL FALSE)
    endif ()
    VALIDATE_VARIABLES_NOT_EMPTY(VARS INPUT_BOARD MSG "must define for target ${INPUT_NAME}")

    _get_board_id(${INPUT_BOARD} "${INPUT_BOARD_CPU}" ${INPUT_NAME} BOARD_ID)

    set(ALL_LIBS)
    set(ALL_SRCS ${INPUT_SRCS} ${INPUT_HDRS})
    set(SKETCH_INCLUDES)

    if (NOT INPUT_MANUAL)
        make_core_library(CORE_LIB ${BOARD_ID})
    endif ()

    if (NOT "${INPUT_SKETCH}" STREQUAL "")
        get_filename_component(INPUT_SKETCH "${INPUT_SKETCH}" ABSOLUTE)
        make_arduino_sketch(${INPUT_NAME} ${INPUT_SKETCH} ALL_SRCS)
        if (IS_DIRECTORY "${INPUT_SKETCH}")
            set(SKETCH_INCLUDES "${SKETCH_INCLUDES} \"${INPUT_SKETCH}\"")
        else ()
            get_filename_component(INPUT_SKETCH_PATH "${INPUT_SKETCH}" PATH)
            set(SKETCH_INCLUDES "${SKETCH_INCLUDES} \"${INPUT_SKETCH_PATH}\"")
        endif ()
    endif ()

    VALIDATE_VARIABLES_NOT_EMPTY(VARS ALL_SRCS MSG "must define SRCS or SKETCH for target ${INPUT_NAME}")

    find_arduino_libraries(LIB_NAMES LIB_PATHS "${ALL_SRCS}" "${INPUT_ARDLIBS}")

    list(APPEND LIB_PATHS ${SKETCH_INCLUDES})

    if (NOT INPUT_NO_AUTOLIBS)
        make_arduino_libraries(ALL_LIBS ${BOARD_ID} "${LIB_NAMES}" "${LIB_PATHS}")
    endif ()

    list(APPEND ALL_LIBS ${CORE_LIB} ${INPUT_LIBS})

    message("**** all libs: ${ALL_LIBS}")
    message("**** all srcs: ${ALL_SRCS}")
    message("**** arduino include paths: ${LIB_PATHS}")


    create_arduino_firmware_target(${INPUT_NAME} ${BOARD_ID} "${ALL_SRCS}" "${ALL_LIBS}" "${LIB_PATHS}" "${INPUT_MANUAL}")

    if (INPUT_PORT)
        create_arduino_upload_target(${BOARD_ID} ${INPUT_NAME} ${INPUT_PORT} "${INPUT_PROGRAMMER}" "${INPUT_AFLAGS}")
    endif ()

    if (INPUT_SERIAL)
        create_serial_target(${INPUT_NAME} "${INPUT_SERIAL}" "${INPUT_PORT}")
    endif ()

endfunction()