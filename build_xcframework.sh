#!/bin/bash

# 项目和方案名称
PROJECT_NAME="RealTimeCutVADCXXLibrary"
SCHEME_NAME="RealTimeCutVADCXXLibrary"
XCFRAMEWORK_NAME="WQVad"
BUILD_DIR="./build"

# 清理构建目录
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# 构建函数
build_framework() {
    local sdk=$1
    local destination_dir=$2
    local release_dir=$3

    echo "Building for $sdk..."

    xcodebuild -project "${PROJECT_NAME}.xcodeproj" \
    -scheme "$SCHEME_NAME" \
    -sdk "$sdk" \
    -configuration Release \
    -derivedDataPath "$destination_dir" \
    BUILD_DIR="$destination_dir" \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    clean build

    FRAMEWORK_PATH="${destination_dir}/${release_dir}/${PROJECT_NAME}.framework"
    if [ ! -d "$FRAMEWORK_PATH" ]; then
        echo "Error: Failed to build $sdk framework."
        exit 1
    fi
    
    # 清理可能导致代码签名问题的文件
    echo "Cleaning framework..."
    find "$FRAMEWORK_PATH" -name ".DS_Store" -delete
    find "$FRAMEWORK_PATH" -name "._*" -delete
    xattr -cr "$FRAMEWORK_PATH"
}

# iOS设备构建
build_framework "iphoneos" "$BUILD_DIR/ios_device" "Release-iphoneos"

# 创建XCFramework (仅iOS设备)
echo "Creating XCFramework..."
xcodebuild -create-xcframework \
    -framework "$BUILD_DIR/ios_device/Release-iphoneos/${PROJECT_NAME}.framework" \
    -output "$BUILD_DIR/${XCFRAMEWORK_NAME}.xcframework"

if [ -d "$BUILD_DIR/${XCFRAMEWORK_NAME}.xcframework" ]; then
    echo "✅ XCFramework successfully created at $BUILD_DIR/${XCFRAMEWORK_NAME}.xcframework"
else
    echo "❌ Failed to create XCFramework."
    exit 1
fi
