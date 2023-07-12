#!/bin/zsh

cd `dirname $0`

TARGET="iOS"

source common.sh
source cmake.sh
source versions.sh

mkdir -p $LIB_PATH
mkdir -p $INCLUDE_PATH

source build_apple.sh

build_with_cmake "fmt" $FMT_VERSION ".tar.gz" "dummy" "libfmt" ".." "-DFMT_TEST=OFF" "-DBUILD_SHARED_LIBS=OFF"
build_with_cmake "eigen" $EIGEN_VERSION ".tar.gz"
build_with_cmake "meshoptimizer" $MESHOPTIMIZER_VERSION ".tar.gz" "meshoptimizer" "libmeshoptimizer"

compile_cspice "arm64"  "${CC_ARM64}"
fat_create_and_clean "cspice"

compile_libpng "arm64"  "${CC_ARM64}"
fat_create_and_clean "libpng16"

compile_jpeg "arm64"  "${CC_ARM64}"
fat_create_and_clean "libjpeg"

compile_lua "arm64"  "${CC_ARM64}"
fat_create_and_clean "liblua"

compile_freetype "arm64"  "${CC_ARM64}"
fat_create_and_clean "libfreetype"

compile_gettext "arm64"  "${CC_ARM64}"
fat_create_and_clean "libintl"

compile_libepoxy "arm64"
fat_create_and_clean "libGL"

compile_icu "arm64" "${CC_ARM64}"
fat_create_and_clean "libicudata"
fat_create_and_clean "libicui18n"
fat_create_and_clean "libicuuc"

unarchive_and_enter $OPENGL_VERSION ".tar.gz"
mkdir -p $INCLUDE_PATH/angle
cp -r api/* $INCLUDE_PATH/angle/
cd ..
