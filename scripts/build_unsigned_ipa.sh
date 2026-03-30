#!/usr/bin/env bash
set -euo pipefail

PROJECT_PATH="${PROJECT_PATH:-Sortis.xcodeproj}"
SCHEME_NAME="${SCHEME_NAME:-Sortis}"
BUILD_ROOT="${BUILD_ROOT:-build}"
ARCHIVE_PATH="${ARCHIVE_PATH:-$BUILD_ROOT/Sortis.xcarchive}"
PAYLOAD_DIR="${PAYLOAD_DIR:-$BUILD_ROOT/Payload}"
OUTPUT_IPA_PATH="${OUTPUT_IPA_PATH:-$BUILD_ROOT/Sortis-Unsigned.ipa}"

echo "Archiving ${SCHEME_NAME} to ${ARCHIVE_PATH}"
xcodebuild archive \
  -project "${PROJECT_PATH}" \
  -scheme "${SCHEME_NAME}" \
  -destination 'generic/platform=iOS' \
  -configuration Release \
  -archivePath "${ARCHIVE_PATH}" \
  CODE_SIGN_IDENTITY="-" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  DEVELOPMENT_TEAM=""

APP_PATH="${ARCHIVE_PATH}/Products/Applications/${SCHEME_NAME}.app"
if [[ ! -d "${APP_PATH}" ]]; then
  echo "App bundle not found: ${APP_PATH}" >&2
  exit 1
fi

TOOLCHAIN_DIR="$(xcode-select -p)/Toolchains/XcodeDefault.xctoolchain"
SWIFT_LIB_DIR="${TOOLCHAIN_DIR}/usr/lib/swift-5.5/iphoneos"
if [[ ! -d "${SWIFT_LIB_DIR}" ]]; then
  SWIFT_LIB_DIR="${TOOLCHAIN_DIR}/usr/lib/swift/iphoneos"
fi

mkdir -p "${APP_PATH}/Frameworks"
for lib in \
  libswiftCore.dylib \
  libswiftFoundation.dylib \
  libswiftUIKit.dylib \
  libswiftSwiftOnoneSupport.dylib \
  libswift_Concurrency.dylib \
  libswiftDarwin.dylib \
  libswiftDispatch.dylib \
  libswiftObjectiveC.dylib \
  libswiftCoreGraphics.dylib \
  libswiftCoreImage.dylib \
  libswiftCoreText.dylib \
  libswiftsimd.dylib \
  libswiftos.dylib \
  libswiftQuartzCore.dylib \
  libswiftSpriteKit.dylib \
  libswiftSceneKit.dylib \
  libswiftCoreAudio.dylib \
  libswiftCoreData.dylib \
  libswiftCoreLocation.dylib \
  libswiftCoreMedia.dylib \
  libswiftAVFoundation.dylib \
  libswiftAccelerate.dylib \
  libswiftMetal.dylib \
  libswiftSwiftDylib.dylib; do
  if [[ -f "${SWIFT_LIB_DIR}/${lib}" ]]; then
    cp "${SWIFT_LIB_DIR}/${lib}" "${APP_PATH}/Frameworks/"
  fi
done

rm -rf "${PAYLOAD_DIR}"
mkdir -p "${PAYLOAD_DIR}"
cp -R "${APP_PATH}" "${PAYLOAD_DIR}/"

rm -f "${OUTPUT_IPA_PATH}"
(
  cd "${BUILD_ROOT}"
  zip -qry "$(basename "${OUTPUT_IPA_PATH}")" Payload
)

echo "Unsigned IPA created at ${OUTPUT_IPA_PATH}"
