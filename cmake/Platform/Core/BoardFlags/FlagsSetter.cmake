include(CompilerFlagsSetter)
include(LinkerFlagsSetter)

#=============================================================================#
# get_arduino_flags
# [PRIVATE/INTERNAL]
#
# _set_board_compile_flags(TARGET_NAME BOARD_ID INCLUDE_PATHS IS_MANUAL)
#
#       TARGET_NAME - cmake target
#       BOARD_ID - The board id name
#       LINKER_FLAGS - Variable holding linker flags
#       IS_MANUAL - (Advanced) Only use AVR Libc/Includes
#
# Configures the the build settings for the specified Arduino Board.
#
#=============================================================================#

function(_set_board_compile_flags TARGET_NAME BOARD_ID INCLUDE_PATHS IS_MANUAL)
    _get_board_compile_defines(BOARD_COMPILE_DEFINES ${BOARD_ID})
    _get_board_compile_options(BOARD_COMPILE_OPTIONS ${BOARD_ID})
    if (NOT IS_MANUAL)
        _get_board_compile_includes(BOARD_COMPILE_INCLUDES ${BOARD_ID})
    endif()
        message("*** includes ${INCLUDE_PATHS}")
    target_compile_definitions(${TARGET_NAME} PRIVATE ${BOARD_COMPILE_DEFINES})
    target_compile_options(${TARGET_NAME} PRIVATE ${BOARD_COMPILE_OPTIONS})
    target_include_directories(${TARGET_NAME} PRIVATE ${INCLUDE_PATHS} "${BOARD_COMPILE_INCLUDES}")
endfunction()

function(_get_arduino_version_define OUTPUT_VAR)

    if (ARDUINO_SDK_VERSION MATCHES "([0-9]+)[.]([0-9]+)")
        if (ARDUINO_SDK_VERSION VERSION_GREATER 1.5.8)
            # since 1.6.0 -DARDUINO format changed, e.g for 1.6.5 version -DARDUINO=10605
            set(ARDUINO_VERSION_DEFINE "${ARDUINO_SDK_VERSION_MAJOR}0${ARDUINO_SDK_VERSION_MINOR}0${ARDUINO_SDK_VERSION_PATCH}")
        else()
            #before 1.0.0 version use only minor version for define, e.g. for 0020 version -DARDUINO=20
            if (ARDUINO_SDK_VERSION VERSION_LESS 1.0.0)
                set(ARDUINO_VERSION_DEFINE "${ARDUINO_SDK_VERSION_MINOR}")
            else()
                #for 1.0.0 and above format changed, e.g. for 1.5.3 version -DARDUINO=153
                set(ARDUINO_VERSION_DEFINE "${ARDUINO_SDK_VERSION_MAJOR}${ARDUINO_SDK_VERSION_MINOR}${ARDUINO_SDK_VERSION_PATCH}")
            endif()
        endif()
    else ()
        message(WARNING "Invalid Arduino SDK Version (${ARDUINO_SDK_VERSION})")
    endif ()
    set(${OUTPUT_VAR} ${ARDUINO_VERSION_DEFINE} PARENT_SCOPE)

endfunction()
