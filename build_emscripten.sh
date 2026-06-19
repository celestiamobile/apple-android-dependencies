#!/bin/zsh

cd `dirname $0`

TARGET="Emscripten"

RESULT_PATH=$1

EMSDK_ROOT=$2

. `pwd`/common.sh
. `pwd`/cmake.sh
. `pwd`/versions.sh

mkdir -p $RESULT_PATH

TIMESTAMP=`git show --no-patch --format=%cd --date=format-local:'%Y%m%d'`

build_with_cmake "fast_float" $FAST_FLOAT_VERSION ".tar.gz" "fast_float" "none" ".." "none"
build_with_cmake "boost" $BOOST_VERSION ".tar.xz" "boost" "libboost_container" ".." "none" "-DBOOST_INCLUDE_LIBRARIES='container;container_hash;describe;smart_ptr'" "-DBUILD_SHARED_LIBS=OFF" "-DCMAKE_CXX_FLAGS=-pthread"
build_with_cmake "SDL2" $SDL2_VERSION ".tar.gz" "SDL2" "libSDL2" ".." "none" "-DSDL_STATIC=ON" "-DSDL_SHARED=OFF" "-DSDL_TEST=OFF" "-DSDL_TESTS=OFF"

configure_emscripten
build_with_cmake "jpeg" $JPEG_TURBO_VERSION ".tar.gz" "jpeg" "libjpeg" ".." "none" "-DENABLE_STATIC=ON" "-DENABLE_SHARED=OFF" "-DWITH_TURBOJPEG=OFF" "-DWITH_SIMD=OFF" "-DBUILD=$TIMESTAMP"
build_with_cmake "zlib" $ZLIB_VERSION ".tar.gz" "zlib" "libz" ".." "none" "-DZLIB_BUILD_SHARED=OFF"
build_with_cmake "libpng" $LIBPNG_VERSION ".tar.xz" "libpng" "libpng" ".." "none" "-DZLIB_LIBRARY=$RESULT_PATH/lib/libz.a" "-DZLIB_INCLUDE_DIR=$RESULT_PATH/include" "-DPNG_SHARED=OFF"
build_with_cmake "freetype" $FREETYPE_VERSION ".tar.xz" "freetype" "libfreetype" ".." "freetype2" "-DZLIB_LIBRARY=$RESULT_PATH/lib/libz.a" "-DZLIB_INCLUDE_DIR=$RESULT_PATH/include" "-DFT_DISABLE_BROTLI=ON" "-DFT_DISABLE_HARFBUZZ=ON" "-DFT_DISABLE_PNG=ON"
build_with_cmake "fmt" $FMT_VERSION ".tar.gz" "fmt" "libfmt" ".." "none" "-DFMT_TEST=OFF" "-DBUILD_SHARED_LIBS=OFF"
build_with_cmake "meshoptimizer" $MESHOPTIMIZER_VERSION ".tar.gz" "meshoptimizer" "libmeshoptimizer"
build_with_cmake "eigen3" $EIGEN_LEGACY_VERSION ".tar.gz"
# build_with_cmake "aom" $AOM_VERSION ".tar.gz" "aom" "libaom" ".." "none" "-DCMAKE_CXX_STANDARD=17" "-DAOM_TARGET_CPU=CELESTIA_STANDARD_ARCH" "-DENABLE_DOCS=OFF" "-DBUILD_SHARED_LIBS=OFF" "-DENABLE_EXAMPLES=OFF"  "-DENABLE_TESTDATA=OFF" "-DENABLE_TESTS=OFF" "-DENABLE_TOOLS=OFF"
# build_with_cmake "libavif" $LIBAVIF_VERSION ".tar.gz" "libavif" "libavif" ".." "none" "-DAVIF_BUILD_APPS=OFF" "-DBUILD_SHARED_LIBS=OFF" "-DAOM_INCLUDE_DIR=$RESULT_PATH/include/aom" "-DAOM_LIBRARY=$RESULT_PATH/lib/libaom.a" "-DCMAKE_DISABLE_FIND_PACKAGE_libsharpyuv=TRUE"  "-DCMAKE_DISABLE_FIND_PACKAGE_libyuv=TRUE" "-DAVIF_CODEC_AOM=SYSTEM"
#
## CSPICE
#
#echo "Building CSPICE"
#compile_cspice()
#{
#  wget "https://naif.jpl.nasa.gov/pub/naif/toolkit/C/MacIntel_OSX_AppleC_64bit/packages/$CSPICE_VERSION.tar.Z" --no-check-certificate
#  unarchive_and_enter $CSPICE_VERSION ".tar.Z"
#
#  echo "Applying patch 1"
#  sed -ie 's/rv  = system(buff);/\/\/ rv  = system(buff);/g' src/cspice/system_.c
#  check_success
#  echo "Applying patch 2"
#  TO_REPLACE="ranlib"
#  NEW_STRING=$RANLIB
#  sed -ie "s#${TO_REPLACE}#${NEW_STRING}#g" src/cspice/mkprodct.csh
#  check_success
#  echo "Applying patch 3"
#  TO_REPLACE="ar  crv"
#  NEW_STRING="${AR}  crv"
#  sed -ie "s#${TO_REPLACE}#${NEW_STRING}#g" src/cspice/mkprodct.csh
#  check_success
#
#  cd src/cspice
#  export TKCOMPILER=$CC
#  export TKCOMPILEOPTIONS="-c -ansi -O2 -fPIC -DNON_UNIX_STDIO"
#  export TKLINKOPTIONS="-lm"
#  tcsh mkprodct.csh
#  check_success
#  cd ../..
#
#  echo "Copying products"
#  mkdir -p $INCLUDE_PATH/cspice
#  cp -r include/* $INCLUDE_PATH/cspice/
#  cp lib/cspice.a $LIB_PATH
#  check_success
#
#  echo "Cleaning"
#  cd ..
#  rm -rf $CSPICE_VERSION
#  rm -rf "$CSPICE_VERSION.tar.Z"
#}
#
#configure_emscripten
#compile_cspice

# gettext

echo "Building gettext"
compile_gettext()
{
  unarchive_and_enter $GETTEXT_LEGACY_VERSION ".tar.gz"
  cd gettext-runtime

  OUTPUT_PATH=$RESULT_PATH
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

  echo "Cleaning"
  cd ../..
  rm -rf $GETTEXT_LEGACY_VERSION
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

  OUTPUT_PATH=$RESULT_PATH

  make generic install INSTALL_TOP=${OUTPUT_PATH}
  check_success

  echo "Applying patch 6"
  TO_REPLACE="prefix= /usr/local"
  NEW_STRING="prefix= ${RESULT_PATH}"
  sed -ie "s#${TO_REPLACE}#${NEW_STRING}#g" etc/lua.pc
  check_success

  cp etc/lua.pc $RESULT_PATH/lib/pkgconfig
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
  unarchive_and_enter $LIBEPOXY_VERSION ".tar.gz"

  # Patch dispatch_common.h: add __EMSCRIPTEN__ platform case
  echo "Applying emscripten patch 1 (dispatch_common.h)"
  sed -ie 's/#elif defined(__APPLE__)/#elif defined(__EMSCRIPTEN__)\
#define PLATFORM_HAS_EGL ENABLE_EGL\
#define PLATFORM_HAS_GLX 0\
#define PLATFORM_HAS_WGL 0\
#elif defined(__APPLE__)/' src/dispatch_common.h
  check_success

  # Patch dispatch_common.c: add __EMSCRIPTEN__ library defines
  echo "Applying emscripten patch 2 (library defines)"
  sed -ie 's/#if defined(__APPLE__)/#if defined(__EMSCRIPTEN__)\
#define GLX_LIB NULL\
#define EGL_LIB NULL\
#define GLES1_LIB NULL\
#define GLES2_LIB NULL\
#define OPENGL_LIB NULL\
#elif defined(__APPLE__)/' src/dispatch_common.c
  check_success

  # Patch: treat emscripten like Android for core_symbol_support (all via eglGetProcAddress)
  echo "Applying emscripten patch 3 (core_symbol_support = 0)"
  sed -ie 's/#elif defined(__ANDROID__)/#elif defined(__EMSCRIPTEN__) || defined(__ANDROID__)/' src/dispatch_common.c
  check_success

  # Patch: add extern declaration for emscripten helper (defined in dispatch_emscripten.c)
  echo "Applying emscripten patch 4 (extern helper declaration)"
  sed -ie '/^#include "dispatch_common.h"/a\
\
#ifdef __EMSCRIPTEN__\
/* Defined in dispatch_emscripten.c to avoid epoxy macro conflicts */\
extern void *_epoxy_emscripten_gpa(const char *name);\
#endif
' src/dispatch_common.c
  check_success

  # Patch get_dlopen_handle: return sentinel on emscripten (no dlopen support)
  echo "Applying emscripten patch 5 (get_dlopen_handle)"
  perl -i -0pe 's/(get_dlopen_handle\(void \*\*handle, const char \*lib_name, bool exit_on_fail, bool load\)\n\{)/$1\n#ifdef __EMSCRIPTEN__\n    (void)lib_name; (void)exit_on_fail; (void)load;\n    if (!*handle) *handle = (void*)0x1;\n    return true;\n#endif/' src/dispatch_common.c
  check_success

  # Patch do_dlsym: use emscripten helper for function resolution
  echo "Applying emscripten patch 6 (do_dlsym)"
  perl -i -0pe 's/(do_dlsym\(void \*\*handle, const char \*name, bool exit_on_fail\)\n\{\n    void \*result;\n    const char \*error = "";)/$1\n#ifdef __EMSCRIPTEN__\n    (void)handle; (void)error;\n    result = _epoxy_emscripten_gpa(name);\n    if (!result \&\& exit_on_fail) { fprintf(stderr, "%s() not found\\n", name); abort(); }\n    return result;\n#endif/' src/dispatch_common.c
  check_success

  # Create dispatch_emscripten.c: resolves EGL+GL functions without epoxy macro interference
  echo "Creating dispatch_emscripten.c"
  cat > src/dispatch_emscripten.c << 'EMEOF'
#ifdef __EMSCRIPTEN__
#include <EGL/egl.h>
#include <string.h>

void *_epoxy_emscripten_gpa(const char *name) {
    void *ret = (void*)eglGetProcAddress(name);
    if (ret) return ret;

    /* EGL functions are linked directly but eglGetProcAddress
     * does not return them per the EGL spec. Match by name. */
    #define EGL_FN(fn) if (strcmp(name, #fn) == 0) return (void*)&fn;
    EGL_FN(eglGetProcAddress)
    EGL_FN(eglGetCurrentDisplay)
    EGL_FN(eglGetCurrentContext)
    EGL_FN(eglGetCurrentSurface)
    EGL_FN(eglQueryContext)
    EGL_FN(eglGetError)
    EGL_FN(eglBindAPI)
    EGL_FN(eglQueryAPI)
    EGL_FN(eglQueryString)
    EGL_FN(eglSwapInterval)
    EGL_FN(eglSwapBuffers)
    EGL_FN(eglMakeCurrent)
    EGL_FN(eglDestroyContext)
    EGL_FN(eglDestroySurface)
    EGL_FN(eglGetDisplay)
    EGL_FN(eglInitialize)
    EGL_FN(eglTerminate)
    EGL_FN(eglChooseConfig)
    EGL_FN(eglGetConfigAttrib)
    EGL_FN(eglGetConfigs)
    EGL_FN(eglCreateWindowSurface)
    EGL_FN(eglCreateContext)
    EGL_FN(eglQuerySurface)
    EGL_FN(eglReleaseThread)
    EGL_FN(eglWaitClient)
    EGL_FN(eglWaitGL)
    EGL_FN(eglWaitNative)
    #undef EGL_FN

    return NULL;
}
#endif
EMEOF
  check_success

  # Add dispatch_emscripten.c to meson build sources
  echo "Patching meson.build to include dispatch_emscripten.c"
  sed -ie "s/epoxy_sources = sources + gen_sources/epoxy_sources = sources + gen_sources + ['dispatch_emscripten.c']/" src/meson.build
  check_success

  mkdir build
  cd build

  OPTIONS_FILE="../../emscripten.txt"

  echo "Replacing SDK path in cross file"
  TO_REPLACE="/Users/linfel/Developer/Personal/Celestia/emsdk"
  NEW_STRING="$EMSDK_ROOT"
  sed -ie "s#${TO_REPLACE}#${NEW_STRING}#g" $OPTIONS_FILE

  meson setup --buildtype=release --default-library=static -Dtests=false -Degl=yes -Dglx=no -Dx11=false --prefix=$RESULT_PATH --cross-file $OPTIONS_FILE .  ..
  check_success

  ninja install
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

  OUTPUT_PATH=$RESULT_PATH
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

  echo "Cleaning"
  cd ..
  rm -rf $ICU_VERSION
}

configure_emscripten
compile_icu

unarchive_and_enter $MINIAUDIO_VERSION ".tar.gz"
cp miniaudio.h $RESULT_PATH/include/
cd ..
