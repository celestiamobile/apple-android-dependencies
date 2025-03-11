create_xcframework()
{
  CREATED_DUMMY_LIB=false
  if [ ! -f $LIB_PATH/$1.a ]; then
    touch dummy.c

    eval "$CC_ARM64 -c dummy.c -o dummy_arm64.o"
    check_success

    ar rcs dummy_arm64.a dummy_arm64.o
    if [[ -v CC_X86_64 ]]; then
      eval "$CC_X86_64 -c dummy.c -o dummy_x86_64.o"
      check_success

      ar rcs dummy_x86_64.a dummy_x86_64.o
      check_success

      lipo -create dummy_x86_64.a dummy_arm64.a -o $LIB_PATH/$1.a
      check_success

      rm -rf dummy_x86_64.o dummy_x86_64.a
    else
      lipo -create dummy_arm64.a -o $LIB_PATH/$1.a
      check_success
    fi
    rm -rf dummy.c dummy_arm64.o dummy_arm64.a
      CREATED_DUMMY_LIB=true
  fi

  if  [ "$4" = "none" ]; then
    xcodebuild -create-xcframework -library $LIB_PATH/$1.a -output $XCFRAMEWORK_PATH/$3.xcframework
  else
    xcodebuild -create-xcframework -library $LIB_PATH/$1.a -headers $INCLUDE_PATH/$2 -output $XCFRAMEWORK_PATH/$3.xcframework
  fi
  check_success

  if [ "$CREATED_DUMMY_LIB" = true ]; then
    CREATED_DUMMY_LIB=false
    rm -rf $LIB_PATH/$1.a
  fi
}

create_xcframework_from_xcframework()
{
  xcodebuild -create-xcframework -library $3/ios/$2.xcframework/ios-arm64/$1.a -headers $3/ios/$2.xcframework/ios-arm64/Headers \
                                 -library $3/iossim/$2.xcframework/ios-arm64_x86_64-simulator/$1.a -headers $3/iossim/$2.xcframework/ios-arm64_x86_64-simulator/Headers \
                                 -library $3/mac/$2.xcframework/macos-arm64_x86_64/$1.a -headers $3/mac/$2.xcframework/macos-arm64_x86_64/Headers \
                                 -library $3/catalyst/$2.xcframework/ios-arm64_x86_64-maccatalyst/$1.a -headers $3/catalyst/$2.xcframework/ios-arm64_x86_64-maccatalyst/Headers \
                                 -library $3/visionos/$2.xcframework/xros-arm64/$1.a -headers $3/visionos/$2.xcframework/xros-arm64/Headers \
                                 -library $3/visionossim/$2.xcframework/xros-arm64_x86_64-simulator/$1.a -headers $3/visionossim/$2.xcframework/xros-arm64_x86_64-simulator/Headers \
                                 -output $4/$2.xcframework
}
