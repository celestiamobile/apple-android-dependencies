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
  if [ "$2" = ".tar.gz" ] || [ "$2" = ".tgz" ]; then
    tar -zxvf "${1}${2}" -C . >/dev/null 2>&1
    check_success
  elif [ "$2" = ".tar.xz" ]; then
    tar -xvJf "${1}${2}" -C . >/dev/null 2>&1
    check_success
  elif [ "$2" = ".tar.Z" ]; then
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

configure_arm64()
{
  export AR=$NDK_TOOLCHAIN/bin/llvm-ar
  export AS=$NDK_TOOLCHAIN/bin/llvm-as
  export LD=$NDK_TOOLCHAIN/bin/llvm-ld
  export RANLIB=$NDK_TOOLCHAIN/bin/llvm-ranlib
  export STRIP=$NDK_TOOLCHAIN/bin/llvm-strip
  export BIN_PREFIX="$NDK_TOOLCHAIN/bin/aarch64-linux-android23-"
  export STATIC_CC="${BIN_PREFIX}clang"
  export CC="$STATIC_CC -fPIC"
  export CXX="${BIN_PREFIX}clang++ -fPIC"
  export HOST=aarch64-linux-android
}

configure_armv7()
{
  export AR=$NDK_TOOLCHAIN/bin/llvm-ar
  export AS=$NDK_TOOLCHAIN/bin/llvm-as
  export LD=$NDK_TOOLCHAIN/bin/llvm-ld
  export RANLIB=$NDK_TOOLCHAIN/bin/llvm-ranlib
  export STRIP=$NDK_TOOLCHAIN/bin/llvm-strip
  export BIN_PREFIX="$NDK_TOOLCHAIN/bin/armv7a-linux-androideabi23-"
  export STATIC_CC="${BIN_PREFIX}clang"
  export CC="$STATIC_CC -fPIC"
  export CXX="${BIN_PREFIX}clang++ -fPIC"
  export HOST=armv7a-linux-androideabi
}

configure_x86()
{
  export AR=$NDK_TOOLCHAIN/bin/llvm-ar
  export AS=$NDK_TOOLCHAIN/bin/llvm-as
  export LD=$NDK_TOOLCHAIN/bin/llvm-ld
  export RANLIB=$NDK_TOOLCHAIN/bin/llvm-ranlib
  export STRIP=$NDK_TOOLCHAIN/bin/llvm-strip
  export BIN_PREFIX="$NDK_TOOLCHAIN/bin/i686-linux-android23-"
  export STATIC_CC="${BIN_PREFIX}clang"
  export CC="$STATIC_CC -fPIC"
  export CXX="${BIN_PREFIX}clang++ -fPIC"
  export HOST=i686-linux-android
}

configure_x86_64()
{
  export AR=$NDK_TOOLCHAIN/bin/llvm-ar
  export AS=$NDK_TOOLCHAIN/bin/llvm-as
  export STATIC_CC=$NDK_TOOLCHAIN/bin/llvm-as
  export LD=$NDK_TOOLCHAIN/bin/llvm-ld
  export RANLIB=$NDK_TOOLCHAIN/bin/llvm-ranlib
  export STRIP=$NDK_TOOLCHAIN/bin/llvm-strip
  export BIN_PREFIX="$NDK_TOOLCHAIN/bin/x86_64-linux-android23-"
  export STATIC_CC="${BIN_PREFIX}clang"
  export CC="$STATIC_CC -fPIC"
  export CXX="${BIN_PREFIX}clang++ -fPIC"
  export HOST=x86_64-linux-android
}

configure_emscripten()
{
  export AR=emar
  export CC="emcc -fPIC"
  export CXX="em++ -fPIC"
  export RANLIB=emranlib
  export STRIP=emstrip
}

if [ "$TARGET" = "iOS" ]; then
  CMAKE=cmake
  CMAKE_TOOLCHAIN_PATH="$(pwd)/ios.toolchain.cmake"
  CC_EXECUTABLE=$(xcrun --sdk iphoneos --find clang)
  if [ "$LEGACY_SUPPORT" = true ]; then
    CC_ARM64_FLAGS="-isysroot $(xcrun --sdk iphoneos --show-sdk-path) -arch arm64 -miphoneos-version-min=11.0"
  else
    CC_ARM64_FLAGS="-isysroot $(xcrun --sdk iphoneos --show-sdk-path) -arch arm64 -miphoneos-version-min=14.0"
  fi
  CC_ARM64="$CC_EXECUTABLE $CC_ARM64_FLAGS"
elif [ "$TARGET" = "iOSSimulator" ]; then
  CMAKE=cmake
  CMAKE_TOOLCHAIN_PATH="$(pwd)/ios.toolchain.cmake"
  CC_EXECUTABLE=$(xcrun --sdk iphonesimulator --find clang)
  if [ "$LEGACY_SUPPORT" = true ]; then
    CC_X86_64_FLAGS="-isysroot $(xcrun --sdk iphonesimulator --show-sdk-path) -arch x86_64 -miphonesimulator-version-min=11.0"
    CC_ARM64_FLAGS="-isysroot $(xcrun --sdk iphonesimulator --show-sdk-path) -arch arm64 -miphonesimulator-version-min=11.0"
  else
    CC_X86_64_FLAGS="-isysroot $(xcrun --sdk iphonesimulator --show-sdk-path) -arch x86_64 -miphonesimulator-version-min=14.0"
    CC_ARM64_FLAGS="-isysroot $(xcrun --sdk iphonesimulator --show-sdk-path) -arch arm64 -miphonesimulator-version-min=14.0"
  fi
  CC_X86_64="$CC_EXECUTABLE $CC_X86_64_FLAGS"
  CC_ARM64="$CC_EXECUTABLE $CC_ARM64_FLAGS"
elif [ "$TARGET" = "visionOS" ]; then
  CMAKE=cmake
  CMAKE_TOOLCHAIN_PATH="$(pwd)/ios.toolchain.cmake"
  CC_EXECUTABLE=$(xcrun --sdk xros --find clang)
  CC_ARM64_FLAGS="-isysroot $(xcrun --sdk xros --show-sdk-path) -target arm64-apple-xros1.0"
  CC_ARM64="$CC_EXECUTABLE $CC_ARM64_FLAGS"
elif [ "$TARGET" = "visionOSSimulator" ]; then
  CMAKE=cmake
  CMAKE_TOOLCHAIN_PATH="$(pwd)/ios.toolchain.cmake"
  CC_EXECUTABLE=$(xcrun --sdk xrsimulator --find clang)
  CC_X86_64_FLAGS="-isysroot $(xcrun --sdk xrsimulator --show-sdk-path) -target x86_64-apple-xros1.0-simulator"
  CC_ARM64_FLAGS="-isysroot $(xcrun --sdk xrsimulator --show-sdk-path) -target arm64-apple-xros1.0-simulator"
  CC_X86_64="$CC_EXECUTABLE $CC_X86_64_FLAGS"
  CC_ARM64="$CC_EXECUTABLE $CC_ARM64_FLAGS"
elif [ "$TARGET" = "macOS" ]; then
  CMAKE=cmake
  CMAKE_TOOLCHAIN_PATH="$(pwd)/ios.toolchain.cmake"
  CC_EXECUTABLE=$(xcrun --sdk macosx --find clang)
  if [ "$LEGACY_SUPPORT" = true ]; then
    CC_X86_64_FLAGS="-isysroot $(xcrun --sdk macosx --show-sdk-path)  -arch x86_64 -mmacosx-version-min=10.12"
    DEPLOYMENT_TARGET_X86_64="10.12"
  else
    CC_X86_64_FLAGS="-isysroot $(xcrun --sdk macosx --show-sdk-path)  -arch x86_64 -mmacosx-version-min=11.0"
    DEPLOYMENT_TARGET_X86_64="11.0"
  fi
  CC_ARM64_FLAGS="-isysroot $(xcrun --sdk macosx --show-sdk-path)  -arch arm64 -mmacosx-version-min=11.0"
  DEPLOYMENT_TARGET_ARM64="11.0"
  CC_X86_64="$CC_EXECUTABLE $CC_X86_64_FLAGS"
  CC_ARM64="$CC_EXECUTABLE $CC_ARM64_FLAGS"
elif [ "$TARGET" = "macCatalyst" ]; then
  CMAKE=cmake
  CMAKE_TOOLCHAIN_PATH="$(pwd)/ios.toolchain.cmake"
  CC_EXECUTABLE=$(xcrun --sdk macosx --find clang)
  CC_X86_64_FLAGS="-isysroot $(xcrun --sdk macosx --show-sdk-path) -target x86_64-apple-ios-macabi -miphoneos-version-min=14.0"
  CC_ARM64_FLAGS="-isysroot $(xcrun --sdk macosx --show-sdk-path) -target arm64-apple-ios-macabi -miphoneos-version-min=14.0"
  CC_X86_64="$CC_EXECUTABLE $CC_X86_64_FLAGS"
  CC_ARM64="$CC_EXECUTABLE $CC_ARM64_FLAGS"
elif [ "$TARGET" = "Android" ]; then
  CMAKE=cmake
  CMAKE_TOOLCHAIN_PATH=$NDK_ROOT/build/cmake/android.toolchain.cmake
elif [ "$TARGET" = "Linux" ]; then
  CMAKE=cmake
elif [ "$TARGET" = "Emscripten" ]; then
  CMAKE=cmake
else
  echo "Unknown target"
  exit
fi
