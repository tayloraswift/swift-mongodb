# ``/BSONABI``

Models the BSON type system and the binary interface of the BSON serialization format.

External users should avoid importing this module directly. Instead, import ``/BSON``.

## Topics

### Type system

-   ``BSON.AnyValue``
-   ``BSON.AnyType``

### Primitive types

-   ``BSON.Min``
-   ``BSON.Max``
-   ``BSON.Identifier``
-   ``BSON.Decimal128``
-   ``BSON.Regex``
-   ``UnixMillisecond``

### String-like types

-   ``BSON.BinaryView``
-   ``BSON.UTF8View``

### Container types

-   ``BSON.List``
-   ``BSON.Document``

### Container fields

-   ``BSON.Key``
-   ``BSON.FieldEncoder``

### Binary interface

-   ``BSON.BufferTraversable``
-   ``BSON.BufferFrame``

### Binary frame types

-   ``BSON.BinaryFrame``
-   ``BSON.DocumentFrame``
-   ``BSON.UTF8Frame``

### Parsing and decoding

This module only implements the basic infrastructure for BSON decoding. Most of the public decoding interface is in ``BSONDecoding``.

-   ``BSON.Decoder``
-   ``BSON.Input``
-   ``BSON.TypeError``
-   ``BSON.TypecastError``

### Serialization and encoding

This module only implements the basic infrastructure for BSON encoding. Most of the public encoding interface is in ``BSONEncoding``.

-   ``BSON.Encoder``
-   ``BSON.Output``
