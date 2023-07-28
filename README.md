<div align="center">

***`mongodb`***<br>`0.5.1`

[![ci status](https://github.com/tayloraswift/swift-mongodb/actions/workflows/build.yml/badge.svg)](https://github.com/tayloraswift/swift-mongodb/actions/workflows/build.yml)

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

## toolchain requirement

This package requires swift 5.8 or greater.

## acknowledgements

This library originally started out as a re-write of [Orlandos](https://orlandos.nl/)’s *MongoKitten*; accordingly the `MongoDriver` module retains *MongoKitten*’s original [MIT-license](https://github.com/orlandos-nl/MongoKitten/blob/master/7.0/LICENSE.md).

The [official MongoDB C driver](https://github.com/mongodb/mongo-swift-driver) also served as prior art for this module.

## license

The `MongoDriver` module is MIT-licensed.

The other modules are available under the MPL 2.0 license. This license was chosen as an organizational default, and is not ideological. Please [reach out](https://github.com/tayloraswift/swift-mongodb/discussions) if you have a use-case that requires a more-permissive license!
