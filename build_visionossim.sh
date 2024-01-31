#!/bin/zsh

cd `dirname $0`

TARGET="visionOSSimulator"

. `pwd`/common.sh
. `pwd`/cmake.sh
. `pwd`/versions.sh

mkdir -p $LIB_PATH
mkdir -p $INCLUDE_PATH

. `pwd`/build_apple.sh

build_with_cmake "jpeg" $JPEG_TURBO_VERSION ".tar.gz" "jpeg" "libjpeg" ".." "-DENABLE_STATIC=ON" "-DENABLE_SHARED=OFF" "-DWITH_TURBOJPEG=OFF"
build_with_cmake "fmt" $FMT_VERSION ".tar.gz" "dummy" "libfmt" ".." "-DFMT_TEST=OFF" "-DBUILD_SHARED_LIBS=OFF"
build_with_cmake "eigen" $EIGEN_VERSION ".tar.gz"
build_with_cmake "meshoptimizer" $MESHOPTIMIZER_VERSION ".tar.gz" "meshoptimizer" "libmeshoptimizer"

compile_cspice "arm64"  "${CC_ARM64}"
compile_cspice "x86_64"  "${CC_X86_64}"
fat_create_and_clean "cspice"

compile_libpng "arm64"  "${CC_ARM64}"
compile_libpng "x86_64"  "${CC_X86_64}"
fat_create_and_clean "libpng16"

compile_lua "arm64"  "${CC_ARM64}"
compile_lua "x86_64"  "${CC_X86_64}"
fat_create_and_clean "liblua"

compile_luajit "arm64" "$CC_EXECUTABLE" "$CC_ARM64_FLAGS"
compile_luajit "x86_64" "$CC_EXECUTABLE" "$CC_X86_64_FLAGS"
fat_create_and_clean "libluajit"

compile_freetype "arm64"  "${CC_ARM64}"
compile_freetype "x86_64"  "${CC_X86_64}"
fat_create_and_clean "libfreetype"

compile_gettext "arm64"  "${CC_ARM64}"
compile_gettext "x86_64"  "${CC_X86_64}"
fat_create_and_clean "libintl"

compile_libepoxy "arm64"
compile_libepoxy "x86_64"
fat_create_and_clean "libGL"

compile_icu "arm64" "${CC_ARM64}"
compile_icu "x86_64" "${CC_X86_64}"
fat_create_and_clean "libicudata"
fat_create_and_clean "libicui18n"
fat_create_and_clean "libicuuc"

mkdir -p $INCLUDE_PATH/angle
unarchive_and_enter $OPENGL_VERSION ".tar.gz"
cp -r api/* $INCLUDE_PATH/angle/
cd ..

unarchive_and_enter $EGL_VERSION ".tar.gz"
cp -r api/KHR $INCLUDE_PATH/angle/
cd ..

unarchive_and_enter $MINIAUDIO_VERSION ".tar.gz"
mkdir -p $INCLUDE_PATH/miniaudio
cp miniaudio.h $INCLUDE_PATH/miniaudio/
cd ..
