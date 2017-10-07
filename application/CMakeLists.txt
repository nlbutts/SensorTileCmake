# ------------------------------------------------------- MINIMUM CMAKE VERSION
cmake_minimum_required(VERSION 3.4)


# ---------------------------------------------------------- ONLY BUILD FOR ARM
if(NOT ${CMAKE_SYSTEM_PROCESSOR} MATCHES arm_baremetal)
    message(FATAL_ERROR "Application can only be built for arm_baremetal!")
endif()


# --------------------------------------------------------------- PROJECT NAMES
set(THIS_RELEASE application.elf)
set(THIS_DEBUG application_debug.elf)

# ------------------------------------------------------------ Aliases
set(SENSOR_TILE_DIR ${CMAKE_SOURCE_DIR}/STSW-STLKT01_V1.3.1)
set(DRIVER_DIR      ${SENSOR_TILE_DIR}/Drivers)
set(MIDDLEWARE_DIR  ${SENSOR_TILE_DIR}/Middlewares)
set(APPLICATION_DIR ${SENSOR_TILE_DIR}/Projects/SensorTile/Applications/BLE_SampleApp/)

# -------------------------------------------------------------- FIND SRC FILES
file(GLOB_RECURSE SRC_FILES
    ${APPLICATION_DIR}/Src/*.c
    ${APPLICATION_DIR}/SW4STM32/*.S
)

message(${SRC_FILES})

# --------------------------------------------------------- DEFINE BUILD TARGET
set(THIS_LINK_LIBS drivers middleware)
add_executable(${THIS_RELEASE} ${SRC_FILES})
target_link_libraries(${THIS_RELEASE} ${THIS_LINK_LIBS})

add_executable(${THIS_DEBUG} ${SRC_FILES})
target_link_libraries(${THIS_DEBUG} ${THIS_LINK_LIBS})


# ------------------------------------------------------------- INCLUDE FOLDERS
target_include_directories(${THIS_RELEASE}
    PRIVATE ${APPLICATION_DIR}/Inc
)

target_include_directories(${THIS_DEBUG}
    PRIVATE ${APPLICATION_DIR}/Inc
)


# ----------------------------------------------------------- SET LINKER SCRIPT
set(LDSCRIPTS_PATH ${APPLICATION_DIR}/SW4STM32/STM32L4xx-SensorTile/)

target_link_libraries(${THIS_RELEASE}
    "-T ${LDSCRIPTS_PATH}/LinkerScript.ld -L${LDSCRIPTS_PATH}"
)

target_link_libraries(${THIS_DEBUG}
    "-T ${LDSCRIPTS_PATH}/LinkerScript.ld -L${LDSCRIPTS_PATH}"
)


# ---------------------------------------------------------------- SET MAP FILE
target_link_libraries(${THIS_RELEASE}
    "-Xlinker -Map=${CMAKE_CURRENT_BINARY_DIR}/${THIS_RELEASE}.map"
)

target_link_libraries(${THIS_DEBUG}
    "-Xlinker -Map=${CMAKE_CURRENT_BINARY_DIR}/${THIS_DEBUG}.map"
)


# ----------------------------------------------------- ADD VERSION INFORMATION
set_property(
    SOURCE ${CMAKE_CURRENT_LIST_DIR}/src/appareo/application/FirmwareVersion.cpp
    APPEND PROPERTY COMPILE_DEFINITIONS
        SMART_NOZZLE_APP_PN=\"${SMART_NOZZLE_APP_PN}\"
        SMART_NOZZLE_BUILD_VERSION=\"${SMART_NOZZLE_BUILD_VERSION}\"
        SMART_NOZZLE_BUILD_DATE=\"${SMART_NOZZLE_BUILD_DATE}\"
        SMART_NOZZLE_VCS_HASH=\"${SMART_NOZZLE_VCS_HASH}\"
)


# -------------------------------------------------------------- INSTALL TARGET
# The buildserver.sh script (and Jenkins) will depend on these files

set(INSTALL_BASENAME "application-${SMART_NOZZLE_APP_PN}-${SMART_NOZZLE_BUILD_VERSION}")

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${THIS_RELEASE}
        RENAME ${INSTALL_BASENAME}.elf
        DESTINATION ./
)
