# CMake configuration for RealTimeCutVADCXXLibrary
# 
# This CMakeLists.txt file appears to be primarily configured for macOS.
# The comment at the bottom of the file indicates macOS-specific setup with
# references to Darwin (macOS core), frameworks like onnxruntime and webrtc_audio_processing,
# and macOS-specific libraries (CoreFoundation, CoreAudio).
#
# For cross-platform compatibility (Windows/Linux):
# - You would need to add platform-specific conditional blocks similar to the macOS one
# - Each platform would need its own library paths, include directories, and linking instructions
# - Windows would require different library names and potentially MSVC-specific flags
# - Linux would need its own package finding mechanisms (likely using pkg-config)
#
# Currently, this file appears to be macOS-focused and would need significant
# modifications to work properly on Windows or Linux platforms.


cmake_minimum_required(VERSION 3.5)
project(RealTimeCutVADCXXLibrary)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

message(STATUS "C++ Compiler: ${CMAKE_CXX_COMPILER}")
message(STATUS "C Compiler: ${CMAKE_C_COMPILER}")

set(MY_CMAKE_PROJECT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/CmakeProject")
set(MY_LIBRARY_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/RealTimeCutVADCXXLibrary")

add_compile_definitions(PROJECT_SOURCE_DIR="${PROJECT_SOURCE_DIR}")
add_compile_definitions(MY_CMAKE_PROJECT_DIR="${MY_CMAKE_PROJECT_DIR}")
add_compile_definitions(MY_LIBRARY_SOURCE_DIR="${MY_LIBRARY_SOURCE_DIR}")

message(STATUS "PROJECT_SOURCE_DIR: ${PROJECT_SOURCE_DIR}")
message(STATUS "MY_CMAKE_PROJECT_DIR: ${MY_CMAKE_PROJECT_DIR}")
message(STATUS "MY_LIBRARY_SOURCE_DIR: ${MY_LIBRARY_SOURCE_DIR}")

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-narrowing")

# install path
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set(CMAKE_INSTALL_PREFIX ${PROJECT_SOURCE_DIR} CACHE PATH "default install path" FORCE)
endif()

file(GLOB_RECURSE SRC "${MY_LIBRARY_SOURCE_DIR}/*.cpp")
file(GLOB_RECURSE INCLUDE "${MY_LIBRARY_SOURCE_DIR}/*.h")

message(STATUS "SRC files: ${SRC}")
message(STATUS "INCLUDE files: ${INCLUDE}")

set(SOURCE_FILES ${SRC})
set(HEADER ${INCLUDE})


# This conditional block checks if the current system is macOS (Darwin is the core Unix-based operating system
# that macOS is built upon). When this condition is true, the following code block will be executed.
# It sets up macOS-specific paths, libraries, and build configurations needed to compile the C++ code
# on macOS systems. This includes setting paths to frameworks like onnxruntime and webrtc_audio_processing,
# finding macOS-specific libraries (CoreFoundation, CoreAudio, etc.), and configuring the build target
# specifically for macOS environments.
# To build on macOS:
# 1. Make sure you have CMake installed (brew install cmake)
# 2. Make sure you have libsndfile installed (brew install libsndfile)
#    libsndfile is a C library for reading and writing files containing sampled audio data.
#    You can check if it's installed by running: brew list libsndfile || echo "Not installed"
#    Or check the version with: brew info libsndfile
# 3. Create a build directory: mkdir build && cd build
# 4. Run CMake: cmake ..
# 5. Build the project: make
# 6. The executable will be available in the build directory
if(CMAKE_SYSTEM_NAME MATCHES "Darwin")

    set(ONNX_RUNTIME_LIBRARY "${PROJECT_SOURCE_DIR}/Frameworks/onnxruntime.xcframework/macos-arm64_x86_64/onnxruntime.framework/onnxruntime")
    set(ONNX_RUNTIME_INCLUDE "${PROJECT_SOURCE_DIR}/Frameworks/onnxruntime.xcframework/macos-arm64_x86_64/onnxruntime.framework/Headers")
    set(WEBRTC_AUDIO_PROCESSING_LIBRARY "${PROJECT_SOURCE_DIR}/Frameworks/webrtc_audio_processing.xcframework/macos-arm64_x86_64/webrtc_audio_processing.framework/webrtc_audio_processing")
    set(WEBRTC_AUDIO_PROCESSING_INCLUDE "${PROJECT_SOURCE_DIR}/Frameworks/webrtc_audio_processing.xcframework/macos-arm64_x86_64/webrtc_audio_processing.framework/Headers/webrtc-audio-processing-1")
    set(WEBRTC_ABSL_INCLUDE "${PROJECT_SOURCE_DIR}/Frameworks/webrtc_audio_processing.xcframework/macos-arm64_x86_64/webrtc_audio_processing.framework/Headers/absl")

    include_directories(/opt/homebrew/include)
    ### mac os x main
    find_library(CORE_FOUNDATION_LIBRARY CoreFoundation)
    find_library(FOUNDATION_LIBRARY Foundation)
    find_library(COREAUDIO_LIBRARY CoreAudio)
    find_library(AUDIO_TOOLBOX_LIBRARY AudioToolbox)
    find_library(CORE_FOUNDATION_LIBRARY CoreFoundation)

    ## command line
    find_library(SNDFILE_LIBRARY sndfile)
    if(NOT SNDFILE_LIBRARY)
        message(FATAL_ERROR "Sndfile not found!")
    else()
        message(STATUS "Sndfile found at ${SNDFILE_LIBRARY}")
    endif()

    set(MACOSX_BUNDLE_INFO_PLIST ${CMAKE_CURRENT_SOURCE_DIR}/Info.plist)
    set(MACOSX_BUNDLE_INFO_STRING "My App")
    set(MACOSX_BUNDLE_GUI_IDENTIFIER "com.example.myapp")
    set(MACOSX_BUNDLE_BUNDLE_NAME "My App")
    set(MACOSX_BUNDLE_BUNDLE_VERSION "1.0.0")
    set(MACOSX_BUNDLE_LONG_VERSION_STRING "1.0.0")
    set(MACOSX_BUNDLE_SHORT_VERSION_STRING "1.0")
    set(MACOSX_BUNDLE_COPYRIGHT "Copyright (c) 2023")
    set(MACOSX_BUNDLE_ICON_FILE "MyApp.icns")

    add_executable(VAD_FILE_COMMAND ${MY_CMAKE_PROJECT_DIR}/main/vad_file.cpp ${HEADER} ${SOURCE_FILES})
    set_target_properties(VAD_FILE_COMMAND PROPERTIES MACOSX_BUNDLE FALSE)
    target_include_directories(VAD_FILE_COMMAND PRIVATE
            ${MY_LIBRARY_SOURCE_DIR}
            ${ONNX_RUNTIME_INCLUDE}
            ${WEBRTC_AUDIO_PROCESSING_INCLUDE}
            ${WEBRTC_ABSL_INCLUDE}
    )
    target_link_libraries(VAD_FILE_COMMAND
            ${CORE_FOUNDATION_LIBRARY}
            ${FOUNDATION_LIBRARY}
            ${COREAUDIO_LIBRARY}
            ${AUDIO_TOOLBOX_LIBRARY}
            ${SNDFILE_LIBRARY}
            ${ONNX_RUNTIME_LIBRARY}
            ${WEBRTC_AUDIO_PROCESSING_LIBRARY}
    )
    install(TARGETS VAD_FILE_COMMAND
            BUNDLE DESTINATION install
            RUNTIME DESTINATION install
    )

endif()


if(ANDROID)

    message(STATUS "Building for Android")

    set(ONNX_RUNTIME_LIBRARY "${PROJECT_SOURCE_DIR}/jniLibs/${ANDROID_ABI}/libonnxruntime.so")
    set(WEBRTC_AUDIO_PROCESSING_LIBRARY "${PROJECT_SOURCE_DIR}/jniLibs/${ANDROID_ABI}/libwebrtc-audio-processing-1.so")
    set(LIBRARY_INCLUDE "${PROJECT_SOURCE_DIR}/jniLibs/Headers")
    set(EXCEPTION_INCLUDE "${PROJECT_SOURCE_DIR}/jniLibs/Headers/webrtc_audio_processing/webrtc-audio-processing-1")

    # Create a shared library for Android
    add_library(RealtimeCutVadLibrary SHARED ${SOURCE_FILES})

    # Include directories
    target_include_directories(RealtimeCutVadLibrary PRIVATE
            ${MY_LIBRARY_SOURCE_DIR}
            ${LIBRARY_INCLUDE}
            ${EXCEPTION_INCLUDE}
    )

    target_link_libraries(RealtimeCutVadLibrary
            android
            log
            ${ONNX_RUNTIME_LIBRARY}
            ${WEBRTC_AUDIO_PROCESSING_LIBRARY}
    )

endif()