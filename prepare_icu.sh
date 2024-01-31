#!/bin/zsh

cd `dirname $0`

if [ "$(uname)" = "Darwin" ]; then
  TARGET="macOS"
  ICU_HOST=MacOSX
else
  TARGET="Linux"
  ICU_HOST=Linux
fi

. `pwd`/common.sh
. `pwd`/versions.sh

compile_icu_prepare()
{
  unarchive_and_enter $ICU_VERSION ".tgz"

  ./source/runConfigureICU $ICU_HOST
  check_success

  make -j4
  check_success

  cd ..

  mv $ICU_VERSION icu-host
  check_success
}

compile_icu_prepare
