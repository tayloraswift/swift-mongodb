<div align="center">
  
***`mongodb`***<br>`0.1.0`

[![ci status](https://github.com/kelvin13/swift-mongodb/actions/workflows/build.yml/badge.svg)](https://github.com/kelvin13/swift-mongodb/actions/workflows/build.yml)

[![swift package index versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fkelvin13%2Fswift-mongodb%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/kelvin13/swift-mongodb)
[![swift package index platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fkelvin13%2Fswift-mongodb%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/kelvin13/swift-mongodb)

</div>

*`swift-mongodb`* is a pure-Swift, Foundation-less BSON library and MongoDB driver.

## products

This package vends the following library products:

1.  [**`BSON`**](Sources/BSON) ([`BSONTraversal`](Sources/BSONTraversal))

    Defines BSON types. Consumers that don’t need to perform any decoding or encoding, or interact with variants (union types) can depend on this product alone.

    This module contains a type (`BSON`) of the same name as the module itself, so every declaration in this module is namespaced to that type.

1.  [**`BSONDSL`**](Sources/BSONDSL) ([`BSON`](Sources/BSON))

    Provides the basic definitions needed to bootstrap BSON-based domain-specific languages (DSLs). Defines the `BSONDSL` protocol and the `BSON.Document`, and `BSON.List` containers.

1.  [**`BSONDecoding`**](Sources/BSONDecoding) ([`BSON`*](Sources/BSON), [`BSONDSL`*](Sources/BSONDSL), [`BSONUnions`](Sources/BSONUnions))

    Provides tools for performantly decoding BSON with an emphasis on type-safety and avoiding allocations.
    
    Also vends a fallback [`Decoder`](https://swiftinit.org/reference/swift/decoder) interface for consumers migrating from [`Decodable`](https://swiftinit.org/reference/swift/decodable).

    Re-exports `BSON` and `BSONDSL`, but not `BSONUnions`.

1.  [**`BSONEncoding`**](Sources/BSONEncoding) ([`BSON`*](Sources/BSON), [`BSONDSL`*](Sources/BSONDSL))

    Vends tools for performantly encoding BSON with an emphasis on static typing and legibility.

    Re-exports `BSON` and `BSONDSL`.

1.  [**`BSONUnions`**](Sources/BSONUnions) ([`BSON`](Sources/BSON))

    Defines the `AnyBSON` union type, the `BSON.TypecastError` type, and provides tools for working with heterogenous/dynamically-typed BSON.

    Also vends [`ExpressibleByArrayLiteral`](https://swiftinit.org/reference/swift/expressiblebyarrayliteral) and [`ExpressibleByDictionaryLiteral`](https://swiftinit.org/reference/swift/expressiblebydictionaryliteral) conformances for various BSON types, including `AnyBSON`.

    Does not re-export `BSON`.

1.  [**`BSON_UUID`**](Sources/BSON_UUID) ([`BSONDecoding`](Sources/BSONDecoding), [`BSONEncoding`](Sources/BSONEncoding), [`UUID`](Sources/UUID))

    A standard overlay module providing `BSONEncodable` and `BSONDecodable` conformances for the `UUID` type.

1.  [**`BSON_Durations`**](Sources/BSON_Durations) ([`BSONDecoding`](Sources/BSONDecoding), [`BSONEncoding`](Sources/BSONEncoding), [`Durations`](Sources/UUID))

    A standard overlay module providing `BSONEncodable` and `BSONDecodable` conformances for the various quantized duration types.

1.  [**`BSON_OrderedCollections`**](Sources/BSON_OrderedCollections) ([`BSONDecoding`](Sources/BSONDecoding), [`BSONEncoding`](Sources/BSONEncoding), `OrderedCollections`)

    A standard overlay module providing `BSONEncodable` and `BSONDecodable` conformances for [`OrderedDictionary`](https://swiftinit.org/reference/swift-collections/orderedcollections/ordereddictionary).

1.  [**`Durations`**](Sources/Durations)

    Vends quantized duration types (`Minutes`, `Seconds`, `Milliseconds`), and the `QuantizedDuration` protocol.

1.  [**`Durations_Atomics`**](Sources/Durations_Atomics) ([`Durations`](Sources/UUID), `Atomics`)

    A standard overlay module declaring `AtomicValue` conformances for the various quantized duration types.

1.  [**`Heartbeats`**](Sources/Heartbeats)

    Vends a `Heartbeat` type.

1.  [**`MongoDSL`**](Sources/MongoDSL) ([`BSONDecoding`](Sources/BSONDecoding), [`BSONEncoding`](Sources/BSONEncoding))

    Implements the MongoDB aggregation expression DSL.

1.  [**`Mongo`**](Sources/Mongo) ([`BSONDecoding`](Sources/BSONDecoding), [`BSONEncoding`](Sources/BSONEncoding), [`Durations`](Sources/Durations), [`MongoMonitoring`](Sources/MongoMonitoring), [`TraceableErrors`](Sources/TraceableErrors))

    A single-namespace module that implements the topology model and state-transition operations used by the driver’s service discovery and monitoring components.

    Also implements much of the server selection specification, including tag sets, secondary staleness, and read modes.

1.  [**`MongoBuiltins`**](Sources/MongoBuiltins) ([`MongoDSL`*](Sources/MongoDSL), [`Mongo`*](Sources/Mongo))

    Implements the MongoDB “standard library”, which currently consists of complex aggregation expression operators, accumulators, various standard MongoDB document formats, and aggregation pipeline stages.

1.  [**`MongoChannel`**](Sources/MongoChannel)
([`BSONDecoding`](Sources/BSONDecoding),
[`BSONEncoding`](Sources/BSONEncoding),
[`MongoWire`](Sources/MongoWire),
[`TraceableErrors`](Sources/TraceableErrors),
`NIOCore`,
`Atomics`)

    A single-namespace, NIO-based layer over `MongoWire`, that vends channel handlers and supports basic command routing and connection lifecycle management.

1.  [**`MongoDB`**](Sources/MongoDB) ([`MongoBuiltins`*](Sources/MongoBuiltins), [`MongoDriver`*](Sources/MongoDriver))

    Vends Swift bindings for MongoDB’s command API, and also implements cursors and managed cursor streams. Most package consumers will depend this module, unless it is possible to depend on one of its constituent dependencies.

    Depends on SwiftNIO (indirectly), and re-exports `MongoBuiltins` and `MongoDriver`.

1.  [**`MongoDriver`**](Sources/MongoDriver)
([`Mongo`*](Sources/Mongo),
[`MongoChannel`](Sources/MongoChannel),
[`BSON_Durations`](Sources/BSON_Durations),
[`BSON_OrderedCollections`](Sources/BSON_OrderedCollections),
[`BSON_UUID`](Sources/BSON_UUID),
[`Durations_Atomics`](Sources/Durations_Atomics),
[`SCRAM`](Sources/SCRAM),
[`SHA2`](https://github.com/kelvin13/swift-hash/tree/master/Sources/SHA2),
`NIOPosix`,
`NIOSSL`)

    Implements a MongoDB driver, for communicating with a `mongod`/`mongos` server. Handles authentication, sessions, transactions, and command execution, but does not define complex MongoDB commands that have DSLs. Notably, `MongoDriver` does not depend on `MongoBuiltins`.

1.  [**`MongoWire`**](Sources/MongoWire) ([`BSON`](Sources/BSON), [`CRC`](https://github.com/kelvin13/swift-hash/tree/master/Sources/CRC))

    A single-namespace module that implements the [MongoDB wire protocol](https://www.mongodb.com/docs/manual/reference/mongodb-wire-protocol/), in a generic manner without dependency on SwiftNIO.

1.  [**`OnlineCDF`**](Sources/OnlineCDF)

    Implements the t-digest data structure, for tracking online CDFs.

1.  [**`SCRAM`**](Sources/SCRAM) ([`Base64`](https://github.com/kelvin13/swift-hash/tree/master/Sources/Base64), [`MessageAuthentication`](https://github.com/kelvin13/swift-hash/tree/master/Sources/MessageAuthentication))

    Implements [SCRAM](https://www.rfc-editor.org/rfc/rfc5802#section-7). The module is intended to be used with [MongoDB SCRAM-SHA-256](https://github.com/mongodb/specifications/blob/master/source/auth/auth.rst#scram-sha-256), but is not strongly coupled with any particular flavor of SCRAM.

1.  [**`TraceableErrors`**](Sources/TraceableErrors)

    Provides support for error chaining and pretty-printing of errors.

1.  [**`UUID`**](Sources/UUID)

    Defines the `UUID` type, and an interface for interacting with UUIDs as [`RandomAccessCollection`](https://swiftinit.org/reference/swift/randomaccesscollection)s of [`UInt8`](https://swiftinit.org/reference/swift/uint8).

All of the modules listed above are Foundation-free.

## external dependencies

I have verified that all products depended-upon by this package are Foundation-free when compiled for a linux target. Note that some package dependencies do vend products that import Foundation, but swift links binaries at the product level, and this library does not depend on any such products.

My packages:

1.  [`swift-grammar`](https://github.com/kelvin13/swift-grammar)

    Rationale: this package provides the `TraceableErrors` module which the driver uses to provide rich diagnostics. The driver does not depend on any parser targets.

1.  [`swift-hash`](https://github.com/kelvin13/swift-hash)

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

This package requires swift 5.7 or greater. Compiling with a swift 5.9 toolchain is not recommended, due to known compiler bugs.

## acknowledgements

This library originally started out as a re-write of [Orlandos](https://orlandos.nl/)’s *MongoKitten*; accordingly the `MongoDriver` module retains *MongoKitten*’s original [MIT-license](https://github.com/orlandos-nl/MongoKitten/blob/master/7.0/LICENSE.md).

The [official MongoDB C driver](https://github.com/mongodb/mongo-swift-driver) also served as prior art for this module. 

## license

The `MongoDriver` module is MIT-licensed.

The other modules are available under the MPL 2.0 license. This license was chosen as an organizational default, and is not ideological. Please [reach out](https://github.com/kelvin13/swift-mongodb/discussions) if you have a use-case that requires a more-permissive license!
