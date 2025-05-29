#!/bin/zsh

cd `dirname $0`

TARGET="visionOSSimulator"

LIB_PATH="$1/libs"
INCLUDE_PATH="$1/include"
XCFRAMEWORK_PATH="$1/xcframework"

. `pwd`/common.sh
. `pwd`/cmake.sh
. `pwd`/xcframework.sh
. `pwd`/versions.sh

mkdir -p $LIB_PATH
mkdir -p $INCLUDE_PATH

. `pwd`/build_apple.sh

TIMESTAMP=`git show --no-patch --format=%cd --date=format-local:'%Y%m%d'`

build_with_cmake "boost" $BOOST_VERSION ".tar.xz" "boost" "libboost_container" ".." "-DBOOST_INCLUDE_LIBRARIES='container;smart_ptr'" "-DBUILD_SHARED_LIBS=OFF"
build_with_cmake "libzip" $LIBZIP_VERSION ".tar.gz" "libzip" "libzip" ".." "-DENABLE_COMMONCRYPTO=OFF" "-DENABLE_GNUTLS=OFF" "-DENABLE_MBEDTLS=OFF" "-DENABLE_OPENSSL=OFF" "-DENABLE_WINDOWS_CRYPTO=OFF" "-DENABLE_BZIP2=OFF" "-DENABLE_LZMA=OFF" "-DENABLE_ZSTD=OFF" "-DENABLE_FDOPEN=OFF" "-DBUILD_TOOLS=OFF" "-DBUILD_REGRESS=OFF" "-DBUILD_EXAMPLES=OFF" "-DBUILD_DOC=OFF" "-DBUILD_SHARED_LIBS=OFF" "-DHAVE_MEMCPY_S=OFF" "-DHAVE_STRNCPY_S=OFF" "-DHAVE_STRERRORLEN_S=OFF" "-DHAVE_STRERROR_S=OFF"
build_with_cmake "jpeg" $JPEG_TURBO_VERSION ".tar.gz" "jpeg" "libjpeg" ".." "-DENABLE_STATIC=ON" "-DENABLE_SHARED=OFF" "-DWITH_TURBOJPEG=OFF" "-DBUILD=$TIMESTAMP"
build_with_cmake "libpng" $LIBPNG_VERSION ".tar.xz" "libpng" "libpng" ".." "-DPNG_SHARED=OFF"
build_with_cmake "freetype" $FREETYPE_VERSION ".tar.xz" "freetype" "libfreetype" ".." "-DFT_DISABLE_BROTLI=ON" "-DFT_DISABLE_HARFBUZZ=ON" "-DFT_DISABLE_PNG=ON"
build_with_cmake "fmt" $FMT_VERSION ".tar.gz" "fmt" "libfmt" ".." "-DFMT_TEST=OFF" "-DBUILD_SHARED_LIBS=OFF"
build_with_cmake "eigen3" $EIGEN_VERSION ".tar.gz"
build_with_cmake "meshoptimizer" $MESHOPTIMIZER_VERSION ".tar.gz" "meshoptimizer" "libmeshoptimizer"
# build_with_cmake "aom" $AOM_VERSION ".tar.gz" "aom" "libaom" ".." "-DCMAKE_CXX_STANDARD=17" "-DAOM_TARGET_CPU=CELESTIA_STANDARD_ARCH" "-DENABLE_DOCS=OFF" "-DBUILD_SHARED_LIBS=OFF" "-DENABLE_EXAMPLES=OFF"  "-DENABLE_TESTDATA=OFF" "-DENABLE_TESTS=OFF" "-DENABLE_TOOLS=OFF"
# build_with_cmake "libavif" $LIBAVIF_VERSION ".tar.gz" "libavif" "libavif" ".." "-DAVIF_BUILD_APPS=OFF" "-DBUILD_SHARED_LIBS=OFF" "-DAOM_INCLUDE_DIR=$INCLUDE_PATH/aom" "-DAOM_LIBRARY=$LIB_PATH/libaom.a" "-DCMAKE_DISABLE_FIND_PACKAGE_libsharpyuv=TRUE"  "-DCMAKE_DISABLE_FIND_PACKAGE_libyuv=TRUE" "-DAVIF_CODEC_AOM=SYSTEM"

compile_cspice "arm64"  "${CC_ARM64}"
compile_cspice "x86_64"  "${CC_X86_64}"
fat_create_and_clean "cspice"
create_xcframework "cspice" "cspice" "cspice"

# compile_lua "arm64"  "${CC_ARM64}"
# compile_lua "x86_64"  "${CC_X86_64}"
# fat_create_and_clean "liblua"

compile_luajit "arm64" "$CC_EXECUTABLE" "$CC_ARM64_FLAGS"
compile_luajit "x86_64" "$CC_EXECUTABLE" "$CC_X86_64_FLAGS"
fat_create_and_clean "libluajit"
create_xcframework "libluajit" "luajit" "luajit"

compile_gettext "arm64"  "${CC_ARM64}" "${HOST_ARM64}"
compile_gettext "x86_64"  "${CC_X86_64}" "${HOST_X86_64}"
fat_create_and_clean "libintl"
create_xcframework "libintl" "gettext" "libintl"

compile_libepoxy "arm64"
compile_libepoxy "x86_64"
fat_create_and_clean "libGL"
create_xcframework "libGL" "libepoxy" "libepoxy"

compile_icu "arm64" "${CC_ARM64}" "${HOST_ARM64}"
compile_icu "x86_64" "${CC_X86_64}" "${HOST_X86_64}"
fat_create_and_clean "libicu"
create_xcframework "libicu" "icu" "icu"

mkdir -p $INCLUDE_PATH/angle
unarchive_and_enter $OPENGL_VERSION ".tar.gz"
cp -r api/* $INCLUDE_PATH/angle/
cd ..
unarchive_and_enter $EGL_VERSION ".tar.gz"
cp -r api/KHR $INCLUDE_PATH/angle/
cd ..
create_xcframework "libangle" "angle" "angle"

unarchive_and_enter $MINIAUDIO_VERSION ".tar.gz"
mkdir -p $INCLUDE_PATH/miniaudio
cp miniaudio.h $INCLUDE_PATH/miniaudio/
cd ..
create_xcframework "libminiaudio" "miniaudio" "miniaudio"

mkdir temp
mv $XCFRAMEWORK_PATH temp
rm -rf $1
mv temp/xcframework $1
