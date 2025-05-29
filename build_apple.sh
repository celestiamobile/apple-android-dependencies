#!/bin/zsh

# cspice

compile_cspice()
{
  if [ "$1" = "arm64" ]; then
    CSPICE_PATH_COMPONENT="MacM1_OSX_clang_64bit"
  else
    CSPICE_PATH_COMPONENT="MacIntel_OSX_AppleC_64bit"
  fi
  wget "https://naif.jpl.nasa.gov/pub/naif/toolkit/C/$CSPICE_PATH_COMPONENT/packages/$CSPICE_VERSION.tar.Z" --no-check-certificate

  unarchive_and_enter $CSPICE_VERSION ".tar.Z"

  echo "Applying patch 1"
  sed -ie 's/rv  = system(buff);/\/\/ rv  = system(buff);/g' src/cspice/system_.c
  check_success

  echo "Compiling for $1"
  cd src/cspice
  export TKCOMPILER=$2
  export TKCOMPILEOPTIONS="-c -ansi -O2 -fPIC -DNON_UNIX_STDIO"
  export TKLINKOPTIONS="-lm"
  tcsh mkprodct.csh
  check_success
  cd ../..

  echo "Copying products"
  mkdir -p $INCLUDE_PATH/cspice
  cp -r include/* $INCLUDE_PATH/cspice/
  cp lib/cspice.a $LIB_PATH/${1}_cspice.a
  check_success

  echo "Cleaning"
  cd ..
  rm -rf $CSPICE_VERSION
  rm -rf "$CSPICE_VERSION.tar.Z"
}

# libpng

compile_libpng()
{
  unarchive_and_enter $LIBPNG_VERSION ".tar.xz"

  echo "Compiling for $1"
  export CC=$2
  export CXX=$2
  OUTPUT_PATH="$(pwd)/output"
  ./configure --disable-dependency-tracking \
              --disable-silent-rules \
              --host=$3 \
              --prefix=${OUTPUT_PATH}
  check_success

  make -j4 install
  check_success

  echo "Copying products"
  mkdir -p $INCLUDE_PATH/libpng
  cp -r output/include/* $INCLUDE_PATH/libpng/
  cp output/lib/libpng16.a $LIB_PATH/${1}_libpng16.a
  check_success

  echo "Cleaning"
  cd ..
  rm -rf $LIBPNG_VERSION
}
#
## jpeg
#
#compile_jpeg()
#{
#  unarchive_and_enter $JPEG_VERSION ".tar.gz"
#
#  echo "Compiling for $1"
#  export CC=$2
#  export CXX=$2
#  OUTPUT_PATH="$(pwd)/output"
#  ./configure --disable-dependency-tracking \
#              --disable-silent-rules \
#              --host=$3 \
#              --prefix=${OUTPUT_PATH}
#  check_success
#
#  make -j4 install
#  check_success
#
#  echo "Copying products"
#  mkdir -p $INCLUDE_PATH/jpeg
#  cp -r output/include/* $INCLUDE_PATH/jpeg/
#  cp output/lib/libjpeg.a $LIB_PATH/${1}_libjpeg.a
#  check_success
#
#  echo "Cleaning"
#  cd ..
#  rm -rf $JPEG_VERSION
#}
#
# # lua
#
# compile_lua()
# {
#   unarchive_and_enter $LUA_VERSION ".tar.gz"

#   echo "Applying patch 1"
#   TO_REPLACE="CC= gcc"
#   NEW_STRING="CC= ${2}"
#   sed -ie "s#${TO_REPLACE}#${NEW_STRING}#g" src/Makefile

#   echo "Applying patch 2"
#   sed -ie 's/#define LUA_USE_READLINE//g' src/luaconf.h

#   echo "Applying patch 3"
#   TO_REPLACE="system(luaL_optstring(L, 1, NULL))"
#   NEW_STRING="0"
#   sed -ie "s#${TO_REPLACE}#${NEW_STRING}#g" src/loslib.c

#   echo "Compiling for $1"
#   export CC=$2
#   export CXX=$2
#   OUTPUT_PATH="$(pwd)/output"

#   make macosx install INSTALL_TOP=${OUTPUT_PATH}
#   check_success

#   echo "Copying products"
#   mkdir -p $INCLUDE_PATH/lua
#   cp -r output/include/* $INCLUDE_PATH/lua/
#   cp output/lib/liblua.a $LIB_PATH/${1}_liblua.a
#   check_success

#   echo "Cleaning"
#   cd ..
#   rm -rf $LUA_VERSION
# }

# luajit

compile_luajit()
{
  unarchive_and_enter $LUAJIT_VERSION ".tar.gz"

  echo "Compiling for $1"
  if [ "$TARGET" = "macOS" ]; then
    export MACOSX_DEPLOYMENT_TARGET=$4
  else
    export TARGET_SYS="iOS"
  fi

  OUTPUT_PATH="$(pwd)/output"

  make install DEFAULT_CC=clang CROSS="$(dirname $2)/" \
     TARGET_FLAGS="$3" PREFIX=$OUTPUT_PATH
  check_success

  echo "Copying products"
  mkdir -p $INCLUDE_PATH/luajit
  cp -r output/include/luajit-2.1/* $INCLUDE_PATH/luajit/
  cp output/lib/libluajit-5.1.a $LIB_PATH/${1}_libluajit.a
  check_success

  echo "Cleaning"
  cd ..
  rm -rf $LUAJIT_VERSION
}

# freetype

compile_freetype()
{
  unarchive_and_enter $FREETYPE_VERSION ".tar.xz"

  echo "Compiling for $1"
  export CC=$2
  export CXX=$2
  OUTPUT_PATH="$(pwd)/output"
  ./configure --enable-freetype-config \
              --with-harfbuzz=no \
              --with-brotli=no \
              --with-png=no \
              --host=$3 \
              --prefix=${OUTPUT_PATH}
  check_success

  make -j4 install
  check_success

  echo "Copying products"
  mkdir -p $INCLUDE_PATH/freetype
  cp -r output/include/freetype2/* $INCLUDE_PATH/freetype/
  cp output/lib/libfreetype.a $LIB_PATH/${1}_libfreetype.a
  check_success

  echo "Cleaning"
  cd ..
  rm -rf $FREETYPE_VERSION
}

# gettext

compile_gettext()
{
  unarchive_and_enter $GETTEXT_VERSION ".tar.gz"
  cd gettext-runtime

  echo "Compiling for $1"
  export CC=$2
  export CXX=$2
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
              --disable-shared \
              --without-git \
              --without-cvs \
              --without-xz \
              --without-iconv \
              --host=$3
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
  cp output/lib/libintl.a $LIB_PATH/${1}_libintl.a
  check_success

  echo "Cleaning"
  cd ../..
  rm -rf $GETTEXT_VERSION
}

# libepoxy

compile_libepoxy()
{
  unarchive_and_enter $LIBEPOXY_VERSION ".tar.gz"

  if [ "$TARGET" = "iOS" ] || [ "$TARGET" = "iOSSimulator" ]; then
    echo "Applying patch 1"
    sed -ie 's/libGLESv2/OpenGLES/g' meson.build
    check_success
    echo "Applying patch 2"
    sed -ie 's/glesv2/OpenGLES/g' meson.build
    check_success
    echo "Applying patch 3"
    sed -ie 's/libGLESv2.so/\/System\/Library\/Frameworks\/OpenGLES.framework\/OpenGLES/g' src/dispatch_common.c
    check_success
    echo "Applying patch 4"
    sed -ie 's/ gl_dep.found()/ false/g' src/meson.build
    check_success
    echo "Applying patch 5"
    sed -ie 's/epoxy_gl_dlsym(name)/epoxy_gles2_dlsym(name)/g' src/dispatch_common.c
    check_success
  fi

  mkdir build
  cd build

  OPTIONS_FILE="../../build_${TARGET}_$1.txt"

  echo "Replacing Xcode.app"
  TO_REPLACE="/Applications/Xcode.app/Contents/Developer"
  NEW_STRING="$(xcode-select -p)"
  sed -ie "s#${TO_REPLACE}#${NEW_STRING}#g" $OPTIONS_FILE

  echo "Compiling for $1"
  meson --buildtype=release --default-library=static -Dtests=false --prefix=`pwd`/output --cross-file $OPTIONS_FILE
  ninja install
  check_success

  echo "Copying products"
  mkdir -p $INCLUDE_PATH/libepoxy
  cp -r output/include/* $INCLUDE_PATH/libepoxy/
  cp output/lib/libepoxy.a $LIB_PATH/${1}_libGL.a
  check_success

  cd ..

  echo "Cleaning"
  cd ..
  rm -rf $LIBEPOXY_VERSION
}

# icu

compile_icu()
{
  unarchive_and_enter $ICU_VERSION ".tgz"
  cp source/config/mh-darwin source/config/mh-unknown

  echo "Applying patch 1"
  TO_REPLACE="int result = system(cmd);"
  NEW_STRING="int result = 0;"
  sed -ie "s#${TO_REPLACE}#${NEW_STRING}#g" source/tools/pkgdata/pkgdata.cpp
  check_success

  echo "Compiling for $1"
  export CC=$2
  export CXX=$2
  export LDFLAGS="${LDFLAGS} -lc++"
  OUTPUT_PATH="$(pwd)/output"
  ./source/configure --disable-samples \
              --disable-tests \
              --disable-extras \
              --enable-static \
              --enable-tools \
              --disable-icuio \
              --disable-shared \
              --disable-dyload \
              --host=$3 \
              --with-cross-build=`pwd`/../icu-host \
              --prefix=${OUTPUT_PATH}
  check_success

  make -j4 install
  check_success

  echo "Copying products"
  mkdir -p $INCLUDE_PATH/icu
  cp -r output/include/* $INCLUDE_PATH/icu/

  echo "Merge static libraries"

  mkdir -p temp
  cd temp
  ar -x ../output/lib/libicudata.a
  ar -x ../output/lib/libicui18n.a
  ar -x ../output/lib/libicuuc.a
  ar rcs $LIB_PATH/${1}_libicu.a *.o *.ao
  cd ..

  check_success

  echo "Cleaning"
  cd ..
  rm -rf $ICU_VERSION
}
