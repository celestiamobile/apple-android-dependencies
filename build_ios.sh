#!/bin/zsh

cd `dirname $0`

TARGET="iOS"

LIB_PATH="$1/libs"
INCLUDE_PATH="$1/include"

. `pwd`/common.sh
. `pwd`/cmake.sh
. `pwd`/versions.sh

mkdir -p $LIB_PATH
mkdir -p $INCLUDE_PATH

. `pwd`/build_apple.sh

build_with_cmake "libzip" $LIBZIP_VERSION ".tar.gz" "libzip" "libzip" ".." "-DENABLE_COMMONCRYPTO=OFF" "-DENABLE_GNUTLS=OFF" "-DENABLE_MBEDTLS=OFF" "-DENABLE_OPENSSL=OFF" "-DENABLE_WINDOWS_CRYPTO=OFF" "-DENABLE_BZIP2=OFF" "-DENABLE_LZMA=OFF" "-DENABLE_ZSTD=OFF" "-DENABLE_FDOPEN=OFF" "-DBUILD_TOOLS=OFF" "-DBUILD_REGRESS=OFF" "-DBUILD_EXAMPLES=OFF" "-DBUILD_DOC=OFF" "-DBUILD_SHARED_LIBS=OFF" "-DHAVE_MEMCPY_S=OFF" "-DHAVE_STRNCPY_S=OFF" "-DHAVE_STRERRORLEN_S=OFF" "-DHAVE_STRERROR_S=OFF"
build_with_cmake "jpeg" $JPEG_TURBO_VERSION ".tar.gz" "jpeg" "libjpeg" ".." "-DENABLE_STATIC=ON" "-DENABLE_SHARED=OFF" "-DWITH_TURBOJPEG=OFF"
build_with_cmake "fmt" $FMT_VERSION ".tar.gz" "none" "libfmt" ".." "-DFMT_TEST=OFF" "-DBUILD_SHARED_LIBS=OFF"
build_with_cmake "eigen" $EIGEN_VERSION ".tar.gz"
build_with_cmake "meshoptimizer" $MESHOPTIMIZER_VERSION ".tar.gz" "meshoptimizer" "libmeshoptimizer"
build_with_cmake "aom" $AOM_VERSION ".tar.gz" "aom" "libaom" ".." "-DCMAKE_CXX_STANDARD=17" "-DAOM_TARGET_CPU=CELESTIA_STANDARD_ARCH" "-DENABLE_DOCS=OFF" "-DBUILD_SHARED_LIBS=OFF" "-DENABLE_EXAMPLES=OFF"  "-DENABLE_TESTDATA=OFF" "-DENABLE_TESTS=OFF" "-DENABLE_TOOLS=OFF"
build_with_cmake "libavif" $LIBAVIF_VERSION ".tar.gz" "libavif" "libavif" ".." "-DAVIF_BUILD_APPS=OFF" "-DBUILD_SHARED_LIBS=OFF" "-DAOM_INCLUDE_DIR=$INCLUDE_PATH/aom" "-DAOM_LIBRARY=$LIB_PATH/libaom.a" "-DCMAKE_DISABLE_FIND_PACKAGE_libsharpyuv=TRUE"  "-DCMAKE_DISABLE_FIND_PACKAGE_libyuv=TRUE" "-DAVIF_CODEC_AOM=SYSTEM"

compile_cspice "arm64"  "${CC_ARM64}"
fat_create_and_clean "cspice"

compile_libpng "arm64"  "${CC_ARM64}"
fat_create_and_clean "libpng16"

compile_lua "arm64"  "${CC_ARM64}"
fat_create_and_clean "liblua"

compile_luajit "arm64" "$CC_EXECUTABLE" "$CC_ARM64_FLAGS"
fat_create_and_clean "libluajit"

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
