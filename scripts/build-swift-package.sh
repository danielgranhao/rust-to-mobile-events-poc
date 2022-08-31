#!/usr/bin/env bash
#set -eEuvx

# EDIT ME!!!!
STATIC_LIB_NAME="libuniffi_events_poc.a"
STATIC_LIB_NAME_SIM="libuniffi_events_poc_simulator.a"
FFI_TARGET="events_poc"
XCFRAMEWORK_NAME="events_pocFFI.xcframework"

RELFLAG=--release
RELDIR="release"
if [[ "${1}" == "debug" ]]; then
  RELFLAG=""
  RELDIR="debug"
fi

TARGETDIR=./target

LIBS_ARCHS=("x86_64" "arm64" "arm64-sim")
IOS_TRIPLES=("x86_64-apple-ios" "aarch64-apple-ios" "aarch64-apple-ios-sim")
for i in "${!LIBS_ARCHS[@]}"; do
    env -i PATH="${PATH}" \
    "${HOME}"/.cargo/bin/cargo build --locked -p "${FFI_TARGET}" --lib ${RELFLAG} --target "${IOS_TRIPLES[${i}]}"
done

UNIVERSAL_BINARY=${TARGETDIR}/universal/${RELDIR}/${STATIC_LIB_NAME}
UNIVERSAL_BINARY_SIM=${TARGETDIR}/universal/${RELDIR}/${STATIC_LIB_NAME_SIM}
NEED_LIPO=

# if the universal binary doesnt exist, or if it's older than the static libs,
# we need to run `lipo` again.
if [[ ! -f "${UNIVERSAL_BINARY}" ]]; then
    NEED_LIPO=1
elif [[ "$(stat -f "%m" "${TARGETDIR}/x86_64-apple-ios/${RELDIR}/${STATIC_LIB_NAME}")" -gt "$(stat -f "%m" "${UNIVERSAL_BINARY}")" ]]; then
    NEED_LIPO=1
elif [[ "$(stat -f "%m" "${TARGETDIR}/aarch64-apple-ios-sim/${RELDIR}/${STATIC_LIB_NAME}")" -gt "$(stat -f "%m" "${UNIVERSAL_BINARY}")" ]]; then
    NEED_LIPO=1
fi

if [[ "${NEED_LIPO}" = "1" ]]; then
    mkdir -p "${TARGETDIR}/universal/${RELDIR}"
    lipo -create -output "${UNIVERSAL_BINARY_SIM}" \
            "${TARGETDIR}/x86_64-apple-ios/${RELDIR}/${STATIC_LIB_NAME}" \
            "${TARGETDIR}/aarch64-apple-ios-sim/${RELDIR}/${STATIC_LIB_NAME}"
fi

#rm -rf ${XCFRAMEWORK_NAME}
#xcodebuild -create-xcframework \
#  -library ./${UNIVERSAL_BINARY_SIM} \
#  -headers ./bindings/swift \
#  -library ./target/aarch64-apple-ios/${RELDIR}/${STATIC_LIB_NAME} \
#  -headers ./bindings/swift \
#  -output ${XCFRAMEWORK_NAME}

XCFRAMEWORK_LIBS=("ios-arm64" "ios-arm64_x86_64-simulator")
for LIB in "${XCFRAMEWORK_LIBS[@]}"; do
    # copy possibly updated header file
    cp bindings/swift/events_pocFFI.h events_pocFFI.xcframework/${LIB}/events_pocFFI.framework/Headers/events_pocFFI.h
done

cp target/aarch64-apple-ios/release/${STATIC_LIB_NAME} ${XCFRAMEWORK_NAME}/ios-arm64/events_pocFFI.framework/events_pocFFI
cp target/universal/release/${STATIC_LIB_NAME_SIM} ${XCFRAMEWORK_NAME}/ios-arm64_x86_64-simulator/events_pocFFI.framework/events_pocFFI