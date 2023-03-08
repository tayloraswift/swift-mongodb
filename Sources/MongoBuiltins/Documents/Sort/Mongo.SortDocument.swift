import BSONEncoding
import BSONDecoding

extension Mongo
{
    @frozen public
    struct SortDocument:BSONRepresentable, BSONDSL, Sendable
    {
        public
        var bson:BSON.Document

        @inlinable public
        init(_ bson:BSON.Document)
        {
            self.bson = bson
        }
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
            self.bson.append(key, 1 as Int32)
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
            self.bson.append(key, -1 as Int32)
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
            self.bson.push(key, value)
        }
    }
}
