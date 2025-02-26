#!/bin/zsh

cd `dirname $0`

. `pwd`/versions.sh

wget "https://downloads.sourceforge.net/project/libpng/libpng16/1.6.47/${LIBPNG_VERSION}.tar.xz" --no-check-certificate

#JPEG_DOWNLOAD_NAME="jpegsrc.v9e.tar.gz"
#wget "https://www.ijg.org/files/${JPEG_DOWNLOAD_NAME}" -O "${JPEG_VERSION}.tar.gz" --no-check-certificate

wget "https://downloads.sourceforge.net/project/freetype/freetype2/2.13.3/${FREETYPE_VERSION}.tar.xz" --no-check-certificate

wget "https://ftp.gnu.org/gnu/gettext/${GETTEXT_VERSION}.tar.gz" --no-check-certificate

wget "https://www.lua.org/ftp/${LUA_VERSION}.tar.gz" --no-check-certificate

wget "https://github.com/LuaJIT/LuaJIT/archive/a4f56a459a588ae768801074b46ba0adcfb49eb1.tar.gz" -O "${LUAJIT_VERSION}.tar.gz" --no-check-certificate

wget "https://github.com/anholt/libepoxy/archive/refs/tags/1.5.10.tar.gz" -O "${LIBEPOXY_VERSION}.tar.gz" --no-check-certificate

FMT_DOWNLOAD_NAME="11.1.3.tar.gz"
wget "https://github.com/fmtlib/fmt/archive/${FMT_DOWNLOAD_NAME}" -O "${FMT_VERSION}.tar.gz" --no-check-certificate

MESHOPTIMIZER_DOWNLOAD_NAME="v0.22.tar.gz"
wget "https://github.com/zeux/meshoptimizer/archive/refs/tags/${MESHOPTIMIZER_DOWNLOAD_NAME}" -O "${MESHOPTIMIZER_VERSION}.tar.gz" --no-check-certificate

wget "https://gitlab.com/libeigen/eigen/-/archive/3.4.0/${EIGEN_VERSION}.tar.gz" --no-check-certificate

ICU_DOWNLOAD_NAME="icu4c-76_1-src.tgz"
wget "https://github.com/unicode-org/icu/releases/download/release-76-1/${ICU_DOWNLOAD_NAME}" -O "${ICU_VERSION}.tgz" --no-check-certificate

# wget "https://github.com/google/breakpad/tarball/e92bea30759edbae08205bccd14dc25bf1806f93" -O "${BREAKPAD_VERSION}.tar.gz" --no-check-certificate

wget "https://github.com/nlohmann/json/releases/download/v3.11.3/json.hpp" --no-check-certificate

wget "https://zlib.net/${ZLIB_VERSION}.tar.gz" --no-check-certificate

wget "https://github.com/KhronosGroup/OpenGL-Registry/tarball/b53ca669bea4715b6d5fa53c459f47a1fecd7944" -O "${OPENGL_VERSION}.tar.gz" --no-check-certificate

wget "https://github.com/KhronosGroup/EGL-Registry/tarball/29c4314e0ef04c730992d295f91b76635019fbba" -O "${EGL_VERSION}.tar.gz" --no-check-certificate

wget "https://github.com/libjpeg-turbo/libjpeg-turbo/releases/download/3.1.0/${JPEG_TURBO_VERSION}.tar.gz" --no-check-certificate

wget "https://codeload.github.com/mackron/miniaudio/tar.gz/refs/tags/0.11.22" -O "${MINIAUDIO_VERSION}.tar.gz" --no-check-certificate

wget "https://github.com/libsdl-org/SDL/releases/download/release-2.32.0/${SDL2_VERSION}.tar.gz" --no-check-certificate

wget "https://github.com/nih-at/libzip/releases/download/v1.11.3/${LIBZIP_VERSION}.tar.gz" --no-check-certificate

# wget "https://github.com/AOMediaCodec/libavif/archive/refs/tags/v1.1.1.tar.gz" -O "${LIBAVIF_VERSION}.tar.gz" --no-check-certificate

# wget "https://storage.googleapis.com/aom-releases/${AOM_VERSION}.tar.gz" -O "${AOM_VERSION}.tar.gz" --no-check-certificate

BOOST_DOWNLOAD_NAME="boost-1.87.0-cmake"
wget "https://github.com/boostorg/boost/releases/download/boost-1.87.0/${BOOST_DOWNLOAD_NAME}.tar.xz" -O "${BOOST_VERSION}.tar.xz" --no-check-certificate
