// swift-tools-version:5.7
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
        .library(name: "BSONCanonicalization", targets: ["BSONCanonicalization"]),
        .library(name: "BSONDecoding", targets: ["BSONDecoding"]),
        .library(name: "BSONEncoding", targets: ["BSONEncoding"]),
        .library(name: "BSONDSL", targets: ["BSONDSL"]),
        .library(name: "BSONView", targets: ["BSONView"]),
        
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
        .library(name: "MongoWire", targets: ["MongoWire"]),

        .library(name: "SCRAM", targets: ["SCRAM"]),
        .library(name: "UUID", targets: ["UUID"]),
    ],
    dependencies: 
    [
        .package(url: "https://github.com/kelvin13/swift-grammar", .upToNextMinor(from: "0.3.1")),
        .package(url: "https://github.com/kelvin13/swift-hash", .upToNextMinor(from: "0.5.0")),
        
        .package(url: "https://github.com/apple/swift-atomics.git", .upToNextMinor(from: "1.0.3")),
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMinor(from: "1.0.4")),
        .package(url: "https://github.com/apple/swift-nio.git", .upToNextMinor(from: "2.48.0")),
        .package(url: "https://github.com/apple/swift-nio-ssl.git", .upToNextMinor(from: "2.23.0")),
    ],
    targets:
    [
        .target(name: "AtomicReferenceShims"),
        
        .target(name: "AtomicReference",
            dependencies:
            [
                .target(name: "AtomicReferenceShims"),
                .product(name: "Atomics", package: "swift-atomics"),
            ]),
        
        .target(name: "UUID",
            dependencies:
            [
                .product(name: "Base16", package: "swift-hash"),
            ]),

        .target(name: "BSONTraversal"),

        .target(name: "BSON",
            dependencies:
            [
                .target(name: "BSONTraversal"),
            ]),
        .target(name: "BSONDSL",
            dependencies:
            [
                .target(name: "BSON"),
            ]),
        .target(name: "BSONCanonicalization",
            dependencies:
            [
                .target(name: "BSONDSL"),
                .target(name: "BSONView"),
            ]),
        .target(name: "BSONDecoding",
            dependencies:
            [
                .target(name: "BSONDSL"),
                .target(name: "BSONView"),
                .product(name: "TraceableErrors", package: "swift-grammar"),
            ]),
        .target(name: "BSONEncoding",
            dependencies:
            [
                .target(name: "BSONDSL"),
            ]),
        .target(name: "BSONView",
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
                .target(name: "AtomicReference"),
                .target(name: "BSON_Durations"),
                .target(name: "BSON_OrderedCollections"),
                .target(name: "BSON_UUID"),
                .target(name: "Durations_Atomics"),
                .target(name: "MongoConfiguration"),
                .target(name: "MongoExecutor"),
                .target(name: "OnlineCDF"),
                .target(name: "SCRAM"),
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
                .target(name: "MongoBuiltins"),
                .target(name: "MongoDriver"),
            ]),

        // the mongo wire protocol. has no awareness of networking or
        // driver-level concepts.
        .target(name: "MongoWire",
            dependencies: 
            [
                .target(name: "BSONDSL"),
                .target(name: "BSONView"),
                .product(name: "CRC", package: "swift-hash"),
            ]),

        .executableTarget(name: "BSONTests",
            dependencies:
            [
                .target(name: "BSONCanonicalization"),
                .product(name: "Base16", package: "swift-hash"),
                .product(name: "Testing", package: "swift-hash"),
            ], 
            path: "Tests/BSON"),
        
        .executableTarget(name: "BSONDecodingTests",
            dependencies:
            [
                .target(name: "BSONDecoding"),
                .product(name: "Testing", package: "swift-hash"),
            ], 
            path: "Tests/BSONDecoding"),
        
        .executableTarget(name: "BSONEncodingTests",
            dependencies:
            [
                .target(name: "BSONEncoding"),
                .target(name: "BSONView"),
                .product(name: "Testing", package: "swift-hash"),
            ], 
            path: "Tests/BSONEncoding"),
        
        .executableTarget(name: "BSONIntegrationTests",
            dependencies:
            [
                .target(name: "BSONCanonicalization"),
                .target(name: "BSONDecoding"),
                .target(name: "BSONEncoding"),
                .product(name: "Testing", package: "swift-hash"),
            ], 
            path: "Tests/BSONIntegration"),
        
        
        .executableTarget(name: "OnlineCDFTests",
            dependencies:
            [
                .target(name: "OnlineCDF"),
                .product(name: "Testing", package: "swift-hash"),
            ], 
            path: "Tests/OnlineCDF"),
        
        .executableTarget(name: "MongoTests",
            dependencies:
            [
                .target(name: "Mongo"),
                .product(name: "Testing", package: "swift-hash"),
            ], 
            path: "Tests/Mongo"),
        
        .executableTarget(name: "MongoDBTests",
            dependencies:
            [
                .target(name: "MongoDB"),
                .product(name: "Testing", package: "swift-hash"),
            ], 
            path: "Tests/MongoDB"),
        
        .executableTarget(name: "MongoDriverTests",
            dependencies:
            [
                .target(name: "MongoDriver"),
                .product(name: "Testing", package: "swift-hash"),
            ], 
            path: "Tests/MongoDriver"),
        
        .target(name: "MongoDSLAPITests",
            dependencies:
            [
                .target(name: "MongoBuiltins"),
            ], 
            path: "Tests/MongoDSLAPI"),
        
        .target(name: "MongoDBAPITests",
            dependencies:
            [
                .target(name: "MongoDB"),
            ], 
            path: "Tests/MongoDBAPI"),
    ]
)
