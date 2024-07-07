// swift-tools-version:5.10
import PackageDescription

let package:Package = .init(name: "swift-mongodb",
    platforms: [
        //  TODO: this is really the wrong place to declare this, because we don’t
        //  want to restrict availability of the BSON libraries just because of the
        //  other modules that use async/await.
        .macOS(.v14),
    ],
    products: [
        .library(name: "BSON", targets: ["BSON"]),
        .library(name: "BSONLegacy", targets: ["BSONLegacy"]),
        .library(name: "BSONReflection", targets: ["BSONReflection"]),
        .library(name: "BSONTesting", targets: ["BSONTesting"]),
        .library(name: "BSONABI", targets: ["BSONABI"]),

        .library(name: "BSON_OrderedCollections", targets: ["BSON_OrderedCollections"]),
        .library(name: "BSON_UUID", targets: ["BSON_UUID"]),

        .library(name: "MongoDB", targets: ["MongoDB"]),
        .library(name: "MongoQL", targets: ["MongoQL"]),
        .library(name: "MongoTesting", targets: ["MongoTesting"]),

        .library(name: "SCRAM", targets: ["SCRAM"]),
        .library(name: "UnixTime_Atomics", targets: ["UnixTime_Atomics"]),
        .library(name: "UUID", targets: ["UUID"]),
    ],
    dependencies: [
        .package(url: "https://github.com/tayloraswift/swift-grammar", .upToNextMinor(
            from: "0.4.0")),
        .package(url: "https://github.com/tayloraswift/swift-hash", .upToNextMinor(
            from: "0.6.0")),
        .package(url: "https://github.com/tayloraswift/swift-unixtime", .upToNextMinor(
            from: "0.1.0")),

        .package(url: "https://github.com/apple/swift-atomics.git", .upToNextMinor(
            from: "1.2.0")),
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMinor(
            from: "1.1.0")),

        .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),
        .package(url: "https://github.com/apple/swift-nio-ssl.git", from: "2.26.0"),
    ],
    targets: [
        .target(name: "UUID",
            dependencies: [
                .product(name: "Base16", package: "swift-hash"),
            ]),

        .target(name: "BSON",
            dependencies: [
                .target(name: "BSONDecoding"),
                .target(name: "BSONEncoding"),
            ],
            exclude: [
                "README.md",
            ]),

        .target(name: "BSONABI",
            dependencies: [
                .product(name: "UnixTime", package: "swift-unixtime"),
            ],
            exclude: [
                "README.md",
            ]),

        .target(name: "BSONDecoding",
            dependencies: [
                .target(name: "BSONABI"),
                .product(name: "TraceableErrors", package: "swift-grammar"),
            ],
            exclude: [
                "README.md",
            ]),

        .target(name: "BSONEncoding",
            dependencies: [
                .target(name: "BSONABI"),
            ],
            exclude: [
                "README.md",
            ]),

        .target(name: "BSONLegacy",
            dependencies: [
                .target(name: "BSON"),
            ]),

        .target(name: "BSONReflection",
            dependencies: [
                .target(name: "BSON"),
            ]),

        .target(name: "BSONTesting",
            dependencies: [
                .target(name: "BSON"),
                .product(name: "Testing_", package: "swift-grammar"),
            ]),

        .target(name: "BSON_UUID",
            dependencies: [
                .target(name: "BSON"),
                .target(name: "UUID"),
            ]),

        .target(name: "BSON_OrderedCollections",
            dependencies: [
                .target(name: "BSON"),
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
                .target(name: "BSON"),
                .target(name: "Mongo"),
            ]),

        .target(name: "MongoBuiltins",
            dependencies: [
                .target(name: "MongoABI"),
            ]),

        .target(name: "MongoClusters",
            dependencies: [
                .target(name: "BSON"),
                .target(name: "Mongo"),
                .product(name: "TraceableErrors", package: "swift-grammar"),
                .product(name: "UnixTime", package: "swift-unixtime"),
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
                .target(name: "BSON_UUID"),
                .target(name: "MongoCommands"),
                .target(name: "MongoConfiguration"),
                .target(name: "MongoExecutor"),
                .target(name: "MongoLogging"),
                .target(name: "SCRAM"),
                .target(name: "UnixTime_Atomics"),
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
                .target(name: "BSON"),
                .target(name: "BSONReflection"),
                .target(name: "BSON_OrderedCollections"),
                .target(name: "BSON_UUID"),
                .target(name: "MongoBuiltins"),
                .target(name: "MongoCommands"),
            ]),


        .target(name: "MongoTesting",
            dependencies: [
                .target(name: "MongoDB"),
                .product(name: "Testing_", package: "swift-grammar"),
            ]),

        // the mongo wire protocol. has no awareness of networking or
        // driver-level concepts.
        .target(name: "MongoWire",
            dependencies: [
                .target(name: "BSON"),
                .target(name: "Mongo"),
                .product(name: "CRC", package: "swift-hash"),
            ]),

        .target(name: "UnixTime_Atomics",
            dependencies: [
                .product(name: "Atomics", package: "swift-atomics"),
                .product(name: "UnixTime", package: "swift-unixtime"),
            ]),

        .executableTarget(name: "BSONTests",
            dependencies: [
                .target(name: "BSONReflection"),
                .target(name: "BSON_UUID"),
                .product(name: "Base16", package: "swift-hash"),
                .product(name: "Testing_", package: "swift-grammar"),
            ]),

        .executableTarget(name: "BSONDecodingTests",
            dependencies: [
                .target(name: "BSONDecoding"),
                .product(name: "Testing_", package: "swift-grammar"),
            ]),

        .executableTarget(name: "BSONEncodingTests",
            dependencies: [
                .target(name: "BSONEncoding"),
                .product(name: "Testing_", package: "swift-grammar"),
            ]),

        .executableTarget(name: "BSONIntegrationTests",
            dependencies: [
                .target(name: "BSON"),
                .target(name: "BSONReflection"),
                .product(name: "Testing_", package: "swift-grammar"),
            ]),

        .executableTarget(name: "BSONReflectionTests",
            dependencies: [
                .target(name: "BSONReflection"),
                .target(name: "BSONEncoding"),
                .product(name: "Testing_", package: "swift-grammar"),
            ]),

        .executableTarget(name: "OnlineCDFTests",
            dependencies: [
                .target(name: "OnlineCDF"),
                .product(name: "Testing_", package: "swift-grammar"),
            ]),

        .executableTarget(name: "MongoClusterTests",
            dependencies: [
                .target(name: "MongoClusters"),
                .product(name: "Testing_", package: "swift-grammar"),
            ]),

        .executableTarget(name: "MongoDBTests",
            dependencies: [
                .target(name: "MongoDB"),
                .target(name: "MongoQL"),
                .target(name: "MongoTesting"),
            ]),

        .executableTarget(name: "MongoDriverTests",
            dependencies: [
                .target(name: "MongoDriver"),
                .product(name: "Testing_", package: "swift-grammar"),
            ]),
    ]
)

for target:PackageDescription.Target in package.targets
{
    {
        var settings:[PackageDescription.SwiftSetting] = $0 ?? []

        settings.append(.enableUpcomingFeature("BareSlashRegexLiterals"))
        settings.append(.enableUpcomingFeature("ConciseMagicFile"))
        settings.append(.enableUpcomingFeature("DeprecateApplicationMain"))
        settings.append(.enableUpcomingFeature("ExistentialAny"))
        settings.append(.enableUpcomingFeature("GlobalConcurrency"))
        settings.append(.enableUpcomingFeature("IsolatedDefaultValues"))
        settings.append(.enableExperimentalFeature("StrictConcurrency"))

        $0 = settings
    } (&target.swiftSettings)
}
