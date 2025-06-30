#!/bin/zsh

cd `dirname $0`

TARGET_XCFRAMEWORK_PATH=$1
SOURCE_XCFRAMEWOKR_PARENT_PATH=$2

. $(pwd)/xcframework.sh

create_xcframework_from_xcframework "libboost_container" "boost" "$SOURCE_XCFRAMEWOKR_PARENT_PATH" "$TARGET_XCFRAMEWORK_PATH"
create_xcframework_from_xcframework "cspice" "cspice" "$SOURCE_XCFRAMEWOKR_PARENT_PATH" "$TARGET_XCFRAMEWORK_PATH"
create_xcframework_from_xcframework "eigen3" "eigen3" "$SOURCE_XCFRAMEWOKR_PARENT_PATH" "$TARGET_XCFRAMEWORK_PATH"
create_xcframework_from_xcframework "libfmt" "fmt" "$SOURCE_XCFRAMEWOKR_PARENT_PATH" "$TARGET_XCFRAMEWORK_PATH"
create_xcframework_from_xcframework "libfreetype" "freetype" "$SOURCE_XCFRAMEWOKR_PARENT_PATH" "$TARGET_XCFRAMEWORK_PATH"
create_xcframework_from_xcframework "libicu" "icu" "$SOURCE_XCFRAMEWOKR_PARENT_PATH" "$TARGET_XCFRAMEWORK_PATH"
create_xcframework_from_xcframework "libjpeg" "jpeg" "$SOURCE_XCFRAMEWOKR_PARENT_PATH" "$TARGET_XCFRAMEWORK_PATH"
create_xcframework_from_xcframework "libGL" "libepoxy" "$SOURCE_XCFRAMEWOKR_PARENT_PATH" "$TARGET_XCFRAMEWORK_PATH"
create_xcframework_from_xcframework "libGL_angle" "libepoxy_angle" "$SOURCE_XCFRAMEWOKR_PARENT_PATH" "$TARGET_XCFRAMEWORK_PATH"
create_xcframework_from_xcframework "libintl" "libintl" "$SOURCE_XCFRAMEWOKR_PARENT_PATH" "$TARGET_XCFRAMEWORK_PATH"
create_xcframework_from_xcframework "libpng" "libpng" "$SOURCE_XCFRAMEWOKR_PARENT_PATH" "$TARGET_XCFRAMEWORK_PATH"
create_xcframework_from_xcframework "libzip" "libzip" "$SOURCE_XCFRAMEWOKR_PARENT_PATH" "$TARGET_XCFRAMEWORK_PATH"
create_xcframework_from_xcframework "libluajit" "luajit" "$SOURCE_XCFRAMEWOKR_PARENT_PATH" "$TARGET_XCFRAMEWORK_PATH"
create_xcframework_from_xcframework "libmeshoptimizer" "meshoptimizer" "$SOURCE_XCFRAMEWOKR_PARENT_PATH" "$TARGET_XCFRAMEWORK_PATH"
create_xcframework_from_xcframework "libminiaudio" "miniaudio" "$SOURCE_XCFRAMEWOKR_PARENT_PATH" "$TARGET_XCFRAMEWORK_PATH"
