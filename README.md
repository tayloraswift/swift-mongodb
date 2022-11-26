<div align="center">
  
***`mongodb`***<br>`0.1.0`

[![swift package index versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fkelvin13%2Fswift-mongodb%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/kelvin13/swift-mongodb)
[![swift package index platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fkelvin13%2Fswift-mongodb%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/kelvin13/swift-mongodb)

</div>

*`swift-mongodb`* is a pure-Swift, Foundation-less BSON library and MongoDB driver.

## products

This package vends the following library products:

1.  [`BSON`](Sources/BSON)
1.  [`BSONDecoding`](Sources/BSONDecoding)
1.  [`BSONEncoding`](Sources/BSONEncoding)
1.  [`BSONSchema`](Sources/BSONSchema)
1.  [`MongoDB`](Sources/MongoDB)
1.  [`MongoDriver`](Sources/MongoDriver)
1.  [`MongoSchema`](Sources/MongoSchema)
1.  [`MongoWire`](Sources/MongoWire)
1.  [`SCRAM`](Sources/SCRAM)
1.  [`TraceableErrors`](Sources/TraceableErrors)
1.  [`UUID`](Sources/UUID)

Please avoid depending on `SCRAM`, `TraceableErrors`, `UUID`, and the BSON libraries; they are likely to migrate to a separate repository in the medium-term.

## license

The `MongoDriver` module was originally a re-write of [*MongoKitten*](https://github.com/orlandos-nl/MongoKitten)’s `MongoClient` module. Although its fork-ancestor is not really recognizable in the module’s current form, *MongoKitten* was [MIT-licensed](https://github.com/orlandos-nl/MongoKitten/blob/master/7.0/LICENSE.md), so `MongoDriver` is MIT-licensed as well.

The rest of the project is available under the MPL 2.0 license.

## acknowledgements

`swift-mongodb` started out as a re-write of [Orlandos](https://orlandos.nl/)’s *MongoKitten*; without *MongoKitten*, `swift-mongodb` would not exist.
