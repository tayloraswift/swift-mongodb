import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct UnwindDocument:Sendable
    {
        public
        var document:BSON.Document

        @inlinable public
        init(bytes:[UInt8] = [])
        {
            self.document = .init(bytes: bytes)
        }
    }
}
extension Mongo.UnwindDocument:BSONStream
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.document.bytes
    }
}
extension Mongo.UnwindDocument:BSONEncodable
{
}
extension Mongo.UnwindDocument:BSONDecodable
{
}

extension Mongo.UnwindDocument
{
    @inlinable public
    subscript<FieldPath>(key:Path) -> FieldPath?
        where FieldPath:MongoFieldPathEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            self.document.push(key, value)
        }
    }
    @inlinable public
    subscript(key:ArrayIndexAs) -> String?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.document.push(key, value)
        }
    }
    @inlinable public
    subscript(key:PreserveNullAndEmptyArrays) -> Bool?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.document.push(key, value)
        }
    }
}
