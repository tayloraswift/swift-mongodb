<div align="center">
  
***`mongodb`***<br>`0.1.0`

[![swift package index versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fkelvin13%2Fswift-mongodb%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/kelvin13/swift-mongodb)
[![swift package index platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fkelvin13%2Fswift-mongodb%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/kelvin13/swift-mongodb)

</div>

*`swift-mongodb`* is a pure-Swift, Foundation-less BSON library and MongoDB driver.

## products

This package vends the following library products:

1.  [**`BSON`**](Sources/BSON) ([`BSONTraversal`](Sources/BSONTraversal))

    Defines BSON types. Consumers that don’t need to perform any decoding or encoding, or interact with variants (union types) can depend on this product alone.

    This module contains a type (`BSON`) of the same name as the module itself, so every declaration in this module is namespaced to that type.

    Does not re-export `BSONTraversal`.

1.  [**`BSONDecoding`**](Sources/BSONDecoding) ([`BSON`*](Sources/BSON), [`BSONUnions`](Sources/BSONUnions))

    Vends tools for (performantly) decoding BSON with an emphasis on type-safety and avoiding allocations.
    
    Also vends a fallback [`Decoder`](https://swiftinit.org/reference/swift/decoder) interface for consumers migrating from [`Decodable`](https://swiftinit.org/reference/swift/decodable).

    Re-exports `BSON`, but not `BSONUnions`.

1.  [**`BSONEncoding`**](Sources/BSONEncoding) ([`BSON`*](Sources/BSON))

    Vends tools for (performantly) encoding BSON with an emphasis on static typing and legibility.

    Re-exports `BSON`.

1.  [**`BSONSchema`**](Sources/BSONSchema) ([`BSONDecoding`*](Sources/BSONDecoding), [`BSONEncoding`*](Sources/BSONEncoding))

    Convenience module that re-exports `BSONDecoding` and `BSONEncoding`, and defines the typealiases `BSONScheme` and `BSONStringScheme`. Contains no code of its own.

1.  [**`BSONUnions`**](Sources/BSONUnions) ([`BSON`](Sources/BSON))

    Defines the `AnyBSON` union type, the `BSON.TypecastError` type, and provides tools for working with heterogenous/dynamically-typed BSON.

    Also vends [`ExpressibleByArrayLiteral`](https://swiftinit.org/reference/swift/expressiblebyarrayliteral) and [`ExpressibleByDictionaryLiteral`](https://swiftinit.org/reference/swift/expressiblebydictionaryliteral) conformances for various BSON types, including `AnyBSON`.

    Does not re-export `BSON`.

1.  [**`MongoDB`**](Sources/MongoDB) ([`MongoDriver`*](Sources/MongoDriver), [`MongoSchema`*](Sources/MongoSchema))

    Vends Swift bindings for MongoDB’s command API, and also implements cursors and managed cursor streams. Most package consumers will depend this module, unless it is possible to depend on one of its constituent dependencies.

    Depends on SwiftNIO (indirectly), and re-exports `MongoDriver` and `MongoSchema`.

1.  [**`MongoDriver`**](Sources/MongoDriver)
([`Mongo`*](Sources/Mongo),
[`MongoWire`](Sources/MongoWire),
[`BSONSchema`](Sources/BSONSchema),
[`SCRAM`](Sources/SCRAM),
[`TraceableErrors`](Sources/TraceableErrors),
[`UUID`](Sources/UUID),
[`Base64`](https://github.com/kelvin13/swift-hash/tree/master/Sources/Base64),
[`MessageAuthentication`](https://github.com/kelvin13/swift-hash/tree/master/Sources/MessageAuthentication),
[`SHA2`](https://github.com/kelvin13/swift-hash/tree/master/Sources/SHA2),
`NIOCore`,
`NIOPosix`,
`NIOSSL`,
`Atomics`)

    Implements a MongoDB driver, for communicating with a `mongod`/`mongos` server. Handles authentication, sessions, transactions, and command execution, but does not define specific MongoDB commands other than the ones needed to bootstrap a connection.

    `MongoDriver` has the concept of databases, but does not have any awareness of collections, or other high-level database concepts.

    Depends on SwiftNIO, and re-exports `Mongo`.

1.  [**`MongoSchema`**](Sources/MongoSchema) ([`BSONSchema`](Sources/BSONSchema))

    Interface module that defines the `MongoDecodable` and `MongoEncodable` protocols, and the `MongoScheme` typealias.

    Consumers that only implement MongoDB schema and do not need to use the MongoDB driver can depend on this product alone.

    Does not re-export `BSONSchema`.

1.  [**`MongoWire`**](Sources/MongoWire) ([`BSON`](Sources/BSON), [`CRC`](https://github.com/kelvin13/swift-hash/tree/master/Sources/CRC))

    Implements the [MongoDB wire protocol](https://www.mongodb.com/docs/manual/reference/mongodb-wire-protocol/), in a generic manner without dependency on SwiftNIO.

    This module contains a type (`MongoWire`) of the same name as the module itself, so every declaration in this module is namespaced to that type.

1.  [**`SCRAM`**](Sources/SCRAM) ([`Base64`](https://github.com/kelvin13/swift-hash/tree/master/Sources/Base64), [`MessageAuthentication`](https://github.com/kelvin13/swift-hash/tree/master/Sources/MessageAuthentication))

    Implements [SCRAM](https://www.rfc-editor.org/rfc/rfc5802#section-7). The module is intended to be used with [MongoDB SCRAM-SHA-256](https://github.com/mongodb/specifications/blob/master/source/auth/auth.rst#scram-sha-256), but is not strongly coupled with any particular flavor of SCRAM.

1.  [**`TraceableErrors`**](Sources/TraceableErrors)

    Provides support for error chaining and pretty-printing of errors.

1.  [**`UUID`**](Sources/UUID)

    Defines the `UUID` type, and an interface for interacting with UUIDs as [`RandomAccessCollection`](https://swiftinit.org/reference/swift/randomaccesscollection)s of [`UInt8`](https://swiftinit.org/reference/swift/uint8).

Please avoid depending on `SCRAM`, `TraceableErrors`, `UUID`, and the BSON libraries; they are likely to migrate to a separate repository in the medium-term.

## license

The `MongoDriver` module was originally a re-write of [*MongoKitten*](https://github.com/orlandos-nl/MongoKitten)’s `MongoClient` module. Although its fork-ancestor is not really recognizable in the module’s current form, *MongoKitten* was [MIT-licensed](https://github.com/orlandos-nl/MongoKitten/blob/master/7.0/LICENSE.md), so `MongoDriver` is MIT-licensed as well.

The rest of the project is available under the MPL 2.0 license.

## acknowledgements

`swift-mongodb` started out as a re-write of [Orlandos](https://orlandos.nl/)’s *MongoKitten*; without *MongoKitten*, `swift-mongodb` would not exist.
