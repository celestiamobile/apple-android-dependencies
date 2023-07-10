check_success()
{
  if [ $? -eq 0 ]; then
    echo "Succeeded"
  else
    echo "Failed"
    exit
  fi
}

fat_create_and_clean()
{
  echo "Creating FAT binary"
  lipo -create $LIB_PATH/*_${1}.a -o $LIB_PATH/${1}.a
  check_success

  echo "Cleaning"
  rm -rf $LIB_PATH/*_${1}.a
}

# $1 archive name
# $2 archive extension
unarchive_and_enter()
{
  echo "Unarchiving"
  if [ "$2" == ".tar.gz" ] || [ "$2" == ".tgz" ]; then
    tar -zxvf "${1}${2}" -C . >/dev/null 2>&1
    check_success
  elif [ "$2" == ".tar.xz" ]; then
    tar -xvJf "${1}${2}" -C . >/dev/null 2>&1
    check_success
  elif [ "$2" == ".tar.Z" ]; then
    tar -xZvf "${1}${2}" -C . >/dev/null 2>&1
    check_success
  else
    echo "Unknown format"
    exit
  fi

  if [ -n "$3" ]; then
    cd $3
    check_success
  else
    cd $1
    check_success
  fi
}

export HOST_TAG=darwin-x86_64
export TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/$HOST_TAG

configure_arm64()
{
  export AR=$TOOLCHAIN/bin/llvm-ar
  export AS=$TOOLCHAIN/bin/llvm-as
  export CC="$TOOLCHAIN/bin/aarch64-linux-android21-clang -fPIC"
  export CXX="$TOOLCHAIN/bin/aarch64-linux-android21-clang++ -fPIC"
  export LD=$TOOLCHAIN/bin/llvm-ld
  export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
  export STRIP=$TOOLCHAIN/bin/llvm-strip
}

configure_armv7()
{
  export AR=$TOOLCHAIN/bin/llvm-ar
  export AS=$TOOLCHAIN/bin/llvm-as
  export CC="$TOOLCHAIN/bin/armv7a-linux-androideabi21-clang -fPIC"
  export CXX="$TOOLCHAIN/bin/armv7a-linux-androideabi21-clang++ -fPIC"
  export LD=$TOOLCHAIN/bin/llvm-ld
  export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
  export STRIP=$TOOLCHAIN/bin/llvm-strip
}

configure_x86()
{
  export AR=$TOOLCHAIN/bin/llvm-ar
  export AS=$TOOLCHAIN/bin/llvm-as
  export CC="$TOOLCHAIN/bin/i686-linux-android21-clang -fPIC"
  export CXX="$TOOLCHAIN/bin/i686-linux-android21-clang++ -fPIC"
  export LD=$TOOLCHAIN/bin/llvm-ld
  export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
  export STRIP=$TOOLCHAIN/bin/llvm-strip
}

configure_x86_64()
{
  export AR=$TOOLCHAIN/bin/llvm-ar
  export AS=$TOOLCHAIN/bin/llvm-as
  export CC="$TOOLCHAIN/bin/x86_64-linux-android21-clang -fPIC"
  export CXX="$TOOLCHAIN/bin/x86_64-linux-android21-clang++ -fPIC"
  export LD=$TOOLCHAIN/bin/llvm-ld
  export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
  export STRIP=$TOOLCHAIN/bin/llvm-strip
}

configure_emscripten()
{
  export AR=emar
  export CC="emcc -fPIC"
  export CXX="em++ -fPIC"
  export RANLIB=emranlib
  export STRIP=emstrip
}

if [ "$TARGET" == "iOS" ]; then
  LIB_PATH="$(pwd)/ios/libs"
  INCLUDE_PATH="$(pwd)/ios/include"
  CMAKE=cmake
  CMAKE_TOOLCHAIN_PATH="$(pwd)/ios.toolchain.cmake"
  if [ "$LEGACY_SUPPORT" = true ]; then
    CC_ARM64="$(xcrun --sdk iphoneos --find clang) -isysroot $(xcrun --sdk iphoneos --show-sdk-path) -arch arm64 -miphoneos-version-min=11.0"
  else
    CC_ARM64="$(xcrun --sdk iphoneos --find clang) -isysroot $(xcrun --sdk iphoneos --show-sdk-path) -arch arm64 -miphoneos-version-min=13.1"
  fi
elif [ "$TARGET" == "iOSSimulator" ]; then
  LIB_PATH="$(pwd)/iossim/libs"
  INCLUDE_PATH="$(pwd)/iossim/include"
  CMAKE=cmake
  CMAKE_TOOLCHAIN_PATH="$(pwd)/ios.toolchain.cmake"
  if [ "$LEGACY_SUPPORT" = true ]; then
    CC_X86_64="$(xcrun --sdk iphonesimulator --find clang) -isysroot $(xcrun --sdk iphonesimulator --show-sdk-path) -arch x86_64 -miphonesimulator-version-min=11.0"
    CC_ARM64="$(xcrun --sdk iphonesimulator --find clang) -isysroot $(xcrun --sdk iphonesimulator --show-sdk-path) -arch arm64 -miphonesimulator-version-min=11.0"
  else
    CC_X86_64="$(xcrun --sdk iphonesimulator --find clang) -isysroot $(xcrun --sdk iphonesimulator --show-sdk-path) -arch x86_64 -miphonesimulator-version-min=13.1"
    CC_ARM64="$(xcrun --sdk iphonesimulator --find clang) -isysroot $(xcrun --sdk iphonesimulator --show-sdk-path) -arch arm64 -miphonesimulator-version-min=13.1"
  fi
elif [ "$TARGET" == "visionOS" ]; then
  LIB_PATH="$(pwd)/visionos/libs"
  INCLUDE_PATH="$(pwd)/visionos/include"
  CMAKE=cmake
  CMAKE_TOOLCHAIN_PATH="$(pwd)/ios.toolchain.cmake"
  CC_ARM64="$(xcrun --sdk xros --find clang) -isysroot $(xcrun --sdk xros --show-sdk-path) -target arm64-apple-xros1.0"
elif [ "$TARGET" == "visionOSSimulator" ]; then
  LIB_PATH="$(pwd)/visionossim/libs"
  INCLUDE_PATH="$(pwd)/visionossim/include"
  CMAKE=cmake
  CMAKE_TOOLCHAIN_PATH="$(pwd)/ios.toolchain.cmake"
  CC_X86_64="$(xcrun --sdk xrsimulator --find clang) -isysroot $(xcrun --sdk xrsimulator --show-sdk-path) -target x86_64-apple-xros1.0-simulator"
  CC_ARM64="$(xcrun --sdk xrsimulator --find clang) -isysroot $(xcrun --sdk xrsimulator --show-sdk-path) -target arm64-apple-xros1.0-simulator"
elif [ "$TARGET" == "macOS" ]; then
  LIB_PATH="$(pwd)/mac/libs"
  INCLUDE_PATH="$(pwd)/mac/include"
  CMAKE=cmake
  CMAKE_TOOLCHAIN_PATH="$(pwd)/ios.toolchain.cmake"
  if [ "$LEGACY_SUPPORT" = true ]; then
    CC_X86_64="$(xcrun --sdk macosx --find clang) -isysroot $(xcrun --sdk macosx --show-sdk-path)  -arch x86_64 -mmacosx-version-min=10.12"
  else
    CC_X86_64="$(xcrun --sdk macosx --find clang) -isysroot $(xcrun --sdk macosx --show-sdk-path)  -arch x86_64 -mmacosx-version-min=10.15"
  fi
  CC_ARM64="$(xcrun --sdk macosx --find clang) -isysroot $(xcrun --sdk macosx --show-sdk-path)  -arch arm64 -mmacosx-version-min=11.0"
elif [ "$TARGET" == "macCatalyst" ]; then
  LIB_PATH="$(pwd)/catalyst/libs"
  INCLUDE_PATH="$(pwd)/catalyst/include"
  CMAKE=cmake
  CMAKE_TOOLCHAIN_PATH="$(pwd)/ios.toolchain.cmake"
  CC_X86_64="$(xcrun --sdk macosx --find clang) -isysroot $(xcrun --sdk macosx --show-sdk-path) -target x86_64-apple-ios-macabi -miphoneos-version-min=13.1"
  CC_ARM64="$(xcrun --sdk macosx --find clang) -isysroot $(xcrun --sdk macosx --show-sdk-path) -target arm64-apple-ios-macabi -miphoneos-version-min=14.0"
elif [ "$TARGET" == "Android" ]; then
  LIB_PATH="$(pwd)/android/libs"
  INCLUDE_PATH="$(pwd)/android/include"
  CMAKE=$NDK/../../cmake/3.22.1/bin/cmake
  CMAKE_TOOLCHAIN_PATH=$NDK/build/cmake/android.toolchain.cmake
elif [ "$TARGET" == "Emscripten" ]; then
  LIB_PATH="$(pwd)/emscripten/libs"
  INCLUDE_PATH="$(pwd)/emscripten/include"
  CMAKE=cmake
else
  echo "Unknown target"
  exit
fi
