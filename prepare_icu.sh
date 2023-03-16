#!/bin/zsh

cd `dirname $0`

TARGET="macOS"

source common.sh
source cmake.sh
source versions.sh

source build_apple.sh

compile_icu_prepare
