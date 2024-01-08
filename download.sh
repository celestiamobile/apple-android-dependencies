#!/bin/zsh

cd `dirname $0`

source versions.sh

wget "https://naif.jpl.nasa.gov/pub/naif/toolkit/C/MacIntel_OSX_AppleC_64bit/packages/${CSPICE_VERSION}.tar.Z"

wget "https://downloads.sourceforge.net/project/libpng/libpng16/1.6.40/${LIBPNG_VERSION}.tar.xz"

#JPEG_DOWNLOAD_NAME="jpegsrc.v9e.tar.gz"
#wget "https://www.ijg.org/files/${JPEG_DOWNLOAD_NAME}" -O "${JPEG_VERSION}.tar.gz"

wget "https://downloads.sourceforge.net/project/freetype/freetype2/2.13.2/${FREETYPE_VERSION}.tar.xz"

wget "https://ftp.gnu.org/gnu/gettext/${GETTEXT_VERSION}.tar.gz"

wget "https://www.lua.org/ftp/${LUA_VERSION}.tar.gz"

wget "https://github.com/LuaJIT/LuaJIT/archive/c525bcb9024510cad9e170e12b6209aedb330f83.tar.gz" -O "${LUAJIT_VERSION}.tar.gz"

wget "https://download.gnome.org/sources/libepoxy/1.5/${LIBEPOXY_VERSION}.tar.xz"

FMT_DOWNLOAD_NAME="10.2.1.tar.gz"
wget "https://github.com/fmtlib/fmt/archive/${FMT_DOWNLOAD_NAME}" -O "${FMT_VERSION}.tar.gz"

MESHOPTIMIZER_DOWNLOAD_NAME="v0.20.tar.gz"
wget "https://github.com/zeux/meshoptimizer/archive/refs/tags/${MESHOPTIMIZER_DOWNLOAD_NAME}" -O "${MESHOPTIMIZER_VERSION}.tar.gz"

wget "https://gitlab.com/libeigen/eigen/-/archive/3.4.0/${EIGEN_VERSION}.tar.gz"

ICU_DOWNLOAD_NAME="icu4c-74_1-src.tgz"
wget "https://github.com/unicode-org/icu/releases/download/release-74-1/${ICU_DOWNLOAD_NAME}" -O "${ICU_VERSION}.tgz"

wget "https://github.com/google/breakpad/tarball/22f54f197fe5be28abda6e00bdfaaed9e87f9851" -O "${BREAKPAD_VERSION}.tar.gz"

wget "https://github.com/nlohmann/json/releases/download/v3.11.3/json.hpp"

wget "https://zlib.net/${ZLIB_VERSION}.tar.gz"

wget "https://github.com/KhronosGroup/OpenGL-Registry/tarball/ca491a0576d5c026f06ebe29bfac7cbbcf1e8332" -O "${OPENGL_VERSION}.tar.gz"

wget "https://github.com/KhronosGroup/EGL-Registry/tarball/a03692eea13514d9aef01822b2bc6575fcabfac2" -O "${EGL_VERSION}.tar.gz"

wget "https://downloads.sourceforge.net/project/libjpeg-turbo/3.0.1/${JPEG_TURBO_VERSION}.tar.gz"

wget "https://codeload.github.com/mackron/miniaudio/tar.gz/refs/tags/0.11.21" -O "${MINIAUDIO_VERSION}.tar.gz"
