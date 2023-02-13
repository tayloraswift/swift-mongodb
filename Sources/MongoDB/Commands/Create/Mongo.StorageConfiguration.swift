// import BSONDecoding
// import BSONEncoding
// import BSONUnions

// extension Mongo
// {
//     @frozen public
//     struct StorageConfiguration:Sendable
//     {
//         @usableFromInline
//         var engines:[(name:String, options:BSON.Fields)]

//         @inlinable public
//         init(_ engines:[(name:String, options:BSON.Fields)])
//         {
//             self.engines = engines
//         }
//     }
// }
// extension Mongo.StorageConfiguration:BSONEncodable, BSONDocumentEncodable
// {
//     public
//     func encode(to bson:inout BSON.Fields)
//     {
//         for (name, options):(String, BSON.Fields) in self
//         {
//             bson[name] = options
//         }
//     }
// }
// extension Mongo.StorageConfiguration:BSONDecodable, BSONDocumentDecodable
// {
//     @inlinable public
//     init<Bytes>(bson:BSON.Document<Bytes>) throws
//     {
//         self.init(try bson.parse
//         {
//             let field:BSON.ExplicitField<String, Bytes.SubSequence> = .init(key: $0,
//                 value: $1)
//             return ($0, try field.decode(to: BSON.Fields.self))
//         })
//     }
// }
// extension Mongo.StorageConfiguration:ExpressibleByDictionaryLiteral
// {
//     @inlinable public
//     init(dictionaryLiteral:(String, BSON.Fields)...)
//     {
//         self.init(dictionaryLiteral)
//     }
// }
// extension Mongo.StorageConfiguration:RandomAccessCollection
// {
//     @inlinable public
//     var startIndex:Int
//     {
//         self.engines.startIndex
//     }
//     @inlinable public
//     var endIndex:Int
//     {
//         self.engines.endIndex
//     }
//     @inlinable public
//     subscript(index:Int) -> (name:String, options:BSON.Fields)
//     {
//         self.engines[index]
//     }
// }
