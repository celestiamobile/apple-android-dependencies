# $1 arch
# $2 archive name
# $3 archive extension
# $4 lib directory name
# $5 lib name
# $6 cmake file path
# $7 extra params
build_with_cmake_arch()
{
  if [ "$TARGET" != "Emscripten" ] ; then
    echo "Building for $1"
  fi

  unarchive_and_enter $2 $3

  mkdir build
  cd build

  OUTPUT_PATH=$(pwd)/output

  if [ "$TARGET" == "iOS" ]; then
    echo "Building for iOS"
    if [ "$1" == "arm64" ]; then
      PLATFORM="OS64"
    else
      echo "Unknown arch"
      exit
    fi
    if [ "$LEGACY_SUPPORT" = true ]; then
      DEPLOYMENT_TARGET="11.0"
    else
      DEPLOYMENT_TARGET="13.1"
    fi
  elif [ "$TARGET" == "iOSSimulator" ]; then
    echo "Building for iOS Simulator"
    if [ "$1" == "arm64" ]; then
      PLATFORM="SIMULATORARM64"
    elif [ "$1" == "x86_64" ]; then
      PLATFORM="SIMULATOR64"
    else
      echo "Unknown arch"
      exit
    fi
    if [ "$LEGACY_SUPPORT" = true ]; then
      DEPLOYMENT_TARGET="11.0"
    else
      DEPLOYMENT_TARGET="13.1"
    fi
  elif [ "$TARGET" == "macOS" ]; then
    echo "Building for macOS"
    if [ "$1" == "arm64" ]; then
      DEPLOYMENT_TARGET="11.0"
      PLATFORM="MAC_ARM64"
    elif [ "$1" == "x86_64" ]; then
      if [ "$LEGACY_SUPPORT" = true ]; then
        DEPLOYMENT_TARGET="10.12"
      else
        DEPLOYMENT_TARGET="10.15"
      fi
      PLATFORM="MAC"
    else
      echo "Unknown arch"
      exit
    fi
  elif [ "$TARGET" == "macCatalyst" ]; then
    echo "Building for macCatalyst"
    if [ "$1" == "arm64" ]; then
      DEPLOYMENT_TARGET="14.0"
      PLATFORM="MAC_CATALYST_ARM64"
    elif [ "$1" == "x86_64" ]; then
      DEPLOYMENT_TARGET="13.1"
      PLATFORM="MAC_CATALYST"
    else
      echo "Unknown arch"
      exit
    fi
  elif [ "$TARGET" == "visionOS" ]; then
    echo "Building for visonOS"
    DEPLOYMENT_TARGET="1.0"
    PLATFORM="VISIONOS"
  elif [ "$TARGET" == "visionOSSimulator" ]; then
    echo "Building for visionOSSimulator"
    DEPLOYMENT_TARGET="1.0"
    if [ "$1" == "arm64" ]; then
      PLATFORM="SIMULATOR_VISIONOS_ARM64"
    elif [ "$1" == "x86_64" ]; then
      PLATFORM="SIMULATOR_VISIONOS"
    else
      echo "Unknown arch"
      exit
    fi
  elif [ "$TARGET" == "Android" ]; then
    echo "Building for Android"
  elif [ "$TARGET" == "Emscripten" ]; then
    echo "Building for Emscripten"
  else
    echo "Unknown target"
    exit
  fi

  if [ -n "$6" ]; then
    CMAKE_FILE_PATH=$6
  else
    CMAKE_FILE_PATH=".."
  fi

  if [ "$TARGET" == "Android" ]; then
    $CMAKE $CMAKE_FILE_PATH -DANDROID_ABI=$1 \
            -DANDROID_STL=c++_shared \
            -DANDROID_NDK=$NDK \
            -DCMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN_PATH \
            -DANDROID_NATIVE_API_LEVEL=21 \
            -DANDROID_TOOLCHAIN=clang \
            -DCMAKE_INSTALL_PREFIX=$OUTPUT_PATH \
            ${@:7}
    check_success
  elif [ "$TARGET" == "Emscripten" ]; then
    emcmake $CMAKE $CMAKE_FILE_PATH \
            -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
            -DCMAKE_INSTALL_PREFIX=$OUTPUT_PATH \
            ${@:7}
    check_success
  else
    $CMAKE $CMAKE_FILE_PATH \
           -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_PATH} \
           -DPLATFORM=$PLATFORM \
           -DDEPLOYMENT_TARGET=$DEPLOYMENT_TARGET \
           -DCMAKE_INSTALL_PREFIX=$OUTPUT_PATH \
           ${@:7}
    check_success
  fi
  $CMAKE --build . --config Release --target install
  check_success

  cd ..

  if [ -z "$4" ] || [ "$4" == "dummy" ]; then
    HEADER_PATH=$INCLUDE_PATH
  else
    HEADER_PATH=$INCLUDE_PATH/$4
  fi

  echo "Copying products"
  mkdir -p $HEADER_PATH
  cp -r $OUTPUT_PATH/include/* $HEADER_PATH
  check_success
  if [ ! -z "$5" ] && [ "$5" != "dummy" ]; then
    if [ "$TARGET" == "Android" ]; then
      cp $OUTPUT_PATH/lib/$5.a $LIB_PATH/$1/$5.a
      check_success
    elif [ "$TARGET" == "Emscripten" ]; then
      cp $OUTPUT_PATH/lib/$5.a $LIB_PATH/$5.a
      check_success
    else
      cp $OUTPUT_PATH/lib/$5.a $LIB_PATH/${1}_$5.a
      check_success
    fi
  fi

  echo "Cleaning"
  cd ..
  rm -rf $2
}

# $1 name
# $2 archive name
# $3 archive extension
# $4 lib directory name
# $5 lib name
# $6 cmake file path
# $7 extra params
build_with_cmake()
{
  echo "Building $1"
  if [ "$TARGET" == "iOS" ] || [ "$TARGET" == "visionOS" ]; then
    build_with_cmake_arch "arm64" ${@:2}
    if [ ! -z "$5" ]; then
      fat_create_and_clean $5
    fi
  elif [ "$TARGET" == "Android" ]; then
    build_with_cmake_arch "x86" ${@:2}
    build_with_cmake_arch "x86_64" ${@:2}
    build_with_cmake_arch "armeabi-v7a" ${@:2}
    build_with_cmake_arch "arm64-v8a" ${@:2}
  elif [ "$TARGET" == "Emscripten" ] ; then
    build_with_cmake_arch "dummy" ${@:2}
  else
    build_with_cmake_arch "arm64" ${@:2}
    build_with_cmake_arch "x86_64" ${@:2}
    if [ ! -z "$5" ]; then
      fat_create_and_clean $5
    fi
  fi
}
