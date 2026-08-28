#!/bin/zsh

cd `dirname $0`

. `pwd`/versions.sh

wget "https://downloads.sourceforge.net/project/libpng/libpng16/1.6.58/${LIBPNG_VERSION}.tar.xz" --no-check-certificate

#JPEG_DOWNLOAD_NAME="jpegsrc.v9e.tar.gz"
#wget "https://www.ijg.org/files/${JPEG_DOWNLOAD_NAME}" -O "${JPEG_VERSION}.tar.gz" --no-check-certificate

wget "https://downloads.sourceforge.net/project/freetype/freetype2/2.14.3/${FREETYPE_VERSION}.tar.xz" --no-check-certificate

download_gettext()
{
  local version=$1
  local checksum=$2
  local archive="${version}.tar.gz"

  wget "https://mirrors.kernel.org/gnu/gettext/${archive}" -O "${archive}" --no-check-certificate &&
    echo "${checksum}  ${archive}" | shasum -a 256 --check || exit 1
}

download_gettext "${GETTEXT_VERSION}" "85d99b79c981a404874c02e0342176cf75c7698e2b51fe41031cf6526d974f1a"
download_gettext "${GETTEXT_LEGACY_VERSION}" "40e21f07b71199fb2796fc43cee82635928eca244c62d3768f581adf928b4f06"

wget "https://www.lua.org/ftp/${LUA_VERSION}.tar.gz" --no-check-certificate

wget "https://github.com/LuaJIT/LuaJIT/archive/1edc3e52b67eaf6ce5f809be8e17d6862594b8bc.tar.gz" -O "${LUAJIT_VERSION}.tar.gz" --no-check-certificate

wget "https://github.com/anholt/libepoxy/archive/refs/tags/1.5.10.tar.gz" -O "${LIBEPOXY_VERSION}.tar.gz" --no-check-certificate

FMT_DOWNLOAD_NAME="12.2.0.tar.gz"
wget "https://github.com/fmtlib/fmt/archive/${FMT_DOWNLOAD_NAME}" -O "${FMT_VERSION}.tar.gz" --no-check-certificate

MESHOPTIMIZER_DOWNLOAD_NAME="v1.2.tar.gz"
wget "https://github.com/zeux/meshoptimizer/archive/refs/tags/${MESHOPTIMIZER_DOWNLOAD_NAME}" -O "${MESHOPTIMIZER_VERSION}.tar.gz" --no-check-certificate

wget "https://gitlab.com/libeigen/eigen/-/archive/5.0.1/${EIGEN_VERSION}.tar.gz" --no-check-certificate

wget "https://gitlab.com/libeigen/eigen/-/archive/3.4.1/${EIGEN_LEGACY_VERSION}.tar.gz" --no-check-certificate

ICU_DOWNLOAD_NAME="icu4c-78.3-sources.tgz"
wget "https://github.com/unicode-org/icu/releases/download/release-78.3/${ICU_DOWNLOAD_NAME}" -O "${ICU_VERSION}.tgz" --no-check-certificate

# wget "https://github.com/google/breakpad/tarball/e92bea30759edbae08205bccd14dc25bf1806f93" -O "${BREAKPAD_VERSION}.tar.gz" --no-check-certificate

wget "https://github.com/nlohmann/json/releases/download/v3.12.0/json.hpp" --no-check-certificate

wget "https://github.com/madler/zlib/releases/download/v1.3.2/${ZLIB_VERSION}.tar.gz" --no-check-certificate

wget "https://github.com/KhronosGroup/OpenGL-Registry/tarball/e8f7cd0e35ac8d6f5667a021ff83d04b1fec41ef" -O "${OPENGL_VERSION}.tar.gz" --no-check-certificate

wget "https://github.com/KhronosGroup/EGL-Registry/tarball/3d7796b3721d93976b6bfe536aa97bbc4bce8667" -O "${EGL_VERSION}.tar.gz" --no-check-certificate

wget "https://github.com/libjpeg-turbo/libjpeg-turbo/releases/download/3.2.0/${JPEG_TURBO_VERSION}.tar.gz" --no-check-certificate

wget "https://codeload.github.com/mackron/miniaudio/tar.gz/refs/tags/0.11.25" -O "${MINIAUDIO_VERSION}.tar.gz" --no-check-certificate


wget "https://github.com/libsdl-org/SDL/releases/download/release-2.32.10/${SDL2_VERSION}.tar.gz" --no-check-certificate

wget "https://github.com/nih-at/libzip/releases/download/v1.11.4/${LIBZIP_VERSION}.tar.gz" --no-check-certificate

# wget "https://github.com/AOMediaCodec/libavif/archive/refs/tags/v1.1.1.tar.gz" -O "${LIBAVIF_VERSION}.tar.gz" --no-check-certificate

# wget "https://storage.googleapis.com/aom-releases/${AOM_VERSION}.tar.gz" -O "${AOM_VERSION}.tar.gz" --no-check-certificate

BOOST_DOWNLOAD_NAME="boost-1.92.0-cmake"
wget "https://github.com/boostorg/boost/releases/download/boost-1.92.0/${BOOST_DOWNLOAD_NAME}.tar.xz" -O "${BOOST_VERSION}.tar.xz" --no-check-certificate

FAST_FLOAT_DOWNLOAD_NAME="v8.2.10.tar.gz"
wget "https://github.com/fastfloat/fast_float/archive/refs/tags/${FAST_FLOAT_DOWNLOAD_NAME}" -O "${FAST_FLOAT_VERSION}.tar.gz" --no-check-certificate

wget "https://ffmpeg.org/releases/${FFMPEG_VERSION}.tar.gz" --no-check-certificate

wget "https://code.videolan.org/videolan/x264/-/archive/stable/x264-stable.tar.gz" -O "${X264_VERSION}.tar.gz" --no-check-certificate