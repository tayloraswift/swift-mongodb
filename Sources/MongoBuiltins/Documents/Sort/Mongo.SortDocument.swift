import BSONEncoding

extension Mongo
{
    @frozen public
    struct SortDocument:MongoDocumentDSL, Sendable
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
extension Mongo.SortDocument
{
    @available(*, unavailable,
        message: "pass the `(+)` or `(-)` operator functions to specify sort direction.")
    @inlinable public
    subscript(key:BSON.Key) -> Int?
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
    subscript(key:BSON.Key) -> ((Mongo.SortAscending) -> Never)?
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
    subscript(key:BSON.Key) -> ((Mongo.SortDescending) -> Never)?
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
    subscript(key:BSON.Key) -> Mongo.SortOperator?
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
