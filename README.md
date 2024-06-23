<div align="center">

***`mongodb`***<br>`0.21`

[![ci status](https://github.com/tayloraswift/swift-mongodb/actions/workflows/ci.yml/badge.svg)](https://github.com/tayloraswift/swift-mongodb/actions/workflows/ci.yml)

[![swift package index versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Ftayloraswift%2Fswift-mongodb%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/tayloraswift/swift-mongodb)
[![swift package index platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Ftayloraswift%2Fswift-mongodb%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/tayloraswift/swift-mongodb)

</div>

*`swift-mongodb`* is a pure-Swift BSON library and MongoDB driver. All of the constituent products in this package are Foundation-free.

## getting started

TODO: add more snippets

```swift
import NIOCore
import NIOPosix
import MongoDB

let executors:MultiThreadedEventLoopGroup = .init(numberOfThreads: 2)

let bootstrap:Mongo.DriverBootstrap = MongoDB / ["mongo-0", "mongo-1"] /?
{
    $0.executors = .shared(executors)
    $0.appname = "example app"
}

let configuration:Mongo.ReplicaSetConfiguration = try await bootstrap.withSessionPool
{
    try await $0.run(
        command: Mongo.ReplicaSetGetConfiguration.init(),
        against: .admin)
}

print(configuration)

//  ...
```

## toolchain requirement

This package requires Swift 5.10 or greater.


## license and acknowledgements

This library is Apache 2.0 licensed. It originally began as a re-write of [*MongoKitten*](https://github.com/orlandos-nl/MongoKitten) by [Joannis Orlandos](https://github.com/Joannis) and [Robbert Brandsma](https://github.com/Obbut).


## external dependencies

I have verified that all products depended-upon by this package are Foundation-free when compiled for a linux target. Note that some package dependencies do vend products that import Foundation, but swift links binaries at the product level, and this library does not depend on any such products.

My packages:

1.  [`swift-grammar`](https://github.com/tayloraswift/swift-grammar)

    Rationale: this package provides the `TraceableErrors` module which the driver uses to provide rich diagnostics. The driver does not depend on any parser targets.

1.  [`swift-hash`](https://github.com/tayloraswift/swift-hash)

    Rationale: this package implements cryptographic algorithms the driver uses to complete authentication with `mongod`/`mongos` servers.

Other packages:

1.  [`apple/swift-atomics`](https://github.com/apple/swift-atomics)

    Rationale: this package provides atomic types that improve the performance of the driver’s various concurrent data structures.

1.  [`apple/swift-collections`](https://github.com/apple/swift-collections)

    Rationale: this package provides data structures that improve the runtime complexity of several algorithms the driver uses internally. Moreover, the driver’s `swift-nio` dependency already depends on one of this package’s modules (`DequeModule`) anyway.

1.  [`apple/swift-nio`](https://github.com/apple/swift-nio)

    Rationale: networking.

1.  [`apple/swift-nio-ssl`](https://github.com/apple/swift-nio-ssl)

    Rationale: networking.

> Note: This library depends on the `NIOSSL` product from `swift-nio-ssl`, which imports Foundation on Apple platforms only. `NIOSSL` is Foundation-free on all other platforms.
