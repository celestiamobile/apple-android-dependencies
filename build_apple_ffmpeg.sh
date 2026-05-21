#!/bin/zsh

cd `dirname $0`

mkdir -p "$1"
BASE_DIR=$(cd "$1" && pwd)

. `pwd`/versions.sh

if [ ! -f "${FFMPEG_VERSION}.tar.gz" ]; then
  wget "https://ffmpeg.org/releases/${FFMPEG_VERSION}.tar.gz" --no-check-certificate
fi

if [ ! -f "${X264_VERSION}.tar.gz" ]; then
  wget "https://code.videolan.org/videolan/x264/-/archive/stable/x264-stable.tar.gz" -O "${X264_VERSION}.tar.gz" --no-check-certificate
fi

build_platform() {
  # $1 = TARGET, $2 = platform dir name, $3 = single|dual arch
  (
    TARGET="$1"
    LIB_PATH="$BASE_DIR/$2/libs"
    INCLUDE_PATH="$BASE_DIR/$2/include"
    XCFRAMEWORK_PATH="$BASE_DIR/$2/xcframework"

    mkdir -p $LIB_PATH $INCLUDE_PATH $XCFRAMEWORK_PATH

    . `pwd`/common.sh
    . `pwd`/xcframework.sh
    . `pwd`/build_apple.sh

    if [ "$3" = "dual" ]; then
      compile_x264 "arm64"  "${CC_ARM64}"
      compile_x264 "x86_64" "${CC_X86_64}"
    else
      compile_x264 "arm64" "${CC_ARM64}"
    fi

    fat_create_and_clean "libx264"
    create_xcframework "libx264" "x264" "x264"

    if [ "$3" = "dual" ]; then
      compile_ffmpeg "arm64"   "${CC_ARM64}"
      compile_ffmpeg "x86_64"  "${CC_X86_64}"
    else
      compile_ffmpeg "arm64" "${CC_ARM64}"
    fi

    fat_create_and_clean "libffmpeg"
    create_xcframework "libffmpeg" "ffmpeg" "ffmpeg"

    mv $XCFRAMEWORK_PATH/x264.xcframework $BASE_DIR/$2/x264.xcframework
    mv $XCFRAMEWORK_PATH/ffmpeg.xcframework $BASE_DIR/$2/ffmpeg.xcframework
    rm -rf $XCFRAMEWORK_PATH $LIB_PATH $INCLUDE_PATH
  )
}

mkdir -p "$BASE_DIR"

echo "=== Building iOS ==="
build_platform "iOS"               "ios"         "single"

echo "=== Building iOS Simulator ==="
build_platform "iOSSimulator"      "iossim"      "dual"

echo "=== Building macOS ==="
build_platform "macOS"             "mac"         "dual"

echo "=== Building macCatalyst ==="
build_platform "macCatalyst"       "catalyst"    "dual"

echo "=== Building visionOS ==="
build_platform "visionOS"          "visionos"    "single"

echo "=== Building visionOS Simulator ==="
build_platform "visionOSSimulator" "visionossim" "dual"

echo "=== Merging into single XCFramework ==="
. `pwd`/xcframework.sh
mkdir -p "$BASE_DIR/merged"
create_xcframework_from_xcframework "libx264" "x264" "$BASE_DIR" "$BASE_DIR/merged"
create_xcframework_from_xcframework "libffmpeg" "ffmpeg" "$BASE_DIR" "$BASE_DIR/merged"

echo "Done: $BASE_DIR/merged/x264.xcframework and $BASE_DIR/merged/ffmpeg.xcframework"
