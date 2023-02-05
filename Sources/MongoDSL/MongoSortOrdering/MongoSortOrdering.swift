import BSONEncoding
import BSONDecoding

@frozen public
struct MongoSortOrdering:Sendable
{
    public
    var fields:BSON.Fields

    @inlinable public
    init(bytes:[UInt8] = [])
    {
        self.fields = .init(bytes: bytes)
    }
}
extension MongoSortOrdering:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.fields.bytes
    }
}
extension MongoSortOrdering:BSONEncodable
{
}
extension MongoSortOrdering:BSONDecodable
{
}

extension MongoSortOrdering
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
extension MongoSortOrdering
{
    @inlinable public
    subscript(key:String) -> ((Ascending) -> Never)?
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
    subscript(key:String) -> ((Descending) -> Never)?
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
    subscript(key:String) -> Operator?
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
