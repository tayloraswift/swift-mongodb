import BSONEncoding
import BSONDecoding

extension Mongo
{
    @frozen public
    struct SortDocument:Sendable
    {
        public
        var fields:BSON.Fields

        @inlinable public
        init(bytes:[UInt8] = [])
        {
            self.fields = .init(bytes: bytes)
        }
    }
}
extension Mongo.SortDocument:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.fields.bytes
    }
}
extension Mongo.SortDocument:BSONEncodable
{
}
extension Mongo.SortDocument:BSONDecodable
{
}

extension Mongo.SortDocument
{
    @available(*, unavailable,
        message: "pass the `(+)` or `(-)` operator functions to specify sort direction.")
    @inlinable public
    subscript(key:String) -> Int?
    {
        get
        {
            nil
        }
        set
        {
        }
    }
}
extension Mongo.SortDocument
{
    @inlinable public
    subscript(key:String) -> ((Mongo.SortAscending) -> Never)?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.fields[key] = 1 as Int32
        }
    }
    @inlinable public
    subscript(key:String) -> ((Mongo.SortDescending) -> Never)?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.fields[key] = -1 as Int32
        }
    }
    @inlinable public
    subscript(key:String) -> Mongo.SortOperator?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.fields[key] = value
        }
    }
}
