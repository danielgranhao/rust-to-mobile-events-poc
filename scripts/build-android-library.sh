#!/usr/bin/env bash

export ANDROID_HOME=/Users/${USER}/Library/Android/sdk
#export NDK_HOME=${ANDROID_HOME}/ndk/25.0.8775105/
export NDK_HOME=${ANDROID_HOME}/ndk/22.1.7171670/

# NDK >= 20
export PATH=${NDK_HOME}/toolchains/llvm/prebuilt/darwin-x86_64/bin:${PATH}

if [[ "${1}" == "debug" ]]; then
  CC=aarch64-linux-android21-clang cargo rustc --lib --target aarch64-linux-android
  CC=armv7a-linux-androideabi21-clang cargo rustc --lib --target armv7-linux-androideabi
  CC=i686-linux-android21-clang cargo rustc --lib --target i686-linux-android
else
  CC=aarch64-linux-android21-clang cargo rustc --lib --target aarch64-linux-android --release
  CC=armv7a-linux-androideabi21-clang cargo rustc --lib --target armv7-linux-androideabi --release
  CC=i686-linux-android21-clang cargo rustc --lib --target i686-linux-android --release
fi

LIB_NAME="libuniffi_events_poc.so"
ANDROID_PROJECT_PATH="android/events_poc"

# copy bindings to Android project
cp bindings/kotlin/uniffi/events_poc/events_poc.kt ${ANDROID_PROJECT_PATH}/events_poc/src/main/java/com/getlipa/events_poc/events_poc.kt

# Save rust root dir
cwd=$(pwd)

# go to Android project
cd ${ANDROID_PROJECT_PATH}/events_poc/src/main
rm -rf jniLibs
mkdir jniLibs
mkdir jniLibs/arm64
mkdir jniLibs/arm64-v8a
mkdir jniLibs/armeabi
mkdir jniLibs/x86

if [[ "${1}" == "debug" ]]; then
  cp ${cwd}/target/aarch64-linux-android/debug/${LIB_NAME} jniLibs/arm64/${LIB_NAME}
  cp ${cwd}/target/aarch64-linux-android/debug/${LIB_NAME} jniLibs/arm64-v8a/${LIB_NAME}
  cp ${cwd}/target/armv7-linux-androideabi/debug/${LIB_NAME} jniLibs/armeabi/${LIB_NAME}
  cp ${cwd}/target/i686-linux-android/debug/${LIB_NAME} jniLibs/x86/${LIB_NAME}
else
  cp ${cwd}/target/aarch64-linux-android/release/${LIB_NAME} jniLibs/arm64/${LIB_NAME}
  cp ${cwd}/target/aarch64-linux-android/release/${LIB_NAME} jniLibs/arm64-v8a/${LIB_NAME}
  cp ${cwd}/target/armv7-linux-androideabi/release/${LIB_NAME} jniLibs/armeabi/${LIB_NAME}
  cp ${cwd}/target/i686-linux-android/release/${LIB_NAME} jniLibs/x86/${LIB_NAME}
fi

cd ${cwd}/${ANDROID_PROJECT_PATH}

./gradlew clean
./gradlew build
./gradlew publishToMavenLocal