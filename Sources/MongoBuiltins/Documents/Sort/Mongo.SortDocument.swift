import BSON
import MongoABI

extension Mongo
{
    @frozen public
    struct SortDocument:Mongo.EncodableDocument, Sendable
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
    subscript(path:Mongo.AnyKeyPath) -> Int?
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
    subscript(natural:Natural) -> ((Mongo.SortAscending) -> Never)?
    {
        get
        {
            nil
        }
        set(value)
        {
            if  case _? = value
            {
                (1 as Int32).encode(to: &self.bson[with: natural])
            }
        }
    }
    @inlinable public
    subscript(path:Mongo.AnyKeyPath) -> ((Mongo.SortAscending) -> Never)?
    {
        get
        {
            nil
        }
        set(value)
        {
            if  case _? = value
            {
                (1 as Int32).encode(to: &self.bson[with: path.stem])
            }
        }
    }

    @inlinable public
    subscript(natural:Natural) -> ((Mongo.SortDescending) -> Never)?
    {
        get
        {
            nil
        }
        set(value)
        {
            if  case _? = value
            {
                (-1 as Int32).encode(to: &self.bson[with: natural])
            }
        }
    }
    @inlinable public
    subscript(path:Mongo.AnyKeyPath) -> ((Mongo.SortDescending) -> Never)?
    {
        get
        {
            nil
        }
        set(value)
        {
            if  case _? = value
            {
                (-1 as Int32).encode(to: &self.bson[with: path.stem])
            }
        }
    }
    @inlinable public
    subscript(path:Mongo.AnyKeyPath) -> Mongo.SortOperator?
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.bson[with: path.stem])
        }
    }
}
