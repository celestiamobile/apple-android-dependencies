#!/bin/zsh

cd `dirname $0`

TARGET="Emscripten"

source common.sh
source cmake.sh
source versions.sh

mkdir -p $LIB_PATH
mkdir -p $INCLUDE_PATH

build_with_cmake "jpeg" $JPEG_TURBO_VERSION ".tar.gz" "jpeg" "libjpeg" ".." "-DENABLE_STATIC=ON" "-DENABLE_SHARED=OFF" "-DWITH_TURBOJPEG=OFF"
build_with_cmake "zlib" $ZLIB_VERSION ".tar.gz" "zlib" "libz" ".."
build_with_cmake "libpng" $LIBPNG_VERSION ".tar.xz" "libpng" "libpng" ".." "-DZLIB_LIBRARY=$LIB_PATH/libz.a" "-DZLIB_INCLUDE_DIR=$INCLUDE_PATH/zlib"
build_with_cmake "freetype" $FREETYPE_VERSION ".tar.xz" "freetype" "libfreetype" ".." "-DZLIB_LIBRARY=$LIB_PATH/libz.a" "-DZLIB_INCLUDE_DIR=$INCLUDE_PATH/zlib" "-DFT_DISABLE_BROTLI=ON" "-DFT_DISABLE_HARFBUZZ=ON" "-DFT_DISABLE_PNG=ON"
build_with_cmake "fmt" $FMT_VERSION ".tar.gz" "fmt" "libfmt" ".." "-DFMT_TEST=OFF" "-DBUILD_SHARED_LIBS=OFF"
build_with_cmake "meshoptimizer" $MESHOPTIMIZER_VERSION ".tar.gz" "meshoptimizer" "libmeshoptimizer"
build_with_cmake "eigen" $EIGEN_VERSION ".tar.gz"

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
  cp lib/cspice.a $LIB_PATH
  check_success

  echo "Cleaning"
  cd ..
  rm -rf $CSPICE_VERSION
}

configure_emscripten
compile_cspice

# gettext

echo "Building gettext"
compile_gettext()
{
  unarchive_and_enter $GETTEXT_VERSION ".tar.gz"
  cd gettext-runtime

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
  cp output/lib/libintl.a $LIB_PATH
  check_success

  echo "Cleaning"
  cd ../..
  rm -rf $GETTEXT_VERSION
}

configure_emscripten
compile_gettext

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

  OUTPUT_PATH="$(pwd)/output"

  make generic install INSTALL_TOP=${OUTPUT_PATH}
  check_success

  echo "Copying products"
  mkdir -p $INCLUDE_PATH/lua
  cp -r output/include/* $INCLUDE_PATH/lua/
  cp output/lib/liblua.a $LIB_PATH
  check_success

  echo "Cleaning"
  cd ..
  rm -rf $LUA_VERSION
}

configure_emscripten
compile_lua

# libepoxy

echo "Building libepoxy"
compile_libepoxy()
{
  unarchive_and_enter $LIBEPOXY_VERSION ".tar.xz"

  mkdir build
  cd build

  meson --buildtype=release --default-library=static -Dtests=false --prefix=`pwd`/output --cross-file ../../emscripten.txt
  ninja install
  check_success

  echo "Copying products"
  mkdir -p $INCLUDE_PATH/libepoxy
  cp -r output/include/* $INCLUDE_PATH/libepoxy/
  cp output/lib/libepoxy.a $LIB_PATH/libGL.a
  check_success

  cd ..

  echo "Cleaning"
  cd ..
  rm -rf $LIBEPOXY_VERSION
}

compile_libepoxy

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

  export LDFLAGS="${LDFLAGS} -lc++"
  OUTPUT_PATH="$(pwd)/output"
  ./source/configure --disable-samples \
              --disable-tests \
              --disable-extras \
              --enable-static \
              --disable-tools \
              --disable-icuio \
              --disable-shared \
              --disable-dyload \
              --host=arm \
              --with-cross-build=`pwd`/../icu-mac \
              --prefix=${OUTPUT_PATH}
  check_success

  make -j8 install
  check_success

  echo "Copying products"
  mkdir -p $INCLUDE_PATH/icu
  cp -r output/include/* $INCLUDE_PATH/icu/
  cp output/lib/libicudata.a $LIB_PATH
  cp output/lib/libicui18n.a $LIB_PATH
  cp output/lib/libicuuc.a $LIB_PATH

  check_success

  echo "Cleaning"
  cd ..
  rm -rf $ICU_VERSION
}

configure_emscripten
compile_icu

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
