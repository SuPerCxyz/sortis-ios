#!/bin/bash

# Sortis iOS 构建脚本
# 使用方法: ./build.sh [device|simulator]

set -e

SCHEME="Sortis"
PROJECT="Sortis.xcodeproj"
CONFIGURATION="Debug"

# 检查参数
TARGET="${1:-simulator}"

if [ "$TARGET" = "device" ]; then
    DESTINATION="generic/platform=iOS"
    ARCHIVE_PATH="build/Sortis.xcarchive"
    IPA_PATH="build/Sortis.ipa"
else
    DESTINATION="platform=iOS Simulator,name=iPhone 15 Pro"
fi

echo "=========================================="
echo "Sortis iOS Build Script"
echo "Target: $TARGET"
echo "=========================================="

# 清理旧的构建文件
echo "Cleaning..."
rm -rf build/
mkdir -p build/

# 构建
echo "Building..."
if [ "$TARGET" = "device" ]; then
    # 构建用于真机
    xcodebuild archive \
        -project "$PROJECT" \
        -scheme "$SCHEME" \
        -configuration "$CONFIGURATION" \
        -archivePath "$ARCHIVE_PATH" \
        -destination "$DESTINATION" \
        CODE_SIGN_IDENTITY="-" \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO

    # 导出 IPA
    xcodebuild -exportArchive \
        -archivePath "$ARCHIVE_PATH" \
        -exportPath build/ \
        -exportOptionsPlist ExportOptions.plist

    echo "IPA exported to: $IPA_PATH"
else
    # 构建用于模拟器
    xcodebuild build \
        -project "$PROJECT" \
        -scheme "$SCHEME" \
        -configuration "$CONFIGURATION" \
        -destination "$DESTINATION" \
        -derivedDataPath build/DerivedData

    # 查找 app 文件
    APP_PATH=$(find build/DerivedData -name "Sortis.app" -type d | head -1)
    echo "App built at: $APP_PATH"

    # 启动模拟器并安装
    echo "Installing to simulator..."
    SIMULATOR_ID=$(xcrun simctl list devices | grep "iPhone 15 Pro" | grep -oE "[A-F0-9-]{36}" | head -1)

    if [ -z "$SIMULATOR_ID" ]; then
        echo "Creating iPhone 15 Pro simulator..."
        SIMULATOR_ID=$(xcrun simctl create "iPhone 15 Pro" "com.apple.CoreSimulator.SimDeviceType.iPhone-15-Pro" "com.apple.CoreSimulator.SimRuntime.iOS-17-0")
    fi

    # 启动模拟器
    xcrun simctl boot "$SIMULATOR_ID" 2>/dev/null || true
    open -a Simulator

    # 安装应用
    xcrun simctl install "$SIMULATOR_ID" "$APP_PATH"

    echo "=========================================="
    echo "Build completed successfully!"
    echo "App installed to simulator: $SIMULATOR_ID"
    echo "Launch with: xcrun simctl launch $SIMULATOR_ID app.sortis.ios"
    echo "=========================================="
fi