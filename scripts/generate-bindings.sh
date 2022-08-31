#!/usr/bin/env bash

uniffi-bindgen generate src/events_poc.udl --no-format --out-dir bindings/kotlin --language kotlin
uniffi-bindgen generate src/events_poc.udl --no-format --out-dir bindings/swift --language swift

mkdir -p Sources/events_poc
mv bindings/swift/events_poc.swift Sources/events_poc/events_poc.swift