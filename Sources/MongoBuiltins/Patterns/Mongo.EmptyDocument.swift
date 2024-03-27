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
extension Mongo.EmptyDocument:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<BSON.Key>) throws
    {
        for unexpected:BSON.FieldDecoder<BSON.Key> in bson
        {
            try unexpected.decode(to: Never.self)
        }
    }
}
