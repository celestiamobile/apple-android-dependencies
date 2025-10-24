#!/bin/zsh

cd `dirname $0`

TARGET="Android"

if [ "$(uname)" = "Darwin" ]; then
  HOST_TAG=darwin-x86_64
else
  HOST_TAG=linux-x86_64
fi

LIB_PATH="$1/libs"
INCLUDE_PATH="$1/include"

NDK_ROOT=$2
NDK_TOOLCHAIN=$NDK_ROOT/toolchains/llvm/prebuilt/$HOST_TAG

. `pwd`/common.sh
. `pwd`/cmake.sh
. `pwd`/versions.sh

mkdir -p $LIB_PATH
mkdir -p $INCLUDE_PATH

mkdir -p $LIB_PATH/x86_64
mkdir -p $LIB_PATH/armeabi-v7a
mkdir -p $LIB_PATH/arm64-v8a

TIMESTAMP=`git show --no-patch --format=%cd --date=format-local:'%Y%m%d'`

build_with_cmake "boost" $BOOST_VERSION ".tar.xz" "boost" "libboost_container" ".." "none" "-DBOOST_INCLUDE_LIBRARIES='container;smart_ptr'" "-DBUILD_SHARED_LIBS=OFF"
build_with_cmake "libzip" $LIBZIP_VERSION ".tar.gz" "libzip" "libzip" ".." "none" "-DENABLE_COMMONCRYPTO=OFF" "-DENABLE_GNUTLS=OFF" "-DENABLE_MBEDTLS=OFF" "-DENABLE_OPENSSL=OFF" "-DENABLE_WINDOWS_CRYPTO=OFF" "-DENABLE_BZIP2=OFF" "-DENABLE_LZMA=OFF" "-DENABLE_ZSTD=OFF" "-DENABLE_FDOPEN=OFF" "-DBUILD_TOOLS=OFF" "-DBUILD_REGRESS=OFF" "-DBUILD_EXAMPLES=OFF" "-DBUILD_DOC=OFF" "-DBUILD_SHARED_LIBS=OFF" "-DHAVE_MEMCPY_S=OFF" "-DHAVE_STRNCPY_S=OFF" "-DHAVE_STRERRORLEN_S=OFF" "-DHAVE_STRERROR_S=OFF"
build_with_cmake "jpeg" $JPEG_TURBO_VERSION ".tar.gz" "jpeg" "libjpeg" ".." "none" "-DENABLE_STATIC=ON" "-DENABLE_SHARED=OFF" "-DWITH_TURBOJPEG=OFF" "-DBUILD=$TIMESTAMP"
build_with_cmake "libpng" $LIBPNG_VERSION ".tar.xz" "libpng" "libpng" ".." "none" "-DPNG_SHARED=OFF"
build_with_cmake "freetype" $FREETYPE_VERSION ".tar.xz" "freetype" "libfreetype" ".." "freetype2" "-DFT_DISABLE_BROTLI=ON" "-DFT_DISABLE_HARFBUZZ=ON" "-DFT_DISABLE_PNG=ON"
build_with_cmake "fmt" $FMT_VERSION ".tar.gz" "fmt" "libfmt" ".." "none" "-DFMT_TEST=OFF" "-DBUILD_SHARED_LIBS=OFF"
build_with_cmake "eigen3" $EIGEN_VERSION ".tar.gz" "none" "none" ".." "none" "-DEIGEN_BUILD_LAPACK=OFF" "-DEIGEN_BUILD_BLAS=OFF" "-DEIGEN_BUILD_TESTING=OFF"
build_with_cmake "meshoptimizer" $MESHOPTIMIZER_VERSION ".tar.gz" "meshoptimizer" "libmeshoptimizer"
# build_with_cmake "aom" $AOM_VERSION ".tar.gz" "aom" "libaom" ".." "none" "-DCMAKE_CXX_STANDARD=17" "-DAOM_TARGET_CPU=CELESTIA_STANDARD_ARCH" "-DENABLE_DOCS=OFF" "-DBUILD_SHARED_LIBS=OFF" "-DENABLE_EXAMPLES=OFF"  "-DENABLE_TESTDATA=OFF" "-DENABLE_TESTS=OFF" "-DENABLE_TOOLS=OFF" "-DENABLE_NEON=CELESTIA_ARCH_IS_ARM64"
# build_with_cmake "libavif" $LIBAVIF_VERSION ".tar.gz" "libavif" "libavif" ".." "none" "-DAVIF_BUILD_APPS=OFF" "-DBUILD_SHARED_LIBS=OFF" "-DAOM_INCLUDE_DIR=$INCLUDE_PATH/aom" "-DAOM_LIBRARY=$LIB_PATH/CELESTIA_ARCH/libaom.a" "-DCMAKE_DISABLE_FIND_PACKAGE_libsharpyuv=TRUE"  "-DCMAKE_DISABLE_FIND_PACKAGE_libyuv=TRUE" "-DAVIF_CODEC_AOM=SYSTEM"
#
## breakpad
#
#echo "Building breakpad"
#compile_breakpad()
#{
#  unarchive_and_enter $BREAKPAD_VERSION ".tar.gz"
#
#  mkdir -p src/third_party/lss
#  curl https://chromium.googlesource.com/linux-syscall-support/+/refs/heads/main/linux_syscall_support.h\?format\=TEXT | base64 --decode > src/third_party/lss/linux_syscall_support.h
#
#  echo "Compiling for $1"
#  OUTPUT_PATH="$(pwd)/output"
#  ./configure --disable-dependency-tracking \
#              --disable-silent-rules \
#              --disable-processor \
#              --disable-tools \
#              --host=arm-linux-androideabi \
#              --prefix=${OUTPUT_PATH}
#  check_success
#
#  rm -rf src/common/android/testing
#
#  make -j4 install
#  check_success
#
#  echo "Copying products"
#  mkdir -p $INCLUDE_PATH/breakpad
#  cp -r output/include/* $INCLUDE_PATH/breakpad/
#  cp output/lib/libbreakpad_client.a $LIB_PATH/${1}
#  check_success
#
#  echo "Cleaning"
#  cd ..
#  rm -rf $BREAKPAD_VERSION
#}
#
#configure_armv7
#compile_breakpad "armeabi-v7a"
#configure_arm64
#compile_breakpad "arm64-v8a"
#configure_x86_64
#compile_breakpad "x86_64"

# CSPICE

echo "Building CSPICE"
compile_cspice()
{
  if [ "$1" = "armeabi-v7a" ]; then
    CSPICE_PATH_COMPONENT="PC_Linux_GCC_32bit"
  else
    CSPICE_PATH_COMPONENT="PC_Linux_GCC_64bit"
  fi
  wget "https://naif.jpl.nasa.gov/pub/naif/toolkit/C/$CSPICE_PATH_COMPONENT/packages/$CSPICE_VERSION.tar.Z" --no-check-certificate

  unarchive_and_enter $CSPICE_VERSION ".tar.Z"

  echo "Applying patch 1"
  sed -ie 's/rv  = system(buff);/\/\/ rv  = system(buff);/g' src/cspice/system_.c
  check_success
  echo "Applying patch 2"
  TO_REPLACE="ranlib"
  NEW_STRING=$RANLIB
  sed -ie "s#${TO_REPLACE}#${NEW_STRING}#g" src/cspice/mkprodct.csh
  check_success
  echo "Applying patch 3"
  TO_REPLACE="ar  crv"
  NEW_STRING="${AR}  crv"
  sed -ie "s#${TO_REPLACE}#${NEW_STRING}#g" src/cspice/mkprodct.csh
  check_success

  echo "Compiling for $1"
  cd src/cspice
  export TKCOMPILER=$CC
  export TKCOMPILEOPTIONS="-c -ansi -O2 -fPIC -DNON_UNIX_STDIO"
  export TKLINKOPTIONS="-lm"
  tcsh mkprodct.csh
  check_success
  cd ../..

  echo "Copying products"
  mkdir -p $INCLUDE_PATH/cspice
  cp -r include/* $INCLUDE_PATH/cspice/
  cp lib/cspice.a $LIB_PATH/${1}
  check_success

  echo "Cleaning"
  cd ..
  rm -rf $CSPICE_VERSION
  rm -rf "$CSPICE_VERSION.tar.Z"
}

configure_x86_64
compile_cspice "x86_64"
configure_armv7
compile_cspice "armeabi-v7a"
configure_arm64
compile_cspice "arm64-v8a"

# gettext

echo "Building gettext"
compile_gettext()
{
  unarchive_and_enter $GETTEXT_VERSION ".tar.gz"
  cd gettext-runtime

  echo "Compiling for $1"
  OUTPUT_PATH="$(pwd)/output"
  ./configure --disable-dependency-tracking \
              --disable-silent-rules \
              --disable-debug \
              --disable-shared \
              --prefix=${OUTPUT_PATH} \
              --with-included-gettext \
              gl_cv_func_ftello_works=yes \
              --with-included-glib \
              --with-included-libcroco \
              --with-included-libunistring \
              --with-emacs \
              --disable-java \
              --disable-csharp \
              --without-git \
              --without-cvs \
              --without-xz \
              --without-iconv \
              --host=$HOST
  check_success

  echo "Applying patch 1"
  sed -ie 's/HAVE_ICONV 1/HAVE_ICONV 0/g' config.h
  check_success
  echo "Applying patch 2"
  sed -ie 's/HAVE_ICONV_H 1/HAVE_ICONV_H 0/g' config.h
  check_success

  make -j4 install
  check_success

  echo "Copying products"
  mkdir -p $INCLUDE_PATH/gettext
  cp -r output/include/* $INCLUDE_PATH/gettext/
  cp output/lib/libintl.a $LIB_PATH/${1}
  check_success

  echo "Cleaning"
  cd ../..
  rm -rf $GETTEXT_VERSION
}

configure_x86_64
compile_gettext "x86_64"
configure_armv7
compile_gettext "armeabi-v7a"
configure_arm64
compile_gettext "arm64-v8a"

# # lua

# echo "Building lua"
# compile_lua()
# {
#   unarchive_and_enter $LUA_VERSION ".tar.gz"

#   echo "Applying patch 1"
#   sed -ie 's/#define LUA_USE_READLINE//g' src/luaconf.h

#   echo "Applying patch 2"
#   TO_REPLACE="system(luaL_optstring(L, 1, NULL))"
#   NEW_STRING="0"
#   sed -ie "s#${TO_REPLACE}#${NEW_STRING}#g" src/loslib.c

#   echo "Applying patch 3"
#   TO_REPLACE="CC= gcc"
#   NEW_STRING="CC= ${CC}"
#   sed -ie "s#${TO_REPLACE}#${NEW_STRING}#g" src/Makefile

#   echo "Applying patch 4"
#   TO_REPLACE="RANLIB= ranlib"
#   NEW_STRING="RANLIB= ${RANLIB}"
#   sed -ie "s#${TO_REPLACE}#${NEW_STRING}#g" src/Makefile

#   echo "Applying patch 5"
#   TO_REPLACE="AR= ar rcu"
#   NEW_STRING="AR= ${AR} rcu"
#   sed -ie "s#${TO_REPLACE}#${NEW_STRING}#g" src/Makefile

#   echo "Compiling for $1"
#   OUTPUT_PATH="$(pwd)/output"

#   make generic install INSTALL_TOP=${OUTPUT_PATH}
#   check_success

#   echo "Copying products"
#   mkdir -p $INCLUDE_PATH/lua
#   cp -r output/include/* $INCLUDE_PATH/lua/
#   cp output/lib/liblua.a $LIB_PATH/${1}
#   check_success

#   echo "Cleaning"
#   cd ..
#   rm -rf $LUA_VERSION
# }

# configure_x86_64
# compile_lua "x86_64"
# configure_armv7
# compile_lua "armeabi-v7a"
# configure_arm64
# compile_lua "arm64-v8a"

# luajit

echo "Building luajit"
compile_luajit()
{
  unarchive_and_enter $LUAJIT_VERSION ".tar.gz"

  echo "Compiling for $1"
  OUTPUT_PATH="$(pwd)/output"

  if [ "$1" = "armeabi-v7a" ]; then
    HOST_CC="gcc -m32"
  else
    HOST_CC="gcc"
  fi

  make install DEFAULT_CC=clang HOST_CC=$HOST_CC CROSS=$BIN_PREFIX \
     STATIC_CC="$STATIC_CC" DYNAMIC_CC="$CC" \
     TARGET_LD="$STATIC_CC" TARGET_AR="$AR rcus" \
     TARGET_STRIP="$STRIP" TARGET_SYS=Linux PREFIX=$OUTPUT_PATH
  check_success

  echo "Copying products"
  mkdir -p $INCLUDE_PATH/luajit
  cp -r output/include/luajit-2.1/* $INCLUDE_PATH/luajit/
  cp output/lib/libluajit-5.1.a $LIB_PATH/${1}/libluajit.a
  check_success

  echo "Cleaning"
  cd ..
  rm -rf $LUAJIT_VERSION
}

configure_x86_64
compile_luajit "x86_64"
configure_armv7
compile_luajit "armeabi-v7a"
configure_arm64
compile_luajit "arm64-v8a"

# libepoxy

echo "Building libepoxy"
compile_libepoxy()
{
  unarchive_and_enter $LIBEPOXY_VERSION ".tar.gz"

  mkdir build
  cd build

  OPTIONS_FILE="../../android_$1.txt"

  echo "Replacing NDK"
  TO_REPLACE="/Users/linfel/Library/Android/sdk/ndk/25.1.8937393/toolchains/llvm/prebuilt/darwin-x86_64"
  NEW_STRING="$NDK_TOOLCHAIN"
  sed -ie "s#${TO_REPLACE}#${NEW_STRING}#g" $OPTIONS_FILE

  echo "Compiling for $1"
  meson --buildtype=release --default-library=static -Dtests=false --prefix=`pwd`/output --cross-file $OPTIONS_FILE
  ninja install
  check_success

  echo "Copying products"
  mkdir -p $INCLUDE_PATH/libepoxy
  cp -r output/include/* $INCLUDE_PATH/libepoxy/
  cp output/lib/libepoxy.a $LIB_PATH/${1}/libGL.a
  check_success

  cd ..

  echo "Cleaning"
  cd ..
  rm -rf $LIBEPOXY_VERSION
}

compile_libepoxy "x86_64"
compile_libepoxy "armeabi-v7a"
compile_libepoxy "arm64-v8a"

# icu

echo "Building icu"
compile_icu()
{
  unarchive_and_enter $ICU_VERSION ".tgz"
  cp source/config/mh-linux source/config/mh-unknown

  echo "Applying patch 1"
  TO_REPLACE="int result = system(cmd);"
  NEW_STRING="int result = 0;"
  sed -ie "s#${TO_REPLACE}#${NEW_STRING}#g" source/tools/pkgdata/pkgdata.cpp
  check_success

  echo "Compiling for $1"
  OUTPUT_PATH="$(pwd)/output"
  ./source/configure --disable-samples \
              --disable-tests \
              --disable-extras \
              --enable-static \
              --enable-tools \
              --disable-icuio \
              --disable-shared \
              --disable-dyload \
              --host=$HOST \
              --with-cross-build=`pwd`/../icu-host \
              --prefix=${OUTPUT_PATH}
  check_success

  make -j8 install
  check_success

  echo "Copying products"
  mkdir -p $INCLUDE_PATH/icu
  cp -r output/include/* $INCLUDE_PATH/icu/
  cp output/lib/libicudata.a $LIB_PATH/${1}
  cp output/lib/libicui18n.a $LIB_PATH/${1}
  cp output/lib/libicuuc.a $LIB_PATH/${1}

  check_success

  echo "Cleaning"
  cd ..
  rm -rf $ICU_VERSION
}

configure_armv7
compile_icu "armeabi-v7a"
configure_arm64
compile_icu "arm64-v8a"
configure_x86_64
compile_icu "x86_64"

mkdir -p $INCLUDE_PATH/json
mv json.hpp $INCLUDE_PATH/json/

unarchive_and_enter $MINIAUDIO_VERSION ".tar.gz"
mkdir -p $INCLUDE_PATH/miniaudio
cp miniaudio.h $INCLUDE_PATH/miniaudio/
cd ..
