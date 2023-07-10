#!/bin/zsh

cd `dirname $0`

source versions.sh

wget "https://naif.jpl.nasa.gov/pub/naif/toolkit/C/MacIntel_OSX_AppleC_64bit/packages/${CSPICE_VERSION}.tar.Z"

wget "https://downloads.sourceforge.net/project/libpng/libpng16/1.6.39/${LIBPNG_VERSION}.tar.xz"

JPEG_DOWNLOAD_NAME="jpegsrc.v9e.tar.gz"
wget "https://www.ijg.org/files/${JPEG_DOWNLOAD_NAME}" -O "${JPEG_VERSION}.tar.gz"

wget "https://downloads.sourceforge.net/project/freetype/freetype2/2.13.0/${FREETYPE_VERSION}.tar.xz"

wget "https://ftp.gnu.org/gnu/gettext/${GETTEXT_VERSION}.tar.gz"

wget "https://www.lua.org/ftp/${LUA_VERSION}.tar.gz"

wget "https://download.gnome.org/sources/libepoxy/1.5/${LIBEPOXY_VERSION}.tar.xz"

FMT_DOWNLOAD_NAME="9.1.0.tar.gz"
wget "https://github.com/fmtlib/fmt/archive/${FMT_DOWNLOAD_NAME}" -O "${FMT_VERSION}.tar.gz"

MESHOPTIMIZER_DOWNLOAD_NAME="v0.19.tar.gz"
wget "https://github.com/zeux/meshoptimizer/archive/refs/tags/${MESHOPTIMIZER_DOWNLOAD_NAME}" -O "${MESHOPTIMIZER_VERSION}.tar.gz"

wget "https://gitlab.com/libeigen/eigen/-/archive/3.4.0/${EIGEN_VERSION}.tar.gz"

ICU_DOWNLOAD_NAME="icu4c-72_1-src.tgz"
wget "https://github.com/unicode-org/icu/releases/download/release-72-1/${ICU_DOWNLOAD_NAME}" -O "${ICU_VERSION}.tgz"

wget "https://github.com/google/breakpad/tarball/7a1a190f4f68e8a3e06788498f50a4d5520a69f3" -O "${BREAKPAD_VERSION}.tar.gz"

wget "https://github.com/nlohmann/json/releases/download/v3.11.2/json.hpp"
