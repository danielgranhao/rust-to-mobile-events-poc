// swift-tools-version:5.3

import PackageDescription
import Foundation

let package = Package(
        name: "events_poc",
        platforms: [
            .iOS(.v13)
        ],
        products: [
            .library(
                name: "events_poc",
                targets: ["events_poc"]),
        ],
        targets: [
            /*
            .binaryTarget(
            name: "events_pocFFI",
            url: "https://github.com/danielgranhao/bdk-swift/releases/download/0.4.0/bdkFFI.xcframework.zip",
            checksum: "The checksum of the ZIP archive that contains the XCFramework."),
            */
            .binaryTarget(
                    name: "events_pocFFI",
                    path: "events_pocFFI.xcframework"),
            .target(
                    name: "events_poc",
                    dependencies: ["events_pocFFI"]),
        ]
)