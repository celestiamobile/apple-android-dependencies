#!/bin/zsh

cd `dirname $0`

TARGET="iOS"

LIB_PATH="$1/libs"
INCLUDE_PATH="$1/include"
XCFRAMEWORK_PATH="$1/xcframework"

. `pwd`/common.sh
. `pwd`/xcframework.sh
. `pwd`/versions.sh

mkdir -p $LIB_PATH
mkdir -p $INCLUDE_PATH
mkdir -p $XCFRAMEWORK_PATH

. `pwd`/build_apple.sh

if [ ! -f "${FFMPEG_VERSION}.tar.gz" ]; then
  wget "https://ffmpeg.org/releases/${FFMPEG_VERSION}.tar.gz" --no-check-certificate
fi

compile_ffmpeg "arm64" "${CC_ARM64}"
fat_create_and_clean "libffmpeg"
create_xcframework "libffmpeg" "ffmpeg" "ffmpeg"

mkdir temp
mv $XCFRAMEWORK_PATH temp
rm -rf $1
mv temp/xcframework $1
