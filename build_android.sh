#!/bin/zsh

cd `dirname $0`

TARGET="Android"

source common.sh
source cmake.sh
source versions.sh

mkdir -p $LIB_PATH
mkdir -p $INCLUDE_PATH

mkdir -p $LIB_PATH/x86
mkdir -p $LIB_PATH/x86_64
mkdir -p $LIB_PATH/armeabi-v7a
mkdir -p $LIB_PATH/arm64-v8a

build_with_cmake "fmt" $FMT_VERSION ".tar.gz" "fmt" "libfmt" ".." "-DFMT_TEST=OFF" "-DBUILD_SHARED_LIBS=OFF"
build_with_cmake "eigen" $EIGEN_VERSION ".tar.gz"
build_with_cmake "meshoptimizer" $MESHOPTIMIZER_VERSION ".tar.gz" "meshoptimizer" "libmeshoptimizer"

# breakpad

echo "Building breakpad"
compile_breakpad()
{
  unarchive_and_enter $BREAKPAD_VERSION ".tar.gz"

  mkdir -p src/third_party/lss
  curl https://chromium.googlesource.com/linux-syscall-support/+/refs/heads/main/linux_syscall_support.h\?format\=TEXT | base64 --decode > src/third_party/lss/linux_syscall_support.h

  echo "Compiling for $1"
  OUTPUT_PATH="$(pwd)/output"
  ./configure --disable-dependency-tracking \
              --disable-silent-rules \
              --disable-processor \
              --disable-tools \
              --host=arm-linux-androideabi \
              --prefix=${OUTPUT_PATH}
  check_success

  rm -rf src/common/android/testing

  make -j4 install
  check_success

  echo "Copying products"
  mkdir -p $INCLUDE_PATH/breakpad
  cp -r output/include/* $INCLUDE_PATH/breakpad/
  cp output/lib/libbreakpad_client.a $LIB_PATH/${1}
  check_success

  echo "Cleaning"
  cd ..
  rm -rf $BREAKPAD_VERSION
}

configure_armv7
compile_breakpad "armeabi-v7a"
configure_arm64
compile_breakpad "arm64-v8a"
configure_x86
compile_breakpad "x86"
configure_x86_64
compile_breakpad "x86_64"

# CSPICE

echo "Building CSPICE"
compile_cspice()
{
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
  csh mkprodct.csh
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
}

configure_x86
compile_cspice "x86"
configure_x86_64
compile_cspice "x86_64"
configure_armv7
compile_cspice "armeabi-v7a"
configure_arm64
compile_cspice "arm64-v8a"

# libpng

echo "Building libpng"
compile_libpng()
{
  unarchive_and_enter $LIBPNG_VERSION ".tar.xz"

  echo "Compiling for $1"
  OUTPUT_PATH="$(pwd)/output"
  ./configure --disable-dependency-tracking \
              --disable-silent-rules \
              --host=arm \
              --prefix=${OUTPUT_PATH}
  check_success

  make -j4 install
  check_success

  echo "Copying products"
  mkdir -p $INCLUDE_PATH/libpng
  cp -r output/include/* $INCLUDE_PATH/libpng/
  cp output/lib/libpng16.a $LIB_PATH/${1}
  check_success

  echo "Cleaning"
  cd ..
  rm -rf $LIBPNG_VERSION
}

configure_x86
compile_libpng "x86"
configure_x86_64
compile_libpng "x86_64"
configure_armv7
compile_libpng "armeabi-v7a"
configure_arm64
compile_libpng "arm64-v8a"

# jpeg

echo "Building jpeg"
compile_jpeg()
{
  unarchive_and_enter $JPEG_VERSION ".tar.gz"

  echo "Compiling for $1"
  OUTPUT_PATH="$(pwd)/output"
  ./configure --disable-dependency-tracking \
              --disable-silent-rules \
              --host=arm \
              --prefix=${OUTPUT_PATH}
  check_success

  make -j4 install
  check_success

  echo "Copying products"
  mkdir -p $INCLUDE_PATH/jpeg
  cp -r output/include/* $INCLUDE_PATH/jpeg/
  cp output/lib/libjpeg.a $LIB_PATH/${1}
  check_success

  echo "Cleaning"
  cd ..
  rm -rf $JPEG_VERSION
}

configure_x86
compile_jpeg "x86"
configure_x86_64
compile_jpeg "x86_64"
configure_armv7
compile_jpeg "armeabi-v7a"
configure_arm64
compile_jpeg "arm64-v8a"

# freetype

echo "Building freetype"
compile_freetype()
{
  unarchive_and_enter $FREETYPE_VERSION ".tar.xz"

  echo "Compiling for $1"
  OUTPUT_PATH="$(pwd)/output"
  ./configure --enable-freetype-config \
              --with-harfbuzz=no \
              --with-brotli=no \
              --with-png=no \
              --host=arm \
              --prefix=${OUTPUT_PATH}
  check_success

  make -j4 install
  check_success

  echo "Copying products"
  mkdir -p $INCLUDE_PATH/freetype
  cp -r output/include/* $INCLUDE_PATH/freetype/
  cp output/lib/libfreetype.a $LIB_PATH/${1}
  check_success

  echo "Cleaning"
  cd ..
  rm -rf $FREETYPE_VERSION
}

configure_x86
compile_freetype "x86"
configure_x86_64
compile_freetype "x86_64"
configure_armv7
compile_freetype "armeabi-v7a"
configure_arm64
compile_freetype "arm64-v8a"

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
              --host=arm
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

configure_x86
compile_gettext "x86"
configure_x86_64
compile_gettext "x86_64"
configure_armv7
compile_gettext "armeabi-v7a"
configure_arm64
compile_gettext "arm64-v8a"

# lua

echo "Building lua"
compile_lua()
{
  unarchive_and_enter $LUA_VERSION ".tar.gz"

  echo "Applying patch 1"
  sed -ie 's/#define LUA_USE_READLINE//g' src/luaconf.h

  echo "Applying patch 2"
  TO_REPLACE="system(luaL_optstring(L, 1, NULL))"
  NEW_STRING="0"
  sed -ie "s#${TO_REPLACE}#${NEW_STRING}#g" src/loslib.c

  echo "Applying patch 3"
  TO_REPLACE="CC= gcc"
  NEW_STRING="CC= ${CC}"
  sed -ie "s#${TO_REPLACE}#${NEW_STRING}#g" src/Makefile

  echo "Applying patch 4"
  TO_REPLACE="RANLIB= ranlib"
  NEW_STRING="RANLIB= ${RANLIB}"
  sed -ie "s#${TO_REPLACE}#${NEW_STRING}#g" src/Makefile

  echo "Applying patch 5"
  TO_REPLACE="AR= ar rcu"
  NEW_STRING="AR= ${AR} rcu"
  sed -ie "s#${TO_REPLACE}#${NEW_STRING}#g" src/Makefile

  echo "Compiling for $1"
  OUTPUT_PATH="$(pwd)/output"

  make generic install INSTALL_TOP=${OUTPUT_PATH}
  check_success

  echo "Copying products"
  mkdir -p $INCLUDE_PATH/lua
  cp -r output/include/* $INCLUDE_PATH/lua/
  cp output/lib/liblua.a $LIB_PATH/${1}
  check_success

  echo "Cleaning"
  cd ..
  rm -rf $LUA_VERSION
}

configure_x86
compile_lua "x86"
configure_x86_64
compile_lua "x86_64"
configure_armv7
compile_lua "armeabi-v7a"
configure_arm64
compile_lua "arm64-v8a"

# libepoxy

echo "Building libepoxy"
compile_libepoxy()
{
  unarchive_and_enter $LIBEPOXY_VERSION ".tar.xz"

  mkdir build
  cd build

  echo "Compiling for $1"
  meson --buildtype=release --default-library=static -Dtests=false --prefix=`pwd`/output --cross-file ../../android_$1.txt
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

compile_libepoxy "x86"
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
  export LDFLAGS="${LDFLAGS} -lc++"
  OUTPUT_PATH="$(pwd)/output"
  ./source/configure --disable-samples \
              --disable-tests \
              --disable-extras \
              --enable-static \
              --disable-tools \
              --disable-icuio \
              --disable-shared \
              --disable-tests \
              --disable-samples \
              --host=arm \
              --with-cross-build=`pwd`/../icu-mac \
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
configure_x86
compile_icu "x86"
configure_x86_64
compile_icu "x86_64"

mkdir -p $INCLUDE_PATH/json
mv json.hpp $INCLUDE_PATH/json/
