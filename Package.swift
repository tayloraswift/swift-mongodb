// swift-tools-version:5.8
import PackageDescription

let package:Package = .init(name: "swift-mongodb",
    platforms:
    [
        //  TODO: this is really the wrong place to declare this, because we don’t
        //  want to restrict availability of the BSON libraries just because of the
        //  other modules that use async/await.
        .macOS(.v10_15),
    ],
    products:
    [
        .library(name: "BSON", targets: ["BSON"]),
        .library(name: "BSONReflection", targets: ["BSONReflection"]),
        .library(name: "BSONDecoding", targets: ["BSONDecoding"]),
        .library(name: "BSONEncoding", targets: ["BSONEncoding"]),
        .library(name: "BSONTypes", targets: ["BSONTypes"]),

        .library(name: "BSON_Durations", targets: ["BSON_Durations"]),
        .library(name: "BSON_OrderedCollections", targets: ["BSON_OrderedCollections"]),
        .library(name: "BSON_UUID", targets: ["BSON_UUID"]),

        .library(name: "Durations", targets: ["Durations"]),
        .library(name: "Durations_Atomics", targets: ["Durations_Atomics"]),

        .library(name: "MongoDB", targets: ["MongoDB"]),

        .library(name: "Mongo", targets: ["Mongo"]),
        .library(name: "MongoBuiltins", targets: ["MongoBuiltins"]),
        .library(name: "MongoConfiguration", targets: ["MongoConfiguration"]),
        .library(name: "MongoDriver", targets: ["MongoDriver"]),
        .library(name: "MongoDSL", targets: ["MongoDSL"]),
        .library(name: "MongoExecutor", targets: ["MongoExecutor"]),
        .library(name: "MongoIO", targets: ["MongoIO"]),
        .library(name: "MongoLibrary", targets: ["MongoLibrary"]),
        .library(name: "MongoTesting", targets: ["MongoTesting"]),
        .library(name: "MongoWire", targets: ["MongoWire"]),

        .library(name: "SCRAM", targets: ["SCRAM"]),
        .library(name: "UUID", targets: ["UUID"]),
    ],
    dependencies:
    [
        .package(url: "https://github.com/tayloraswift/swift-grammar", .upToNextMinor(
            from: "0.3.2")),
        .package(url: "https://github.com/tayloraswift/swift-hash", .upToNextMinor(
            from: "0.5.0")),

        .package(url: "https://github.com/apple/swift-atomics.git", .upToNextMinor(
            from: "1.1.0")),
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMinor(
            from: "1.0.4")),
        .package(url: "https://github.com/apple/swift-nio.git", .upToNextMinor(
            from: "2.54.0")),
        .package(url: "https://github.com/apple/swift-nio-ssl.git", .upToNextMinor(
            from: "2.24.0")),
    ],
    targets:
    [
        .target(name: "UUID",
            dependencies:
            [
                .product(name: "Base16", package: "swift-hash"),
            ]),

        .target(name: "BSON",
            dependencies:
            [
                .target(name: "BSONStreaming"),
            ]),

        .target(name: "BSONTraversal"),

        .target(name: "BSONTypes",
            dependencies:
            [
                .target(name: "BSONTraversal"),
            ]),

        .target(name: "BSONStreaming",
            dependencies:
            [
                .target(name: "BSONTypes"),
            ]),

        .target(name: "BSONReflection",
            dependencies:
            [
                .target(name: "BSON"),
            ]),
        .target(name: "BSONDecoding",
            dependencies:
            [
                .target(name: "BSON"),
                .product(name: "TraceableErrors", package: "swift-grammar"),
            ]),
        .target(name: "BSONEncoding",
            dependencies:
            [
                .target(name: "BSON"),
            ]),

        .target(name: "BSON_UUID",
            dependencies:
            [
                .target(name: "BSONDecoding"),
                .target(name: "BSONEncoding"),
                .target(name: "UUID"),
            ]),
        .target(name: "BSON_Durations",
            dependencies:
            [
                .target(name: "BSONDecoding"),
                .target(name: "BSONEncoding"),
                .target(name: "Durations"),
            ]),
        .target(name: "BSON_OrderedCollections",
            dependencies:
            [
                .target(name: "BSONDecoding"),
                .target(name: "BSONEncoding"),
                .product(name: "OrderedCollections", package: "swift-collections"),
            ]),

        .target(name: "OnlineCDF"),

        .target(name: "Durations"),

        .target(name: "Durations_Atomics",
            dependencies:
            [
                .target(name: "Durations"),
                .product(name: "Atomics", package: "swift-atomics"),
            ]),

        .target(name: "SCRAM",
            dependencies:
            [
                .product(name: "Base64", package: "swift-hash"),
                .product(name: "MessageAuthentication", package: "swift-hash"),
            ]),

        .target(name: "MongoDB",
            dependencies:
            [
                .target(name: "MongoLibrary"),
            ]),

        .target(name: "Mongo",
            dependencies:
            [
                .target(name: "BSONDecoding"),
                .target(name: "BSONEncoding"),
                .target(name: "Durations"),
                .product(name: "TraceableErrors", package: "swift-grammar"),
            ]),

        .target(name: "MongoBuiltins",
            dependencies:
            [
                .target(name: "Mongo"),
                .target(name: "MongoDSL"),
            ]),

        .target(name: "MongoConfiguration",
            dependencies:
            [
                .target(name: "Mongo"),
                .product(name: "NIOCore", package: "swift-nio"),
            ]),

        .target(name: "MongoDriver",
            dependencies:
            [
                .target(name: "BSON_Durations"),
                .target(name: "BSON_OrderedCollections"),
                .target(name: "BSON_UUID"),
                .target(name: "Durations_Atomics"),
                .target(name: "MongoConfiguration"),
                .target(name: "MongoExecutor"),
                .target(name: "OnlineCDF"),
                .target(name: "SCRAM"),
                .product(name: "Atomics", package: "swift-atomics"),
                .product(name: "SHA2", package: "swift-hash"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "NIOSSL", package: "swift-nio-ssl"),
            ]),

        .target(name: "MongoDSL",
            dependencies:
            [
                .target(name: "BSONDecoding"),
                .target(name: "BSONEncoding"),
            ]),

        .target(name: "MongoExecutor",
            dependencies:
            [
                .target(name: "MongoIO"),
            ]),

        .target(name: "MongoIO",
            dependencies:
            [
                .target(name: "MongoWire"),
                .product(name: "NIOCore", package: "swift-nio"),
            ]),

        .target(name: "MongoLibrary",
            dependencies:
            [
                .target(name: "BSONReflection"),
                .target(name: "MongoBuiltins"),
                .target(name: "MongoDriver"),
            ]),

        .target(name: "MongoTesting",
            dependencies:
            [
                .target(name: "MongoDB"),
                .product(name: "Testing", package: "swift-grammar"),
            ]),

        // the mongo wire protocol. has no awareness of networking or
        // driver-level concepts.
        .target(name: "MongoWire",
            dependencies:
            [
                .target(name: "BSON"),
                .product(name: "CRC", package: "swift-hash"),
            ]),

        .executableTarget(name: "BSONTests",
            dependencies:
            [
                .target(name: "BSONReflection"),
                .product(name: "Base16", package: "swift-hash"),
                .product(name: "Testing", package: "swift-grammar"),
            ]),

        .executableTarget(name: "BSONDecodingTests",
            dependencies:
            [
                .target(name: "BSONDecoding"),
                .product(name: "Testing", package: "swift-grammar"),
            ]),

        .executableTarget(name: "BSONEncodingTests",
            dependencies:
            [
                .target(name: "BSONEncoding"),
                .product(name: "Testing", package: "swift-grammar"),
            ]),

        .executableTarget(name: "BSONIntegrationTests",
            dependencies:
            [
                .target(name: "BSONReflection"),
                .target(name: "BSONDecoding"),
                .target(name: "BSONEncoding"),
                .product(name: "Testing", package: "swift-grammar"),
            ]),

        .executableTarget(name: "BSONReflectionTests",
            dependencies:
            [
                .target(name: "BSONReflection"),
                .target(name: "BSONEncoding"),
                .product(name: "Testing", package: "swift-grammar"),
            ]),

        .executableTarget(name: "OnlineCDFTests",
            dependencies:
            [
                .target(name: "OnlineCDF"),
                .product(name: "Testing", package: "swift-grammar"),
            ]),

        .executableTarget(name: "MongoDBTests",
            dependencies:
            [
                .target(name: "MongoTesting"),
            ]),

        .executableTarget(name: "MongoDriverTests",
            dependencies:
            [
                .target(name: "MongoDriver"),
                .product(name: "Testing", package: "swift-grammar"),
            ]),
    ]
)

for target:PackageDescription.Target in package.targets
{
    {
        var settings:[PackageDescription.SwiftSetting] = $0 ?? []

        settings.append(.enableUpcomingFeature("BareSlashRegexLiterals"))
        settings.append(.enableUpcomingFeature("ConciseMagicFile"))
        settings.append(.enableUpcomingFeature("ExistentialAny"))
        settings.append(.enableUpcomingFeature("StrictConcurrency"))

        $0 = settings
    } (&target.swiftSettings)
}
