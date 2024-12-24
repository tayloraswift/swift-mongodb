// swift-tools-version:6.0
import PackageDescription

let package:Package = .init(name: "swift-mongodb",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .library(name: "MongoDB", targets: ["MongoDB"]),
        .library(name: "MongoQL", targets: ["MongoQL"]),
        .library(name: "MongoTesting", targets: ["MongoTesting"]),

        .library(name: "SCRAM", targets: ["SCRAM"]),
        .library(name: "UnixTime_Atomics", targets: ["UnixTime_Atomics"]),
    ],
    dependencies: [
        .package(url: "https://github.com/tayloraswift/swift-bson", .upToNextMinor(
            from: "0.4.0")),
        .package(url: "https://github.com/tayloraswift/swift-grammar", .upToNextMinor(
            from: "0.4.0")),
        .package(url: "https://github.com/tayloraswift/swift-hash", .upToNextMinor(
            from: "0.7.0")),
        .package(url: "https://github.com/tayloraswift/swift-unixtime", .upToNextMinor(
            from: "0.1.5")),

        .package(url: "https://github.com/apple/swift-atomics", .upToNextMinor(
            from: "1.2.0")),
        .package(url: "https://github.com/apple/swift-collections", .upToNextMinor(
            from: "1.1.0")),

        .package(url: "https://github.com/apple/swift-nio",
            from: "2.75.0"),
        .package(url: "https://github.com/apple/swift-nio-ssl",
            from: "2.28.0"),
    ],
    targets: [
        .target(name: "BSON_OrderedCollections",
            dependencies: [
                .product(name: "BSON", package: "swift-bson"),
                .product(name: "OrderedCollections", package: "swift-collections"),
            ]),

        .target(name: "OnlineCDF"),

        .target(name: "SCRAM",
            dependencies: [
                .product(name: "Base64", package: "swift-hash"),
                .product(name: "MessageAuthentication", package: "swift-hash"),
            ]),


        .target(name: "Mongo"),

        .target(name: "MongoABI",
            dependencies: [
                .target(name: "Mongo"),
                .product(name: "BSON", package: "swift-bson"),
            ]),

        .target(name: "MongoBuiltins",
            dependencies: [
                .target(name: "MongoABI"),
            ]),

        .target(name: "MongoClusters",
            dependencies: [
                .target(name: "Mongo"),
                .product(name: "BSON", package: "swift-bson"),
                .product(name: "TraceableErrors", package: "swift-grammar"),
            ]),

        .target(name: "MongoCommands",
            dependencies: [
                .target(name: "MongoABI"),
                .product(name: "UnixTime", package: "swift-unixtime"),
            ]),

        .target(name: "MongoConfiguration",
            dependencies: [
                .target(name: "MongoClusters"),
                .target(name: "MongoABI"),
                .product(name: "NIOCore", package: "swift-nio"),
            ]),

        .target(name: "MongoDB",
            dependencies: [
                .target(name: "MongoQL"),
                .target(name: "MongoDriver"),
            ]),

        .target(name: "MongoDriver",
            dependencies: [
                .target(name: "BSON_OrderedCollections"),
                .target(name: "MongoCommands"),
                .target(name: "MongoConfiguration"),
                .target(name: "MongoExecutor"),
                .target(name: "MongoLogging"),
                .target(name: "SCRAM"),
                .target(name: "UnixTime_Atomics"),
                .product(name: "BSON_UUID", package: "swift-bson"),
                .product(name: "Atomics", package: "swift-atomics"),
                .product(name: "SHA2", package: "swift-hash"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "NIOSSL", package: "swift-nio-ssl"),
            ]),

        .target(name: "MongoExecutor",
            dependencies: [
                .target(name: "MongoIO"),
            ]),

        .target(name: "MongoIO",
            dependencies: [
                .target(name: "Mongo"),
                .target(name: "MongoWire"),
                .product(name: "NIOCore", package: "swift-nio"),
            ]),

        .target(name: "MongoLogging",
            dependencies: [
                .target(name: "MongoClusters"),
                .product(name: "Atomics", package: "swift-atomics"),
            ]),

        .target(name: "MongoQL",
            dependencies: [
                .target(name: "BSON_OrderedCollections"),
                .target(name: "MongoBuiltins"),
                .target(name: "MongoCommands"),
                .product(name: "BSON", package: "swift-bson"),
                .product(name: "BSONReflection", package: "swift-bson"),
                .product(name: "BSON_UUID", package: "swift-bson"),
            ]),

        .target(name: "MongoTesting",
            dependencies: [
                .target(name: "MongoDB"),
            ]),

        // the mongo wire protocol. has no awareness of networking or
        // driver-level concepts.
        .target(name: "MongoWire",
            dependencies: [
                .target(name: "Mongo"),
                .product(name: "BSON", package: "swift-bson"),
                .product(name: "CRC", package: "swift-hash"),
            ]),

        .target(name: "UnixTime_Atomics",
            dependencies: [
                .product(name: "Atomics", package: "swift-atomics"),
                .product(name: "UnixTime", package: "swift-unixtime"),
            ]),


        .testTarget(name: "OnlineCDFTests",
            dependencies: [
                .target(name: "OnlineCDF"),
            ]),

        .testTarget(name: "MongoClusterTests",
            dependencies: [
                .target(name: "MongoClusters"),
            ]),

        .testTarget(name: "MongoDBTests",
            dependencies: [
                .target(name: "MongoDB"),
                .target(name: "MongoTesting"),
            ]),

        .testTarget(name: "MongoDriverTests",
            dependencies: [
                .target(name: "MongoDriver"),
            ]),
    ]
)

for target:PackageDescription.Target in package.targets
{
    {
        var settings:[PackageDescription.SwiftSetting] = $0 ?? []

        settings.append(.enableUpcomingFeature("ExistentialAny"))
        settings.append(.enableExperimentalFeature("StrictConcurrency"))

        $0 = settings
    } (&target.swiftSettings)
}
