#=============================================================================#
# find_sources
# [PRIVATE/INTERNAL]
#
# find_sources(VAR_NAME LIB_PATH RECURSE)
#
#        VAR_NAME - Variable name that will hold the detected sources
#        LIB_PATH - The base path
#        RECURSE  - Whether or not to recurse
#
# Finds all C/C++ sources located at the specified path.
#
#=============================================================================#
function(find_sources VAR_NAME LIB_PATH RECURSE)
    set(FILE_SEARCH_LIST
            ${LIB_PATH}/*.c
            ${LIB_PATH}/*.cc
            ${LIB_PATH}/*.cpp
            ${LIB_PATH}/*.cxx)

    if (RECURSE)
        file(GLOB_RECURSE SOURCE_FILES ${FILE_SEARCH_LIST})
        file(GLOB_RECURSE S_FILE "${LIB_PATH}/*.[sS]")
    else ()
        file(GLOB SOURCE_FILES ${FILE_SEARCH_LIST})
        file(GLOB S_FILE "${LIB_PATH}/*.[sS]")
    endif ()
    if (S_FILE)
        set_source_files_properties(${S_FILE} PROPERTIES
                LANGUAGE C
                COMPILE_FLAGS "-x assembler-with-cpp")
        list(INSERT SOURCE_FILES 0 ${S_FILE})
    endif()

    if (SOURCE_FILES)
        set(${VAR_NAME} ${SOURCE_FILES} PARENT_SCOPE)
    endif ()
endfunction()
