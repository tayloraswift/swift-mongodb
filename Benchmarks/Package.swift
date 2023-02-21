// swift-tools-version:5.7
import PackageDescription

let package:Package = .init(name: "swift-mongodb-benchmarks",
    products: 
    [
    ],
    dependencies: 
    [
        .package(url: "https://github.com/ordo-one/package-benchmark",
            .upToNextMajor(from: "0.8.0")),
        .package(path: ".."),
    ],
    targets: 
    [
        .executableTarget(name: "BSONEncodingBenchmarks",
            dependencies:
            [
                .product(name: "BenchmarkSupport", package: "package-benchmark"),
                .product(name: "BSONEncoding", package: "swift-mongodb"),
            ], 
            path: "Benchmarks/BSONEncoding"),
    ]
)
