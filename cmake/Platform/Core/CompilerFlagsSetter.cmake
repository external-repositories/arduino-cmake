# ToDo: Comment
function(set_board_compiler_flags COMPILER_FLAGS BOARD_ID IS_MANUAL)

    set(COMPILE_FLAGS "-DF_CPU=${${BOARD_ID}.build.f_cpu}
    -DARDUINO=${ARDUINO_VERSION_DEFINE} -mmcu=${${BOARD_ID}.build.mcu}")
    if (DEFINED ${BOARD_ID}.build.vid)
        set(COMPILE_FLAGS "${COMPILE_FLAGS} -DUSB_VID=${${BOARD_ID}.build.vid}")
    endif ()
    if (DEFINED ${BOARD_ID}.build.pid)
        set(COMPILE_FLAGS "${COMPILE_FLAGS} -DUSB_PID=${${BOARD_ID}.build.pid}")
    endif ()
    if (NOT MANUAL)
        set(COMPILE_FLAGS "${COMPILE_FLAGS}
        -I\"${${BOARD_CORE}.path}\" -I\"${ARDUINO_LIBRARIES_PATH}\"")
        if (${ARDUINO_PLATFORM_LIBRARIES_PATH})
            set(COMPILE_FLAGS "${COMPILE_FLAGS} -I\"${ARDUINO_PLATFORM_LIBRARIES_PATH}\"")
        endif ()
    endif ()
    if (ARDUINO_SDK_VERSION VERSION_GREATER 1.0 OR ARDUINO_SDK_VERSION VERSION_EQUAL 1.0)
        if (NOT MANUAL)
            set(PIN_HEADER ${${${BOARD_ID}.build.variant}.path})
            if (PIN_HEADER)
                set(COMPILE_FLAGS "${COMPILE_FLAGS} -I\"${PIN_HEADER}\"")
            endif ()
        endif ()
    endif ()

    set(${COMPILER_FLAGS} "${COMPILE_FLAGS}" PARENT_SCOPE)

endfunction()