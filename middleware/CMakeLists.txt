# Top level CMake for building the libj1939 library and unit tests
# ----------------------------------------------- Set the minimum CMake version
cmake_minimum_required(VERSION 3.7)


# -------------------------------------------------------- Set the project type
project(middleware LANGUAGES C CXX ASM)

message(STATUS "CMAKE_SYSTEM_PROCESSOR: " ${CMAKE_SYSTEM_PROCESSOR})
message(STATUS "CMAKE_SYSTEM_NAME: " ${CMAKE_SYSTEM_NAME})


# ----------------------------------------------------- C/C++ Language standard
# C++ language standard
option(BUILD_CXX14 "Build for C++14" OFF)
if(BUILD_CXX14)
    include(CheckCXXCompilerFlag)
    CHECK_CXX_COMPILER_FLAG("-std=c++14" COMPILER_SUPPORTS_CXX14)
    CHECK_CXX_COMPILER_FLAG("-std=c++1y" COMPILER_SUPPORTS_CXX1Y)
    if(COMPILER_SUPPORTS_CXX14)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++14")
        message(STATUS "Enabled C++14 support")
    elseif(COMPILER_SUPPORTS_CXX1Y)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++1y")
        message(STATUS "Enabled C++1y support")
    else()
        message(FATAL_ERROR "The compiler ${CMAKE_CXX_COMPILER} does not have C++14 support!")
    endif()
else()
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++03")
    message(STATUS "Enabled C++03 support")
endif()

# C language standard
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c99")
message(STATUS "Enabled C99 support")


# ---------------------------------------------------------- Optimization flags
# Do NOT set CMAKE_BUILD_TYPE, otherwise CMake will add in its own optimization
# flags, which will default to -O3 optimization
add_compile_options(-Os)

# Enable debug symbols
add_compile_options(-g3 -ggdb)

# Enable warnings
add_compile_options(-Wall)

# Separate data / function sections, garbage collect unused ones during linking
add_compile_options(-ffunction-sections -fdata-sections)
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Xlinker --gc-sections")

# Test coverage flags
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -ftest-coverage -fprofile-arcs")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -lgcov")


# ------------------------------------------------------------ Aliases
set(SENSOR_TILE_DIR ${CMAKE_SOURCE_DIR}/STSW-STLKT01_V1.3.1)
set(DRIVER_DIR      ${SENSOR_TILE_DIR}/Drivers)
set(MIDDLEWARE_DIR  ${SENSOR_TILE_DIR}/Middlewares)
set(APPLICATION_DIR ${SENSOR_TILE_DIR}/Projects/SensorTile/Applications/BLE_SampleApp/)


# ------------------------------------------------------------ Get files
# file(GLOB_RECURSE SRC_FILES
#     ${MIDDLEWARE_DIR}/ST/STM32_USB_Device_Library/*.c
# )
file(GLOB_RECURSE SRC_FILES
    ${MIDDLEWARE_DIR}/ST/*.c
)

foreach(item ${SRC_FILES})
    if(${item} MATCHES ".*template.c")
            message(STATUS "excluding for STM32F405: ${item}")
            list(REMOVE_ITEM SRC_FILES ${item})
    endif()
    if(${item} MATCHES "bluenrg_utils_small.c")
            message(STATUS "excluding for STM32F405: ${item}")
            list(REMOVE_ITEM SRC_FILES ${item})
    endif()
    if(${item} MATCHES "hci_dma_lp.c")
            message(STATUS "excluding for STM32F405: ${item}")
            list(REMOVE_ITEM SRC_FILES ${item})
    endif()
endforeach()

#----------------------------------------------------- Define the build target
add_library(${PROJECT_NAME} STATIC ${SRC_FILES})

# ----------------------------------------------------------- Set include paths
target_include_directories(${PROJECT_NAME}
    PUBLIC ${DRIVER_DIR}/CMSIS/Include
    PUBLIC ${DRIVER_DIR}/CMSIS/Device/ST/STM32L4xx/Include
    PUBLIC ${DRIVER_DIR}/STM32L4xx_HAL_Driver/Inc
    PUBLIC ${DRIVER_DIR}/BSP/Components/Common
    PUBLIC ${DRIVER_DIR}/BSP/Components/hts221
    PUBLIC ${DRIVER_DIR}/BSP/Components/lps22hb
    PUBLIC ${DRIVER_DIR}/BSP/Components/lsm303agr
    PUBLIC ${DRIVER_DIR}/BSP/Components/lsm6dsm
    PUBLIC ${DRIVER_DIR}/BSP/Components/pcm1774
    PUBLIC ${DRIVER_DIR}/BSP/Components/stc3115
    PUBLIC ${DRIVER_DIR}/BSP/SensorTile
    PUBLIC ${MIDDLEWARE_DIR}/ST/STM32_BlueNRG/Interface
    PUBLIC ${MIDDLEWARE_DIR}/ST/STM32_BlueNRG/SimpleBlueNRG_HCI/includes
    PUBLIC ${MIDDLEWARE_DIR}/ST/STM32_USB_Device_Library/Core/Inc
    PUBLIC ${MIDDLEWARE_DIR}/ST/STM32_USB_Device_Library/Class/AUDIO/Inc
    PUBLIC ${MIDDLEWARE_DIR}/ST/STM32_USB_Device_Library/Class/CDC/Inc
)


target_include_directories(${PROJECT_NAME}
    PUBLIC ${APPLICATION_DIR}/Inc
)

