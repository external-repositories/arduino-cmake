# ToDo: Comment
function(_get_board_compile_defines DEFINES BOARD_ID)
    _get_arduino_version_define(ARDUINO_VERSION_DEFINE)
    _get_board_property(${BOARD_ID} build.f_cpu FCPU)

    set(FLAGS F_CPU=${FCPU} ARDUINO=${ARDUINO_VERSION_DEFINE})

    _get_board_property_if_exists(${BOARD_ID} build.vid VID)
    _get_board_property_if_exists(${BOARD_ID} build.pid PID)
    if (VID)
        list(APPEND FLAGS USB_VID=${VID})
    endif ()
    if (PID)
        list(APPEND FLAGS USB_PID=${PID})
    endif ()

    set(${DEFINES} "${FLAGS}" PARENT_SCOPE)

endfunction()





# ToDo: Comment
function(_get_board_compile_options OPTIONS BOARD_ID)
    _get_board_property(${BOARD_ID} build.mcu MCU)
    set(${OPTIONS} -mmcu=${MCU} PARENT_SCOPE)

endfunction()

# ToDo: Comment
function(_get_board_compile_includes INCLUDES BOARD_ID)
    _get_board_property(${BOARD_ID} build.core BOARD_CORE)
        #todo probabaly we shouldn't include libraries path by default
    set(ALL_INCLUDES ${${BOARD_CORE}.path}
            #${ARDUINO_LIBRARIES_PATH}
            )

    if (${ARDUINO_PLATFORM_LIBRARIES_PATH})
        #list(APPEND ALL_INCLUDES ${ARDUINO_PLATFORM_LIBRARIES_PATH})
    endif ()
    if (ARDUINO_SDK_VERSION VERSION_GREATER 1.0 OR ARDUINO_SDK_VERSION VERSION_EQUAL 1.0)
        _get_board_property(${BOARD_ID} build.variant VARIANT)
        set(PIN_HEADER ${${VARIANT}.path})
        if (PIN_HEADER)
            list(APPEND ALL_INCLUDES ${PIN_HEADER})
        endif ()
    endif ()

    set(${INCLUDES} ${ALL_INCLUDES} PARENT_SCOPE)

endfunction()
