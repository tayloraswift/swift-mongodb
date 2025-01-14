import BSON

extension Mongo
{
    /// A type that can be used to expect an empty document. Decoding from a non-empty document
    /// (or a value that is not a document at all) will throw an error.
    @frozen public
    struct EmptyDocument
    {
        @inlinable
        init()
        {
        }
    }
}
extension Mongo.EmptyDocument:ExpressibleByDictionaryLiteral
{
    @inlinable public
    init(dictionaryLiteral _:(Never, Never)...) {}
}
extension Mongo.EmptyDocument:BSONEncodable, BSONDocumentEncodable
{
    @inlinable public
    func encode(to _:inout BSON.DocumentEncoder<BSON.Key>)
    {
    }
}
extension Mongo.EmptyDocument:BSONDecodable, BSONKeyspaceDecodable
{
    @inlinable public
    init(bson:consuming BSON.KeyspaceDecoder<BSON.Key>) throws
    {
        while let _:Never = try bson[+]?.decode(to: Never.self)
        {
        }
    }
}
