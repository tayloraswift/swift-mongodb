// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "swift-mongodb",
    products: 
    [
        .library(name: "BSON", targets: ["BSON"]),
        .library(name: "BSONDecoding", targets: ["BSONDecoding"]),
        .library(name: "BSONEncoding", targets: ["BSONEncoding"]),
        .library(name: "BSONSchema", targets: ["BSONSchema"]),

        .library(name: "MongoDB", targets: ["MongoDB"]),
        .library(name: "MongoDriver", targets: ["MongoDriver"]),
        .library(name: "MongoSchema", targets: ["MongoSchema"]),
        .library(name: "MongoWire", targets: ["MongoWire"]),

        .library(name: "SCRAM", targets: ["SCRAM"]),
        .library(name: "TraceableErrors", targets: ["TraceableErrors"]),
        .library(name: "UUID", targets: ["UUID"]),
    ],
    dependencies: 
    [
        .package(url: "https://github.com/kelvin13/swift-grammar", .upToNextMinor(from: "0.2.0")),
        .package(url: "https://github.com/kelvin13/swift-hash", .upToNextMinor(from: "0.4.3")),
        
        // used by the _BSON module
        .package(url: "https://github.com/kelvin13/swift-package-factory.git",
            revision: "swift-DEVELOPMENT-SNAPSHOT-2022-11-11-a"),
        
        .package(url: "https://github.com/apple/swift-nio.git", .upToNextMinor(from: "2.45.0")),
        .package(url: "https://github.com/apple/swift-nio-ssl.git", .upToNextMinor(from: "2.23.0")),
        .package(url: "https://github.com/apple/swift-atomics.git", from: "1.0.2"),
    ],
    targets: 
    [
        .target(name: "TraceableErrors"),

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
        .target(name: "BSONPrimitives",
            dependencies:
            [
                .target(name: "BSON"),
            ]),
        .target(name: "BSONDecoding",
            dependencies:
            [
                .target(name: "BSONPrimitives"),
                .target(name: "TraceableErrors"),
            ]),
        .target(name: "BSONEncoding",
            dependencies:
            [
                .target(name: "BSONPrimitives"),
            ]),
        .target(name: "BSONSchema",
            dependencies:
            [
                .target(name: "BSONDecoding"),
                .target(name: "BSONEncoding"),
            ]),
        
        .target(name: "SCRAM",
            dependencies: 
            [
                .product(name: "Base64",                package: "swift-hash"),
                .product(name: "MessageAuthentication", package: "swift-hash"),
            ]),

        // the mongo wire protocol. has no awareness of networking or
        // driver-level concepts.
        .target(name: "MongoWire",
            dependencies: 
            [
                .target(name: "BSON"),
                .product(name: "CRC", package: "swift-hash"),
            ]),
        
        // basic type definitions and conformances. driver peripherals can
        // import this instead of ``/MongoDriver`` to avoid depending on `swift-nio`.
        .target(name: "Mongo",
            dependencies: 
            [
                // this dependency is here because we need several of the
                // enumeration types to be ``BSONDecodable`` and ``BSONEncodable``,
                // and we do not want a downstream module to have to declare
                // retroactive conformances.
                .target(name: "BSONSchema"),
            ]),
        
        .target(name: "MongoSchema",
            dependencies: 
            [
                .target(name: "BSONSchema"),
            ]),

        .target(name: "MongoDriver",
            dependencies: 
            [
                .target(name: "Mongo"),
                .target(name: "MongoSchema"),
                .target(name: "MongoWire"),
                .target(name: "SCRAM"),
                .target(name: "TraceableErrors"),
                .target(name: "UUID"),

                .product(name: "Base64",                package: "swift-hash"),
                .product(name: "MessageAuthentication", package: "swift-hash"),
                .product(name: "SHA2",                  package: "swift-hash"),
                .product(name: "NIOCore",               package: "swift-nio"),
                .product(name: "NIOPosix",              package: "swift-nio"),
                .product(name: "NIOSSL",                package: "swift-nio-ssl"),
                .product(name: "Atomics",               package: "swift-atomics"),
            ]),
        
        .target(name: "MongoDB",
            dependencies: 
            [
                .target(name: "MongoDriver"),
            ]),

        // connection uri strings.
        .target(name: "MongoURI",
            dependencies: 
            [
                .target(name: "Mongo"),
            ]),
        

        .executableTarget(name: "BSONTests",
            dependencies:
            [
                .target(name: "BSON"),
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
                .product(name: "Testing", package: "swift-hash"),
            ], 
            path: "Tests/BSONEncoding"),
        
        .executableTarget(name: "MongoDBTests",
            dependencies:
            [
                .target(name: "MongoDB"),
                // already included by `MongoDriver`’s transitive `NIOSSL` dependency,
                // but restated here for clarity.
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "Testing", package: "swift-hash"),
            ], 
            path: "Tests/MongoDB"),
        
        .executableTarget(name: "MongoDriverTests",
            dependencies:
            [
                .target(name: "MongoDriver"),
                // already included by `MongoDriver`’s transitive `NIOSSL` dependency,
                // but restated here for clarity.
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "Testing", package: "swift-hash"),
            ], 
            path: "Tests/MongoDriver"),
    ]
)
