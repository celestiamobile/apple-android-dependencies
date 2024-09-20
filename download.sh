#!/bin/zsh

cd `dirname $0`

. `pwd`/versions.sh

wget "https://downloads.sourceforge.net/project/libpng/libpng16/1.6.44/${LIBPNG_VERSION}.tar.xz" --no-check-certificate

#JPEG_DOWNLOAD_NAME="jpegsrc.v9e.tar.gz"
#wget "https://www.ijg.org/files/${JPEG_DOWNLOAD_NAME}" -O "${JPEG_VERSION}.tar.gz" --no-check-certificate

wget "https://downloads.sourceforge.net/project/freetype/freetype2/2.13.3/${FREETYPE_VERSION}.tar.xz" --no-check-certificate

wget "https://ftp.gnu.org/gnu/gettext/${GETTEXT_VERSION}.tar.gz" --no-check-certificate

wget "https://www.lua.org/ftp/${LUA_VERSION}.tar.gz" --no-check-certificate

wget "https://github.com/LuaJIT/LuaJIT/archive/87ae18af97fd4de790bb6c476b212e047689cc93.tar.gz" -O "${LUAJIT_VERSION}.tar.gz" --no-check-certificate

wget "https://download.gnome.org/sources/libepoxy/1.5/${LIBEPOXY_VERSION}.tar.xz" --no-check-certificate

FMT_DOWNLOAD_NAME="11.0.2.tar.gz"
wget "https://github.com/fmtlib/fmt/archive/${FMT_DOWNLOAD_NAME}" -O "${FMT_VERSION}.tar.gz" --no-check-certificate

MESHOPTIMIZER_DOWNLOAD_NAME="v0.21.tar.gz"
wget "https://github.com/zeux/meshoptimizer/archive/refs/tags/${MESHOPTIMIZER_DOWNLOAD_NAME}" -O "${MESHOPTIMIZER_VERSION}.tar.gz" --no-check-certificate

wget "https://gitlab.com/libeigen/eigen/-/archive/3.4.0/${EIGEN_VERSION}.tar.gz" --no-check-certificate

ICU_DOWNLOAD_NAME="icu4c-75_1-src.tgz"
wget "https://github.com/unicode-org/icu/releases/download/release-75-1/${ICU_DOWNLOAD_NAME}" -O "${ICU_VERSION}.tgz" --no-check-certificate

wget "https://github.com/google/breakpad/tarball/e92bea30759edbae08205bccd14dc25bf1806f93" -O "${BREAKPAD_VERSION}.tar.gz" --no-check-certificate

wget "https://github.com/nlohmann/json/releases/download/v3.11.3/json.hpp" --no-check-certificate

wget "https://zlib.net/${ZLIB_VERSION}.tar.gz" --no-check-certificate

wget "https://github.com/KhronosGroup/OpenGL-Registry/tarball/9da96319b5180c55bab6f0231d384941f4d57200" -O "${OPENGL_VERSION}.tar.gz" --no-check-certificate

wget "https://github.com/KhronosGroup/EGL-Registry/tarball/29c4314e0ef04c730992d295f91b76635019fbba" -O "${EGL_VERSION}.tar.gz" --no-check-certificate

wget "https://github.com/libjpeg-turbo/libjpeg-turbo/releases/download/3.0.4/${JPEG_TURBO_VERSION}.tar.gz" --no-check-certificate

wget "https://codeload.github.com/mackron/miniaudio/tar.gz/refs/tags/0.11.21" -O "${MINIAUDIO_VERSION}.tar.gz" --no-check-certificate

wget "https://github.com/libsdl-org/SDL/releases/download/release-2.30.7/${SDL2_VERSION}.tar.gz" --no-check-certificate

wget "https://github.com/nih-at/libzip/releases/download/v1.11.1/${LIBZIP_VERSION}.tar.gz" --no-check-certificate

# wget "https://github.com/AOMediaCodec/libavif/archive/refs/tags/v1.1.1.tar.gz" -O "${LIBAVIF_VERSION}.tar.gz" --no-check-certificate

# wget "https://storage.googleapis.com/aom-releases/${AOM_VERSION}.tar.gz" -O "${AOM_VERSION}.tar.gz" --no-check-certificate

BOOST_DOWNLOAD_NAME="boost-1.86.0-cmake"
wget "https://github.com/boostorg/boost/releases/download/boost-1.86.0/${BOOST_DOWNLOAD_NAME}.tar.xz" -O "${BOOST_VERSION}.tar.xz" --no-check-certificate
