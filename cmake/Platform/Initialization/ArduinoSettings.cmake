#=============================================================================#
#                         Arduino Settings
#=============================================================================#
# setup_arduino_settings
# [PRIVATE/INTERNAL]
#
# setup_arduino_settings()
#
# Setups some basic flags for the arduino upload tools.
#=============================================================================#
function(setup_arduino_settings)
    set(ARDUINO_OBJCOPY_EEP_FLAGS -O ihex -j .eeprom --set-section-flags=.eeprom=alloc,load
            --no-change-warnings --change-section-lma .eeprom=0 CACHE STRING "")
    set(ARDUINO_OBJCOPY_HEX_FLAGS -O ihex -R .eeprom CACHE STRING "")
    set(ARDUINO_AVRDUDE_FLAGS -V CACHE STRING "")
endfunction()